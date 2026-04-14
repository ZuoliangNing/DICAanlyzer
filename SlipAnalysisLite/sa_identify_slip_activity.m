function result = sa_identify_slip_activity(dataset, definitions, options)
%SA_IDENTIFY_SLIP_ACTIVITY Run slip identification grain by grain.
%
%   result = sa_identify_slip_activity(dataset, definitions, options)
%
%   DATASET is produced by sa_prepare_from_dicanalyzer.
%
%   DEFINITIONS is a struct with fields such as:
%       definitions.HCP = sa_define_slip_systems('hcp', ...)
%       definitions.FCC = sa_define_slip_systems('fcc')
%
%   OPTIONS fields (most important)
%   --------------------------------
%   Stages              Stage numbers to process. Default = all stages.
%   HcpPhase            Phase index corresponding to HCP. Default = 1.
%   FccPhase            Phase index corresponding to FCC. Default = [].
%   HcpFamilyWeights    One weight per active HCP family. Default = 1.
%   FccFamilyWeights    One weight per active FCC family. Default = 1.
%   IncludeRotation     Default = true.
%   RotationWeight      Default = 1.
%   MinEffectiveShear   Scalar or one value per processed stage. Default = 0.
%   ResidualTolerance   Default = 1e-5.
%   StressMatrix        3x3 stress matrix used for Schmid-factor reporting.
%
%   Output RESULT contains phase-wise activity maps, residual maps, and a
%   compact grain summary.

if nargin < 3
    options = struct;
end
if ~isfield(options, 'Stages') || isempty(options.Stages)
    options.Stages = 1:numel(dataset.Stages);
end
if ~isfield(options, 'HcpPhase') || isempty(options.HcpPhase)
    options.HcpPhase = 1;
end
if ~isfield(options, 'FccPhase')
    options.FccPhase = [];
end
if ~isfield(options, 'IncludeRotation') || isempty(options.IncludeRotation)
    options.IncludeRotation = true;
end
if ~isfield(options, 'RotationWeight') || isempty(options.RotationWeight)
    options.RotationWeight = 1;
end
if ~isfield(options, 'ResidualTolerance') || isempty(options.ResidualTolerance)
    options.ResidualTolerance = 1e-5;
end
if ~isfield(options, 'StressMatrix') || isempty(options.StressMatrix)
    options.StressMatrix = diag([1, 0, 0]);
end
if ~isfield(options, 'MinEffectiveShear') || isempty(options.MinEffectiveShear)
    options.MinEffectiveShear = 0;
end
if ~isfield(options, 'UseParallel') || isempty(options.UseParallel)
    options.UseParallel = false;
end
if ~isfield(options, 'ShowWaitbar') || isempty(options.ShowWaitbar)
    options.ShowWaitbar = true;
end

nStages = numel(options.Stages);
pixelSize = dataset.PixelNumber;

if isfield(definitions, 'HCP')
    hcpDef = definitions.HCP;
    nHcpSystem = numel(hcpDef.ActiveSystemIndex) + double(options.IncludeRotation);
    HCP = struct;
    HCP.Activity = zeros([pixelSize, nHcpSystem, nStages]);
    HCP.Definition = hcpDef;
    HCP.Dataset = dataset;
else
    HCP = [];
end

if isfield(definitions, 'FCC')
    fccDef = definitions.FCC;
    nFccSystem = numel(fccDef.ActiveSystemIndex) + double(options.IncludeRotation);
    FCC = struct;
    FCC.Activity = zeros([pixelSize, nFccSystem, nStages]);
    FCC.Definition = fccDef;
    FCC.Dataset = dataset;
else
    FCC = [];
end

Residual = zeros([pixelSize, nStages]);
stress = stressTensor(options.StressMatrix);
ori0 = local_base_orientation(dataset.CoincideCoordsFlag);

allValidIDs = dataset.ValidGrainIDs(:)';
summaryTemplate = struct('GrainID', nan, 'Phase', '', 'Stage', nan, ...
    'PixelCount', nan, 'Area', nan, 'SystemSum', [], 'FamilySum', [], ...
    'SystemMean', [], 'FamilyMean', [], 'SystemFraction', [], 'FamilyFraction', [], ...
    'SchmidSystem', [], 'SchmidFamily', []);
GrainSummary(numel(allValidIDs), nStages) = summaryTemplate;

wb = [];
if options.ShowWaitbar
    try
        wb = waitbar(0, 'SlipAnalysisLite: processing grains...', ...
            'Name', 'SlipAnalysisLite');
    catch
        wb = [];
    end
end
cleanupObj = onCleanup(@() local_close_waitbar(wb)); %#ok<NASGU>

for i = 1:numel(allValidIDs)
    grainID = allValidIDs(i);
    grain = dataset.Map.grains(grainID == dataset.AllGrainIDs);
    if isempty(grain)
        continue
    end

    if grain.phase == options.HcpPhase && isfield(definitions, 'HCP')
        def = definitions.HCP;
        familyWeights = local_expand_family_weights(def, options, 'HcpFamilyWeights');
        phaseName = 'HCP';
    elseif ~isempty(options.FccPhase) && grain.phase == options.FccPhase && isfield(definitions, 'FCC')
        def = definitions.FCC;
        familyWeights = local_expand_family_weights(def, options, 'FccFamilyWeights');
        phaseName = 'FCC';
    else
        continue
    end

    ori = ori0 * orientation(rotation.byEuler(grain.meanphi1, grain.meanPHI, grain.meanphi2), def.CrystalSymmetry);
    localSystems = transpose(ori * def.AllSystems);
    activeLocalSystems = localSystems(def.ActiveSystemIndex);

    schmidSystem = abs(SchmidFactor(activeLocalSystems, stress));
    schmidFamily = cellfun(@(idx) max(schmidSystem(idx)), def.ActiveFamilyToSystems)';

    [mask, rowMask, colMask] = sa_extract_grain_mask(grainID, dataset.IntrinsicIDs, dataset.PixelNumber);
    nr = sum(rowMask);
    nc = sum(colMask);

    for s = 1:nStages
        stageNumber = options.Stages(s);
        stageData = dataset.Stages(stageNumber);

        hxx = stageData.Hxx(rowMask, colMask);
        hxy = stageData.Hxy(rowMask, colMask);
        hyx = stageData.Hyx(rowMask, colMask);
        hyy = stageData.Hyy(rowMask, colMask);

        solverOpt = struct;
        solverOpt.MinEffectiveShear = local_stage_threshold(options.MinEffectiveShear, s);
        solverOpt.ResidualTolerance = options.ResidualTolerance;
        solverOpt.IncludeRotation = options.IncludeRotation;
        solverOpt.RotationWeight = options.RotationWeight;
        solverOpt.UseParallel = options.UseParallel;

        [gammaLocal, residualLocal] = sa_solve_weighted_l1( ...
            activeLocalSystems, familyWeights, hxx, hxy, hyx, hyy, solverOpt);

        gammaLocal(:, ~mask) = 0;
        tempMap = reshape(gammaLocal', nr, nc, []);
        tempResidual = reshape(residualLocal, nr, nc);
        tempResidual(~mask) = 0;

        if strcmp(phaseName, 'HCP')
            HCP.Activity(rowMask, colMask, :, s) = HCP.Activity(rowMask, colMask, :, s) + tempMap;
        else
            FCC.Activity(rowMask, colMask, :, s) = FCC.Activity(rowMask, colMask, :, s) + tempMap;
        end
        Residual(rowMask, colMask, s) = Residual(rowMask, colMask, s) + tempResidual;

        value = sum(abs(gammaLocal(:, mask)), 2, 'omitnan');
        grainSummary = summaryTemplate;
        grainSummary.GrainID = grainID;
        grainSummary.Phase = phaseName;
        grainSummary.Stage = stageNumber;
        grainSummary.PixelCount = sum(mask, 'all');
        grainSummary.Area = grain.area;
        grainSummary.SystemSum = value;
        grainSummary.SystemMean = value / max(grainSummary.PixelCount, 1);
        totalValue = sum(value);
        if totalValue > 0
            grainSummary.SystemFraction = value / totalValue;
        else
            grainSummary.SystemFraction = zeros(size(value));
        end
        grainSummary.FamilySum = cellfun(@(idx) sum(value(idx)), def.ActiveFamilyToSystems)';
        grainSummary.FamilyMean = cellfun(@(idx) sum(grainSummary.SystemMean(idx)), def.ActiveFamilyToSystems)';
        familyTotal = sum(grainSummary.FamilySum);
        if familyTotal > 0
            grainSummary.FamilyFraction = grainSummary.FamilySum / familyTotal;
        else
            grainSummary.FamilyFraction = zeros(size(grainSummary.FamilySum));
        end
        grainSummary.SchmidSystem = schmidSystem;
        grainSummary.SchmidFamily = schmidFamily;
        GrainSummary(i, s) = grainSummary;
    end

    if ~isempty(wb) && isgraphics(wb)
        try
            waitbar(i / numel(allValidIDs), wb, sprintf('SlipAnalysisLite: %d / %d grains processed', i, numel(allValidIDs)));
        catch
        end
    end
end

result = struct;
result.Options = options;
result.StageNumbers = options.Stages;
result.Residual = Residual;
result.GrainSummary = GrainSummary;
result.HCP = HCP;
result.FCC = FCC;

end

function ori0 = local_base_orientation(coincideCoordsFlag)
if coincideCoordsFlag
    ori0 = orientation.byMatrix(eye(3));
else
    ori0 = orientation.byMatrix([0, -1, 0; -1, 0, 0; 0, 0, -1]);
end
end

function weights = local_expand_family_weights(def, options, fieldName)
if isfield(options, fieldName) && ~isempty(options.(fieldName))
    familyWeights = options.(fieldName);
else
    familyWeights = ones(1, numel(def.ActiveFamilyIndex));
end
if isscalar(familyWeights)
    familyWeights = repmat(familyWeights, 1, numel(def.ActiveFamilyIndex));
end
if numel(familyWeights) ~= numel(def.ActiveFamilyIndex)
    error('%s must match the number of active families.', fieldName);
end
weights = zeros(1, numel(def.ActiveSystemIndex));
for k = 1:numel(def.ActiveFamilyToSystems)
    weights(def.ActiveFamilyToSystems{k}) = familyWeights(k);
end
end

function val = local_stage_threshold(inputVal, stageIndex)
if isscalar(inputVal)
    val = inputVal;
elseif numel(inputVal) >= stageIndex
    val = inputVal(stageIndex);
else
    error('MinEffectiveShear must be scalar or provide one value per processed stage.');
end
end

function local_close_waitbar(wb)
if ~isempty(wb) && isgraphics(wb)
    try
        delete(wb);
    catch
    end
end
end

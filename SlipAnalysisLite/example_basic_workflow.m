%% Example: basic slip analysis workflow for DICAnalyzer projects
% This example illustrates a minimal workflow for the public open-source
% SlipAnalysisLite module. It assumes that a DICAnalyzer project object
% named OBJ already exists in the workspace.
%
% Requirements:
%   - MTEX on the MATLAB path
%   - Optimization Toolbox (coneprog)
%   - Parallel Computing Toolbox is optional if options.UseParallel = true
%
% Example project source:
%   OBJ can be taken from an open DICAnalyzer session or loaded from a
%   saved project file using the DICAnalyzer project classes.

% /// example_basic_workflow ///

%% -----------------------------------------------------------------------
% 1. Select one DICAnalyzer project object
% -----------------------------------------------------------------------
obj = app.Projects(1);   % example when called from the App workspace

%% -----------------------------------------------------------------------
% 2. Configure the analysis options
% -----------------------------------------------------------------------
options = struct;

% Basic preprocessing options
options.FilterStd = 1;     % Gaussian smoothing on displacement fields.
                           % Use 0 to skip filtering.
options.Coarsegrain = 4;   % Spatial downsampling factor used before the
                           % gradient calculation. Use 1 to keep the
                           % original resolution.

% Crystal / phase definition
options.HcpAxialRatio = 1.587;   % c/a ratio of the HCP phase.
options.HcpPhase = 1;            % Phase index of the HCP phase in EBSD.
options.UseFCC = false;          % If true, FCC grains are also processed.
                                 % If false, only grains belonging to the
                                 % HCP phase are analyzed.
                                 % This option is mainly kept for the
                                 % generality of the DICAnalyzer framework;
                                 % the present manuscript focuses on HCP.

% -----------------------------------------------------------------------
% HCP slip-family selection
% -----------------------------------------------------------------------
% options.HcpFamilies defines which HCP slip families are included in the
% identification. Supported values are:
%
%   'Basal'         or 'Bas'
%   'Prismatic'     or 'Pris'
%   'PyramidalA'    or 'PyrA'      -> pyramidal <a>
%   'PyramidalCA1'  or 'PyrCA1'    -> 1st-order pyramidal <c+a>
%   'PyramidalCA2'  or 'PyrCA2'    -> 2nd-order pyramidal <c+a>
%
% In the manuscript, the main HCP analysis uses the combination:
%   {'Basal','Prismatic','PyramidalCA1'}
%
options.HcpFamilies = {'Basal', 'Prismatic', 'PyramidalCA1'};

% -----------------------------------------------------------------------
% HCP family weights
% -----------------------------------------------------------------------
% options.HcpFamilyWeights assigns one weight to each selected family in
% options.HcpFamilies, in the same order.
%
% These weights correspond to the normalized slip resistance
% \tilde{\tau}_{\alpha} introduced in the improved energy-based slip
% identification method in the manuscript (see the improved SI formulation,
% Section 3.3 / Eq. (10) of the paper).
%
% A larger value means that the corresponding slip family is penalized more
% strongly in the weighted L1 minimization and therefore becomes harder to
% activate in the decomposition.
%
% Example below:
%   Basal         -> 1.3
%   Prismatic     -> 1.0
%   PyramidalCA1  -> 2.5
%
options.HcpFamilyWeights = [1.3, 1.0, 2.5];

% -----------------------------------------------------------------------
% Rotation correction term
% -----------------------------------------------------------------------
% options.IncludeRotation controls whether an additional rotation-correction
% variable is introduced in the solver.
%
% This corresponds to the rotation correction \omega' in the manuscript,
% i.e. the extra term added in the theoretical displacement-gradient tensor
% to account for the non-slip part of the measured in-plane rotation
% (see Section 3.1 and the improved weighted formulation in Section 3.3).
%
% If IncludeRotation = true, one extra unknown is appended to the solver.
%
% options.RotationWeight is the weight applied to this extra unknown in the
% same weighted minimization. Its role is analogous to the resistance term
% \tilde{\tau}_{Rot} in the manuscript.
%
% If IncludeRotation = false, RotationWeight is ignored.
%
options.IncludeRotation = true;
options.RotationWeight = 1.0;

% -----------------------------------------------------------------------
% Solver controls
% -----------------------------------------------------------------------
% options.MinEffectiveShear:
%   Pixels with local effective shear below this threshold are skipped and
%   their activity is set to zero. This is used to avoid solving the sparse
%   identification problem in nearly undeformed / noisy regions.
%
% options.ResidualTolerance:
%   Residual constraint used in the cone-programming solver. It controls the
%   allowed mismatch between the experimental in-plane displacement gradient
%   and the reconstructed one from the selected slip systems.
%   Smaller values mean a stricter fit.
%
options.MinEffectiveShear = 1e-3;
options.ResidualTolerance = 1e-5;

% -----------------------------------------------------------------------
% Runtime controls
% -----------------------------------------------------------------------
% options.ShowWaitbar:
%   If true, a grain-level waitbar is displayed.
%
% options.UseParallel:
%   If true, the pixel-wise solver inside sa_solve_weighted_l1 uses PARFOR
%   when Parallel Computing Toolbox is available. Otherwise it will fall
%   back to serial execution automatically.
%
options.ShowWaitbar = true;
options.UseParallel = true;

% -----------------------------------------------------------------------
% Stage selection
% -----------------------------------------------------------------------
options.Stages = 2;   % analyze stage 1 only

%% -----------------------------------------------------------------------
% 3. Run the analysis
% -----------------------------------------------------------------------
result = sa_run_slip_analysis(obj, options);

%% -----------------------------------------------------------------------
% 4. Visualize the family-wise maps
% -----------------------------------------------------------------------
fig = sa_plot_family_maps(result, 'HCP', 1, ...
    'UseAbs', true, ...
    'CLim', [0, 0.3], ...
    'Colormap', TheBestColor('akun',67,'map',256), ...
    'ResidualColormap', hot(256));

%% -----------------------------------------------------------------------
% 5. Inspect the grain summary table
% -----------------------------------------------------------------------
stage1Summary = result.GrainSummary(:, 1);

% Remove empty entries if necessary
validMask = ~isnan([stage1Summary.GrainID]);
stage1Summary = stage1Summary(validMask);

% Basic columns
T = table( ...
    [stage1Summary.GrainID]', ...
    string({stage1Summary.Phase})', ...
    [stage1Summary.Stage]', ...
    [stage1Summary.PixelCount]', ...
    [stage1Summary.Area]', ...
    'VariableNames', {'GrainID', 'Phase', 'Stage', 'PixelCount', 'Area'} );

% Convert FamilyFraction from struct field to an Ngrain-by-Nfamily matrix
familyFractions = cell2mat(arrayfun(@(s) s.FamilyFraction(:), ...
    stage1Summary, 'UniformOutput', false)')';

% Add family-wise activity fractions automatically
familyNames = options.HcpFamilies;

for i = 1:numel(familyNames)
    varName = matlab.lang.makeValidName([char(string(familyNames{i})), 'Frac']);
    T.(varName) = familyFractions(:, i);
end

% Display the table in Command Window
disp(T)

% Export to base workspace for interactive inspection
assignin('base', 'GrainSummaryTable', T);
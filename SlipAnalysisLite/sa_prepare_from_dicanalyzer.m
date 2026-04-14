function dataset = sa_prepare_from_dicanalyzer(obj, options)
%SA_PREPARE_FROM_DICANALYZER Extract and preprocess data from DICAnalyzer.
%
%   dataset = sa_prepare_from_dicanalyzer(obj, options)
%
%   This helper converts a DICAnalyzer project object into a compact data
%   structure that is convenient for slip-system identification.
%
%   Required input
%   --------------
%   obj : one DICAnalyzer project instance.
%
%   Optional fields in OPTIONS
%   --------------------------
%   FilterStd      Default = 0   (skip displacement smoothing)
%   Coarsegrain    Default = 1   (keep original pixel resolution)
%
%   Output DATASET contains:
%       Stages            1 x nStages struct array with fields U, V,
%                         Hxx, Hxy, Hyx, Hyy, Hzz, Eeff
%       IntrinsicIDs      Grain-ID map in the processed grid
%       ValidGrainIDs     Valid grain IDs after cropping / coarse-graining
%       AllGrainIDs       All grain IDs in the EBSD map
%       Map               EBSD polygon map from DICAnalyzer
%       x, y              Coordinate vectors of the processed grid
%       PixelSize         [dx, dy]
%       PixelNumber       size of the processed grid
%       CoincideCoordsFlag Whether the sample axes coincide with image axes
%
%   Notes
%   -----
%   - The function uses the most recent EBSD dataset stored in OBJ.
%   - U and V are restored from the compressed integer storage used by the
%     app and converted back to double precision.

if nargin < 2
    options = struct;
end
if ~isfield(options, 'FilterStd') || isempty(options.FilterStd)
    options.FilterStd = 0;
end
if ~isfield(options, 'Coarsegrain') || isempty(options.Coarsegrain)
    options.Coarsegrain = 1;
end

EBSDData = obj.EBSD.Data(end);
map = EBSDData.Map;
allIDs = [map.grains.ID];
DIC = obj.DIC;

CoincideCoordsFlag = isequal(EBSDData.SampleCoordOri.X, [1, 0]) && ...
    isequal(EBSDData.SampleCoordOri.Y, [0, -1]);

stageData = cell(1, DIC.StageNumber);
for n = 1:DIC.StageNumber
    U = local_restore_data(DIC.Data(n).u, DIC.DataValueRange.u);
    V = local_restore_data(DIC.Data(n).v, DIC.DataValueRange.v);

    if options.FilterStd > 0
        temp = sa_filter_displacements(U, V, struct('filt_std', options.FilterStd));
        U = temp.U;
        V = temp.V;
    end

    crs = sa_coarsegrain_displacements(U, V, EBSDData.XData, EBSDData.YData, options.Coarsegrain);
    [Hxx, Hxy] = gradient(crs.U, crs.PixelSize(1), crs.PixelSize(2));
    [Hyx, Hyy] = gradient(crs.V, crs.PixelSize(1), crs.PixelSize(2));
    Hzz = -Hxx - Hyy;

    tempStage = struct;
    tempStage.U = crs.U;
    tempStage.V = crs.V;
    tempStage.Hxx = Hxx;
    tempStage.Hxy = Hxy;
    tempStage.Hyx = Hyx;
    tempStage.Hyy = Hyy;
    tempStage.Hzz = Hzz;
    tempStage.Eeff = sa_compute_effective_shear(Hxx, Hxy, Hyx, Hyy);
    stageData{n} = tempStage;
end

intrinsicIDs = nan(EBSDData.DataSize(1:2));
valueList = cell2mat(arrayfun(@(g) [g.IntrinsicInds, g.ID * ones(size(g.IntrinsicInds))], ...
    map.grains, 'UniformOutput', false));
intrinsicIDs(valueList(:,1)) = valueList(:,2);
intrinsicIDs = intrinsicIDs(crs.In, crs.Im);
span = crs.sps;
intrinsicIDs = intrinsicIDs(1:span:end, 1:span:end);

if any(size(intrinsicIDs) ~= crs.Npx)
    error('Size mismatch between the grain-ID map and the processed DIC grid.');
end
validGrainIDs = unique(intrinsicIDs(~isnan(intrinsicIDs)));

dataset = struct;
dataset.Stages = [stageData{:}];
dataset.IntrinsicIDs = intrinsicIDs;
dataset.ValidGrainIDs = validGrainIDs;
dataset.AllGrainIDs = allIDs;
dataset.Map = map;
dataset.x = crs.x;
dataset.y = crs.y;
dataset.PixelSize = crs.PixelSize;
dataset.PixelNumber = crs.Npx;
dataset.CoincideCoordsFlag = CoincideCoordsFlag;
dataset.SourceObjectName = obj.DisplayName;

end

function out = local_restore_data(in, valueRange)
scale = 32768 / valueRange;
out = double(in) / scale;
end

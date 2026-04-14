function fig = sa_plot_family_maps(result, phaseName, stageIndex, varargin)
%SA_PLOT_FAMILY_MAPS Quick visualization of family-wise activity maps.
%
%   fig = sa_plot_family_maps(result, 'HCP', 1)
%   fig = sa_plot_family_maps(result, 'FCC', 1, 'UseAbs', true, ...
%       'ShowResidual', true)
%
%   Additional plotting controls:
%       'CLim'              -> [cmin cmax] for slip-family maps
%       'ResidualCLim'      -> [cmin cmax] for the residual map
%       'Colormap'          -> colormap for slip-family maps
%       'ResidualColormap'  -> colormap for the residual map
%
%   Example:
%       sa_plot_family_maps(result, 'HCP', 1, ...
%           'UseAbs', true, ...
%           'CLim', [0, 0.05], ...
%           'Colormap', turbo(256), ...
%           'ResidualCLim', [0, 0.01], ...
%           'ResidualColormap', hot(256));
%
%   Notes:
%   - 'Colormap' and 'ResidualColormap' can be:
%         1) a numeric N-by-3 colormap array, or
%         2) a string / char name of a built-in MATLAB colormap, e.g.
%            'parula', 'turbo', 'hot', 'jet', 'gray'.
%   - This function is intentionally lightweight and meant for quick
%     inspection rather than final manuscript-quality figures.

p = inputParser;
p.addRequired('result', @isstruct);
p.addRequired('phaseName', @(x) ischar(x) || isstring(x));
p.addRequired('stageIndex', @(x) isnumeric(x) && isscalar(x));
p.addParameter('UseAbs', true, @islogical);
p.addParameter('ShowResidual', true, @islogical);
p.addParameter('CLim', [], @(x) isempty(x) || (isnumeric(x) && numel(x) == 2));
p.addParameter('ResidualCLim', [], @(x) isempty(x) || (isnumeric(x) && numel(x) == 2));
p.addParameter('Colormap', 'turbo');
p.addParameter('ResidualColormap', 'hot');
p.parse(result, phaseName, stageIndex, varargin{:});
phaseName = upper(string(phaseName));

switch phaseName
    case "HCP"
        phaseResult = result.HCP;
    case "FCC"
        phaseResult = result.FCC;
    otherwise
        error('phaseName must be ''HCP'' or ''FCC''.');
end

if isempty(phaseResult) || isempty(phaseResult.Activity)
    error('No activity maps are available for phase %s.', phaseName);
end

familyMaps = sa_sum_by_family(phaseResult.Activity(:,:,:,stageIndex), ...
    phaseResult.Definition.ActiveFamilyToSystems, p.Results.UseAbs);

mainCMap = local_get_colormap(p.Results.Colormap);
residualCMap = local_get_colormap(p.Results.ResidualColormap);

fig = figure('Name', sprintf('%s family maps - stage %d', phaseName, stageIndex));
tl = tiledlayout(fig, 'flow', 'TileSpacing', 'compact', 'Padding', 'compact');

for i = 1:size(familyMaps, 3)
    ax = nexttile(tl);
    imagesc(ax, phaseResult.Dataset.x, phaseResult.Dataset.y, familyMaps(:,:,i));
    axis(ax, 'image');
    ax.YDir = 'reverse';
    colormap(ax, mainCMap);
    cb = colorbar(ax);
    if ~isempty(p.Results.CLim)
        clim(ax, p.Results.CLim);
    end
    title(ax, phaseResult.Definition.ActiveFamilyShort{i}, 'Interpreter', 'none');
    xlabel(ax, 'x');
    ylabel(ax, 'y');
    if p.Results.UseAbs
        cb.Label.String = '|\gamma| (family sum)';
    else
        cb.Label.String = '\gamma (family sum)';
    end
end

if p.Results.ShowResidual
    ax = nexttile(tl);
    imagesc(ax, phaseResult.Dataset.x, phaseResult.Dataset.y, result.Residual(:,:,stageIndex));
    axis(ax, 'image');
    ax.YDir = 'reverse';
    colormap(ax, residualCMap);
    cb = colorbar(ax);
    if ~isempty(p.Results.ResidualCLim)
        clim(ax, p.Results.ResidualCLim);
    end
    title(ax, 'Residual');
    xlabel(ax, 'x');
    ylabel(ax, 'y');
    cb.Label.String = '||H^{exp} - H^{fit}||';
end

end

function cmap = local_get_colormap(cmapInput)
%LOCAL_GET_COLORMAP Convert user input to an N-by-3 colormap array.
if isnumeric(cmapInput)
    if size(cmapInput, 2) ~= 3
        error('Numeric colormap input must be an N-by-3 array.');
    end
    cmap = cmapInput;
    return
end

if isstring(cmapInput) || ischar(cmapInput)
    cmapName = lower(char(cmapInput));
    switch cmapName
        case 'parula'
            cmap = parula(256);
        case 'turbo'
            cmap = turbo(256);
        case 'hot'
            cmap = hot(256);
        case 'jet'
            cmap = jet(256);
        case 'gray'
            cmap = gray(256);
        case 'cool'
            cmap = cool(256);
        case 'spring'
            cmap = spring(256);
        case 'summer'
            cmap = summer(256);
        case 'autumn'
            cmap = autumn(256);
        case 'winter'
            cmap = winter(256);
        case 'bone'
            cmap = bone(256);
        case 'copper'
            cmap = copper(256);
        case 'pink'
            cmap = pink(256);
        case 'lines'
            cmap = lines(256);
        otherwise
            error('Unsupported colormap name: %s', char(cmapInput));
    end
    return
end

error('Invalid colormap input. Use a colormap name or an N-by-3 array.');
end

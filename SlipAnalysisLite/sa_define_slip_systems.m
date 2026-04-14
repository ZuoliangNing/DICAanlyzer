function def = sa_define_slip_systems(crystalType, varargin)
%SA_DEFINE_SLIP_SYSTEMS Define reordered slip systems for HCP or FCC crystals.
%
%   def = sa_define_slip_systems('hcp', 'AxialRatio', 1.587, ...
%       'Families', {'Basal','Prismatic','PyramidalCA1'})
%
%   def = sa_define_slip_systems('fcc')
%
%   Output DEF is a structure containing:
%       CrystalType
%       CrystalSymmetry
%       AllSystems            All slip systems in the internal ordering
%       FamilyNames           Long family names
%       FamilyShortNames      Short family labels
%       AllSystemNames        Names for all systems
%       FamilyIndexOfAll      Family index of each system
%       ActiveFamilyIndex     Selected family indices
%       ActiveFamilyNames     Long names of active families
%       ActiveFamilyShort     Short names of active families
%       ActiveSystemIndex     Indices of active systems in AllSystems
%       ActiveSystems         Active slip systems
%       ActiveSystemNames     Names of active systems
%       ActiveFamilyToSystems Cell array mapping active family -> local active systems
%
%   The ordering of HCP slip systems is kept consistent with the internal
%   scripts used in the manuscript workflow, so that Schmid-factor plots and
%   activity summaries remain easy to interpret.
%
%   Requirements:
%       MTEX must be available on the MATLAB path.

p = inputParser;
p.addRequired('crystalType', @(x) ischar(x) || isstring(x));
p.addParameter('AxialRatio', 1.587, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('Families', [], @(x) iscell(x) || isnumeric(x) || isstring(x));
p.parse(crystalType, varargin{:});
crystalType = lower(string(p.Results.crystalType));

switch crystalType
    case "hcp"
        a = 0.266;
        CS = crystalSymmetry('6/mmm', [a, a, a * p.Results.AxialRatio], 'x||a', 'Z||c');

        famLong = {'Basal <a>', 'Prismatic <a>', 'Pyramidal <a>', ...
            'Pyramidal <c+a>-1st', 'Pyramidal <c+a>-2nd'};
        famShort = {'Bas', 'Pris', 'PyrA', 'PyrCA1', 'PyrCA2'};

        ssBas = symmetrise(slipSystem.basal(CS),       'antipodal');
        ssPri = symmetrise(slipSystem.prismaticA(CS),  'antipodal');
        ssPyrA = symmetrise(slipSystem.pyramidalA(CS), 'antipodal');
        ssPyrCA1 = symmetrise(slipSystem.pyramidalCA(CS),  'antipodal');
        ssPyrCA2 = symmetrise(slipSystem.pyramidal2CA(CS), 'antipodal');

        % Reorder for consistent plotting / reporting.
        ssBas    = ssBas([1, 3, 2]);
        ssPri    = ssPri([3, 1, 2]);
        ssPyrA   = ssPyrA([5, 2, 6, 4, 1, 3]);
        ssPyrCA1 = ssPyrCA1([5, 6, 3, 4, 8, 7, 11, 12, 2, 1, 10, 9]);
        ssPyrCA2 = ssPyrCA2([1, 2, 6, 4, 3, 5]);

        familySystems = {ssBas; ssPri; ssPyrA; ssPyrCA1; ssPyrCA2};

    case "fcc"
        CS = crystalSymmetry('m-3m');
        famLong = {'{111}<110>'};
        famShort = {'FCC'};

        ssFCC = symmetrise(slipSystem.fcc(CS), 'antipodal');
        ssFCC = ssFCC([1, 4, 7, 10, 2, 5, 8, 11, 3, 6, 9, 12]);
        familySystems = {ssFCC};

    otherwise
        error('Unsupported crystalType: %s', crystalType);
end

familyCounts = cellfun(@length, familySystems);
allSystems = vertcat(familySystems{:});
familyIndex = nan(1, sum(familyCounts));
allNames = cell(1, sum(familyCounts));

cursor = 0;
for i = 1:numel(familySystems)
    ind = cursor + (1:familyCounts(i));
    familyIndex(ind) = i;
    allNames(ind) = arrayfun(@(k) sprintf('%s #%d', famShort{i}, k), ...
        1:familyCounts(i), 'UniformOutput', false);
    cursor = cursor + familyCounts(i);
end

activeFamilyIndex = local_parse_family_selection(p.Results.Families, famLong, famShort);
if isempty(activeFamilyIndex)
    activeFamilyIndex = 1:numel(famLong);
end
activeSystemIndex = find(ismember(familyIndex, activeFamilyIndex));
activeSystems = allSystems(activeSystemIndex);
activeSystemNames = allNames(activeSystemIndex);
activeFamilyToSystems = cell(1, numel(activeFamilyIndex));
localFamilyIndexOfActive = familyIndex(activeSystemIndex);
for i = 1:numel(activeFamilyIndex)
    activeFamilyToSystems{i} = find(localFamilyIndexOfActive == activeFamilyIndex(i));
end

def = struct;
def.CrystalType = char(crystalType);
def.CrystalSymmetry = CS;
def.AllSystems = allSystems;
def.FamilyNames = famLong;
def.FamilyShortNames = famShort;
def.AllSystemNames = allNames;
def.FamilyIndexOfAll = familyIndex;
def.ActiveFamilyIndex = activeFamilyIndex;
def.ActiveFamilyNames = famLong(activeFamilyIndex);
def.ActiveFamilyShort = famShort(activeFamilyIndex);
def.ActiveSystemIndex = activeSystemIndex;
def.ActiveSystems = activeSystems;
def.ActiveSystemNames = activeSystemNames;
def.ActiveFamilyToSystems = activeFamilyToSystems;

end

function activeFamilyIndex = local_parse_family_selection(selection, famLong, famShort)
if isempty(selection)
    activeFamilyIndex = [];
    return
end
if isnumeric(selection)
    activeFamilyIndex = selection(:)';
    return
end
selection = cellstr(string(selection));
activeFamilyIndex = [];
for i = 1:numel(selection)
    tag = lower(strtrim(selection{i}));
    idx = find(strcmpi(tag, famLong) | strcmpi(tag, famShort), 1, 'first');
    if isempty(idx)
        switch tag
            case {'basal', 'bas'}
                idx = 1;
            case {'prismatic', 'pris'}
                idx = 2;
            case {'pyramidala', 'pyra', 'pyramidal <a>'}
                idx = 3;
            case {'pyramidalca1', 'pyr', 'pyrca1', 'pyramidal <c+a>-1st'}
                idx = 4;
            case {'pyramidalca2', 'pyrca2', 'pyramidal <c+a>-2nd'}
                idx = 5;
            otherwise
                error('Unknown family name: %s', selection{i});
        end
    end
    activeFamilyIndex(end + 1) = idx; %#ok<AGROW>
end
activeFamilyIndex = unique(activeFamilyIndex, 'stable');
end

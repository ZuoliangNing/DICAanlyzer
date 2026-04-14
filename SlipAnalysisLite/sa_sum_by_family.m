function familyMaps = sa_sum_by_family(activityMaps, activeFamilyToSystems, useAbs)
%SA_SUM_BY_FAMILY Sum slip activity maps over the requested slip families.
%
%   familyMaps = sa_sum_by_family(activityMaps, activeFamilyToSystems, useAbs)
%
%   activityMaps           nr x nc x nSystems            or
%                          nr x nc x nSystems x nStages
%   activeFamilyToSystems  cell array mapping family -> system indices
%   useAbs                 if true, sum absolute activity

if nargin < 3
    useAbs = true;
end

val = activityMaps;
if useAbs
    val = abs(val);
end

sz = size(val);
if numel(sz) == 3
    familyMaps = nan(sz(1), sz(2), numel(activeFamilyToSystems));
    for i = 1:numel(activeFamilyToSystems)
        familyMaps(:,:,i) = sum(val(:,:,activeFamilyToSystems{i}), 3, 'omitnan');
    end
elseif numel(sz) == 4
    familyMaps = nan(sz(1), sz(2), numel(activeFamilyToSystems), sz(4));
    for i = 1:numel(activeFamilyToSystems)
        familyMaps(:,:,i,:) = sum(val(:,:,activeFamilyToSystems{i},:), 3, 'omitnan');
    end
else
    error('activityMaps must be 3-D or 4-D.');
end

end

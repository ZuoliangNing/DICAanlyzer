function [mask, rowMask, colMask] = sa_extract_grain_mask(grainID, intrinsicIDs, fullSize)
%SA_EXTRACT_GRAIN_MASK Return a cropped logical mask for a single grain.
%
%   [mask, rowMask, colMask] = sa_extract_grain_mask(grainID, intrinsicIDs, fullSize)
%
%   mask    : cropped binary mask of the requested grain
%   rowMask : logical index into the full map rows
%   colMask : logical index into the full map columns

if nargin < 3
    fullSize = size(intrinsicIDs);
end

val = nan(fullSize);
ind = intrinsicIDs == grainID;
val(ind) = 1;

nanInd = isnan(val);
rowMask = ~all(nanInd, 2);
colMask = ~all(nanInd, 1);
val = val(rowMask, colMask);
mask = ~isnan(val);

end

function data = sa_filter_displacements(U, V, options)
%SA_FILTER_DISPLACEMENTS Gaussian smoothing for displacement fields.
%
%   data = sa_filter_displacements(U, V, options)
%
%   This function is a lightweight, documented version of the displacement
%   filtering step used in the original DICAnalyzer / SlipAnalysis scripts.
%   It reproduces the common practice of smoothing raw HRDIC displacement
%   fields before numerical differentiation.
%
%   Required fields in OPTIONS:
%       options.filt_std         Standard deviation of the Gaussian filter.
%
%   Optional fields:
%       options.cutofffraction   Default = 1.
%
%   Output DATA contains:
%       data.U           Filtered U displacement
%       data.V           Filtered V displacement
%       data.imageFilter Filter kernel used
%
%   Note:
%   - NaN values are preserved.
%   - This function requires Image Processing Toolbox for fspecial.
%
%   See also: fspecial, imfilter

if nargin < 3
    options = struct;
end
if ~isfield(options, 'cutofffraction')
    options.cutofffraction = 1;
end
if ~isfield(options, 'filt_std') || isempty(options.filt_std)
    error('options.filt_std must be provided.');
end

filt_std = options.filt_std;
EffectiveWindowSize = 2 * sqrt(-2 * log(1 - options.cutofffraction) * filt_std^2);

if options.cutofffraction < 1
    window = ceil(EffectiveWindowSize) + 1 - rem(ceil(EffectiveWindowSize), 2);
    imageFilter = fspecial('gaussian', window, filt_std);
    imageFilter(imageFilter < (1 - options.cutofffraction) * max(imageFilter(:))) = 0;
else
    window = ceil(15 * filt_std) + 1 - rem(ceil(15 * filt_std), 2);
    imageFilter = fspecial('gaussian', window, filt_std);
end

nanU = isnan(U);
nanV = isnan(V);

Uf = local_nanconv(U, imageFilter);
Vf = local_nanconv(V, imageFilter);

Uf(nanU) = NaN;
Vf(nanV) = NaN;

data.imageFilter = imageFilter;
data.U = Uf;
data.V = Vf;

end

function out = local_nanconv(in, kernel)
%LOCAL_NANCONV Minimal NaN-aware convolution helper.
valid = ~isnan(in);
in2 = in;
in2(~valid) = 0;
weight = conv2(double(valid), kernel, 'same');
out = conv2(in2, kernel, 'same');
out = out ./ weight;
out(weight == 0) = NaN;
end

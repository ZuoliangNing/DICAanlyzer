function crs = sa_coarsegrain_displacements(U, V, XData, YData, coarsegrainstep)
%SA_COARSEGRAIN_DISPLACEMENTS Downsample a displacement field by averaging.
%
%   crs = sa_coarsegrain_displacements(U, V, XData, YData, coarsegrainstep)
%
%   coarsegrainstep = 1 keeps the original resolution.
%   coarsegrainstep = 2 averages 2x2 super-pixels, etc.
%
%   Output CRS contains the coarse-grained field, coordinates, pixel size,
%   and cropping information.
%
%   This helper is adapted from the internal project scripts, but simplified
%   and documented for open-source release.

if nargin < 5 || isempty(coarsegrainstep)
    coarsegrainstep = 1;
end

[n, m] = size(U);
crs.factor = coarsegrainstep - 1;
crs.sps = 2 ^ crs.factor;

nmod = mod(n, crs.sps);
In = floor(1 + nmod / 2):(n - (nmod - floor(nmod / 2)));
mmod = mod(m, crs.sps);
Im = floor(1 + mmod / 2):(m - (mmod - floor(mmod / 2)));

U = U(In, Im);
V = V(In, Im);
YData = YData(In);
XData = XData(Im);
crs.In = In;
crs.Im = Im;

[n, m] = size(U);
if coarsegrainstep ~= 1
    crs.Npx = [n, m] ./ crs.sps;
else
    crs.Npx = [n, m];
end

if coarsegrainstep ~= 1
    Pn = repmat(eye(crs.Npx(1)), crs.sps, 1);
    Pn = reshape(Pn, crs.Npx(1), n)';
    Pm = repmat(eye(crs.Npx(2)), crs.sps, 1);
    Pm = reshape(Pm, crs.Npx(2), m)';

    crs.x = (XData * Pm) ./ crs.sps;
    crs.y = (YData * Pn) ./ crs.sps;

    if ~any(isnan(U(:)) | isnan(V(:)))
        crs.U = (Pn' * U * Pm) ./ crs.sps^2;
        crs.V = (Pn' * V * Pm) ./ crs.sps^2;
    else
        crs.U = zeros(crs.Npx(1), crs.Npx(2));
        crs.V = zeros(crs.Npx(1), crs.Npx(2));
        Ucnt = zeros(crs.Npx(1), crs.Npx(2));
        Vcnt = zeros(crs.Npx(1), crs.Npx(2));

        for in = 1:crs.sps
            for im = 1:crs.sps
                subRows = in:crs.sps:n;
                subCols = im:crs.sps:m;
                Ut = U(subRows, subCols);
                Vt = V(subRows, subCols);

                crs.U(~isnan(Ut)) = crs.U(~isnan(Ut)) + Ut(~isnan(Ut));
                crs.V(~isnan(Vt)) = crs.V(~isnan(Vt)) + Vt(~isnan(Vt));
                Ucnt = Ucnt + isnan(Ut);
                Vcnt = Vcnt + isnan(Vt);
            end
        end

        crs.U = crs.U ./ (crs.sps^2 - Ucnt);
        crs.V = crs.V ./ (crs.sps^2 - Vcnt);
        crs.U(Ucnt == crs.sps^2) = NaN;
        crs.V(Vcnt == crs.sps^2) = NaN;
        crs.U(isinf(crs.U)) = NaN;
        crs.V(isinf(crs.V)) = NaN;
    end
else
    crs.U = U;
    crs.V = V;
    crs.x = XData;
    crs.y = YData;
end

pixelSize(1) = mean(diff(XData));
pixelSize(2) = mean(diff(YData));
crs.PixelSize = pixelSize * crs.sps;
crs.Npx = size(crs.U);
[crs.X, crs.Y] = meshgrid(crs.x, crs.y);

end

function Eeff = sa_compute_effective_shear(Hxx, Hxy, Hyx, Hyy)
%SA_COMPUTE_EFFECTIVE_SHEAR Compute the in-plane effective shear strain.
%
%   Eeff = sa_compute_effective_shear(Hxx, Hxy, Hyx, Hyy)
%
%   This helper uses the same definition adopted in DICAnalyzer and in the
%   manuscript workflow:
%
%       gamma_eff = sqrt(0.5 * (Hxx - Hyy).^2 + 0.5 * (Hxy + Hyx).^2)
%
%   where Hxx, Hxy, Hyx and Hyy are the in-plane components of the
%   displacement-gradient tensor.
%
%   Inputs can be matrices or vectors of the same size.
%
%   See also: gradient

Eeff = sqrt(0.5 .* (Hxx - Hyy).^2 + 0.5 .* (Hxy + Hyx).^2);

end

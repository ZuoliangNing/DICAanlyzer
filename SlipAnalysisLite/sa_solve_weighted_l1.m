function [gamma, residual, exitflag] = sa_solve_weighted_l1( ...
    slipSystems, systemWeights, Hxx, Hxy, Hyx, Hyy, options)
%SA_SOLVE_WEIGHTED_L1 Weighted sparse slip identification using coneprog.
%
% This function was developed for the present repository with reference to
% the public SSLIP MATLAB implementation by Tijmen Vermeij et al.
% The current version is simplified and reorganized for integration with
% DICAnalyzer and does not reproduce the full upstream workflow.
%
%   [gamma, residual, exitflag] = sa_solve_weighted_l1( ...
%       slipSystems, systemWeights, Hxx, Hxy, Hyx, Hyy, options)
%
%   This is the core numerical solver of the open-source slip-analysis
%   module. It solves a weighted L1-minimization problem under a residual
%   constraint for each pixel independently.
%
%   Inputs
%   ------
%   slipSystems   MTEX slipSystem array in the sample / image frame.
%   systemWeights One weight per slip system (positive numbers).
%   Hxx...Hyy     In-plane displacement-gradient components.
%   options.MinEffectiveShear  Default = 0.
%   options.ResidualTolerance  Default = 1e-5.
%   options.IncludeRotation    Default = false.
%   options.RotationWeight     Default = 1.
%   options.UseParallel        Default = false.
%
%   Outputs
%   -------
%   gamma      (nUnknowns x nPixels) signed activity values.
%   residual   Residual norm at each pixel.
%   exitflag   coneprog exit flag at each pixel.
%
%   Notes
%   -----
%   - The solver allows signed activity by splitting each unknown into
%     positive and negative parts.
%   - If IncludeRotation = true, one additional unknown is appended with
%     deformation tensor [0 -1; 1 0].
%   - Requires Optimization Toolbox (coneprog).

if nargin < 7
    options = struct;
end
if ~isfield(options, 'MinEffectiveShear') || isempty(options.MinEffectiveShear)
    options.MinEffectiveShear = 0;
end
if ~isfield(options, 'ResidualTolerance') || isempty(options.ResidualTolerance)
    options.ResidualTolerance = 1e-5;
end
if ~isfield(options, 'IncludeRotation') || isempty(options.IncludeRotation)
    options.IncludeRotation = false;
end
if ~isfield(options, 'RotationWeight') || isempty(options.RotationWeight)
    options.RotationWeight = 1;
end
if ~isfield(options, 'UseParallel') || isempty(options.UseParallel)
    options.UseParallel = false;
end

Hslip = slipSystems.deformationTensor.matrix;
A = [reshape(Hslip(1,1,:), 1, []); ...
     reshape(Hslip(1,2,:), 1, []); ...
     reshape(Hslip(2,1,:), 1, []); ...
     reshape(Hslip(2,2,:), 1, [])];

weights = systemWeights(:);
if size(A, 2) ~= numel(weights)
    error('Length of systemWeights must match the number of slip systems.');
end

if options.IncludeRotation
    A = [A, [0; -1; 1; 0]];
    weights(end + 1, 1) = options.RotationWeight;
end
nUnknown = size(A, 2);

pixelCount = numel(Hxx);
Hexp = zeros(2, 2, pixelCount);
Hexp(1,1,:) = Hxx(:);
Hexp(1,2,:) = Hxy(:);
Hexp(2,1,:) = Hyx(:);
Hexp(2,2,:) = Hyy(:);
Eeff = sa_compute_effective_shear(Hxx(:), Hxy(:), Hyx(:), Hyy(:));

solverOptions = optimoptions('coneprog', 'Display', 'none');

gamma = nan(nUnknown, pixelCount);
residual = nan(pixelCount, 1);
exitflag = zeros(pixelCount, 1);

runParallel = options.UseParallel && local_parallel_available();

if runParallel
    parfor i = 1:pixelCount
        [gamma(:,i), residual(i), exitflag(i)] = local_solve_one_pixel( ...
            Hexp(:,:,i), Eeff(i), A, weights, options, solverOptions, nUnknown);
    end
else
    for i = 1:pixelCount
        [gamma(:,i), residual(i), exitflag(i)] = local_solve_one_pixel( ...
            Hexp(:,:,i), Eeff(i), A, weights, options, solverOptions, nUnknown);
    end
end

end

function [gammaCol, residualVal, exitflagVal] = local_solve_one_pixel( ...
    HexpSingle, EeffSingle, A, weights, options, solverOptions, nUnknown)

gammaCol = nan(nUnknown, 1);
residualVal = NaN;
exitflagVal = 0;

if any(isnan(HexpSingle), 'all')
    return
end
if EeffSingle < options.MinEffectiveShear
    gammaCol(:) = 0;
    residualVal = 0;
    exitflagVal = 1;
    return
end

H = HexpSingle';
H = H(:);

lb = zeros(2 * nUnknown, 1);
Aext = [A, -A];
soc = secondordercone(Aext, H, lb, -options.ResidualTolerance);
f = [weights; weights];

[x, ~, flag] = coneprog(f, soc, [], [], [], [], lb, [], solverOptions);
exitflagVal = flag;

if flag == 1 || flag == -7
    x = x(1:nUnknown) - x(nUnknown + 1:end);
    gammaCol = x;
    residualVal = norm(A * x - H);
end

end

function tf = local_parallel_available()
tf = false;
try
    tf = license('test', 'Distrib_Computing_Toolbox') && ~isempty(ver('parallel'));
catch
    tf = false;
end
end

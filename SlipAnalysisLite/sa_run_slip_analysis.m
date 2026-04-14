function result = sa_run_slip_analysis(obj, options)
%SA_RUN_SLIP_ANALYSIS One-stop entry point for the public slip-analysis module.
%
%   result = sa_run_slip_analysis(obj, options)
%
%   This wrapper connects the lightweight open-source slip-identification
%   code to a DICAnalyzer project object. The function performs:
%       1. data extraction / preprocessing from the selected project,
%       2. slip-system definition (HCP and optionally FCC),
%       3. grain-wise slip identification,
%       4. activity and summary assembly.
%
%   Typical use
%   -----------
%       obj = app.Projects(1);
%       options = struct;
%       options.HcpFamilies = {'Basal','Prismatic','PyramidalCA1'};
%       options.HcpFamilyWeights = [1.3, 1.0, 2.5];
%       options.IncludeRotation = true;
%       options.MinEffectiveShear = 1e-3;
%       result = sa_run_slip_analysis(obj, options);
%       sa_plot_family_maps(result, 'HCP', 1);
%
%   Important notes
%   ---------------
%   - This public module intentionally contains only the core, reusable
%     functionality required to run slip identification.
%   - Manuscript-specific figure scripts, CRSS fitting workflows, and other
%     highly customized analysis utilities are intentionally not included in
%     this simplified release.
%
%   Requirements
%   ------------
%   - MTEX
%   - Optimization Toolbox (coneprog)
%   - Image Processing Toolbox (recommended if displacement filtering is used)

if nargin < 2
    options = struct;
end

if ~isfield(options, 'FilterStd')
    options.FilterStd = 0;
end
if ~isfield(options, 'Coarsegrain')
    options.Coarsegrain = 1;
end
if ~isfield(options, 'HcpFamilies')
    options.HcpFamilies = {'Basal', 'Prismatic', 'PyramidalCA1'};
end
if ~isfield(options, 'HcpAxialRatio')
    options.HcpAxialRatio = 1.587;
end
if ~isfield(options, 'UseFCC')
    options.UseFCC = false;
end
if ~isfield(options, 'UseParallel')
    options.UseParallel = false;
end
if ~isfield(options, 'FccFamilies')
    options.FccFamilies = {'{111}<110>'};
end
if ~isfield(options, 'Stages') || isempty(options.Stages)
    options.Stages = 1:obj.DIC.StageNumber;
end

dataset = sa_prepare_from_dicanalyzer(obj, options);

definitions = struct;
definitions.HCP = sa_define_slip_systems('hcp', ...
    'AxialRatio', options.HcpAxialRatio, 'Families', options.HcpFamilies);
if options.UseFCC
    definitions.FCC = sa_define_slip_systems('fcc', 'Families', options.FccFamilies);
end

result = sa_identify_slip_activity(dataset, definitions, options);

end

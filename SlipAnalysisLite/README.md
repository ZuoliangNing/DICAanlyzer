# SlipAnalysisLite

`SlipAnalysisLite` is a lightweight, public-facing MATLAB module for slip-system identification based on fused HRDIC-EBSD data processed in **DICAnalyzer**.

This folder is intentionally a **simplified open-source release**. It contains only the core functions required to:

1. extract data from a DICAnalyzer project,
2. define HCP / FCC slip systems,
3. perform grain-wise slip identification using a weighted sparse solver,
4. summarize activity by slip system and slip family,
5. generate quick inspection plots.

## What is included

- **Documented data extraction** from a DICAnalyzer project object.
- **HCP and FCC slip-system definitions** based on MTEX.
- **Weighted L1 identification solver** using `coneprog`.
- **Optional rotation correction term**.
- **Family-wise activity summaries** and a compact grain summary.
- **Minimal example script** for reproducible usage.

## What is intentionally not included

This public module does **not** contain the full internal analysis pipeline used to prepare all manuscript figures. In particular, the following were intentionally omitted to keep the release clean, reusable, and easy to maintain:

- manuscript-specific plotting scripts,
- CRSS fitting / iteration workflows,
- exploratory or redundant development scripts,
- highly customized post-processing utilities,
- project-specific parameter presets.

## Requirements

- MATLAB (recent release with `coneprog` support)
- [MTEX](https://mtex-toolbox.github.io/)
- Optimization Toolbox
- Image Processing Toolbox (recommended if displacement filtering is used)

## Quick start

```matlab
options = struct;
options.HcpFamilies = {'Basal','Prismatic','PyramidalCA1'};
options.HcpFamilyWeights = [1.3, 1.0, 2.5];
options.IncludeRotation = true;
options.MinEffectiveShear = 1e-3;
options.ShowWaitbar = true;
options.UseParallel = false;

result = sa_run_slip_analysis(obj, options);
sa_plot_family_maps(result, 'HCP', 1);
```

See `example_basic_workflow.m` for a more complete template.

## Main files

- `sa_run_slip_analysis.m` – one-stop wrapper for a DICAnalyzer project.
- `sa_prepare_from_dicanalyzer.m` – data extraction and preprocessing.
- `sa_define_slip_systems.m` – slip-system definitions for HCP / FCC.
- `sa_identify_slip_activity.m` – grain-wise activity calculation.
- `sa_solve_weighted_l1.m` – pixel-wise weighted sparse solver.
- `sa_plot_family_maps.m` – quick visualization helper.

## Suggested citation / acknowledgement

If you use this module in academic work, please cite the relevant DICAnalyzer publication / repository and the original SSLIP paper if the sparse-identification workflow is relevant to your implementation.


A grain-level waitbar is enabled by default in `sa_identify_slip_activity`. Set `options.ShowWaitbar = false` if you prefer to run silently.

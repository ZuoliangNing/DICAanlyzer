# DICAanlyzer

DICAanlyzer is a MATLAB App for correlative analysis of **HRDIC** (High-Resolution Digital Image Correlation) and **EBSD** (Electron Backscatter Diffraction) data. It is designed to help users build a pixel-level link between local deformation fields and crystallographic information, so that strain localization, grain-scale behavior, and structure-property relations can be studied in a single workflow.

## What the software does

The App provides an integrated workflow for:

- importing HRDIC and EBSD data,
- reconstructing grains from EBSD maps,
- registering EBSD onto the HRDIC coordinate system using homologous points,
- calculating derived variables from the fused dataset,
- performing line measurements and regional statistics,
- exporting quasi-3D CPFE input models,
- extending the workflow with user-defined importers, calculations, and GUI modules.

## Main capabilities

### 1) Grain reconstruction and correlative mapping
- Grain reconstruction from raw EBSD data using a polygon-based representation.
- Grain cleaning, boundary detection, and grain-boundary / grain-interior partitioning.
- Homologous-point-based spatial mapping from EBSD to the HRDIC grid.

### 2) Derived-field calculation
- Built-in post-processing of common HRDIC quantities such as effective shear, generalized in-plane strain, rotation, and other custom variables.
- Access to both DIC-only and fused HRDIC-EBSD calculations through a unified interface.

### 3) Quantitative analysis
- Line-profile measurements on any mapped variable.
- Regional statistics inside user-selected rectangular windows.
- Automatic partitioning by deformation stage, phase, and grain-boundary / grain-interior region.

### 4) CPFE export
- Export of quasi-3D CPFE models directly from the fused dataset.
- Optional use of measured HRDIC displacement fields as boundary conditions.
- Customization of thickness, mesh density, step definitions, and export parameters.

### 5) Extensibility
- Unified interfaces for adding:
  - new HRDIC import formats,
  - new EBSD preprocessing methods,
  - new calculated variables,
  - new App extensions.

## New in this public version: `SlipAnalysisLite`

A new folder, **`SlipAnalysisLite`**, is included as a lightweight public release of the slip-identification workflow used on top of the DICAnalyzer data structure.

This module is meant to be easy to read and easy to reuse. It provides the essential functions needed to:

- extract fused data from a DICAnalyzer project object,
- define HCP / FCC slip systems,
- run grain-wise weighted sparse slip identification,
- summarize activity by system and family,
- generate quick inspection plots.

To keep the public release clean and maintainable, highly customized internal scripts, manuscript-specific figure pipelines, and detailed CRSS-fitting utilities are intentionally **not** included.

## Repository structure

- `DICAnalyzer.mlapp` – main App entry point.
- `@DICInstance`, `@DICProcessor` – project and preprocessing classes.
- `USER_funs` – user-extensible import, calculation, and GUI modules.
- `cal_funs` – shared utility functions.
- `SlipAnalysisLite` – lightweight public slip-analysis module.
- `Documents` – supporting notes and workflow documents.

## Requirements

- MATLAB with App Designer support.
- A recent MATLAB release with `coneprog` support is recommended if `SlipAnalysisLite` is used.
- [MTEX](https://mtex-toolbox.github.io/) is required for crystallographic operations.
- Image Processing Toolbox is recommended for displacement filtering.

## Installation

1. Clone or download this repository.
2. Add the repository (and MTEX, if needed) to the MATLAB path.
3. Open and run `DICAnalyzer.mlapp`.
4. For scripted slip analysis, use the functions in `SlipAnalysisLite`.

## Quick scripted example for slip analysis

```matlab
options = struct;
options.HcpFamilies = {'Basal','Prismatic','PyramidalCA1'};
options.HcpFamilyWeights = [1.3, 1.0, 2.5];
options.IncludeRotation = true;
result = sa_run_slip_analysis(obj, options);
sa_plot_family_maps(result, 'HCP', 1);
```

See `SlipAnalysisLite/example_basic_workflow.m` for a commented template.

## Acknowledgement of the SSLIP framework

The slip-identification workflow in this repository is developed on top of the SSLIP framework originally proposed by Vermeij et al. for point-by-point identification of slip-system activity fields from DIC displacement-gradient data.

Parts of the public MATLAB implementation in `SlipAnalysisLite` were developed with reference to the open-source SSLIP code released by the original authors. The present repository does not reproduce the full upstream project; instead, it provides a simplified and reorganized implementation adapted to the DICAnalyzer data structure and to the methodology developed in our work.

Our study extends the original SSLIP framework toward HCP materials with multiple slip families and introduces the weighted formulation used in our manuscript for improved slip identification and subsequent CRSS-oriented analysis.

If you use this repository, please cite both:
1. the original SSLIP paper by Vermeij et al.; and
2. our paper / repository corresponding to the present implementation.

## Contact

For questions, bug reports, or collaboration inquiries, please contact:

- Zuoliang Ning – ningzuoliang2019@outlook.com

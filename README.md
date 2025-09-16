# DICAanlyzer
This MATLAB APP seamlessly fuses HRDIC and EBSD data. It provides an integrated suite for precise mapping, grain analysis, and visualization to directly correlate material microstructure with local mechanical behavior, simplifying complex post-processing tasks.

## Abstract
DICAanlyzer is a MATLAB APP designed to address the challenges of integrating and analyzing data from High-Resolution Digital Image Correlation (HRDIC) and Electron Backscatter Diffraction (EBSD). It provides a comprehensive suite of tools for data fusion, post-processing, quantitative analysis, and visualization, enabling researchers in materials science and mechanics to efficiently correlate microstructural features with local mechanical responses.

## Background and Motivation
In experimental mechanics, HRDIC and EBSD are powerful techniques for characterizing local strain fields and crystallographic orientations, respectively. However, these characterizations are often performed using different equipment, at different times, and with varying resolutions. This leads to significant challenges in establishing a direct, pixel-to-pixel correspondence between the datasets. For instance, EBSD data acquisition can introduce distortions due to high beam currents, sample charging, or minute sample slippage when tilted at 70°.

To bridge this gap, it is crucial to perform a spatial registration that correctly maps crystallographic information (orientation, image quality, confidence index) from EBSD onto every pixel of the HRDIC data, which contains displacement and strain fields. Furthermore, the post-processing of this vast amount of fused data—especially when analyzing results partitioned by grains, phases, or grain boundaries—is often laborious and complex. This app was developed to provide an efficient, user-friendly, and feature-rich platform to streamline this entire workflow.

## Key Features
### Data Processing & Reconstruction:
* Reconstructs grains from raw EBSD data into a polygon-based data structure.
  Using the project [EBSDPolygonizer] (https://github.com/samjliu/EBSDPolygonizer)
* Performs data cleaning, noise reduction, grain identification, and segmentation of grain boundary vs. grain interior regions.
### Correlative Mapping:
* Implements a homologous points matching-based transformation to accurately map EBSD data onto the HRDIC coordinate system.
### Advanced Calculations:
* Computes a variety of secondary physical quantities based on HRDIC, EBSD, or the fused dataset.
* Provides a unified interface for users to define and calculate new custom quantities.
### Quantitative Analysis:
* Performs line-scan measurements and regional statistical analysis on any variable.
* Automatically partitions statistics by deformation stage, grain boundary/interior, and phase.
* Allows for dynamic modification of visualization and statistical parameters.
### Modeling & Export:
* Exports quasi-3D Crystal Plasticity Finite Element (CPFE) models from the fused data.
* Offers customization of model thickness, mesh size, analysis step parameters, and subroutine variables.
* Optionally applies HRDIC-measured displacements as boundary conditions to the model.
### Interactive Visualization:
* Customizable display of grain groups (user-defined or by phase).
* Toggles for displaying grain boundary vs. grain interior regions.
* Highlights neighbors of a selected grain.
* Customizable plotting of grain boundaries and IDs.
* Flexible colormaps and value ranges for different variables.
### Project Management & Extensibility:
* Saves and loads analysis sessions in a custom project file format.
* Exports statistical results and processed data fields.
* Features a modular design with unified interfaces for extending data import formats, secondary calculation methods, and new GUI-based analysis modules (e.g., pole figure analysis).

## System Requirements & Installation
### Requirements
* MATLAB R2025a or newer.
### Installation
* Clone the repository to your local machine
* Direct to '\DICAnalyzer' and run 'DICAnalyzer.mlapp'.

## Contact us
* For questions, bug reports, or support, please contact the author at ningzuoliang2019@outlook.com.

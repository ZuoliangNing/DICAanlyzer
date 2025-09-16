function SavedDefault = getDefault()

% Default settings

SavedDefault.LanguageSelection = 2;     % 1 - English / 2 - Chinese

% ---------- Paths ----------
SavedDefault.Path.DICImport = [ cd, '\' ];
SavedDefault.Path.EBSDImport = [ cd, '\' ];
SavedDefault.Path.ProjectSave = [ cd, '\' ];
SavedDefault.Path.ProjectOpen = [ cd, '\' ];
SavedDefault.Path.ExportData = [ cd, '\' ];
SavedDefault.Path.ExportCurves = [ cd, '\' ];
SavedDefault.Path.ExportEBSDDataangTemplate = [ cd, '\' ];
SavedDefault.Path.ExportABAQUSinputfile = [ cd, '\' ];

% ---------- UI Sizes ----------
SavedDefault.UIFigureInitialSize = ...
    getMiddlePosition(get(0,'ScreenSize'),[1000,600]);
SavedDefault.AppNameLabelFontSize = 17;


% ---------- Options ----------
SavedDefault.Options.EBSDSelection = 1;         % X / Y / Z

% Value Range estimation for disp & strain
SavedDefault.Options.ValueRanges = [ 200, 1 ];

% Maximum size of all dims of data
SavedDefault.Options.MaxResolution = 1000;

%   ---/// DICImport
SavedDefault.Options.DICFileFormatSelection = 1;
SavedDefault.Options.DICPreprocessMethod = 'UseDefault';

%   ---/// DIC image
SavedDefault.Options.DICColormapIndex = 1;
SavedDefault.Options.DICCLimCoeff = 2; % used in 'refreshCLimSlider(app)'
SavedDefault.Options.DICAxesFlag = false;
SavedDefault.Options.OverlayDIC = false;

%   ---/// EBSDImport
SavedDefault.Options.EBSDPreprocessMethod = 'Format_OIM';
SavedDefault.Options.EBSDAxesFlag = false;

%   ---/// PlotStyle
SavedDefault.Options.GBLineWidth = 1.5;
SavedDefault.Options.GBColor = [0,0,0];
SavedDefault.Options.OverlayOpacity = 0.5;
SavedDefault.Options.GrainLabelsFontSize = 18;
SavedDefault.Options.GrainLabelsColor = [0,0,0];
SavedDefault.Options.LineStatisticLineWidth = 1.5;
SavedDefault.Options.ReigonStatisticLineWidth = 1;
% SavedDefault.Options.DisplayIndependentFigureSize = [800,600];

%   ---/// EBSDPolygonize
SavedDefault.Options.GBSmoothDegree = 3;
SavedDefault.Options.MinimumGrainSize = 10; % pixels
SavedDefault.Options.ParallelComputing = false;

%   ---/// GrainsTab
SavedDefault.Options.GrainsTab.Labels = false;
SavedDefault.Options.GrainsTab.Neighbours = false;
SavedDefault.Options.GrainsTab.GBs = false;
% SavedDefault.Options.GrainsTab.DICOption = 'Overlay';
SavedDefault.Options.GrainsTab.DICFlag = false;
SavedDefault.Options.GrainsTab.InteriorFlag = true;
SavedDefault.Options.GrainsTab.FrontierFlag = false;
SavedDefault.Options.GrainsTab.FrontierDev = 1;
SavedDefault.Options.GrainsTab.IntrinsicFlag = false;
SavedDefault.Options.GrainsTab.DICFlag = false;

%   ---/// ExportData
SavedDefault.Options.ExportData.BoundaryOnly = true;
SavedDefault.Options.ExportData.UsePolygonizedID = true;
SavedDefault.Options.ExportData.ExportDICSeparately = true;

%   ---/// ExportInp
SavedDefault.Options.ExportData.MaxElemNumberOnEdge = 500;
SavedDefault.Options.ExportData.ZLayerNumber = 1;
SavedDefault.Options.ExportData.UserMaterialFormatSelection = 1;
% InpParameters -- TimePeriod / InitialInc / MinInc / MaxInc / maxNumInc
SavedDefault.Options.ExportData.InpParameters = ...
    { 1.0, 1e-5, 1e-16, 0.01, 1e7, 'SAMPLE' };


% ---------- PARAMETERS ----------

%   ---/// DICImport
SavedDefault.Parameters.DICPreprocessMethods = struct();

%   ---/// EBSDImport
SavedDefault.Parameters.EBSDPreprocessMethods = struct();

%   ---/// EXTENSIONS
SavedDefault.Parameters.Extensions.OriPF = struct( ...
    'Orientation', [0,0,0,1], ...
    'SurfaceTrace', [0,0,0,1], ...
    'SurfacePole', [0,0,0,1] );
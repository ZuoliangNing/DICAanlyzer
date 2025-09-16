function setOthers(app)
% check menus & set buttons icon & define ContextMenu

% Icons
% app.OpenButton.Icon = 'open.png';
% app.AddPlotButton.Icon = 'plot.png';
% app.ClearButton.Icon = 'clear.png';
% app.HideButton.Icon = 'hide.png';

% ///////////// ContextMenu /////////////

% ---Tree---
AllTreeContextMenuTypes = fieldnames(app.TreeContextMenuTypes);
for i = 1:length(AllTreeContextMenuTypes)
    ContextMenuType = AllTreeContextMenuTypes{i};
    cm = uicontextmenu( app.UIFigure, ...
        'UserData', struct( ...
        'Parent', 'Tree', 'ContextMenuType', ContextMenuType ), ...
        'ContextMenuOpeningFcn', { str2func( ...
            [ ContextMenuType, 'OpeningFcn' ] ), app } );
    cellfun( @(str) uimenu( cm, ...
        'UserData', str, ...
        'MenuSelectedFcn', { str2func( ...
            [ ContextMenuType, str, 'MenuSelectedFcn' ] ), app } ), ...
        app.TreeContextMenuTypes.(ContextMenuType) )
    app.TreeContextMenu.(ContextMenuType) = cm;
end
% ---Tree2---
app.Tree2ContextMenu = uicontextmenu( app.UIFigure, ...
    'ContextMenuOpeningFcn', { @ Tree2ContextMenuOpeningFcn, app } );
uimenu( app.Tree2ContextMenu, ...
    'MenuSelectedFcn', { @ Tree2DeleteMenuSelectedFcn, app } )
% ---UIAxes---
app.UIAxesContextMenu = uicontextmenu( app.UIFigure, ...
    'ContextMenuOpeningFcn', { @ UIAxesContextMenuOpeningFcn, app } );
uimenu( app.UIAxesContextMenu, ...
    'MenuSelectedFcn', { @ UIAxesDisplayMiniatureMenuSelectedFcn, app } )
uimenu( app.UIAxesContextMenu, ...
    'MenuSelectedFcn', { @ UIAxesDisplayIndependentMenuSelectedFcn, app } )


% -------- dropdowns --------
app.EBSDDropDown.Items = app.ConstantValues.EBSDDirections;
app.EBSDDropDown.ValueIndex = app.Default.Options.EBSDSelection;
app.EBSDDropDown.UserData = 'EBSD';
app.EBSDDropDown.Enable = 'off';
app.EBSDDropDownLabel.Enable = 'off';
app.StageDropDown.Enable = 'off';
app.StageDropDownLabel.Enable = 'off';

% -------- UIAxes --------
%   /// UIAxesImages - DIC ///
app.UIAxesImages.NextPlot = 'add';
app.UIAxesImages.Visible = 'off';
colormap( app.UIAxesImages, ...
    app.ConstantValues.Colormaps{ app.Default.Options.DICColormapIndex } )
% app.CLimSlider.Enable = 'off';
% app.CLimSliderLabel.Enable = 'off';
% app.CLimManualButton.Enable = 'off';
axis( app.UIAxesImages, 'image' )
% app.DICColorbar = colorbar( app.UIAxesImages, 'Visible', 'off' );
% app.UIAxesImages.Toolbar.Visible = 'off';
app.UIAxesImages.Tag = '1';
app.UIAxesImages.XTick = [];
app.UIAxesImages.YTick = [];
app.UIAxesImages.YAxis.Direction = 'reverse';
%   /// UIAxesImages2 - EBSD ///
app.UIAxesImages2.NextPlot = 'add';
app.UIAxesImages2.Visible = 'off';
axis( app.UIAxesImages2, 'image' )
app.UIAxesImages2.Tag = '2';
app.UIAxesImages2.XTick = [];
app.UIAxesImages2.YTick = [];
app.UIAxesImages2.ClippingStyle ='rectangle';
app.UIAxesImages2.YAxis.Direction = 'reverse';
%   /// UIAxesValue - Value ///
app.UIAxesValue = getUIAxe( app.GridLayout6, ...
    'XLabel', 'Distance, µm', 'YLabel', 'Value' );
app.UIAxesValue.Tag = '3';
app.UIAxesValue.ContextMenu = app.UIAxesContextMenu;
%   /// UIAxesFrequency - Frequency ///
app.UIAxesFrequency = getUIAxe( app.GridLayout6_3, ...
    'XLabel', 'Strain, 1', 'YLabel', 'Frequency, %' );
app.UIAxesFrequency.Tag = '4';
app.UIAxesFrequency.ContextMenu = app.UIAxesContextMenu;
%   /// UIAxesImages3
axis( app.UIAxesImages3, 'image' )
imshow( 'default.png', 'Parent', app.UIAxesImages3 )
app.UIAxesImages3.XTick = [];
app.UIAxesImages3.YTick = [];
app.UIAxesImages3.Tag = 'Sub';
app.UIAxesImages3.NextPlot = 'add';

% -------- buttons --------
app.ButtonFold.UserData = 'down';
app.OverlayDICButton.Enable = 'off';
app.OverlayPolygons.Enable = 'off';
app.StyleButton.Icon = 'style.png';
app.StatisticButton.Icon = 'plot.png';
app.StatisticButton.Enable = 'off';
app.MonitorButton.Icon = 'statistic.png';
app.LinePropertiesRandomColorButton.Icon = 'random.png';
app.AxisSettingsAutoButton.Icon = 'auto.png';

app.OverlayDICButton.Value = app.Default.Options.OverlayDIC;

% ///////////// CREATE Menus /////////////

% -------- DICFileFormatMenu --------
cellfun( @(str) uimenu( app.DICFileFormatMenu, ...
    'Text', str, ...
    'MenuSelectedFcn', { @ DICFileFormatMenuSelectedFcn, app } ), ...
    app.DICFileFormats )

% -------- DICColormapMenu --------
cellfun( @(str) uimenu( app.DICColormapMenu, ...
    'Text', str, ...
    'MenuSelectedFcn', { @ DICColormapMenuSelectedFcn, app } ), ...
    app.ConstantValues.ColormapsNames )

% -------- ExtensionsMenu --------
Extensions = fieldnames( app.Extensions );
for i = 1:length( Extensions )
    name = Extensions{i};
    fun = eval( [ '@ Extensions_', name ] );
    uimenu( app.ExtensionsMenu, ...
        'Text', app.Extensions.(name).Name{ app.Default.LanguageSelection }, ...
        'MenuSelectedFcn', { fun, app } );
end



% ///////////// CHECK Menus /////////////

% -------- LanguageMenu --------
temp = app.LanguageMenu.Children;
temp( app.Default.LanguageSelection ).Checked = 'on';

% -------- DICFileFormatMenu --------
temp = flip( app.DICFileFormatMenu.Children );
temp( app.Default.Options.DICFileFormatSelection ).Checked = 'on';

% -------- DICColormapMenu --------
temp = flip(app.DICColormapMenu.Children);
temp( app.Default.Options.DICColormapIndex ).Checked = 'on';

% -------- ShowAxesMenu --------
if app.Default.Options.DICAxesFlag
    app.DICShowAxesMenu.Checked = 'on';
end
if app.Default.Options.EBSDAxesFlag
    app.EBSDShowAxesMenu.Checked = 'on';
end

% -------- Polygonize --------
if app.Default.Options.ParallelComputing
    app.ParallelComputingMenu.Checked = 'on';
end

% ///////////// TabGroup2 /////////////

app.GrainSelectionPanel.Enable = 'off';
app.BoundaryPanel.Enable = 'off';
app.DICPanel.Enable = 'off';
app.ImagePolygonize.ImageSource = app.ConstantValues.EmptyImage;
app.ImageAdjust.ImageSource = app.ConstantValues.EmptyImage;



% ///////////// Grians Tab /////////////
app.LabelsCheckBox.Value = app.Default.Options.GrainsTab.Labels;
app.NeighboursCheckBox.Value = app.Default.Options.GrainsTab.Neighbours;
app.InteriorCheckBox.Value = app.Default.Options.GrainsTab.InteriorFlag;
app.FrontierCheckBox.Value = app.Default.Options.GrainsTab.FrontierFlag;
app.FrontierDevSpinner.Value = app.Default.Options.GrainsTab.FrontierDev;
app.IntrinsicCheckBox.Value = app.Default.Options.GrainsTab.IntrinsicFlag;

app.GBsCheckBox.Value = app.Default.Options.GrainsTab.GBs;
app.GrainSelectionButton.Icon = 'add.png';
app.ShowButton.Value = app.Default.Options.GrainsTab.DICFlag;


% ///////////// Curves Tab /////////////
app.LineStyleStyleDropDown.Items = {'-', '--', ':', '-.'};
app.LineStylePanel.Enable = 'off';
app.AxisSettingsPanel.Enable = 'off';
app.StatisticalIntervalsPanel.Enable = 'off';
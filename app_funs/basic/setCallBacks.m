function setCallBacks(app)

% UIFigure
app.UIFigure.SizeChangedFcn = {@UIFigureSizeChangedFcn,app};
app.UIFigure.KeyPressFcn = {@UIFigureKeyPressFcn,app};

% Menus
%   --- Project ---
app.ProjectNewMenu.MenuSelectedFcn = {@ProjectNewMenuSelectedFcn,app};
app.ProjectOpenMenu.MenuSelectedFcn = {@ProjectOpenMenuSelectedFcn,app};
app.ProjectSaveMenu.MenuSelectedFcn = {@ProjectSaveMenuSelectedFcn,app};
app.ProjectClearMenu.MenuSelectedFcn = {@ProjectClearMenuSelectedFcn,app};

%   --- Options ---
app.GBStyleMenu.MenuSelectedFcn = {@GBStyleMenuSelectedFcn,app};
app.GrainLabelsStyleMenu.MenuSelectedFcn = {@GrainLabelsStyleMenuSelectedFcn,app};
app.OverlayOpacityMenu.MenuSelectedFcn = {@OverlayOpacityMenuSelectedFcn,app};
app.MaxResolutionMenu.MenuSelectedFcn = ...
    {@MaxResolutionMenuSelectedFcn,app};
app.DICPreprocessCalculationMethodMenu.MenuSelectedFcn = ...
    {@DICPreprocessCalculationMethodMenuSelectedFcn,app};
app.CLimCoeffMenu.MenuSelectedFcn = ...
        {@CLimCoeffMenuSelectedFcn,app};
app.DICShowAxesMenu.MenuSelectedFcn = {@ShowAxesMenuSelectedFcn,app};
app.ValueRangesMenu.MenuSelectedFcn = {@ValueRangesMenuSelectedFcn,app};
app.GBSmoothDegreeMenu.MenuSelectedFcn = {@GBSmoothDegreeMenuSelectedFcn,app};
app.MinimumGrainSizeMenu.MenuSelectedFcn = {@MinimumGrainSizeMenuSelectedFcn,app};
app.ParallelComputingMenu.MenuSelectedFcn = {@ParallelComputingMenuSelectedFcn,app};
app.EBSDShowAxesMenu.MenuSelectedFcn = {@ShowAxesMenuSelectedFcn,app};
app.ChineseMenu.MenuSelectedFcn = {@LanguageMenuSelectedFcn,app};
app.EnglishMenu.MenuSelectedFcn = {@LanguageMenuSelectedFcn,app};

%   --- Export ---
app.ExportImagesMenu.MenuSelectedFcn = {@ExportImagesMenuSelectedFcn,app};
app.ExportCurvesMenu.MenuSelectedFcn = {@ExportCurvesMenuSelectedFcn,app};
app.ExportDataMenu.MenuSelectedFcn = {@ExportDataMenuSelectedFcn,app};
app.ExportEBSDDataangMenu.MenuSelectedFcn = {@ExportEBSDDataangMenuSelectedFcn,app};
app.ExportABAQUSinputfileinpMenu.MenuSelectedFcn = ...
    {@ExportABAQUSinputfileinpMenuSelectedFcn,app};
% Buttons
app.ButtonFold.ButtonPushedFcn = { @ButtonFoldButtonPushedFcn,app};
% app.CLimManualButton.ButtonPushedFcn = {@CLimManualButtonPushedFcn,app};
app.OverlayDICButton.ValueChangedFcn = {@OverlayDICButtonValueChangedFcn,app};
app.OverlayPolygons.ValueChangedFcn = {@OverlayPolygonsValueChangedFcn,app};
app.StyleButton.ValueChangedFcn = {@StyleButtonValueChangedFcn,app};
app.StatisticButton.ButtonPushedFcn = {@StatisticButtonPushedFcn,app};
app.MonitorButton.ValueChangedFcn = {@MonitorButtonValueChangedFcn,app};

% Dropdowns
app.StageDropDown.ValueChangedFcn = {@StageDropDownValueChangedFcn,app};
app.EBSDDropDown.ValueChangedFcn = {@EBSDDropDownValueChangedFcn,app};

% Tree
app.Tree.SelectionChangedFcn = {@TreeSelectionChangedFcn,app};
% Tree2
app.Tree2.CheckedNodesChangedFcn = {@Tree2CheckedNodesChangedFcn,app};
app.Tree2.SelectionChangedFcn = {@Tree2SelectionChangedFcn,app};

% CLimSlider
% app.CLimSlider.ValueChangedFcn = {@CLimSliderValueChangedFcn,app};

% GrainsTab
app.InteriorCheckBox.ValueChangedFcn = { @InteriorCheckBoxValueChangedFcn, app };
app.FrontierCheckBox.ValueChangedFcn = { @FrontierCheckBoxValueChangedFcn, app };
app.FrontierDevSpinner.ValueChangedFcn = { @FrontierDevSpinnerValueChangedFcn, app };
app.IntrinsicCheckBox.ValueChangedFcn = { @IntrinsicCheckBoxValueChangedFcn, app };
app.GrainSelectionTree.CheckedNodesChangedFcn = ...
    { @GrainSelectionTreeCheckedNodesChangedFcn, app };
app.LabelsCheckBox.ValueChangedFcn = { @LabelsCheckBoxValueChangedFcn, app };
app.NeighboursCheckBox.ValueChangedFcn = { @NeighboursCheckBoxValueChangedFcn, app };
app.GBsCheckBox.ValueChangedFcn = { @GBsCheckBoxValueChangedFcn, app };
app.GBsSmoothButton.ValueChangedFcn = { @GBsSmoothButtonValueChangedFcn, app };
app.DICTree.SelectionChangedFcn = ...
    { @DICTreeSelectionChangedFcn, app };
app.ShowButton.ValueChangedFcn = { @ShowButtonValueChangedFcn, app };
app.GrainSelectionButton.ButtonPushedFcn = {@GrainSelectionButtonPushedFcn,app};
app.GBsDropDown.ValueChangedFcn = {@GBsDropDownValueChangedFcn,app};

% Curves Tab
app.LinePropertiesColorButton.ButtonPushedFcn = ...
    {@LinePropertiesColorButtonPushedFcn,app};
app.LinePropertiesRandomColorButton.ButtonPushedFcn = ...
    {@LinePropertiesRandomColorButtonPushedFcn,app};
app.LineStyleStyleDropDown.ValueChangedFcn = ...
    {@LineStyleStyleDropDownValueChangedFcn,app};
app.LineStyleWidthSpinner.ValueChangedFcn = ...
    {@LineStyleWidthSpinnerValueChangedFcn,app};
app.AxisSettingsXMinEditField.ValueChangedFcn = ...
    {@AxisSettingsXMinEditFieldValueChangedFcn,app};
app.AxisSettingsXMaxEditField.ValueChangedFcn = ...
    {@AxisSettingsXMaxEditFieldValueChangedFcn,app};
app.AxisSettingsYMinEditField.ValueChangedFcn = ...
    {@AxisSettingsYMinEditFieldValueChangedFcn,app};
app.AxisSettingsYMaxEditField.ValueChangedFcn = ...
    {@AxisSettingsYMaxEditFieldValueChangedFcn,app};
app.AxisSettingsAutoButton.ButtonPushedFcn = ...
    {@AxisSettingsAutoButtonPushedFcn,app};
app.StatisticalIntervalsMinEditField.ValueChangedFcn = ...
    {@StatisticalIntervalsMinEditFieldValueChangedFcn,app};
app.StatisticalIntervalsMaxEditField.ValueChangedFcn = ...
    {@StatisticalIntervalsMaxEditFieldValueChangedFcn,app};
app.StatisticalIntervalsNumberSpinner.ValueChangedFcn = ...
    {@StatisticalIntervalsNumberSpinnerValueChangedFcn,app};
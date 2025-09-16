function setDefaultuponClosing( app )

% Store some default values upon closing
app.Default.UIFigureInitialSize = app.UIFigure.Position;
app.Default.AppNameLabelFontSize = app.AppNameLabel.FontSize;
app.Default.Options.EBSDSelection = app.EBSDDropDown.ValueIndex;
app.Default.Options.OverlayDIC = app.OverlayDICButton.Value;

app.Default.Options.GrainsTab.Labels = app.LabelsCheckBox.Value;
app.Default.Options.GrainsTab.Neighbours = app.NeighboursCheckBox.Value;
% app.Default.Options.GrainsTab.InteriorFlag = app.InteriorCheckBox.Value;
% app.Default.Options.GrainsTab.FrontierFlag = app.FrontierCheckBox.Value;
% app.Default.Options.GrainsTab.FrontierDev = app.FrontierDevSpinner.Value;
% app.Default.Options.GrainsTab.IntrinsicFlag = app.IntrinsicCheckBox.Value;

app.Default.Options.GrainsTab.GBs = app.GBsCheckBox.Value;
% if app.OnlyCheckBox.Value
%     app.Default.Options.GrainsTab.DICOption = 'only';
% else; app.Default.Options.GrainsTab.DICOption = 'overlay';
% end
app.Default.Options.GrainsTab.DICFlag = app.ShowButton.Value;
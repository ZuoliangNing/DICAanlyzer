function AxisSettingsAutoButtonPushedFcn( button, ~, app )


axe = app.CurvesTab.UserData.Parent;

axe.XLimMode = 'auto';
axe.YLimMode = 'auto';

app.AxisSettingsXMinEditField.Value = axe.XLim(1);
app.AxisSettingsXMaxEditField.Value = axe.XLim(2);
app.AxisSettingsYMinEditField.Value = axe.YLim(1);
app.AxisSettingsYMaxEditField.Value = axe.YLim(2);

app.TabGroup.SelectedTab = axe.Parent.Parent;
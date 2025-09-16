function AxisSettingsXMaxEditFieldValueChangedFcn( edit, event, app )


axe = app.CurvesTab.UserData.Parent;

if edit.Value <= app.AxisSettingsXMinEditField.Value
    edit.Value = event.PreviousValue;
    return
end

axe.XLim = [ app.AxisSettingsXMinEditField.Value, edit.Value ];

app.TabGroup.SelectedTab = axe.Parent.Parent;
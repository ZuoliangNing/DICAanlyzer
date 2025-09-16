function AxisSettingsXMinEditFieldValueChangedFcn( edit, event, app )


axe = app.CurvesTab.UserData.Parent;

if edit.Value >= app.AxisSettingsXMaxEditField.Value
    edit.Value = event.PreviousValue;
    return
end

axe.XLim = [ edit.Value, app.AxisSettingsXMaxEditField.Value ];

app.TabGroup.SelectedTab = axe.Parent.Parent;
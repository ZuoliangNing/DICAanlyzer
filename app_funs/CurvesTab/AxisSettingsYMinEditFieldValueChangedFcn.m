function AxisSettingsYMinEditFieldValueChangedFcn( edit, event, app )


axe = app.CurvesTab.UserData.Parent;

if edit.Value >= app.AxisSettingsYMaxEditField.Value
    edit.Value = event.PreviousValue;
    return
end

axe.YLim = [ edit.Value, app.AxisSettingsYMaxEditField.Value ];

app.TabGroup.SelectedTab = axe.Parent.Parent;
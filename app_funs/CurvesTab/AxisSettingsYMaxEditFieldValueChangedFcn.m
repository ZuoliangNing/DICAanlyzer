function AxisSettingsYMaxEditFieldValueChangedFcn( edit, event, app )


axe = app.CurvesTab.UserData.Parent;

if edit.Value <= app.AxisSettingsYMinEditField.Value
    edit.Value = event.PreviousValue;
    return
end

axe.YLim = [ app.AxisSettingsYMinEditField.Value, edit.Value ];

app.TabGroup.SelectedTab = axe.Parent.Parent;
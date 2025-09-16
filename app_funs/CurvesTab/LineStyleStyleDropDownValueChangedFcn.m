function LineStyleStyleDropDownValueChangedFcn( dropdown, ~, app )


gobj = app.CurvesTab.UserData;

gobj.LineStyle = dropdown.Value;

app.TabGroup.SelectedTab = gobj.Parent.Parent.Parent;

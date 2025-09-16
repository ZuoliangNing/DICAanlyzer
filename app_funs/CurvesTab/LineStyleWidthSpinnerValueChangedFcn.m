function LineStyleWidthSpinnerValueChangedFcn( spinner, event, app )


gobj = app.CurvesTab.UserData;

if spinner.Value <= 0 
    spinner.Value = 0.5;
end

gobj.LineWidth = spinner.Value;

app.TabGroup.SelectedTab = gobj.Parent.Parent.Parent;
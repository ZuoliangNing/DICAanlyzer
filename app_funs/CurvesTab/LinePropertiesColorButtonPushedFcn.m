function LinePropertiesColorButtonPushedFcn( button, ~, app )


gobj = app.CurvesTab.UserData;

c = uisetcolor();
if ~c; return; end

button.BackgroundColor = c;
gobj.MarkerFaceColor = c;
gobj.Color = c;

app.TabGroup.SelectedTab = gobj.Parent.Parent.Parent;
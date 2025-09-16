function setCurvesTab( gobj, app )


if isempty( gobj )
    app.LineStylePanel.Enable = 'off';
    app.AxisSettingsPanel.Enable = 'off';
    app.StatisticalIntervalsPanel.Enable = 'off';
    app.CurvesTab.UserData = [];
    return
else
    app.LineStylePanel.Enable = 'on';
    app.AxisSettingsPanel.Enable = 'on';
    app.CurvesTab.UserData = gobj;
end

app.LinePropertiesColorButton.BackgroundColor = gobj.Color; % [1,1,1] * 0.96
app.LineStyleWidthSpinner.Value = gobj.LineWidth;
app.LineStyleStyleDropDown.Value = gobj.LineStyle;
axe = gobj.Parent;
app.AxisSettingsXMinEditField.Value = axe.XLim(1);
app.AxisSettingsXMaxEditField.Value = axe.XLim(2);
app.AxisSettingsYMinEditField.Value = axe.YLim(1);
app.AxisSettingsYMaxEditField.Value = axe.YLim(2);

if axe.Tag == '4'
    app.StatisticalIntervalsPanel.Enable = 'on';
    app.StatisticalIntervalsNumberSpinner.Value = gobj.UserData.Number;
    app.StatisticalIntervalsMinEditField.Value = gobj.UserData.Limits(1);
    app.StatisticalIntervalsMaxEditField.Value = gobj.UserData.Limits(2);
else
    app.StatisticalIntervalsPanel.Enable = 'off';
end


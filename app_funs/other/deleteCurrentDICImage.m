function deleteCurrentDICImage( app )


delete( app.CurrentImage )
app.CurrentImage = gobjects(1);

% app.CLimSlider.Enable = 'off';
% app.CLimSliderLabel.Enable = 'off';
% app.CLimManualButton.Enable = 'off';

app.UIAxesImages.Visible = 'off';
app.DICColorbar.Visible = 'off';
% app.UIAxesImages.Toolbar.Visible = 'off';
if app.Default.Options.DICAxesFlag
    app.UIAxesImages.XAxis.Visible = 'off';
    app.UIAxesImages.YAxis.Visible = 'off';
end

app.StageDropDown.Enable = 'off';
app.StageDropDownLabel.Enable = 'off';

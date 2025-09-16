function visualizeDICColorbar( app, opt )

app.DICColorbar.Visible = opt;
app.UIAxesImages.Toolbar.Visible = opt;

app.StageDropDown.Enable = opt;
app.StageDropDownLabel.Enable = opt;

app.CLimSlider.Enable = opt;
app.CLimSliderLabel.Enable = opt;
app.CLimManualButton.Enable = opt;
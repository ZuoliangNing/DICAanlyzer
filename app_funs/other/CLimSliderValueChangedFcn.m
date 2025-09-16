function CLimSliderValueChangedFcn( slider, event, app )

app.UIAxesImages.CLim = slider.Value;
app.DICColorbar.Ticks = linspace( slider.Value(1), slider.Value(2), 5 );
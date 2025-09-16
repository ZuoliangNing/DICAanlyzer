function FrontierCheckBoxValueChangedFcn( cbox, ~, app )

if cbox.Value
    app.Default.Options.GrainsTab.FrontierFlag = true;
    app.IntrinsicCheckBox.Value = false;
    IntrinsicCheckBoxValueChangedFcn( app.IntrinsicCheckBox, [], app )
    app.FrontierDevSpinner.Enable = 'on';
else
    app.Default.Options.GrainsTab.FrontierFlag = false;
    app.FrontierDevSpinner.Enable = 'off';
end

refreshCurrentImage2(app)
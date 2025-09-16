function IntrinsicCheckBoxValueChangedFcn( cbox, ~, app )

if cbox.Value
    app.Default.Options.GrainsTab.IntrinsicFlag = true;
    app.InteriorCheckBox.Value = false;
    InteriorCheckBoxValueChangedFcn( app.InteriorCheckBox, [], app )
    app.FrontierCheckBox.Value = false;
    FrontierCheckBoxValueChangedFcn( app.FrontierCheckBox, [], app )
else
    app.Default.Options.GrainsTab.IntrinsicFlag = false;
end

refreshCurrentImage2(app)
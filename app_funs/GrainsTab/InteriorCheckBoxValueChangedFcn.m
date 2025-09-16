function InteriorCheckBoxValueChangedFcn( cbox, ~, app )

if cbox.Value
    app.Default.Options.GrainsTab.InteriorFlag = true;
    app.IntrinsicCheckBox.Value = false;
    IntrinsicCheckBoxValueChangedFcn( app.IntrinsicCheckBox, [], app )
else
    app.Default.Options.GrainsTab.InteriorFlag = false;
end

refreshCurrentImage2(app)
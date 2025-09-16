function ShowButtonValueChangedFcn( button, ~, app )

if button.Value

    app.DICTree.Enable = 'on';
    app.Default.Options.GrainsTab.DICFlag = true;

    app.StageDropDownLabel.Enable = 'on';
    app.StageDropDown.Enable = 'on';
else

    app.DICTree.Enable = 'off';
    app.Default.Options.GrainsTab.DICFlag = false;

    app.StageDropDownLabel.Enable = 'off';
    app.StageDropDown.Enable = 'off';
    
end

refreshCurrentImage2(app)
function GBsCheckBoxValueChangedFcn( cbox, ~, app )

if cbox.Value

    ProjectIndex = getProjectIndex( app.CurrentProjectSelection, app );
    obj = app.Projects( ProjectIndex );
    EBSDIndex = getEBSDIndex( app.CurrentEBSDSelection, obj );
    % EBSDIndex = app.CurrentEBSDSelection;
    EBSDData = obj.EBSD.Data( EBSDIndex );

    plotEBSDGBs( app, EBSDData )

    app.GBsSmoothButton.Enable = 'on';
    app.GBsDropDown.Enable = 'on';
else
    delete( app.GBsPlot )
    app.GBsSmoothButton.Enable = 'off';
    app.GBsDropDown.Enable = 'off';
end
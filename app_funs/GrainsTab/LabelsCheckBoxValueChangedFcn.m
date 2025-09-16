function LabelsCheckBoxValueChangedFcn( cbox, ~, app )


if cbox.Value

    ProjectIndex = getProjectIndex( app.CurrentProjectSelection, app );
    obj = app.Projects( ProjectIndex );
    EBSDIndex = getEBSDIndex( app.CurrentEBSDSelection, obj );
    % EBSDIndex = app.CurrentEBSDSelection;
    EBSDData = obj.EBSD.Data( EBSDIndex );

    plotEBSDGrainLabels( app, EBSDData )

else
    delete( app.GrainLabels )
end
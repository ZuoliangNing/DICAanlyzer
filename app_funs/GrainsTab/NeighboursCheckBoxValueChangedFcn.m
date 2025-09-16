function NeighboursCheckBoxValueChangedFcn( cbox, ~, app )


Node = app.Tree.SelectedNodes;
ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
obj = app.Projects( ProjectIndex );
EBSDIndex = getEBSDIndex( Node.NodeData.EBSDSerial, obj );
EBSDData = obj.EBSD.Data( EBSDIndex );

if cbox.Value
    app.Default.Options.GrainsTab.Neighbours = true;
else
    app.Default.Options.GrainsTab.Neighbours = false;
end

refreshCurrentImage2(app)
if app.LabelsCheckBox.Value
    plotEBSDGrainLabels( app, EBSDData )
end
if app.GBsCheckBox.Value
    plotEBSDGBs( app, EBSDData )
end
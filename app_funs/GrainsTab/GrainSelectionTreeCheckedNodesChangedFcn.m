function GrainSelectionTreeCheckedNodesChangedFcn( tree, ~, app )


Node = app.Tree.SelectedNodes;
ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
obj = app.Projects( ProjectIndex );
EBSDIndex = getEBSDIndex( Node.NodeData.EBSDSerial, obj );
EBSDData = obj.EBSD.Data( EBSDIndex );

if ~isempty( tree.CheckedNodes )

    EBSDData.GrainSelection = unique([ tree.CheckedNodes.UserData ]);
    EBSDData.GrainGroupSelection = [ tree.CheckedNodes.NodeData ];
else
    EBSDData.GrainSelection = [];
end

obj.EBSD.Data( EBSDIndex ) = EBSDData;
app.Projects( ProjectIndex ) = obj;

refreshCurrentImage2(app)
if app.LabelsCheckBox.Value
    plotEBSDGrainLabels( app, EBSDData )
end
if app.GBsCheckBox.Value
    plotEBSDGBs( app, EBSDData )
end
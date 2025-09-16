function DICTreeSelectionChangedFcn( tree, ~, app )


Node = app.Tree.SelectedNodes;
ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
obj = app.Projects( ProjectIndex );

app.Projects( ProjectIndex ).EBSD.Data( ...
    getEBSDIndex( Node.NodeData.EBSDSerial, obj ) ...
    ).DICSelection = tree.SelectedNodes.NodeData;

refreshCurrentImage2(app)

app.TabGroup.SelectedTab = app.Images2Tab;
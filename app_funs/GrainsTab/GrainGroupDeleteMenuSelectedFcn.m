function GrainGroupDeleteMenuSelectedFcn( menu, ~, app )


Node = app.Tree.SelectedNodes;
ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
obj = app.Projects( ProjectIndex );
EBSDIndex = getEBSDIndex( Node.NodeData.EBSDSerial, obj );
EBSDData = obj.EBSD.Data( EBSDIndex );

node = app.UIFigure.CurrentObject;
EBSDData.GrainGroup( node.NodeData == ....
    [app.GrainSelectionTree.Children.NodeData] ) = [];
EBSDData.GrainGroupSelection = setdiff( ...
    EBSDData.GrainGroupSelection, node.NodeData );
temp = app.GBsDropDown.Value;
app.GBsDropDown.Items = setdiff( app.GBsDropDown.Items, node.Text );
if ~strcmp( temp, app.GBsDropDown.Value )
    GBsCheckBoxValueChangedFcn( app.GBsCheckBox, [], app )
end
delete( node )

GrainSelectionTreeCheckedNodesChangedFcn( app.GrainSelectionTree, [], app )

obj.EBSD.Data( EBSDIndex ) = EBSDData;
app.Projects( ProjectIndex ) = obj;


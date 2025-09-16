function Tree2CheckedNodesChangedFcn( tree, event, app )


AllNodes = vertcat( tree.Children.Children );
SelectedNodes = setdiff( tree.CheckedNodes, tree.Children );
NotSelectedNodes = setdiff( AllNodes, SelectedNodes );

arrayfun( @(node) set( node.NodeData, 'Visible', 'on' ), SelectedNodes )
arrayfun( @(node) set( node.NodeData, 'Visible', 'off' ), NotSelectedNodes )


% axe = node.NodeData.Parent;
% app.TabGroup.SelectedTab = axe.Parent.Parent;
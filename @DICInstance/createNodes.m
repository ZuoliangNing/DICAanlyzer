function obj = createNodes( obj, app )

% ----- NODES -----
% Tree -Main
TreeMainNode = uitreenode( app.Tree, ...
    'Text', obj.DisplayName, ...
    'UserData', struct( 'Parent', 'Tree', 'NodeType', 'Main' ), ...
    'NodeData', struct( 'Serial', obj.Serial, 'Enable', true ) );
TreeMainNode.ContextMenu = app.TreeContextMenu.Main;
% TreeMainNode.Icon = 'ellipsis.png';
obj.TreeNodes.Main = TreeMainNode;

AllTreeNodeTypes = fieldnames( app.TreeNodeTypes );
for i = 2:length( AllTreeNodeTypes )
    NodeType = AllTreeNodeTypes{i};
    Node = uitreenode( TreeMainNode, ...
        'UserData', struct( ...
            'Parent', 'Tree', 'NodeType', NodeType ), ...
        'NodeData', struct( ...
            'Serial', obj.Serial, 'Enable', false ), ...
        'ContextMenu', app.TreeContextMenu.(NodeType) );
    obj.TreeNodes.(NodeType) = Node;
end

setNodesText( app, obj )

temp = struct2array( obj.TreeNodes );
EnableDisableNode( app, temp(2:end), 'off' )

expand( TreeMainNode )

% Tree2
Tree2MainNode = uitreenode( app.Tree2, ...
    'Text', obj.DisplayName, ...
    'UserData', struct( 'Parent', 'Tree2', 'NodeType', 'Main' ), ...
    'NodeData', struct( 'Serial', obj.Serial, 'Enable', true ) );
obj.Tree2Nodes = struct( 'Main', Tree2MainNode );

expand( Tree2MainNode )
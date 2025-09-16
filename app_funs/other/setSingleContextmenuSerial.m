function setSingleContextmenuSerial( contextmenu, app )

SelectedNode = app.UIFigure.CurrentObject;
RootNode = getRootNode( SelectedNode );
contextmenu.UserData.Serial = RootNode.NodeData.Serial;
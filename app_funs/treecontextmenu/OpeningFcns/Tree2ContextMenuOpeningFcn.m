function Tree2ContextMenuOpeningFcn( contextmenu, ~, app )


Node = app.Tree2.SelectedNodes;

if isstruct( Node.UserData )
    contextmenu.Children.Enable = 'off';
else; contextmenu.Children.Enable = 'on';
end
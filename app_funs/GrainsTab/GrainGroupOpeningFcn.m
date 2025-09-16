function GrainGroupOpeningFcn( contextmenu, ~, app )

node = app.UIFigure.CurrentObject;
if strcmp( node.Text, 'All' )
    contextmenu.Children.Enable ='off';
else
    contextmenu.Children.Enable ='on';
end
function Tree2DeleteMenuSelectedFcn( menu, ~, app )


Node = app.UIFigure.CurrentObject;

ProjectIndex = getProjectIndex( Node.Parent.NodeData.Serial, app );
obj = app.Projects( ProjectIndex );

StatisticResultIndex = getStatisticResultIndex( Node.UserData, obj );
StatisticResult = obj.StatisticResults( StatisticResultIndex );

delete( StatisticResult.GraphicObject )
delete( StatisticResult.StatisticObject )
delete( StatisticResult.Nodes )

obj.StatisticResults( StatisticResultIndex ) = [];
app.Projects( ProjectIndex ) = obj;

Tree2SelectionChangedFcn( app.Tree2, [], app )
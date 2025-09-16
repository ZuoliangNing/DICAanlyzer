function Tree2SelectionChangedFcn( tree, ~, app )


Node = tree.SelectedNodes;

removeStyle( tree )

% set colors of all 'GraphicObjects' to 'white'
for axe = [ app.UIAxesImages, app.UIAxesImages2 ]
    ind = arrayfun( @(obj) ...
        strcmp( obj.UserData, 'GraphicObject'), axe.Children );
    for gobj = axe.Children( ind )'
        if isa( gobj, 'matlab.graphics.primitive.Rectangle' )
            gobj.EdgeColor = 'w';
        else; gobj.Color = 'w';
        end
    end
end

% 'Main' node selected
if isempty( Node ) || isstruct( Node.UserData )
    setCurvesTab( [], app )
    return
end

% get the selected 'StatisticResult'
ProjectIndex = getProjectIndex( Node.Parent.NodeData.Serial, app );
obj = app.Projects( ProjectIndex );
StatisticResultIndex = getStatisticResultIndex( Node.UserData, obj );
StatisticResult = obj.StatisticResults( StatisticResultIndex );

% highlight in 'Tree2'
%   --- all nodes that belonged to this 'StatisticResult'
s = uistyle( 'FontWeight', 'bold', ...
             'BackgroundColor', 0.8*[1,1,1]);
addStyle( tree, s, 'node', vertcat( Node, StatisticResult.Nodes ) );

% highlight the 'GraphicObject' of this 'StatisticResult'
if ishandle( StatisticResult.GraphicObject )
    if strcmp( StatisticResult.Type, 'line' )
        StatisticResult.GraphicObject(1).Color = 'r';
    else
        StatisticResult.GraphicObject(1).EdgeColor = 'r';
    end
    StatisticResult.GraphicObject(2).Color = 'r';
end

% enable and set 'CurvesTab'
setCurvesTab( Node.NodeData, app )

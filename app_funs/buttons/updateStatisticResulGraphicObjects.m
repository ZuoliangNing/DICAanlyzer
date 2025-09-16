function updateStatisticResulGraphicObjects( ProjectIndex, Node, app )


obj = app.Projects( ProjectIndex );
if isempty( obj.Tree2Nodes.Main.Children ); return; end


StatisticResults = obj.StatisticResults;

if strcmp( Node.UserData.NodeType, 'EBSDData' )
    ind = Node.NodeData.EBSDSerial == [ StatisticResults.EBSDSerial ];
    axe = app.UIAxesImages2;
else
    ind = strcmp( 'DICData', {StatisticResults.NodeType} );
    axe = app.UIAxesImages;
end

if ~any(ind); return; end


Size = [ obj.DIC.XData(end), obj.DIC.YData(end) ];
obj.StatisticResults( ind ) = arrayfun( @(StatisticResult) ...
    createGraphicObject( ...
        StatisticResult, Size, axe ), StatisticResults( ind ) );


app.Projects( ProjectIndex ) = obj;
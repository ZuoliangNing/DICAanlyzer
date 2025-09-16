function StatisticalIntervalsMaxEditFieldValueChangedFcn( edit, event, app )


if edit.Value <= app.StatisticalIntervalsMinEditField.Value
    edit.Value = event.PreviousValue;
    return
end

Node = app.Tree2.SelectedNodes;
ProjectIndex = getProjectIndex( Node.Parent.NodeData.Serial, app );
obj = app.Projects( ProjectIndex );
StatisticResultIndex = getStatisticResultIndex( Node.UserData, obj );
StatisticResult = obj.StatisticResults( StatisticResultIndex );


Limits = [ app.StatisticalIntervalsMinEditField.Value, edit.Value ];
for i = 1:length( StatisticResult.StatisticObject )
    gobj = StatisticResult.StatisticObject(i);
    N = gobj.UserData.Number;
    [ LineValue, edges ] = histcounts( ...
        gobj.UserData.Data, ...
        'NumBins', N, ...
        'BinLimits', Limits, ...
        'Normalization', 'percentage' ); % percentage pdf cdf cumcount
    x = ( edges(1:end-1) + edges(2:end) ) / 2;
    gobj.XData = x;
    gobj.YData = LineValue;
    gobj.UserData.Limits = Limits;
end

app.TabGroup.SelectedTab = gobj.Parent.Parent.Parent;
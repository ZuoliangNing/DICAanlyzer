function load( FileName, app )

load( FileName, 'obj' )

app.Serial = app.Serial + 1;
obj.Serial = app.Serial;

obj = obj.createNodes( app );
if obj.Flag.DICPreprocess
    EnableDisableNode( app, obj.TreeNodes.DIC, 'on' )
    % DIC Nodes
    obj = createDICNodes( obj, app );
end
% EBSD Nodes
if obj.Flag.EBSDData
    EnableDisableNode( app, obj.TreeNodes.EBSD, 'on' )
    DefaultEBSDVariables = app.ConstantValues.EBSDVariables;
    DefaultEBSDVariableNames = app.ConstantValues.EBSDVariableNames ...
        ( app.Default.LanguageSelection );
    for i = 1:length(obj.EBSD.Data)
        EBSDData = obj.EBSD.Data(i);
        NodeEBSD2 = uitreenode( obj.TreeNodes.EBSD, ...
            'Text',         EBSDData.DisplayName, ...
            'UserData',     struct( 'Parent',       'Tree', ...
                                    'NodeType',     'EBSD2' ), ...
            'NodeData',     struct( 'Serial', obj.Serial, ...
                                    'Enable', true, ...
                                    'EBSDSerial', EBSDData.Serial ), ...
            'ContextMenu',  app.TreeContextMenu.EBSD2 );
        obj.TreeNodes.EBSD2 = [ obj.TreeNodes.EBSD2, NodeEBSD2 ];
        for j = 1:length(DefaultEBSDVariables)
            VariableName = DefaultEBSDVariables{j};
            Node = uitreenode( NodeEBSD2, ...
                'Text',         DefaultEBSDVariableNames.( VariableName ), ...
                'UserData',     struct( 'Parent',       'Tree', ...
                                        'NodeType',     'EBSDData', ...
                                        'VariableName',  VariableName ), ...
                'NodeData',     struct( 'Serial', obj.Serial, ...
                                        'Enable', true, ...
                                        'EBSDSerial', EBSDData.Serial ));
            if ~isempty( EBSDData.(VariableName) )
                EnableDisableNode( app, Node, 'on' )
            else;  EnableDisableNode( app, Node, 'off' )
            end
            obj.TreeNodes.EBSDData(i).(VariableName) = Node;
        end
    end
end

% Statistic Results

ind = find( arrayfun( @(sr) ~isempty( sr.NodeType ), obj.StatisticResults ) );

for n = ind
    sr = obj.StatisticResults(n);
    for i = 1:length( sr.StatisticObject )
        obj.StatisticResults(n).Nodes(i,1) = uitreenode( ...
            obj.Tree2Nodes.Main, ...
            'Text', sr.StatisticObject(i).DisplayName, ...
            'NodeData', sr.StatisticObject(i), ...
            'UserData', sr.Serial, ...
            'ContextMenu', app.Tree2ContextMenu );
        if isstruct( sr.StatisticObject(i).UserData )
            sr.StatisticObject(i).Parent = app.UIAxesFrequency;
        else
            sr.StatisticObject(i).Parent = app.UIAxesValue;
        end
        sr.StatisticObject(i).Visible = 'off';
    end

end


app.Projects = [ app.Projects, obj ];
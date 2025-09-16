function createbyBounding( obj, Name, Bounding, ...
            EBSDDataind, DICFlag, EBSDVariables, app, dlg )


EBSDData = obj.EBSD.Data(EBSDDataind);
xmin = min(Bounding([1,3])); xmax = max(Bounding([1,3]));
ymin = min(Bounding([2,4])); ymax = max(Bounding([2,4]));

colind = EBSDData.XData >= xmin & EBSDData.XData <= xmax;
rowind = EBSDData.YData >= ymin & EBSDData.YData <= ymax;

% 'EulerAngles' is not included in 'app.ConstantValues.EBSDVariables'
% 'Coords' is useless
EBSDVariables = setdiff([EBSDVariables,'EulerAngles','AlphaData'],'IPF');
for i = 1:length(EBSDVariables)
    if ~isempty( EBSDData.(EBSDVariables{i}) )
        EBSDData.(EBSDVariables{i}) = ...
            EBSDData.(EBSDVariables{i})( rowind, colind, : );
    end
end
for i = 1:3
    EBSDData.IPF{i} = EBSDData.IPF{i}( rowind, colind, : );
end
EBSDData.XData = EBSDData.XData( colind );
EBSDData.YData = EBSDData.YData( rowind );
% EBSDData.XData = EBSDData.XData - EBSDData.XData(1);
% EBSDData.YData = EBSDData.YData - EBSDData.YData(1);
Size0 = EBSDData.DataSize;
Size = size( EBSDData.IPF{3}, 1, 2 );
EBSDData.DataSize = [ Size, prod(Size) ];

if EBSDData.Flag.Polygonized

    EBSDData.Map = EBSDData.Map.duplicate;
    map = EBSDData.Map;

    EBSDData = map.cropmapEBSDData( EBSDData, [], dlg );



    allIDs = [map.grains.ID];
    Names = {'IntrinsicInds','InteriorInds'};
    for i = 1:2
        Data = nan( Size0(1:2) );
        val = cell2mat( arrayfun( @(g) ...
            [ g.(Names{i}), ...
              find( g.ID == allIDs ) * ones(size(g.(Names{i}))) ], ...
            map.grains, 'UniformOutput', false ));
        Data( val(:,1) ) = val(:,2);
        Data = Data( rowind, colind );
        Inds = find( ~isnan( Data ) );
        newval = [ Inds, Data( Inds ) ];
        ActiveGrainInd = unique( newval(:,2) );
        IdleGrainInd = setdiff( 1:map.numgrains, ActiveGrainInd );
        arrayfun( @(j) set( map.grains(j), ...
            Names{i}, ...
            newval( newval(:,2) == j, 1 ) ), ...
            ActiveGrainInd )
        arrayfun( @(j) set( map.grains(j), ...
            Names{i}, [] ), IdleGrainInd )
    end
    for i = 1:map.numgrains
        temp = false( Size0(1:2) );
        OldIndex = map.grains(i).FrontierInds;
        temp( OldIndex ) = true;
        temp = temp( rowind, colind );
        map.grains(i).FrontierInds = find(temp);
    end


    % convert 'IntrinsicInds' / 'InteriorInds' / 'FrontierInds'
    % Names = {'IntrinsicInds','InteriorInds','FrontierInds'};
    % for i = 1:map.numgrains
    %     for j = 1:3
    %         temp = false( Size0(1:2) );
    %         OldIndex = map.grains(i).(Names{j});
    %         temp( OldIndex ) = true;
    %         temp = temp( rowind, colind );
    %         map.grains(i).(Names{j}) = find(temp);
    %     end
    % end

    allIntrinsicInds = unique(vertcat( map.grains.IntrinsicInds ));
    allHasvalueInds = find( EBSDData.AlphaData );
    if numel( allIntrinsicInds ) < numel( allHasvalueInds )
        UnallocatedInds = setdiff( ...
            allHasvalueInds, allIntrinsicInds );
        N = numel( UnallocatedInds );
        [ x, y ] = arrayfun( @(g) g.polygon.centroid, map.grains );
        Centroids = [x';y'];
        [X,Y] = meshgrid( EBSDData.XData, EBSDData.YData );
        X = X(:); Y = Y(:);
        for i = 1:N
            Distance = vecnorm( ...
                [ X( UnallocatedInds(i) ); Y( UnallocatedInds(i) ) ] ...
                    - Centroids );
            [ ~, ind ] = min( Distance );
            map.grains( ind(1) ).IntrinsicInds = [ ...
                map.grains( ind(1) ).IntrinsicInds; UnallocatedInds(i) ];
        end
    end

    % smooth GBs
    map.grains.smoothgb( {map.GBSmoothDegree}, dlg, app.TextArea )

end

% ************ CREATE INSTANCE ************

Newobj = DICInstance( Name, app );
S = whos('EBSDData');
EBSDData.MemorySize = S.bytes * 1e-6;
Newobj.EBSD.Data = EBSDData;
% EBSD Nodes
EnableDisableNode( app, Newobj.TreeNodes.EBSD, 'on' )
DefaultEBSDVariables = app.ConstantValues.EBSDVariables;
DefaultEBSDVariableNames = app.ConstantValues.EBSDVariableNames ...
    ( app.Default.LanguageSelection );
NodeEBSD2 = uitreenode( Newobj.TreeNodes.EBSD, ...
    'Text',         EBSDData.DisplayName, ...
    'UserData',     struct( 'Parent',       'Tree', ...
                            'NodeType',     'EBSD2' ), ...
    'NodeData',     struct( 'Serial', Newobj.Serial, ...
                            'Enable', true, ...
                            'EBSDSerial', EBSDData.Serial ), ...
    'ContextMenu',  app.TreeContextMenu.EBSD2 );
Newobj.TreeNodes.EBSD2 = [ Newobj.TreeNodes.EBSD2, NodeEBSD2 ];
for j = 1:length(DefaultEBSDVariables)
    VariableName = DefaultEBSDVariables{j};
    Node = uitreenode( NodeEBSD2, ...
        'Text',         DefaultEBSDVariableNames.( VariableName ), ...
        'UserData',     struct( 'Parent',       'Tree', ...
                                'NodeType',     'EBSDData', ...
                                'VariableName',  VariableName ), ...
        'NodeData',     struct( 'Serial', Newobj.Serial, ...
                                'Enable', true, ...
                                'EBSDSerial', EBSDData.Serial ));
    if ~isempty( EBSDData.(VariableName) )
        EnableDisableNode( app, Node, 'on' )
    else;  EnableDisableNode( app, Node, 'off' )
    end
    Newobj.TreeNodes.EBSDData.(VariableName) = Node;
end
Newobj.Flag.EBSDData = 1;
expand(Newobj.TreeNodes.EBSD)
expand(NodeEBSD2)

% DIC
if DICFlag
    Newobj.DIC = obj.DIC;
    
    Names = fieldnames(Newobj.DIC.Data);
    for i = 1:Newobj.DIC.StageNumber
        for name = Names'
            Newobj.DIC.Data(i).(name{1}) = ...
                Newobj.DIC.Data(i).(name{1})( rowind, colind );
        end
    end

    Newobj.DIC.XData = Newobj.DIC.XData( colind );
    Newobj.DIC.YData = Newobj.DIC.YData( rowind );
    Newobj.DIC.DataSize = EBSDData.DataSize;

    % set disp at origin to 0
    for n = 1 : Newobj.DIC.StageNumber

        tempU = restoreData( Newobj.DIC.Data(n).u, ...
            Newobj.DIC.DataValueRange.u );
        Newobj.DIC.Data(n).u = simplifyData( ...
            tempU - tempU(1,1), ...
            Newobj.DIC.DataValueRange.u );
        tempV = restoreData( Newobj.DIC.Data(n).v, ...
            Newobj.DIC.DataValueRange.v );
        Newobj.DIC.Data(n).v = simplifyData( ...
            tempV - tempV(1,1), ...
            Newobj.DIC.DataValueRange.v );

        % Newobj.DIC.Data(n).u = Newobj.DIC.Data(n).u ...
        %     - Newobj.DIC.Data(n).u(1,1);
        % Newobj.DIC.Data(n).v = Newobj.DIC.Data(n).v ...
        %     - Newobj.DIC.Data(n).v(1,1);
    end

    DIC = Newobj.DIC;
    S = whos('DIC');
    Newobj.DIC.MemorySize = S.bytes * 1e-6;

    EnableDisableNode( app, Newobj.TreeNodes.DIC, 'on' )
    Newobj = createDICNodes( Newobj, app );
    Newobj.Flag.DICPreprocess = 1;
    % expand(Newobj.TreeNodes.DIC)
end

if EBSDData.Flag.Polygonized
    Newobj.Flag.Polygonize = 1;
end

% Ending
app.Projects(end) = Newobj;
expand(Newobj.TreeNodes.Main)
scroll(app.Tree,'bottom')
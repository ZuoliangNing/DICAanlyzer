function createReigonStatistic( Name, Flag, app )


ProjectIndex = getProjectIndex( app.CurrentProjectSelection, app );
Node = app.Tree.SelectedNodes;
if strcmp( Node.UserData.NodeType, 'DICData' )
    axe = app.UIAxesImages;
    Variable = Node.UserData.VariableName;
    app.CurrentImage.ContextMenu = '';
else
    axe = app.UIAxesImages2;
    Variable = app.DICTree.SelectedNodes.NodeData;
    app.CurrentImage2.ContextMenu = '';
end

axe.UserData = struct( ...
    'Lines', gobjects(1), ...
    'Pos1', [], ...
    'Pos2', [], ...
    'ContextMenu', axe.Children(end).ContextMenu );


if strcmp( Flag.ReigonMethod, 'whole' )

    ManualFlag = false;
    tempDIC = app.Projects( ProjectIndex ).DIC;
    axe.UserData.Pos1 = [ tempDIC.XData(1), tempDIC.YData(1) ];
    axe.UserData.Pos2 = [ tempDIC.XData(end), tempDIC.YData(end) ];
    createReigonStatisticCompleteMenuSelectedFcn( [], [], axe )
    
else

    ManualFlag = true;
    OldEnableStates = setUIsOff( app );

    cm = uicontextmenu( app.UIFigure );
    uimenu( cm, ...
        'Text', app.OtherDisplayNames( app.Default.LanguageSelection ). ...
                    Adjust_Complete, ...
        'MenuSelectedFcn', ...
            {@ createReigonStatisticCompleteMenuSelectedFcn, axe} )
    
    app.UIFigure.WindowButtonMotionFcn = ...
        { @ createReigonStatistic_WindowButtonMotionFcn, axe, app };
    app.UIFigure.KeyPressFcn = ...
        { @ createReigonStatistic_KeyPressFcn, axe, OldEnableStates, app };
    app.UIFigure.WindowButtonDownFcn = ...
        { @ createReigonStatistic_WindowButtonDownFcn, axe, app, cm };

end


% ---------- WindowButtonMotionFcn ----------
function createReigonStatistic_WindowButtonMotionFcn( ~, ~, axe, app )

    if ~strcmp( app.TabGroup.SelectedTab.Tag, axe.Tag )
        app.TabGroup.SelectedTab = axe.Parent.Parent;
    end

    pos = axe.CurrentPoint( 1, 1:2 );

    pos(1) = max( pos(1), axe.XLim(1) );
    pos(1) = min( pos(1), axe.XLim(2) );
    pos(2) = max( pos(2), axe.YLim(1) );
    pos(2) = min( pos(2), axe.YLim(2) );

    if ~isempty( axe.UserData.Pos1 ) && isempty( axe.UserData.Pos2 )
        delete(axe.UserData.Lines)
        pos1 = axe.UserData.Pos1;
        w = abs( pos(1) - pos1(1) );
        h = abs( pos(2) - pos1(2) );
        x = min([pos1(1),pos(1)]);
        y = min([pos1(2),pos(2)]);
        axe.UserData.Lines = rectangle( axe, ...
            'Position', [x,y,w,h], ...
            'EdgeColor', 'w', 'LineWidth', 2 );
    end

end


% ---------- WindowButtonDownFcn ----------
function createReigonStatistic_WindowButtonDownFcn( fig, ~, axe, app, cm )

    if ~strcmp( app.TabGroup.SelectedTab.Tag, axe.Tag )
        app.TabGroup.SelectedTab = axe.Parent.Parent;
    end
    if ~strcmp( fig.SelectionType, 'normal' ); return; end

    pos = axe.CurrentPoint( 1, 1:2 );

    pos(1) = max( pos(1), axe.XLim(1) );
    pos(1) = min( pos(1), axe.XLim(2) );
    pos(2) = max( pos(2), axe.YLim(1) );
    pos(2) = min( pos(2), axe.YLim(2) );

    if isempty( axe.UserData.Pos1 )
        axe.UserData.Pos1 = pos;
    else
        axe.UserData.Pos2 = pos;
        axe.Children(end).ContextMenu = cm;
    end

end


% ---------- KeyPressFcn ----------
function createReigonStatistic_KeyPressFcn( ~, event, axe, OldEnableStates, app )
    if strcmp( event.Key, 'escape' )
        delete( axe.UserData.Lines )
        setUIsOn( OldEnableStates, app )
        app.UIFigure.WindowButtonMotionFcn = '';
        app.UIFigure.WindowButtonDownFcn = '';
        app.UIFigure.KeyPressFcn = { @ UIFigureKeyPressFcn, app };
        axe.Children(end).ContextMenu = axe.UserData.ContextMenu;
        axe.UserData = [];
        app.StatisticUIFigure.Visible = 'on';
        app.StatisticUIFigure.WindowStyle = 'modal';
    end
end


% ---------- createReigonStatisticCompleteMenu ----------
function createReigonStatisticCompleteMenuSelectedFcn( ~, ~, axe )

    % --------- Preparing data ---------
    obj = app.Projects( ProjectIndex );
    DIC = obj.DIC;

    StatisticResult.DisplayName = Name;
    if strcmp( Node.UserData.NodeType, 'DICData' )
        StatisticResult.EBSDSerial = nan;
        StatisticResult.NodeType = 'DICData';
        EBSDData = [];
    else
        StatisticResult.EBSDSerial = app.CurrentEBSDSelection;
        StatisticResult.NodeType = 'EBSDData';
        EBSDData = obj.EBSD.Data( ...
            getEBSDIndex( app.CurrentEBSDSelection, obj ) );
    end

    % --------- set UIs ---------
    if ManualFlag
        delete(axe.UserData.Lines)
        setUIsOn( OldEnableStates, app )
        app.UIFigure.WindowButtonMotionFcn = '';
        app.UIFigure.WindowButtonDownFcn = '';
        app.UIFigure.KeyPressFcn = { @UIFigureKeyPressFcn, app };
        axe.Children(end).ContextMenu = app.UIAxesContextMenu;
    end

    Pos1 = axe.UserData.Pos1;
    Pos2 = axe.UserData.Pos2;
    axe.UserData = [];
    delete( app.StatisticUIFigure )


    % -------------------------------------------
    % --------- create StatisticObjects ---------
    % -------------------------------------------

    StatisticObjectLinWidth = app.Default.Options.ReigonStatisticLineWidth;
    Colors = app.ConstantValues.Colormaps{2};
    Markers = { 's','o','^','v','>','<','+','*','.','x','_','|', ...
        'square','diamond','pentagram','hexagram' };

    obj.StatisticResultsSerial = obj.StatisticResultsSerial + 1;
    StatisticResult.Serial = obj.StatisticResultsSerial;

    % ----- GRAPHIC objects -----
    StatisticResult.Type = 'reigon';
    StatisticResult.Pos = [ Pos1; Pos2 ];
    Size = [ DIC.XData(end), DIC.YData(end) ];
    StatisticResult = createGraphicObject( ...
        StatisticResult, Size, axe );

    % ----- STATISTIC Objects -----
    N = 100;
    xran = sort( [ Pos1(1), Pos2(1) ] );
    yran = sort( [ Pos1(2), Pos2(2) ] );
    indCol = DIC.XData >= xran(1) & DIC.XData <= xran(2);
    indRow = DIC.YData >= yran(1) & DIC.YData <= yran(2);
    % PixelNumber = length(indx) * length(indy);

    if Flag.AllStage;   AllStages = 1:DIC.StageNumber;
    else;               AllStages = obj.StageSelection; % !!!
    end

    if Flag.AllStage && ( ...
            ( Flag.Phases && length( EBSDData.PhaseNames )>1 ) ...
            || Flag.GrainPartition )
        uiprogressdlg( app.UIFigure, 'Indeterminate', 'on' );
    end

    if Flag.GrainPartition

        if Flag.GrainPartitionShow
            fig = figure( 'NumberTitle', 'off', ...
                'Name', [obj.DisplayName,': ',Name] );
            t = tiledlayout( fig, 'flow' );
            % axe = axes( fig, 'NextPlot', 'add' );
            % colors = [ 1,0,0; 0,0,1 ];
            % rat = 0.5;
            % fdark = @(val) val*rat;
            % flight = @(val) val*rat + [1,1,1]*(1-rat);
            % c = { flight( colors(1,:) ), fdark( colors(1,:) ); ...
            %       flight( colors(2,:) ), fdark( colors(2,:) ) };
        end
        FrontierDev = Flag.GrainPartitionCoeff;
        map = EBSDData.Map;
        GBName = [ '-GB(',num2str(FrontierDev),')' ];
        GMName = [ '-GM(',num2str(FrontierDev),')' ];
        if Flag.Whole
            GrainSelection = 1:length( map.grains );
            ind = ExtendFrontierInds( ...
                map, GrainSelection, ...
                EBSDData.DataSize(1:2), FrontierDev );
            IndFrontier = false( EBSDData.DataSize(1:2) );
            IndFrontier( ind ) = true;
            IndFrontier = IndFrontier & EBSDData.AlphaData;
            IndInterior = ~IndFrontier;
            IndInterior = IndInterior & EBSDData.AlphaData;
            if Flag.GrainPartitionShow
                DisplayName = [ Name, '-Whole' ];
                axe = nexttile(t);
                val = IndFrontier( indRow, indCol );
                image( axe, val, ...
                    'CDataMapping', 'scaled', ...
                    'AlphaData', val )
                axe.Title.String = [ DisplayName, GBName ];
                axe = nexttile(t);
                % AlphaData = zeros( length(indRow), length(indCol) );
                val = IndInterior( indRow, indCol );
                image( axe, val, ...
                    'CDataMapping', 'scaled', ...
                    'AlphaData', val )
                axe.Title.String = [ DisplayName, GMName ];
            end
        end

        if Flag.Phases
            [ PhaseIndFrontier, PhaseIndInterior ] = deal( ...
                cell( 1, length( EBSDData.PhaseNames ) ) );
            for i = 1:length( EBSDData.PhaseNames )
                GrainSelection = find( [map.grains.phase] == i );
                ind = ExtendFrontierInds( ...
                    map, GrainSelection, ...
                    EBSDData.DataSize(1:2), FrontierDev );
                PhaseIndFrontier{i} = false( EBSDData.DataSize(1:2) );
                PhaseIndFrontier{i}( ind ) = true;
                PhaseIndFrontier{i} = PhaseIndFrontier{i} & EBSDData.AlphaData;
                PhaseIndInterior{i} = ~PhaseIndFrontier{i} ...
                    & EBSDData.Phase == i ;
                PhaseIndInterior{i} = PhaseIndInterior{i} & EBSDData.AlphaData;
                if Flag.GrainPartitionShow
                    DisplayName = [ Name, '-', EBSDData.PhaseNames{i} ];
                    axe = nexttile(t);
                    val = PhaseIndFrontier{i}( indRow, indCol );
                    image( axe, val, ...
                        'CDataMapping', 'scaled', ...
                        'AlphaData', val )
                    % dat = val.*permute(c{i,2},[1,3,2]);
                    % image( axe, dat, 'AlphaData', val )
                    axe.Title.String = [ DisplayName, GBName ];
                    axe = nexttile(t);
                    val = PhaseIndInterior{i}( indRow, indCol );
                    image( axe, val, ...
                        'CDataMapping', 'scaled', ...
                        'AlphaData', val )
                    % dat = val.*permute(c{i,1},[1,3,2]);
                    % image( axe, dat, 'AlphaData', val )
                    axe.Title.String = [ DisplayName, GMName ];
                end
            end
        end

        if Flag.GrainPartitionShow
            axis( t.Children, 'image' )
            arrayfun( @(a) set( a.XAxis, 'Visible', 'off' ), t.Children )
            arrayfun( @(a) set( a.YAxis, 'Visible', 'off' ), t.Children )
            % axis( axe, 'image' )
            % axe.XAxis.Visible = 'off';
            % axe.YAxis.Visible = 'off';
        end
    end


    nl = 0;
    for n = AllStages

        if isfield( DIC.DataValueRange, Variable )
            ReigonValue = restoreData( ...
                DIC.Data(n).( Variable ), DIC.DataValueRange.( Variable ) );
        else
            ReigonValue = DIC.Data(n).( Variable );
        end
        if ~isempty( EBSDData )
            ReigonValue( ~EBSDData.AlphaData ) = nan;
        end

        ReigonValue = ReigonValue( indRow, indCol );
        
        % same marker for same satge
        mk = Markers{randi(length(Markers))};
        if Flag.Whole
            %%%% NAME - WHOLE %%%%
            DisplayName = [ Name, '-',Variable, '-S', num2str(n), '-All' ];
            nl = nl + 1;
            c = Colors( randi(256), : );
            StatisticResult.StatisticObject( nl ) = fun( ...
                ReigonValue, N, ...
                DisplayName, StatisticObjectLinWidth, c, mk );

            if Flag.GrainPartition
                ReigonIndGB = IndFrontier( indRow, indCol );
                ReigonIndGM = IndInterior( indRow, indCol );
                %%%% NAME - GB - Frontier %%%%
                DisplayNameGB = [ DisplayName, GBName ];
                nl = nl + 1;
                c = Colors(randi(256),:);
                StatisticResult.StatisticObject( nl ) = fun( ...
                    ReigonValue( ReigonIndGB ), N, ...
                    DisplayNameGB, StatisticObjectLinWidth, c, mk );
                %%%% NAME - GM - Interior %%%%
                DisplayNameGM = [ DisplayName, GMName ];
                nl = nl + 1;
                c = Colors(randi(256),:);
                StatisticResult.StatisticObject( nl ) = fun( ...
                    ReigonValue( ReigonIndGM ), N, ...
                    DisplayNameGM, StatisticObjectLinWidth, c, mk );
            end
        end

        if Flag.Phases
            ReigonPhase = EBSDData.Phase( indRow, indCol );
            for i = 1:length( EBSDData.PhaseNames )
                ReigonIndPhase = ReigonPhase == i;
                %%%% NAME - PHASE %%%%
                DisplayName = [ Name, '-', Variable, ...
                    '-S', num2str(n), '-', EBSDData.PhaseNames{i} ];
                nl = nl + 1;
                c = Colors( randi(256), : );
                StatisticResult.StatisticObject( nl ) = fun( ...
                    ReigonValue( ReigonIndPhase ), N, ...
                    DisplayName, StatisticObjectLinWidth, c, mk );
                if Flag.GrainPartition
                    ReigonIndPhaseGB = PhaseIndFrontier{i}( indRow, indCol );
                    ReigonIndPhaseGM = PhaseIndInterior{i}( indRow, indCol );
                    %%%% NAME - PhaseGB - Frontier %%%%
                    DisplayNameGB = [ DisplayName, GBName ];
                    nl = nl + 1;
                    c = Colors(randi(256),:);
                    StatisticResult.StatisticObject( nl ) = fun( ...
                        ReigonValue( ReigonIndPhaseGB ), N, ...
                        DisplayNameGB, StatisticObjectLinWidth, c, mk );
                    %%%% NAME - PhaseGM - Interior %%%%
                    DisplayNameGM = [ DisplayName, GMName ];
                    nl = nl + 1;
                    c = Colors(randi(256),:);
                    StatisticResult.StatisticObject( nl ) = fun( ...
                        ReigonValue( ReigonIndPhaseGM ), N, ...
                        DisplayNameGM, StatisticObjectLinWidth, c, mk );
                end
            end
        end

    end

    % --------- create Nodes ---------
    for i = 1:nl
        StatisticResult.Nodes(i,1) = uitreenode( obj.Tree2Nodes.Main, ...
            'Text', StatisticResult.StatisticObject(i).DisplayName, ...
            'NodeData', StatisticResult.StatisticObject(i), ...
            'UserData', StatisticResult.Serial, ...
            'ContextMenu', app.Tree2ContextMenu );
    end
    app.Tree2.CheckedNodes = ...
        [ app.Tree2.CheckedNodes; StatisticResult.Nodes ];
    expand( obj.Tree2Nodes.Main )

    % --------- Ending ---------
    obj.StatisticResults = [ obj.StatisticResults, StatisticResult ];
    app.Projects( ProjectIndex ) = obj;

    app.TabGroup.SelectedTab = app.FrequencyTab;

end



function gobj = fun( val, N, name, lw, c, mk )

    [ LineValue, edges ] = histcounts( ...
        val, N, ...
        'Normalization', 'percentage' ); % percentage pdf
    x = ( edges(1:end-1) + edges(2:end) ) / 2;
    gobj = plotLine( ...
        app.UIAxesFrequency, ...
        x, LineValue, c, ...
        name, lw, ...
        'Marker', mk );
    gobj.UserData = ...
        struct( 'Data', val, ...
                'Number', N, ...
                'Limits', [edges(1),edges(end)] );
end


end
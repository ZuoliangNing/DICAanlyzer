function createLineStatistic( Name, Flag, app )


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

OldEnableStates = setUIsOff( app );

axe.UserData = struct( ...
    'Lines', gobjects(1), ...
    'Pos1', [], ...
    'Pos2', [], ...
    'ContextMenu', axe.Children(end).ContextMenu );

cm = uicontextmenu( app.UIFigure );
uimenu( cm, ...
    'Text', app.OtherDisplayNames( app.Default.LanguageSelection ). ...
                Adjust_Complete, ...
    'MenuSelectedFcn', ...
        {@ createLineStatisticCompleteMenuSelectedFcn, axe} )


app.UIFigure.WindowButtonMotionFcn = ...
    { @ createLineStatistic_WindowButtonMotionFcn, axe, app };
app.UIFigure.KeyPressFcn = ...
    { @ createLineStatistic_KeyPressFcn, axe, OldEnableStates, app };
app.UIFigure.WindowButtonDownFcn = ...
    { @ createLineStatistic_WindowButtonDownFcn, axe, app, cm };


% ---------- WindowButtonMotionFcn ----------
function createLineStatistic_WindowButtonMotionFcn( ~, ~, axe, app )

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
        axe.UserData.Lines = line( axe, ...
            [pos1(1),pos(1)], [pos1(2),pos(2)], ...
            'Color', 'w', 'LineWidth', 2 );
    end

end


% ---------- WindowButtonDownFcn ----------
function createLineStatistic_WindowButtonDownFcn( fig, ~, axe, app, cm )

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
function createLineStatistic_KeyPressFcn( ~, event, axe, OldEnableStates, app )
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


% ---------- createLineStatisticCompleteMenu ----------
function createLineStatisticCompleteMenuSelectedFcn( ~, ~, axe )
    
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
    delete( axe.UserData.Lines )
    setUIsOn( OldEnableStates, app )
    app.UIFigure.WindowButtonMotionFcn = '';
    app.UIFigure.WindowButtonDownFcn = '';
    app.UIFigure.KeyPressFcn = { @UIFigureKeyPressFcn, app };
    axe.Children(end).ContextMenu = app.UIAxesContextMenu;
    Pos1 = axe.UserData.Pos1;
    Pos2 = axe.UserData.Pos2;
    axe.UserData = [];
    close( app.StatisticUIFigure )


    % -------------------------------------------
    % --------- create StatisticObjects ---------
    % -------------------------------------------

    StatisticObjectLinWidth = app.Default.Options.LineStatisticLineWidth;
    Colors = app.ConstantValues.Colormaps{2};

    obj.StatisticResultsSerial = obj.StatisticResultsSerial + 1;
    StatisticResult.Serial = obj.StatisticResultsSerial;

    % ----- GRAPHIC objects -----
    StatisticResult.Type = 'line';
    StatisticResult.Pos = [ Pos1; Pos2 ];
    Size = [ DIC.XData(end), DIC.YData(end) ];
    StatisticResult = createGraphicObject( ...
        StatisticResult, Size, axe );

    % ----- STATISTIC Objects -----
    [ X, Y ] = meshgrid( DIC.XData, DIC.YData );
    N = 300;
    Xq = linspace( Pos1(1), Pos2(1), N );
    Yq = linspace( Pos1(2), Pos2(2), N );
    LineLength = norm( Pos2 - Pos1 );
    x = LineLength / (N-1) * (0:N-1);

    if Flag.AllStage;   AllStages = 1:DIC.StageNumber;
    else;               AllStages = obj.StageSelection; % !!!
    end

    if Flag.AllStage && ...
            ( Flag.Phases && length(EBSDData.PhaseNames)>1 )
        uiprogressdlg( app.UIFigure, 'Indeterminate', 'on' );
    end

    nl = 0;
    for n = AllStages

        if isfield( DIC.DataValueRange, Variable )
            val = restoreData( ...
                DIC.Data(n).( Variable ), DIC.DataValueRange.( Variable ) );
        else
            val = DIC.Data(n).( Variable );
        end

        if ~isempty( EBSDData )
            val( ~EBSDData.AlphaData ) = nan;
        end

        LineValue = interp2( X, Y, val, Xq, Yq );

        if Flag.Whole
            %%%% NAME - WHOLE %%%%
            DisplayName = [ Name, '-',Variable, '-S', num2str(n), '-Whole' ];
            nl = nl + 1;
            StatisticResult.StatisticObject( nl ) = plotLine( ...
                app.UIAxesValue, ...
                x, LineValue, Colors(randi(256),:), ...
                DisplayName, StatisticObjectLinWidth );
        end
        
        if Flag.Phases
            LinePhase = round( interp2( X, Y, EBSDData.Phase, Xq, Yq ) );
            for i = 1:length( EBSDData.PhaseNames )
                val = nan( size( LineValue ) );
                ind = LinePhase == i;
                val( ind ) = LineValue( ind );
                %%%% NAME - PHASE %%%%
                DisplayName = [ Name, '-', Variable, ...
                    '-S', num2str(n), '-', EBSDData.PhaseNames{i} ];
                nl = nl + 1;
                StatisticResult.StatisticObject( nl ) = ...
                    plotLine( app.UIAxesValue, x, val, Colors(randi(256),:), ...
                        DisplayName, StatisticObjectLinWidth );
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

    app.TabGroup.SelectedTab = app.ValueTab;

    clear obj

end


end
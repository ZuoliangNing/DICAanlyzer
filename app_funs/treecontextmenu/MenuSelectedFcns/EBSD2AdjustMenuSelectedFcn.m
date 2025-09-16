function EBSD2AdjustMenuSelectedFcn( menu, ~, app )


ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

node = app.UIFigure.CurrentObject;
EBSDSerial = getEBSDIndex( node.NodeData.EBSDSerial, obj );

EBSDData = obj.EBSD.Data( EBSDSerial );

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );


% -------/// CREATE INTERFACE ///-------

% ---------- DISABLE ----------
OldEnableStates = setUIsOff(app);


[ Figure1, Axe1, Figure2, Axe2, Figure3, ...
    ConfirmButton, CancelButton, ...
    DICSelectionDropdown, DICSelectionLabel, ...
    EBSDSelectionDropdown, EBSDSelectionLabel, ...
    SelectButton, SelectionTree, ...
    TextArea ] = createEBSD_Adjust_UI( app, obj );

Figure3.CloseRequestFcn = @ CancelButtonPushedFcn;
CancelButton.ButtonPushedFcn = @ CancelButtonPushedFcn;
DICSelectionDropdown.ValueChangedFcn = ...
    @ DICSelectionDropdownValueChangedFcn;
EBSDSelectionDropdown.ValueChangedFcn = ...
    @ EBSDSelectionDropdownValueChangedFcn;
SelectButton.ButtonPushedFcn = @ SelectButtonPushedFcn;
SelectionTree.SelectionChangedFcn = @ TreeSelectionChangedFcn;
Figure3.WindowButtonDownFcn = @ Figure3WindowButtonDownFcn;
ConfirmButton.ButtonPushedFcn = @ ConfirmButtonPushedFcn;

colormap( Axe1, app.UIAxesImages.Colormap )

% Selection: Next / Complete
cm = uicontextmenu( Figure1 );
uimenu( cm, ...
    'Text', DisplayNames.Adjust_SelectButton_Text_2, ...
    'MenuSelectedFcn', @ ConfirmButtonPushedFcn_2 )

% Delete
cm2 = uicontextmenu( Figure3 );
uimenu( cm2, ...
    'Text', DisplayNames.cm_Delete, ...
    'MenuSelectedFcn', @ DeleteMenuSelectedFcn )

dY = EBSDData.YData(2) - EBSDData.YData(1);
dX = EBSDData.XData(2) - EBSDData.XData(1);
Axe2.DataAspectRatio(2) = dX / dY;

% ************************
pause(1)
CurrentImage = gobjects(1,2);
OldEnableStates_2 = {};
DICSelectionDropdownValueChangedFcn( DICSelectionDropdown, [] )
EBSDSelectionDropdownValueChangedFcn( EBSDSelectionDropdown, [] )

TempLines = gobjects(1,2); 
TempScatter = gobjects(1,2); TempText = gobjects(1,2);
TempPointPos = nan(2,2);
funline = @( axe, x, y ) line( axe, x, y, ...
    'Color', 'w', 'LineWidth', 2, 'PickableParts', 'none' );
ScatterColor = 'w';
ScatterSize = 30;
TextFontSize = 20;

HighlightColor = 'r';

OBJS = { DICSelectionDropdown, DICSelectionLabel, ...
         EBSDSelectionDropdown, EBSDSelectionLabel, ...
         SelectButton };

PointSetNum = 0;
PointCoords = nan( 0, 2, 2 ); % (PointSetNum)(x/y)(DIC/EBSD)
Scatters = []; Texts = [];
tempratio = 0.01;
TextDev = [ obj.DICSize(2), size( EBSDData.IPF{2} ) ] * tempratio;

MinPointSetNum = 3;


    function CancelButtonPushedFcn( ~, ~ )

        setUIsOn( OldEnableStates, app )
        delete( [ Figure1, Figure2, Figure3 ] )

    end


    function DICSelectionDropdownValueChangedFcn( dropdown, ~ )

        delete( CurrentImage(1) )
        
        VariableName = dropdown.ItemsData{ dropdown.ValueIndex };
        
        n = obj.StageSelection;

        if isfield( obj.DIC.DataValueRange, VariableName )
            val = simplifyCData( restoreData( ...
                obj.DIC.Data(n).( VariableName ), ...
                obj.DIC.DataValueRange.( VariableName ) ), ...
                app.Default.Options.MaxResolution );
        else
            val = simplifyCData( obj.DIC.Data(n).( VariableName ), ...
                app.Default.Options.MaxResolution );
        end


        CurrentImage(1) = image( ...
            Axe1, val, ...
            'XData', [ 1, obj.DICSize(2) ], ...
            'YData', [ 1, obj.DICSize(1) ], ...
            'CDataMapping','scaled' );

        uistack( CurrentImage(1), 'bottom' )

        % colormap( Axe1, app.Default.Options.DICColormap )

        % [ minval, maxval ] = getCLim( ...
        %     val, app.Default.Options.DICCLimCoeff );
        Axe1.CLim = obj.DIC.CLim( n ).( VariableName ); % [ minval, maxval ];
        
        AxeVsibleOff(Axe1)
        
    end


    function EBSDSelectionDropdownValueChangedFcn( dropdown, ~ )

        delete( CurrentImage(2) )

        VariableName = dropdown.ItemsData{ dropdown.ValueIndex };

        if strcmp( VariableName, 'IPF' )

            val = EBSDData.IPF{ app.EBSDDropDown.ValueIndex };

            CurrentImage(2) = image( ...
                Axe2, val );
            % , ...
            %     'XData', EBSDData.XData, ...
            %     'YData', EBSDData.YData

        else

            val = EBSDData.( VariableName );

            CurrentImage(2) = image( ...
                Axe2, val, ...
                'CDataMapping','scaled' );
            % , ...
            %     'XData', EBSDData.XData, ...
            %     'YData', EBSDData.YData 

        end
        
        uistack( CurrentImage(2), 'bottom' )

        switch VariableName
            case { 'CI', 'IQ' }
                colormap( Axe2, 'gray' ) ; clim( Axe2, 'auto' )
            case 'GrainID'
                colormap( Axe2, 'prism' ); clim( Axe2, [0,1000] )
            case 'Phase'
                colormap( Axe2, 'jet' )  ; clim( Axe2, 'auto' )
            case 'EdgeIndex'
                colormap( Axe2, 'lines' ); clim( Axe2, 'auto' )
        end

        AxeVsibleOff(Axe2)
        

    end


    % *************** CONFIRM BUTTON ***************
    function ConfirmButtonPushedFcn( ~, ~ )
        
        % Figure3.Visible = 'off';
        
        CancelButtonPushedFcn( [], [] )
        % setUIsOn( OldEnableStates, app )
        dlg = uiprogressdlg( app.UIFigure, ...
            'Indeterminate', 'on' );

        % app.UIFigure.CloseRequestFcn = '';


        % -----------------------------
        obj = AdjustEBSD( ...
            obj, EBSDData, PointCoords, ...
            dlg, app.TextArea );
        % -----------------------------   


        NodeEBSD2 = uitreenode( obj.TreeNodes.EBSD, ...
            'Text',         obj.EBSD.Data(end).DisplayName, ...
            'UserData',     struct( 'Parent',       'Tree', ...
                                    'NodeType',     'EBSD2' ), ...
            'NodeData',     struct( 'Serial', obj.Serial, ...
                                    'Enable', true, ...
                                    'EBSDSerial', obj.EBSDSerial ), ...
            'ContextMenu',  app.TreeContextMenu.EBSD2 );
        
        obj.TreeNodes.EBSD2 = [ obj.TreeNodes.EBSD2, NodeEBSD2 ];

        DefaultEBSDVariables = app.ConstantValues.EBSDVariables;
        DefaultEBSDVariableNames = app.ConstantValues.EBSDVariableNames ...
            ( app.Default.LanguageSelection );

        N = getEBSDIndex( obj.EBSDSerial, obj );

        for i = 1:length( DefaultEBSDVariables )

            VariableName = DefaultEBSDVariables{i};

            Node = uitreenode( NodeEBSD2, ...
                'Text',         DefaultEBSDVariableNames.( VariableName ), ...
                'UserData',     struct( 'Parent',       'Tree', ...
                                        'NodeType',     'EBSDData', ...
                                        'VariableName',  VariableName ), ...
                'NodeData',     struct( 'Serial', obj.Serial, ...
                                        'Enable', true, ...
                                        'EBSDSerial', obj.EBSDSerial ));
            % , ...
            %     'ContextMenu',  app.TreeContextMenu.EBSDData 

            if ~isempty( obj.EBSD.Data(N).(VariableName) )
                EnableDisableNode( app, Node, 'on' )
            else
                EnableDisableNode( app, Node, 'off' )
            end
            
            obj.TreeNodes.EBSDData(N).(VariableName) = Node;

        end

        expand( NodeEBSD2 )
        scroll( app.Tree, 'bottom' )

        app.Projects( ProjectIndex ) = obj;


    end



    % *************** SELECT BUTTON ***************
    function SelectButtonPushedFcn( ~, ~ )

        TextArea.Enable = 'on';
        TextArea.Value = DisplayNames.Adjust_TextArea_Value_1;

        
        OldEnableStates_2 = cellfun( @(obj) ...
            obj.Enable, OBJS, 'UniformOutput', false );
        cellfun( @(obj) set( obj, 'Enable', 'off' ), OBJS );


        CancelButton.ButtonPushedFcn = @ CancelButtonPushedFcn_2;
        ConfirmButton.ButtonPushedFcn = @ ConfirmButtonPushedFcn_2;
        ConfirmButton.Text = DisplayNames.Adjust_SelectButton_Text_2;
        % ConfirmButton.Enable = 'on';

        Figure1.WindowButtonMotionFcn = @ FigureWindowButtonMotionFcn;
        Figure1.WindowButtonDownFcn = @ FigureWindowButtonDownFcn;

    end


    function CancelButtonPushedFcn_2( button, ~ )
        
        arrayfun( @(i) ...
            set( OBJS{i}, 'Enable', OldEnableStates_2{i} ), ...
            1:length(OBJS) );
        
        TextArea.Enable = 'off';
        TextArea.Value = '';

        button.ButtonPushedFcn = @ CancelButtonPushedFcn;
        ConfirmButton.ButtonPushedFcn = @ ConfirmButtonPushedFcn;
        ConfirmButton.Text = DisplayNames.uiopt_ok;
        
        if size( PointCoords, 1 ) >= MinPointSetNum
            ConfirmButton.Enable = 'on';
        else
            ConfirmButton.Enable = 'off';
        end

        delete( TempLines ); delete( TempScatter ); delete( TempText )
        TempPointPos = nan(2,2);

        Figure1.WindowButtonMotionFcn = '';
        Figure1.WindowButtonDownFcn = '';
        Figure2.WindowButtonMotionFcn = '';
        Figure2.WindowButtonDownFcn = '';

    end


    function ConfirmButtonPushedFcn_2( ~, ~ )

        delete( TempLines )
        
        if isnan( TempPointPos(2,1) )

            TextArea.Value = DisplayNames.Adjust_TextArea_Value_2;
    
            Figure1.WindowButtonMotionFcn = '';
            Figure1.WindowButtonDownFcn = '';
    
            Figure2.WindowButtonMotionFcn = @ FigureWindowButtonMotionFcn;
            Figure2.WindowButtonDownFcn = @ FigureWindowButtonDownFcn;

            CurrentImage(1).ContextMenu = '';

        else

            PointSetNum = PointSetNum + 1 ;

            PointCoords( PointSetNum, :, : ) = ...
                permute( TempPointPos, [ 3,2,1 ] );

            arrayfun( @(obj) set( obj, 'UserData', PointSetNum ), ...
                [ TempScatter, TempText ] )

            Scatters = [ Scatters; TempScatter ];
            Texts = [ Texts; TempText ];

            TempScatter = gobjects(1,2);
            TempText = gobjects(1,2);
            TempPointPos = nan(2,2);

            uitreenode( SelectionTree, ...
                'Text', char( 64 + PointSetNum ), ...
                'NodeData', PointSetNum, ...
                'ContextMenu', cm2 );

            CurrentImage(2).ContextMenu = '';

            CancelButtonPushedFcn_2( CancelButton, [] )


        end

    end


    function FigureWindowButtonMotionFcn( fig, ~ )

        axe = fig.Children(end);
        pos = axe.CurrentPoint( 1, 1:2 );

        pos(1) = max( pos(1), axe.XLim(1) );
        pos(1) = min( pos(1), axe.XLim(2) );
        pos(2) = max( pos(2), axe.YLim(1) );
        pos(2) = min( pos(2), axe.YLim(2) );

        % if pos(1) < axe.XLim(1) || pos(1) > axe.XLim(2) ...
        %         || pos(2) < axe.YLim(1) || pos(2) > axe.YLim(2)
        %     return
        % end

        delete( TempLines )

        TempLines = [ ...
            funline( axe, axe.XLim, [ pos(2), pos(2) ] ), ...
            funline( axe, [ pos(1), pos(1) ], axe.YLim ) ];

    end


    function FigureWindowButtonDownFcn( fig, ~ )

        if ~strcmp( fig.SelectionType, 'normal' )
            return
        end

        axe = fig.Children(end);
        pos = axe.CurrentPoint( 1, 1:2 );
        i = fig.UserData;

        pos(1) = max( pos(1), axe.XLim(1) );
        pos(1) = min( pos(1), axe.XLim(2) );
        pos(2) = max( pos(2), axe.YLim(1) );
        pos(2) = min( pos(2), axe.YLim(2) );

        % if pos(1) < axe.XLim(1) || pos(1) > axe.XLim(2) ...
        %         || pos(2) < axe.YLim(1) || pos(2) > axe.YLim(2)
        %     return
        % end

        delete( TempScatter(i) ); delete( TempText(i) )

        x = pos(1); y = pos(2);
        
        TempScatter(i) = scatter( axe, ...
            x, y, ...
            ScatterSize, ScatterColor, 'filled', ...
            'PickableParts','none');
        
        TempText(i) = text( axe, ...
            x + TextDev(i), y, ...
            char( 65 + PointSetNum ), ...
            'Color', ScatterColor, ...
            'FontSize', TextFontSize );
        TempPointPos(i,:) = [ x, y ];

        ConfirmButton.Enable = 'on';
        cm.Parent = fig;
        CurrentImage(i).ContextMenu = cm;

        if i > 1
            cm.Children.Text = DisplayNames.Adjust_Complete;
        else
            cm.Children.Text = DisplayNames.Adjust_SelectButton_Text_2;
        end
    end


    function DeleteMenuSelectedFcn( ~, ~ )

        Node = Figure3.CurrentObject;

        ind = arrayfun( @(s) s.UserData == Node.NodeData, Scatters(:,1) );

        delete( [ Scatters( ind, : ), Texts( ind, : ) ] )
        Scatters( ind, : ) = []; Texts( ind, : ) = [];
        delete( Node )

        PointCoords( ind, :, : ) = [];
        PointSetNum = PointSetNum - 1 ;

        if size( PointCoords, 1 ) >= MinPointSetNum
            ConfirmButton.Enable = 'on';
        else
            ConfirmButton.Enable = 'off';
        end

    end


    function TreeSelectionChangedFcn( tree, event )

        PreNode = event.PreviousSelectedNodes;
        Node = tree.SelectedNodes;
    
        setColor( Node, HighlightColor )

        if ~isempty( PreNode )

            setColor( PreNode, ScatterColor )

        end


    end


    function Figure3WindowButtonDownFcn( fig, ~ )

        if isempty( SelectionTree.Children )
            return
        end

        if ~isa( fig.CurrentObject, 'matlab.ui.container.TreeNode' )

            Node = SelectionTree.SelectedNodes;
            if isempty( Node ); return; end

            setColor( Node, ScatterColor )

            
        end

    end


    function AxeVsibleOff(axe)
    
        axe.Visible = 'off'; 
        axe.XAxis.Visible = 'off'; axe.YAxis.Visible = 'off';
        axe.XTick = []; axe.YTick = [];

    end
    
    function setColor( Node, Color )

        ind = arrayfun( @(s) s.UserData == Node.NodeData, Scatters(:,1) );

        arrayfun( @(obj) set( obj, 'MarkerFaceColor', Color ), ...
            Scatters( ind, : ) )
        arrayfun( @(obj) set( obj, 'Color', Color ), ...
            Texts( ind, : ) )

    end



end
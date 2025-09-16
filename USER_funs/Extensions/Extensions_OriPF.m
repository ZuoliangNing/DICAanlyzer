function Extensions_OriPF( menu, ~, app )


if menu.Checked; return; end
Node = app.Tree.SelectedNodes;
if isempty( Node ) || ~strcmp( Node.UserData.NodeType, 'EBSDData' )
    return
end
menu.Checked = 'on';

app.Tree.Enable = 'off';

UIFigureSize = [660,420];
% TreeHeight = 120;
OriAxeWidth = 240;
PFAxeHeight = 240;
TextAreaHeight = 50;
% LabelWidth = 120;
EditWidth = 20;

AxialRatio = 1.593; % Zr - c/a = 1.593

% ---------- UIFigure ----------
UIFigure = uifigure( ...
    'Name', menu.Text, ...
    'WindowStyle', 'alwaysontop', ...alwaysontop modal
    'Icon', app.ConstantValues.IconSource, ...
    'Resize', 'off', ...
    'CloseRequestFcn', @ UIFigureCloseRequestFcn, ...
    'WindowButtonDownFcn', @ WindowButtonDownFcn );
UIFigure.Position = getMiddlePosition( ...
    app.UIFigure.Position, UIFigureSize );
app.Extensions.OriPF.gobjs = UIFigure;

% ---------- GridLayoutMain ----------
GridLayoutMain = uigridlayout( UIFigure, ...
    'ColumnWidth',  { OriAxeWidth, PFAxeHeight, '1x' }, ...
    'RowHeight', { PFAxeHeight, '1x', TextAreaHeight }, ...
    'Padding', 10*ones(1,4));

% ---------- OriAxe ----------
OriAxe = getUIAxe( GridLayoutMain );
OriAxe.XTick = []; OriAxe.YTick = [];
legend( OriAxe, "off" )
OriAxe.Visible = 'off';
axis( OriAxe, 'equal' )
OriAxe.XLim = 1.5*[-1,1];
OriAxe.YLim = OriAxe.XLim; OriAxe.ZLim = OriAxe.XLim;
OriAxe.Layout.Column = 1; OriAxe.Layout.Row = 1;

% ---------- PFAxe ----------
ori = getSampleCoordOri();
PFAxe = getPFAxe( GridLayoutMain, ori );
PFAxe.Layout.Column = [2,3]; PFAxe.Layout.Row = 1;

% ---------- GridLayoutPointTree ----------
GridLayoutPointTree = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', '1x' }, ...
    'Padding', [0,0,0,0], ...
    'ColumnSpacing', 0 );
GridLayoutPointTree.Layout.Column = 1; GridLayoutPointTree.Layout.Row = 2;

% ---------- PointTree ----------
PointTree = uitree( GridLayoutPointTree, ...
    'SelectionChangedFcn', @ TreeSelectionChangedFcn );
PointTree.Layout.Column = 2; PointTree.Layout.Row = 1;

% ---------- PFPanel ----------
PFPanel = uipanel( GridLayoutMain );
PFPanel.Layout.Column = 2; PFPanel.Layout.Row = 2;

% ---------- GridLayoutPFPanel ----------
GridLayoutPFPanel = uigridlayout( PFPanel, ...
    'RowHeight',    { '1x','1x','1x' }, ...
    'ColumnWidth',  { '1x', EditWidth, EditWidth, EditWidth, EditWidth }, ...
    'RowSpacing', 5, ...
    'Padding', [15,5,15,5], ...
    'ColumnSpacing', 5 );

Default = app.Default.Parameters.Extensions.OriPF;
Edits = cell(3,4);
% ---------- OrientationCheckBox ----------
OrientationCheckBox = uicheckbox( GridLayoutPFPanel, ...
    'Text', 'Orientation', ...
    'Value', true );
OrientationCheckBox.Layout.Row = 1;
OrientationCheckBox.Layout.Column = 1;
% ---------- OrientationEdits ----------
for j = 1:4
    Edits{1,j} = uieditfield( GridLayoutPFPanel, 'numeric', ...
        'Value', Default.Orientation(j), ...
        'HorizontalAlignment', 'center', ...
        'ValueChangedFcn', @ EditValueChangedFcn, ...
        'UserData', 1 );
    Edits{1,j}.Layout.Row = 1;
    Edits{1,j}.Layout.Column = j+1;
end
Edits{1,3}.Enable = 'off';

% ---------- SurfaceTraceCheckBox ----------
SurfaceTraceCheckBox = uicheckbox( GridLayoutPFPanel, ...
    'Text', 'Surface Trace', ...
    'Value', true );
SurfaceTraceCheckBox.Layout.Row = 2;
SurfaceTraceCheckBox.Layout.Column = 1;
% ---------- SurfaceTraceEdits ----------
for j = 1:4
    Edits{2,j} = uieditfield( GridLayoutPFPanel, 'numeric', ...
        'HorizontalAlignment', 'center', ...
        'Value', Default.SurfaceTrace(j), ...
        'HorizontalAlignment', 'center', ...
        'ValueChangedFcn', @ EditValueChangedFcn, ...
        'UserData', 2 );
    Edits{2,j}.Layout.Row = 2;
    Edits{2,j}.Layout.Column = j+1;
end
Edits{2,3}.Enable = 'off';

% ---------- SurfacePoleCheckBox ----------
SurfacePoleCheckBox = uicheckbox( GridLayoutPFPanel, ...
    'Text', 'Surface Pole', ...
    'Value', true );
SurfacePoleCheckBox.Layout.Row = 3;
SurfacePoleCheckBox.Layout.Column = 1;
% ---------- SurfacePoleEdits ----------
for j = 1:4
    Edits{3,j} = uieditfield( GridLayoutPFPanel, 'numeric', ...
        'HorizontalAlignment', 'center', ...
        'Value', Default.SurfacePole(j), ...
        'HorizontalAlignment', 'center', ...
        'ValueChangedFcn', @ EditValueChangedFcn, ...
        'UserData', 3 );
    Edits{3,j}.Layout.Row = 3;
    Edits{3,j}.Layout.Column = j+1;
end
Edits{3,3}.Enable = 'off';

% ---------- InfoTextArea ----------
InfoTextArea = uitextarea( GridLayoutMain, ...
    'BackgroundColor', UIFigure.Color, ...
    'FontName', 'Times New Roman', 'FontSize', 18 );
InfoTextArea.Layout.Column = [1,2]; InfoTextArea.Layout.Row = 3;


% ******************************************************


PreviousWindowButtonMotionFcn = app.UIFigure.WindowButtonMotionFcn;
app.UIFigure.WindowButtonMotionFcn = ...
    { @ Extensions_OriPF_WindowButtonMotionFcn, app };
PreviousKeyPressFcn = app.UIFigure.KeyPressFcn;
app.UIFigure.KeyPressFcn = { @ Extensions_OriPF_KeyPressFcn, app };
TempPFobjs = gobjects(1);
Colors = slanCM( 'glasbey' );

Points = [];
PointSerial = 0;
CurrX = []; CurrY = [];
cm = uicontextmenu( UIFigure );
uimenu( cm, 'Text', 'Delete', 'MenuSelectedFcn', @ DeleteMenuSelectedFcn )
FrezScat = gobjects(1);

G = getMatrix_Sam2Plot( ori ); % Smaple Coord -> Plot Coord


    function UIFigureCloseRequestFcn( fig, ~ )
        app.Tree.Enable = 'on';
        arrayfun( @(p) delete( p.scat ), Points )
        arrayfun( @(p) delete( p.text ), Points )
        delete( FrezScat )
        set( menu, 'Checked', 'off' )
        app.UIFigure.WindowButtonMotionFcn = PreviousWindowButtonMotionFcn;
        app.UIFigure.KeyPressFcn = PreviousKeyPressFcn;
        temp = [ Edits{1,:} ];
        app.Default.Parameters.Extensions.OriPF.Orientation = [ temp.Value ];
        temp = [ Edits{2,:} ];
        app.Default.Parameters.Extensions.OriPF.SurfaceTrace = [ temp.Value ];
        temp = [ Edits{3,:} ];
        app.Default.Parameters.Extensions.OriPF.SurfacePole = [ temp.Value ];
        delete( fig )
    end

    function Extensions_OriPF_WindowButtonMotionFcn( ~, ~, app )

        ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
        obj = app.Projects( ProjectIndex );
        EBSDData = obj.EBSD.Data( getEBSDIndex( ...
                Node.NodeData.EBSDSerial, obj ) );

        InfoTextArea.Value = '';
        delete( OriAxe.Children )
        delete( TempPFobjs ); TempPFobjs = [];

        if ~strcmp( app.TabGroup.SelectedTab.Tag, '2' )
            return
        end

        axe = app.UIAxesImages2;
        pos = axe.CurrentPoint( 1, 1:2 );
        if pos(1) < axe.XLim(1) || pos(1) > axe.XLim(2) ...
                || pos(2) < axe.YLim(1) || pos(2) > axe.YLim(2)
            return
        end

        ic = find( EBSDData.XData > pos(1), 1 );
        ir = find( EBSDData.YData > pos(2), 1 );
        Angles = permute( EBSDData.EulerAngles( ir, ic, : ), [1,3,2] );

        if any( isnan( Angles ) ); return; end

        g = EulerAngle2TransferMatrix( Angles )'; % cry -> sam

        Phase = EBSDData.Phase( ir, ic );
        PhaseName = EBSDData.PhaseNames{ Phase };

        nr = @(val) num2str( val, '%10.2f' ); % round( val, 2 )
        CurrX = EBSDData.XData(ic);
        CurrY = EBSDData.YData(ir);
        Angles = rad2deg( Angles );
        InfoTextArea.Value = { ...
            ['Euler Angles:  ', nr( Angles(1) ), ',  ', nr( Angles(2) ), ...
            ',  ', nr( Angles(3) ), ...
            '        X:  ', nr( CurrX ), ...
            '    Y:  ', nr( CurrY )], ...
            ['Phase Name:  ', PhaseName, ...
            '                     Use Ctrl+A to add point' ] };

        % ******** plot orientation ********
        HCPFlag = false;
        if EBSDData.HCPPhase( Phase )
            plotHCPOri( g, AxialRatio, G )
            HCPFlag = true;
        elseif EBSDData.FCCPhase( Phase )
            plotFCCOri( g, G )
        end
        
        % ******** scatter PF ********
        scatterPF( g, AxialRatio, HCPFlag )

    end

    function plotHCPOri( g, AxialRatio, G )

        A = 1; B = A/2*sqrt(3);
        C = A * AxialRatio;
        X = repmat( [ -0.5*A , -A , -0.5*A , 0.5*A , A , 0.5*A ], 1, 2 );
        Y = repmat( [ B , 0 , -B , -B , 0 , B ], 1, 2 );
        Z = [ -C/2 * ones(1,6), C/2 * ones(1,6) ];

        CoordsCrystal = [ X; Y; Z ];
        CoordsSample = g * CoordsCrystal;
        CoordsSample = G * CoordsSample;
        X = CoordsSample(1,:);
        Y = CoordsSample(2,:);
        Z = CoordsSample(3,:);

        for i = 1:5
            ind = [ i, i+1, i+7, i+6 ];
            OriSurf( X(ind), Y(ind), Z(ind), OriAxe )
        end
        ind = [ 6, 1, 7, 12 ];
        OriSurf( X(ind), Y(ind), Z(ind), OriAxe )
        ind = 1:6;
        OriSurf( X(ind), Y(ind), Z(ind), OriAxe )
        ind = 7:12;
        OriSurf( X(ind), Y(ind), Z(ind), OriAxe )
        
    end

    function OriSurf( x, y, z, axe )
        c = 0.9*[1,1,1];
        fill3( axe, x, y, z, c, ...
            'FaceAlpha', 0.8, ...
            'LineWidth', 3, ...
            'EdgeAlpha', 1 )
    end

    function plotFCCOri( g, G )

        A = 0.75;
        X = repmat( [ A, -A, -A, A ], 1, 2 );
        Y = repmat( [ A, A, -A, -A ], 1, 2 );
        Z = [ -A * ones(1,4), A * ones(1,4) ];
        
        CoordsCrystal = [ X; Y; Z ];
        CoordsSample = g * CoordsCrystal;
        CoordsSample = G * CoordsSample;
        X = CoordsSample(1,:);
        Y = CoordsSample(2,:);
        Z = CoordsSample(3,:);

        ind = [ 1,2,6,5; 2,3,7,6; 3,4,8,7; 4,1,5,8; 1,2,3,4; 5,6,7,8 ];
        arrayfun( @(i) OriSurf( ...
            X(ind(i,:)), Y(ind(i,:)), Z(ind(i,:)), OriAxe ), ...
            1:6 )

    end

    function scatterPF( g, AxialRatio, HCPFlag )
        
        cn = 0;
        OrientationFlag = OrientationCheckBox.Value;
        SurfaceTraceFlag = SurfaceTraceCheckBox.Value;
        SurfacePoleFlag = SurfacePoleCheckBox.Value;
        mksz = 40; lwt = 1.5;

        if SurfaceTraceFlag
            temp = [Edits{2,:}]; d = [ temp.Value ];
            if HCPFlag
                if d(4) < 0 ; d = -d; end
                temp = unique( perms( d(1:3) ), 'rows' );
                nd = size( temp, 1 );
                Directions4Crystal = unique( [ ...
                         temp, d(4) * ones( nd, 1 ); ...
                        -temp, d(4) * ones( nd, 1 ) ], 'rows' );
                Names = arrayfun( @(i) ...
                    num2str( Directions4Crystal(i,:) ), ...
                    1 : size( Directions4Crystal, 1 ), 'UniformOutput', false );
                if d(4) == 0 % prismatic - 3 v
                   [ ~, ia, ~ ] =  unique( abs( Directions4Crystal ), 'rows' );
                   Directions4Crystal = Directions4Crystal( ia, : );
                   Names = Names( ia );
                end
                Directions3Crystal = SurfaceNormalIndexConvert( ...
                    Directions4Crystal, AxialRatio, 'OIM' );
            else
                d = d([1,2,4]);
                temp = [ perms( d ); perms( d.*[-1,1,1] ); ...
                    perms( d.*[1,-1,1] ); perms( d.*[1,1,-1] ) ];
                temp = unique( [ temp; -temp ], 'rows' );
                Names = arrayfun( @(i) ...
                    num2str( temp(i,:) ), ...
                    1 : size( temp, 1 ), ...
                    'UniformOutput', false );
                Directions3Crystal = ( temp ./ vecnorm( temp, 2, 2 ) )';
                % Directions3Crystal = Directions4Crystal( :, [1,2,4] );
                % Directions3Crystal = ( Directions3Crystal ...
                %     ./ vecnorm( Directions3Crystal, 2, 2 ) )';
            end
            Directions3Sample = g * Directions3Crystal;
            Directions3Sample = G * Directions3Sample;
            if ~HCPFlag
                ind = Directions3Sample(3,:) >= 0;
                Directions3Sample = Directions3Sample( :, ind );
            end
            sn = size( Directions3Sample, 2 );
            tempgobjs = gobjects(1,sn);
            for i = 1:sn
                x = -1:0.001:1;
                d1 = Directions3Sample(1,i);
                d2 = Directions3Sample(2,i);
                d3 = Directions3Sample(3,i);
                if d3~=0
                    delta = 1 - d1^2 - x.^2;
                    ind = delta >= 0;
                    x = x( ind );
                    delta = delta( ind );
                    y = [ ( -d1*d2*x + d3*sqrt( delta ) ), ...
                        flip( ( -d1*d2*x - d3*sqrt(delta) ) ) ] ...
                        / ( 1 - d1^2 );
                    x1 = [ x, flip(x), x(1) ];
                    y1 = [ y, y(1) ];
                    z1 = - ( d1*x1 + d2*y1 ) / d3;
                    ind = z1 >= 0;
                    x1 = x1( ind ); y1 = y1( ind ); z1 = z1( ind );
                else
                    x1 = x;
                    y1 = -d1 / d2 * x;
                    z1 = sqrt( 1 - x1.^2 - y1.^2 );
                    z1 = real( z1 );
                end
                [ theta, rho ] = cart2pol( x1, y1 );
                R = rho./ ( 1 + z1 );
                [ theta, I ] = sort( theta );
                R = R(I);
                theta1 = theta;
                dd = abs( diff( theta1 ) );
                ind = find( dd == max( dd ) );
                if max( dd ) > 0.3
                    theta = [ theta( ind+1 : end ), theta( 1 : ind-1 ) ];
                    R = [ R( ind+1 : end ), R( 1 : ind-1 ) ];
                end
                % theta = theta + pi/2;
                tempgobjs(i) = polarplot( PFAxe, theta, R, ...
                    'Color', Colors(cn+i,:), ...
                    'DisplayName', ['(',Names{i},')'], ...
                    'LineWidth', 1 );
            end
            TempPFobjs = [ TempPFobjs, tempgobjs ];
            cn = cn + sn;
        end
        if OrientationFlag
            temp = [Edits{1,:}]; d = [ temp.Value ];
            if HCPFlag
                if d(4) < 0 ; d = -d; end
                temp = unique( perms( d(1:3) ), 'rows' );
                nd = size( temp, 1 );
                Directions4Crystal = unique( [ ...
                         temp, d(4) * ones( nd, 1 ); ...
                        -temp, d(4) * ones( nd, 1 ) ], 'rows' );
                Names = arrayfun( @(i) ...
                    num2str( Directions4Crystal(i,:) ), ...
                    1 : size( Directions4Crystal, 1 ), ...
                    'UniformOutput', false );
                if d(4) ~= 0
                    Directions4Crystal = [ ...
                        Directions4Crystal; -Directions4Crystal ];
                    Names = [ Names, Names ];
                end
                Directions3Crystal = DirectionIndexConvert( ...
                    Directions4Crystal, AxialRatio, 'OIM' );
            else
                d = d([1,2,4]);
                temp = [ perms( d ); perms( d.*[-1,1,1] ); ...
                    perms( d.*[1,-1,1] ); perms( d.*[1,1,-1] ) ];
                temp = unique( [ temp; -temp ], 'rows' );
                Names = arrayfun( @(i) ...
                    num2str( temp(i,:) ), ...
                    1 : size( temp, 1 ), ...
                    'UniformOutput', false );
                Directions3Crystal = ( temp ./ vecnorm( temp, 2, 2 ) )';
            end
            Directions3Sample = g * Directions3Crystal;
            Directions3Sample = G * Directions3Sample;
            ind = Directions3Sample(3,:) >= 0;
            Directions3Sample = Directions3Sample( :, ind );
            Z = Directions3Sample(3,:);
            Names = Names( ind );
            [ theta, rho ] = cart2pol( ...
                Directions3Sample(1,:), Directions3Sample(2,:) );
            R = rho ./ ( 1 + Z );
            sn = length( theta );
            % theta = theta + pi/2;
            TempPFobjs = [ TempPFobjs, arrayfun( @(i) scatter( PFAxe, ...
                theta(i), R(i), mksz, Colors(cn+i,:), ...
                'LineWidth', lwt, ...
                'Marker', 'o', ...
                'DisplayName', ['[',Names{i},']'] ), 1:sn ) ];
            cn = cn + sn;
        end
        if SurfacePoleFlag
            temp = [Edits{3,:}]; d = [ temp.Value ];
            if HCPFlag
                if d(4) < 0 ; d = -d; end
                temp = unique( perms( d(1:3) ), 'rows' );
                nd = size( temp, 1 );
                Directions4Crystal = unique( [ ...
                         temp, d(4) * ones( nd, 1 ); ...
                        -temp, d(4) * ones( nd, 1 ) ], 'rows' );
                Names = arrayfun( @(i) ...
                    num2str( Directions4Crystal(i,:) ), ...
                    1 : size( Directions4Crystal, 1 ), ...
                    'UniformOutput', false );
                if d(4) ~= 0
                    Directions4Crystal = [ ...
                        Directions4Crystal; -Directions4Crystal ];
                    Names = [ Names, Names ];
                end
                Directions3Crystal = SurfaceNormalIndexConvert( ...
                    Directions4Crystal, AxialRatio, 'OIM' );
            else
                d = d([1,2,4]);
                temp = [ perms( d ); perms( d.*[-1,1,1] ); ...
                    perms( d.*[1,-1,1] ); perms( d.*[1,1,-1] ) ];
                temp = unique( [ temp; -temp ], 'rows' );
                Names = arrayfun( @(i) ...
                    num2str( temp(i,:) ), ...
                    1 : size( temp, 1 ), ...
                    'UniformOutput', false );
                Directions3Crystal = ( temp ./ vecnorm( temp, 2, 2 ) )';
            end
            Directions3Sample = g * Directions3Crystal;
            Directions3Sample = G * Directions3Sample;
            ind = Directions3Sample(3,:) >= 0;
            Directions3Sample = Directions3Sample( :, ind );
            Z = Directions3Sample(3,:);
            Names = Names( ind );
            [ theta, rho ] = cart2pol( ...
                Directions3Sample(1,:), Directions3Sample(2,:) );
            R = rho ./ ( 1 + Z );
            sn = length( theta );
            % theta = theta + pi/2;
            TempPFobjs = [ TempPFobjs, arrayfun( @(i) scatter( PFAxe, ...
                theta(i), R(i), mksz, Colors(cn+i,:), ...
                'LineWidth', lwt, ...
                'Marker', '^', ...
                'DisplayName', ['(',Names{i},')'] ), 1:sn ) ];
        end

        if any( [ OrientationFlag, SurfaceTraceFlag, SurfacePoleFlag ] )
            legend( PFAxe, TempPFobjs, ...
                    'Location', 'northeastoutside', ...
                    'FontSize', 12, ...
                    'Box', 'off' );
        end

    end

    function EditValueChangedFcn( edit, ~ )
        Edits{ edit.UserData, 3 }.Value = ...
            - sum( Edits{ edit.UserData, 1 }.Value ...
            + Edits{ edit.UserData, 2 }.Value );
    end

    function Extensions_OriPF_KeyPressFcn( ~, event, app )

        mksz = 60; lwt = 2;
        if isempty( OriAxe.Children ); return; end
        if strcmp( event.Key, 'f' )
            if ishandle( FrezScat )
                delete( FrezScat )
                app.UIFigure.WindowButtonMotionFcn = ...
                    { @ Extensions_OriPF_WindowButtonMotionFcn, app };
            else
                FrezScat = scatter( app.UIAxesImages2, ...
                    CurrX, CurrY, 60, 'r', 'filled', 'PickableParts', 'none' );
                app.UIFigure.WindowButtonMotionFcn = PreviousWindowButtonMotionFcn;
            end
        end
        
        if strcmp( event.Key, 'a' ) && strcmp( event.Modifier{1}, 'control' )
            PointName = char( 65 + PointSerial );
            TreeNode = uitreenode( PointTree, ...
                'Text', PointName, ...
                'UserData', PointSerial, ...
                'ContextMenu', cm );
            Color = 'white'; TextFontSize = 20;
            Scatter = scatter( app.UIAxesImages2, ...
                CurrX, CurrY, 20, Color, 'filled', ...
                'UserData', PointSerial );
            ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
            obj = app.Projects( ProjectIndex );
            EBSDData = obj.EBSD.Data( getEBSDIndex( ...
                    Node.NodeData.EBSDSerial, obj ) );
            TextDev = EBSDData.XData(end) * 0.01;
            Text = text( app.UIAxesImages2, ...
                CurrX + TextDev, CurrY, ...
                PointName, ...
                'Color', Color, ...
                'FontSize', TextFontSize, ...
                'UserData', PointSerial );
            p = struct( ...
                'Node',     TreeNode, ...
                'gobjs',    copyobj( TempPFobjs, PFAxe ), ...
                'scat',     Scatter, ...
                'text',     Text, ...
                'color',    Colors(randi(256),:), ...
                'Serial',   PointSerial );
            
            sind = arrayfun( @(obj) isa( obj, ...
                'matlab.graphics.chart.primitive.Scatter' ), p.gobjs );
            set( p.gobjs( ~sind ), 'Color', p.color )
            set( p.gobjs( sind ), 'MarkerEdgeColor', p.color )
            set( p.gobjs( sind ), 'SizeData', mksz )
            set( p.gobjs( sind ), 'LineWidth', lwt )

            Points = [ Points, p ];
            PointSerial = PointSerial + 1;
        end

    end

    function DeleteMenuSelectedFcn( ~, ~ )
        PointNode = UIFigure.CurrentObject;
        ind = arrayfun( @(p) PointNode.UserData == p.Node.UserData, Points );
        p = Points( ind );
        delete( p.Node ); delete( p.gobjs ); delete( p.scat ); delete( p.text )
        Points( ind ) = [];
    end

    function TreeSelectionChangedFcn( tree, event )

        c = 'r';
        PreNode = event.PreviousSelectedNodes;
        PointNode = tree.SelectedNodes;
        ind = arrayfun( @(p) ...
            PointNode.UserData == p.Node.UserData, Points );
        p = Points( ind );
        sind = arrayfun( @(obj) isa( obj, ...
            'matlab.graphics.chart.primitive.Scatter' ), p.gobjs );
        set( p.gobjs( ~sind ), 'Color', c )
        set( p.gobjs( sind ), 'MarkerEdgeColor', c )
        p.text.Color = c; p.scat.MarkerFaceColor = c;

        if ~isempty( PreNode )
            ind = arrayfun( @(p) PreNode.UserData == p.Node.UserData, Points );
            p = Points( ind );
            sind = arrayfun( @(obj) isa( obj, ...
                'matlab.graphics.chart.primitive.Scatter' ), p.gobjs );
            set( p.gobjs( ~sind ), 'Color', p.color )
            set( p.gobjs( sind ), 'MarkerEdgeColor', p.color )
            p.text.Color = 'w'; p.scat.MarkerFaceColor = 'w';
        end
    end

    function WindowButtonDownFcn( fig, ~ )
        if isempty( PointTree.Children ); return; end
        if ~isa( fig.CurrentObject, 'matlab.ui.container.TreeNode' )
            PointNode = PointTree.SelectedNodes;
            if isempty( PointNode ); return; end
            ind = arrayfun( @(p) ...
                PointNode.UserData == p.Node.UserData, Points );
            p = Points( ind );
            sind = arrayfun( @(obj) isa( obj, ...
                'matlab.graphics.chart.primitive.Scatter' ), p.gobjs );
            set( p.gobjs( ~sind ), 'Color', p.color )
            set( p.gobjs( sind ), 'MarkerEdgeColor', p.color )
            p.text.Color = 'w'; p.scat.MarkerFaceColor = 'w';
        end
    end

    function ori = getSampleCoordOri()
        ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
        obj = app.Projects( ProjectIndex );
        EBSDData = obj.EBSD.Data( getEBSDIndex( ...
                Node.NodeData.EBSDSerial, obj ) );
        ori = EBSDData.SampleCoordOri;
    end

end
function ExportCurvesMenuSelectedFcn( ~, ~, app )


AllNodes = vertcat( app.Tree2.Children.Children );
if isempty( AllNodes ); return; end


DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
SIZE = [300,240];
ButtonSize = app.ConstantValues.TextedButtonSize;

% ---------- UIFigure ----------
UIFigure = uifigure( ...
    'Name', DisplayNames.ExportCurves_UIFigure, ...
    'WindowStyle', 'alwaysontop', ...alwaysontop
    'Icon', app.ConstantValues.IconSource );
% 'Resize', 'off'
UIFigure.Position = getMiddlePosition( app.UIFigure.Position, ...
    SIZE );

% ---------- GridLayoutMain ----------
GridLayoutMain = uigridlayout( UIFigure, ...
    'RowHeight',    { 15,'1x', ButtonSize(2) }, ...
    'ColumnWidth',  { '1x' }, ...
    'Padding', 15*ones(1,4));

% ---------- GridLayoutButtons ----------
GridLayoutButtons = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1), ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutButtons.Layout.Row = 3;

% ---------- ConfirmButton * ----------
ConfirmButton = uibutton( GridLayoutButtons, 'push', ...
    'Text', DisplayNames.uiopt_ok, ...
    'ButtonPushedFcn', @ ConfirmButtonPushedFcn, ...
    'Enable', 'off' );
ConfirmButton.Layout.Row = 1; ConfirmButton.Layout.Column = 2;

% ---------- CancelButton ----------
CancelButton = uibutton( GridLayoutButtons, 'push', ...
    'Text', DisplayNames.uiopt_cancel, ...
    'ButtonPushedFcn', @(~,~) close(UIFigure) );
CancelButton.Layout.Row = 1; CancelButton.Layout.Column = 3;

% ---------- CurvesLabel ----------
CurvesLabel = uilabel( GridLayoutMain, ...
    'Text', DisplayNames.ExportCurves_CurvesLabel );
CurvesLabel.Layout.Row = 1;

% ---------- CurvesTree ----------
CurvesTree = uitree( GridLayoutMain, 'checkbox', ...
    'CheckedNodesChangedFcn', @fun1);
    function fun1(tree,~)
        if isempty(tree.CheckedNodes)
            ConfirmButton.Enable = 'off';
        else; ConfirmButton.Enable = 'on';
        end
    end
CurvesTree.Layout.Row = 2;
copyobj( flip( app.Tree2.Children ), CurvesTree )
expand( CurvesTree )



function ConfirmButtonPushedFcn( ~, ~ )

    UIFigure.WindowStyle = 'normal';
    UIFigure.WindowStyle = 'modal';

    % ------ SELECT Path ------
    path = uigetdir( app.Default.Path.ExportCurves, ...
        DisplayNames.ExportCurves_UIFigure );
    if ~path; UIFigure.WindowStyle = 'alwaysontop'; return; end
    app.Default.Path.ExportCurves = path;
    

    % ------ WRITE File ------
    dlg = uiprogressdlg( app.UIFigure, 'Indeterminate', 'on' );
    dlg.Title = DisplayNames.ProjectSave_UIFigure;

    UIFigure.Visible = 'off';
    
    AllSelectedNodes = setdiff( ...
        CurvesTree.CheckedNodes, CurvesTree.Children );
    SelectedMainNodes = unique( [ AllSelectedNodes.Parent ] );

    for i = 1:length( SelectedMainNodes )

        SelectedNodes = intersect( ...
            CurvesTree.CheckedNodes, SelectedMainNodes(i).Children );
        temp = [ SelectedMainNodes(i).Text, '-Exported_Curves' ];
        FileName = [ path, '\', temp, '.xlsx' ];
        
        dlg.Message = [ DisplayNames.ProjectSave_dlg, ...
            ' ', FileName, ' ...' ];

        for j = 1:length( SelectedNodes )
            Curve = SelectedNodes(j).NodeData;
            Title = { Curve.Parent.XLabel.String, ...
                      Curve.Parent.YLabel.String };
            Data = [ Curve.XData', Curve.YData' ];
            writecell( Title, FileName, ...
                'Sheet', Curve.DisplayName, ...
                'WriteMode', 'overwrite' )
            writematrix( Data, FileName, ...
                'Sheet', Curve.DisplayName, ...
                'WriteMode', 'append' )
        end

    end

    close( UIFigure )

end


end
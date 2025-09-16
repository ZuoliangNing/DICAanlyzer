function ProjectSaveMenuSelectedFcn(~,~,app)

objs = app.Projects;
if isempty(objs); return; end

% ********** CREATE UI **********
DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
SIZE = [300,240];
ButtonSize = app.ConstantValues.TextedButtonSize;

% ---------- UIFigure ----------
UIFigure = uifigure( ...
    'Name', DisplayNames.ProjectSave_UIFigure, ...
    'WindowStyle', 'alwaysontop', ...alwaysontop
    'Icon', app.ConstantValues.IconSource );
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
    'ButtonPushedFcn', @ ConfirmButtonPushedFcn );
ConfirmButton.Layout.Row = 1; ConfirmButton.Layout.Column = 2;

% ---------- CancelButton ----------
CancelButton = uibutton( GridLayoutButtons, 'push', ...
    'Text', DisplayNames.uiopt_cancel, ...
    'ButtonPushedFcn', @(~,~) close(UIFigure) );
CancelButton.Layout.Row = 1; CancelButton.Layout.Column = 3;

% ---------- ProjectLabel ----------
ProjectLabel = uilabel( GridLayoutMain, ...
    'Text', DisplayNames.ProjectSave_ProjectLabel_Text );
ProjectLabel.Layout.Row = 1;

% ---------- ProjectTree ----------
ProjectTree = uitree( GridLayoutMain, 'checkbox', ...
    'CheckedNodesChangedFcn', @fun1);
    function fun1(tree,~)
        if isempty(tree.CheckedNodes)
            ConfirmButton.Enable = 'off';
        else; ConfirmButton.Enable = 'on';
        end
    end
ProjectTree.Layout.Row = 2;

% ******************************
MemorySizes = arrayfun( @(obj) ...
    sum([obj.EBSD.Data.MemorySize])+obj.DIC.MemorySize, ...
    objs );
Versions = {'-v7.3','-v7.3'}; % -v7
Versions = arrayfun( @(siz) Versions((siz>2000)+1), MemorySizes );
Nodes = arrayfun( @(obj,msiz,v) uitreenode( ProjectTree, ...
    'Text', [obj.DisplayName, ' (', ...
    num2str(round(msiz,1)), ...
    ' MB)'], 'NodeData', obj.Serial, 'UserData', v ), ...
     objs, MemorySizes, Versions );

ProjectTree.CheckedNodes = Nodes;


    function ConfirmButtonPushedFcn(~,~)

        UIFigure.WindowStyle = 'normal';
        UIFigure.WindowStyle = 'modal';

        % ------ SELECT Path ------
        path = uigetdir( app.Default.Path.ProjectSave, ...
            DisplayNames.ProjectSave_UIFigure );
        if ~path; UIFigure.WindowStyle = 'alwaysontop'; return; end
        app.Default.Path.ProjectSave = path;

        objs = arrayfun( @(Serial) objs( Serial == [objs.Serial] ), ...
            [ProjectTree.CheckedNodes.NodeData] );
        version = [ProjectTree.CheckedNodes.UserData];
        close(UIFigure)

        dlg = uiprogressdlg( app.UIFigure );
        dlg.Title = DisplayNames.ProjectSave_UIFigure;
        n = length(objs); val1 = 1/n; val2 = val1/2;
        for i = 1:n
            dlg.Value = i*val1 - val2;
            dlg.Message = [ DisplayNames.ProjectSave_dlg, ...
                objs(i).DisplayName, '...' ];
            objs(i).save( path, version{i} )
        end

    end






end


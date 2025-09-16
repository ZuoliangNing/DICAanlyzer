function [ Figure1, Axe1, Figure2, Axe2, Figure3, ...
    ConfirmButton, CancelButton, ...
    DICSelectionDropdown, DICSelectionLabel, ...
    EBSDSelectionDropdown, EBSDSelectionLabel, ...
    SelectButton, SelectionTree, ...
    TextArea ] = createEBSD_Adjust_UI( app, obj )


node = app.UIFigure.CurrentObject;

Padding = 0.05; % 0.1;
MagnifiedFontSize = 14;

TextAreaHeight = 50;

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
ButtonSize = app.ConstantValues.TextedButtonSize;
DropdownWidth = app.ConstantValues.DropdownWidth;
DropDownHeight = app.ConstantValues.DropDownHeight;
LabelHeight = app.ConstantValues.LabelSize(2);

% -------/// CREATE INTERFACE ///-------

Adjust_UIFigure_size = [600,400];
Adjust_UIFigureControl_size = [220,400];

% ---------- Figure1 ----------
Figure1 = createFig( ...
    [ DisplayNames.cm_Adjust, '-', ...
    DisplayNames.Adjust_DICSelectionLabel_Text, DisplayNames.Figure ] );
Figure1.Position = getMiddlePosition( app.UIFigure.Position, Adjust_UIFigure_size );
Figure1.Position(2) = Figure1.Position(2) + Adjust_UIFigure_size(2)/2;
Figure1.UserData = 1;

% ---------- Axe1 ----------
Axe1 = createAxe( Figure1, Padding );


% ---------- Figure2 ----------
Figure2 = createFig( ...
    [ DisplayNames.cm_Adjust, '-', ...
    DisplayNames.Adjust_EBSDSelectionLabel_Text, DisplayNames.Figure ] );
% right
% Figure2.Position(1) = Figure1.Position(1) + Figure1.Position(3);
% Figure2.Position(2) = Figure1.Position(2);
% Figure2.Position(3:4) = figSize;
% bottom
Figure2.Position(1) = Figure1.Position(1);
Figure2.Position(2) = Figure1.Position(2) - Figure1.Position(4) - 30;
Figure2.Position(3:4) = Adjust_UIFigure_size;
Figure2.UserData = 2;

% ---------- Axe2 ----------
Axe2 = createAxe( Figure2, Padding );


% ---------- Figure3 ----------
Figure3 = createFig( DisplayNames.cm_Adjust );
Figure3.Position(3:4) = Adjust_UIFigureControl_size;
Figure3.Position(1) = Figure1.Position(1) - Figure3.Position(3);
Figure3.Position(2) = Figure1.Position(2) - Adjust_UIFigure_size(2)/2;
Figure3.Resize = 'off';


% ---------- GridLayoutMain ----------
GridLayoutMain = uigridlayout( Figure3, ...
    'RowHeight',    { ...
            DropDownHeight, DropDownHeight, ...
            LabelHeight, '1x', ButtonSize(2), ...
            TextAreaHeight, ButtonSize(2) }, ...
    'ColumnWidth',  { '1x' } );


% ---------- GridLayoutButtons ----------
GridLayoutButtons = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1), ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutButtons.Layout.Row = 7;


% ---------- ConfirmButton * ----------
ConfirmButton = uibutton( GridLayoutButtons, 'push', ...
    'Text', DisplayNames.uiopt_ok, ...
    'Enable', 'off' );
ConfirmButton.Layout.Row = 1; ConfirmButton.Layout.Column = 2;


% ---------- CancelButton *  ----------
CancelButton = uibutton( GridLayoutButtons, 'push', ...
    'Text', DisplayNames.uiopt_cancel );
CancelButton.Layout.Row = 1; CancelButton.Layout.Column = 3;


% ---------- GridLayoutDICSelection ----------
GridLayoutDICSelection = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { app.ConstantValues.LabelSize(1), '1x' }, ...
    'Padding', zeros(1,4) );
GridLayoutDICSelection.Layout.Row = 1;


% ---------- DICSelectionLabel ----------
DICSelectionLabel = uilabel( GridLayoutDICSelection, ...
    'Text', DisplayNames.Adjust_DICSelectionLabel_Text );
DICSelectionLabel.Layout.Column = 1;


% ---------- DICSelectionDropdown * ----------
DICSelectionNames = struct2cell( structfun( @(node) node.Text, ...
    obj.TreeNodes.DICData, 'UniformOutput', false ))';
DICSelectionDropdown = uidropdown( GridLayoutDICSelection, ...
    'Items',            DICSelectionNames, ...
    'ItemsData',        fieldnames( obj.DIC.Data ) );
DICSelectionDropdown.ValueIndex = 3; % e_xx
DICSelectionDropdown.Layout.Column = 2;


% ---------- GridLayoutEBSDSelection ----------
GridLayoutEBSDSelection = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { app.ConstantValues.LabelSize(1), '1x' }, ...
    'Padding', zeros(1,4) );
GridLayoutEBSDSelection.Layout.Row = 2;


% ---------- EBSDSelectionLabel ----------
EBSDSelectionLabel = uilabel( GridLayoutEBSDSelection, ...
    'Text', DisplayNames.Adjust_EBSDSelectionLabel_Text );
EBSDSelectionLabel.Layout.Column = 1;


% ---------- EBSDSelectionDropdown * ----------
EBSDSelectionNames = arrayfun( @(node) ...
    node.Text, node.Children, 'UniformOutput', false )';
ind = arrayfun( @(node) node.NodeData.Enable, node.Children )';
EBSDSelectionNames = EBSDSelectionNames( ind );
ItemsData = arrayfun( @(node) ...
    node.UserData.VariableName, node.Children(ind), ...
    'UniformOutput', false )';
EBSDSelectionDropdown = uidropdown( GridLayoutEBSDSelection, ...
    'Items',            EBSDSelectionNames, ...
    'ItemsData',        ItemsData );
EBSDSelectionDropdown.ValueIndex = 1;
EBSDSelectionDropdown.Layout.Column = 2;


% ---------- GridLayoutSelectButton ----------
GridLayoutSelectButton = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutSelectButton.Layout.Row = 5;


% ---------- SelectButton * ----------
SelectButton = uibutton( GridLayoutSelectButton, 'push', ...
    'Text', DisplayNames.Adjust_SelectButton_Text );
SelectButton.Layout.Column = 2;


% ---------- SelectionLabel ----------
SelectionLabel = uilabel( GridLayoutMain, ...
    'Text', DisplayNames.Adjust_SelectionLabel_Text );
SelectionLabel.Layout.Row = 3;


% ---------- SelectionTree ----------
SelectionTree = uitree( GridLayoutMain );
SelectionTree.Layout.Row = 4;


% ---------- TextArea ----------
TextArea = uitextarea( GridLayoutMain, ...
    'Value', '', ...
    'Enable', 'off' );
TextArea.Layout.Row = 6;


 function fig = createFig( Name )

        fig = uifigure( ...
            'Name',         Name, ...
            'NumberTitle',  'off', ...
            'MenuBar',      'none', ...
            'Icon',         'TJU_logo.png', ...
            'WindowStyle',  'alwaysontop', ...
            'CloseRequestFcn', '' );
                    % 'Resize',       'off', ...
        
        
    end

    function axe = createAxe( fig, Padding )

        axe = axes( fig, ...
            'Units',  'normalized', ...
            'YDir',    'reverse', ...
            'NextPlot','add', ...
            'Visible', 'off' );
        %            
        axe.XAxis.Visible = 'off'; axe.YAxis.Visible = 'off';
        
        axe.Position = [ Padding, Padding, 1-2*Padding, 1-2*Padding ] ;
        
        axis( axe, 'image' )
        axtoolbar(axe,{'export','pan','zoomin','zoomout','restoreview'});
        
        axe.XTick = []; axe.YTick = [];

    end


end
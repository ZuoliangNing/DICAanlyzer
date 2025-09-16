function DICCalculateMenuSelectedFcn( menu, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

UIFigureSize = [200,500];
ButtonSize = app.ConstantValues.TextedButtonSize;
LabelHeight = 15;
DropDownHeight = app.ConstantValues.DropDownHeight;

% ---------- UIFigure ----------
UIFigure = uifigure( ...
    'Name', DisplayNames.cm_Calculate, ...
    'WindowStyle', 'alwaysontop', ...alwaysontop
    'Icon', app.ConstantValues.IconSource, ...
    'Resize', 'off' );
UIFigure.Position = getMiddlePosition( ...
    app.UIFigure.Position, UIFigureSize );


% ---------- GridLayoutMain ----------
GridLayoutMain = uigridlayout( UIFigure, ...
    'RowHeight',    { LabelHeight, '3x', LabelHeight, ...
        DropDownHeight, '2x', ButtonSize(2) }, ...
    'ColumnWidth',  { '1x' }, ...
    'RowSpacing', 5, ...
    'Padding',      10*ones(1,4));

% ---------- BasicLabel ----------
BasicLabel = uilabel( GridLayoutMain, ...
    'Text', DisplayNames.DICCalculateMenu_BasicLabel );
BasicLabel.Layout.Row = 1;

% ---------- VariableTree ----------
VariableTree = uitree( GridLayoutMain, 'checkbox', ...
    'CheckedNodesChangedFcn', @ VariableTreeCheckedNodesChangedFcn );
VariableTree.Layout.Row = 2;
ind = app.Default.LanguageSelection;
Methods = fieldnames( app.DICCalculateMethods );
BasicInd = structfun( @(s) strcmp( s.Type, 'basic' ), ...
    app.DICCalculateMethods );
BasicMethods = Methods( BasicInd );
for i0 = 1:length( BasicMethods )
    Name = app.DICCalculateMethods.( BasicMethods{i0} ).Name{ind};
    node = uitreenode( VariableTree, ...
        'Text', Name, 'UserData', BasicMethods{i0} );
    % if isfield( obj.DIC.Data, BasicMethods{i0} )
    %     VariableTree.CheckedNodes = [ VariableTree.CheckedNodes; node ];
    % end
end

% ---------- BESDBasedLabel ----------
BESDBasedLabel = uilabel( GridLayoutMain, ...
    'Text', DisplayNames.DICCalculateMenu_BESDBasedLabel );
BESDBasedLabel.Layout.Row = 3;

% ---------- EBSDDropDown ----------
EBSDDropDown = uidropdown( GridLayoutMain, ...
    'ValueChangedFcn', @ EBSDDropDownValueChangedFcn );
EBSDDropDown.Layout.Row = 4;
EBSDind = arrayfun( @(s) ...
    s.Flag.Adjusted & s.Flag.Polygonized, obj.EBSD.Data );
if ~any( EBSDind )
    EBSDDropDown.Enable = 'off';
    EBSDDropDown.Items = {};
    BESDBasedLabel.Enable = 'off';
else
    Names = { obj.EBSD.Data(EBSDind).DisplayName };
    EBSDDropDown.Items = Names;
    EBSDDropDown.ItemsData = find( EBSDind );
end

% ---------- VariableTree2 ----------
VariableTree2 = uitree( GridLayoutMain, 'checkbox', ...
    'CheckedNodesChangedFcn', @ VariableTreeCheckedNodesChangedFcn );
VariableTree2.Layout.Row = 5;
EBSDBasedMethods = Methods( ~BasicInd );
for i0 = 1:length( EBSDBasedMethods )
    Name = app.DICCalculateMethods.( EBSDBasedMethods{i0} ).Name{ind};
    node = uitreenode( VariableTree2, ...
        'Text', Name, 'UserData', EBSDBasedMethods{i0} );
    if isfield( obj.DIC.Data, EBSDBasedMethods{i0} )
        VariableTree2.CheckedNodes = [ VariableTree2.CheckedNodes; node ];
    end
end
if ~any( EBSDind ); VariableTree2.Enable = 'off'; end

% ---------- GridLayoutButtons ----------
GridLayoutButtons = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1), ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutButtons.Layout.Row = 6;


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


VariableTreeCheckedNodesChangedFcn( VariableTree, [] )



function ConfirmButtonPushedFcn( ~, ~ )
    
    OBJ = app.Projects( ProjectIndex );
    DIC = OBJ.DIC;
    if ~isempty( VariableTree.CheckedNodes )
        SelectedBasicMethods = { VariableTree.CheckedNodes.UserData };
    else
        SelectedBasicMethods = [];
    end
    if ~isempty( VariableTree2.CheckedNodes )
        SelectedEBSDBasedMethods = { VariableTree2.CheckedNodes.UserData };
        EBSDData = OBJ.EBSD.Data( EBSDDropDown.Value );
    else
        SelectedEBSDBasedMethods = [];
    end

    close( UIFigure )
    dlg = uiprogressdlg( app.UIFigure, ...
        'Indeterminate', 'on', ...
        'Title', DisplayNames.DICCalculateMenu_UIFigure );
    if ~isempty( SelectedBasicMethods )
        for i = 1:length( SelectedBasicMethods )
            name = SelectedBasicMethods{i};
            fun = eval( [ '@ DICCalculate_', name ] );
            DIC = fun( DIC, dlg );
    
            CLimCoeff = app.Default.Options.DICCLimCoeff;
            for n = 1 : DIC.StageNumber
                val = DIC.Data(n).( name );
                [ minval, maxval ] = getCLim( val, CLimCoeff );
                DIC.CLim(n).( name ) = [ minval, maxval ];
                DIC.CLimCoeff(n).( name ) = CLimCoeff;
                DIC.CLimMethod(n).( name ) = 'auto';
            end
        end
    end
    if ~isempty( SelectedEBSDBasedMethods )
        for i = 1:length( SelectedEBSDBasedMethods )
            name = SelectedEBSDBasedMethods{i};
            fun = eval( [ '@ DICCalculate_', name ] );
            DIC = fun( DIC, EBSDData, dlg );

            CLimCoeff = app.Default.Options.DICCLimCoeff;
            for n = 1 : DIC.StageNumber
                val = DIC.Data(n).( name );
                [ minval, maxval ] = getCLim( val, CLimCoeff );
                DIC.CLim(n).( name ) = [ minval, maxval ];
                DIC.CLimCoeff(n).( name ) = CLimCoeff;
                DIC.CLimMethod(n).( name ) = 'auto';
            end
        end
    end

    S = whos('DIC');
    DIC.MemorySize = S.bytes * 1e-6;
    OBJ.DIC = DIC;

    deleteNodes( OBJ.TreeNodes.DICData )
    OBJ = createDICNodes( OBJ, app );

    app.Projects( ProjectIndex ) = OBJ;
    
    TreeSelectionChangedFcn( app.Tree, [], app )

end


function VariableTreeCheckedNodesChangedFcn( ~, ~ )
    if ~isempty( VariableTree.CheckedNodes ) ...
            || ~isempty( VariableTree2.CheckedNodes )
        ConfirmButton.Enable = 'on';
    else; ConfirmButton.Enable = 'off';
    end
end


end
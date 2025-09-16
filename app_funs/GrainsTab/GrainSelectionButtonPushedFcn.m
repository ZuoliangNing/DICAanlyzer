function GrainSelectionButtonPushedFcn(~,~,app)


ProjectIndex = getProjectIndex( app.CurrentProjectSelection, app );
% ProjectIndex = app.CurrentProjectSelection;
obj = app.Projects( ProjectIndex );
EBSDIndex = getEBSDIndex( app.CurrentEBSDSelection, obj );
EBSDData = obj.EBSD.Data( EBSDIndex );
map = EBSDData.Map;

% ********** CREATE UI **********
DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
ButtonSize = app.ConstantValues.TextedButtonSize;
EditSize = app.ConstantValues.EditSize;
LabelWidth = 35;
NameEditWidth = 100;
SIZE = [280,300];

% ---------- UIFigure ----------
UIFigure = uifigure( ...
    'Name', DisplayNames.GrainSelection_UIFigure, ...
    'WindowStyle', 'alwaysontop', ...alwaysontop
    'Icon', app.ConstantValues.IconSource, ...
    'Resize', 'off' );
UIFigure.Position = getMiddlePosition( app.UIFigure.Position, ...
    SIZE );
%app.ConstantValues.GrainSelection_UIFigure_size

% ---------- GridLayoutMain ----------
GridLayoutMain = uigridlayout( UIFigure, ...
    'RowHeight',    { EditSize(2), 60, '1x', ButtonSize(2) }, ...
    'ColumnWidth',  { '1x' }, ...
    'Padding', 10*ones(1,4));

% ---------- GridLayoutName ----------
GridLayoutName = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { LabelWidth,NameEditWidth,'1x' }, ...
    'Padding', 0*ones(1,4));
GridLayoutName.Layout.Row = 1;

% ---------- NameLabel ----------
NameLabel = uilabel( GridLayoutName, ...
    'Text', DisplayNames.cm_Name );
NameLabel.Layout.Column = 1;

% ---------- NameEdit ----------
NameEdit = uieditfield( GridLayoutName, ...
    'Value', ['Selection',num2str(length(EBSDData.GrainGroup))] );
NameEdit.Layout.Column = 2;

% ---------- GridLayoutButtons ----------
GridLayoutButtons = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1), ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutButtons.Layout.Row = 4;

% ---------- ConfirmButton * ----------
ConfirmButton = uibutton( GridLayoutButtons, 'push', ...
    'Text', DisplayNames.uiopt_ok, ...
    'Enable', 'off', ...
    'ButtonPushedFcn', @ ConfirmButtonPushedFcn );
ConfirmButton.Layout.Row = 1; ConfirmButton.Layout.Column = 2;

% ---------- CancelButton ----------
CancelButton = uibutton( GridLayoutButtons, 'push', ...
    'Text', DisplayNames.uiopt_cancel, ...
    'ButtonPushedFcn', @(~,~) close(UIFigure) );
CancelButton.Layout.Row = 1; CancelButton.Layout.Column = 3;


% ---------- TypeButtonGroup ----------
TypeButtonGroup = uibuttongroup( GridLayoutMain, ...
    'Title', DisplayNames.GrainSelection_TypeButtonGroup_Title );
TypeButtonGroup.Layout.Row = 2;

ButtonSize = [80,20];
NumberButton = uiradiobutton( TypeButtonGroup, ...
    'Text', DisplayNames.GrainSelection_NumberButton_Text, ...
    'Position', [15,10,ButtonSize], ...
    'Value', true, ...
    'UserData', 'Number' );

PhaseButton = uiradiobutton( TypeButtonGroup, ...
    'Text', DisplayNames.GrainSelection_PhaseButton_Text, ...
    'Position', [15+ButtonSize(1),10,ButtonSize], ...
    'UserData', 'Phase' );

% ---------- GridLayout2 ----------
GridLayout2 = uigridlayout( GridLayoutMain, ...
    'ColumnWidth', {'1x', '1x'}, ...
    'RowHeight', {'1x'}, ...
    'ColumnSpacing', 5, ...
    'Padding', [0,0,0,0] );
GridLayout2.Layout.Row = 3;

% ---------- NumberPanel ----------
NumberPanel = uipanel( GridLayout2, ...
    "Title", DisplayNames.GrainSelection_NumberButton_Text );
NumberPanel.Layout.Column = 1;

% ---------- GridLayoutNumber ----------
GridLayoutNumber = uigridlayout( NumberPanel, ...
    'ColumnWidth', {'1x'}, ...
    'RowHeight', {EditSize(2),'1x'}, ...
    'RowSpacing', 5, ...
    'Padding', 5*[1,1,1,1] );

% ---------- NumberTree ----------
NumberTree = uitree( GridLayoutNumber );
NumberTree.Layout.Row = 2;

% ---------- GridLayoutNumber3 ----------
GridLayoutNumber3 = uigridlayout( GridLayoutNumber, ...
    'ColumnWidth', {EditSize(1),'1x',EditSize(2)-6,EditSize(2)-6}, ...
    'RowHeight', {'1x'}, ...
    'ColumnSpacing', 5, ...
    'Padding', 3*[1,1,1,1] );
GridLayoutNumber3.Layout.Row = 1;

% ---------- NumberEdit ----------
NumberEdit = uieditfield( GridLayoutNumber3, 'numeric', ...
    'Value', map.grains(1).ID );
NumberEdit.Layout.Column = 1;

% ---------- NumberAddButton ----------
NumberAddButton = uibutton( GridLayoutNumber3, ...
    'Text', '', 'Icon', 'add.png' );
NumberAddButton.Layout.Column = 3;

% ---------- NumberMinusButton ----------
NumberMinusButton = uibutton( GridLayoutNumber3, ...
    'Text', '', 'Icon', 'minus.png' );
NumberMinusButton.Layout.Column = 4;

% ---------- PhasePanel ----------
PhasePanel = uipanel( GridLayout2, ...
    "Title", DisplayNames.GrainSelection_PhaseButton_Text, ...
    'Enable', 'off' );
PhasePanel.Layout.Column = 2;

% ---------- GridLayoutPhase ----------
GridLayoutPhase = uigridlayout( PhasePanel, ...
    'ColumnWidth', {'1x'}, ...
    'RowHeight', {EditSize(2),'1x'}, ...
    'RowSpacing', 5, ...
    'Padding', 5*[1,1,1,1] );

% ---------- PhaseDropdown ----------
PhaseDropdown = uidropdown( GridLayoutPhase, ...
    'Items', EBSDData.PhaseNames );
PhaseDropdown.Layout.Row = 1;
if isempty( EBSDData.Phase )
    PhaseButton.Enable = 'off';
end


% ******************************


GrianNumbers = [];

% ******************************


TypeButtonGroup.SelectionChangedFcn = @TypeButtonGroupSelectionChangedFcn;
    function TypeButtonGroupSelectionChangedFcn( ButtonGroup, event )
        if strcmp(event.NewValue.UserData,'Number')
            NumberPanel.Enable = 'on';
            PhasePanel.Enable = 'off';
            if isempty( GrianNumbers ); ConfirmButton.Enable = 'off'; end
        else
            NumberPanel.Enable = 'off';
            PhasePanel.Enable = 'on';
            ConfirmButton.Enable = 'on';
        end
        
    end

NumberEdit.ValueChangedFcn = @ NumberEditValueChangedFcn;
    function NumberEditValueChangedFcn( ~, event )
        
        if ~any( event.Value == [map.grains.ID] )
            uialert( UIFigure, ...
                DisplayNames.invalidvalue_title, ...
                UIFigure.Name )
        end
    end


NumberAddButton.ButtonPushedFcn = @ NumberAddBButtonPushedFcn;
    function NumberAddBButtonPushedFcn( ~, ~ )
        val = NumberEdit.Value;
        if all( val ~= GrianNumbers )
            GrianNumbers = [ GrianNumbers, val ];
            NumberTree.Children = [ NumberTree.Children; ...
                uitreenode( NumberTree, ...
                    'Text', num2str(val), ...
                    'NodeData', val ) ];
            ConfirmButton.Enable = 'on';
        end

    end


NumberMinusButton.ButtonPushedFcn = @ NumberMinusButtonPushedFcn;
    function NumberMinusButtonPushedFcn( ~, ~ )
        node = NumberTree.SelectedNodes;
        if ~isempty( node )
            GrianNumbers = setdiff( GrianNumbers, node.NodeData );
            delete( node )
        end
        if isempty( GrianNumbers ); ConfirmButton.Enable = 'off'; end
    end


    function ConfirmButtonPushedFcn( ~, ~ )
        EBSDData.GrainGroupSerial = EBSDData.GrainGroupSerial + 1;
        if NumberButton.Value
            Index = arrayfun(@(val) ...
                        find(val == [map.grains.ID]), GrianNumbers);
        else
            i = find(strcmp( PhaseDropdown.Value, EBSDData.PhaseNames ));
            Index = find( i == [map.grains.phase] );
        end
        EBSDData.GrainGroup(end+1) = struct( ...
            'Name', NameEdit.Value, ...
            'Index', Index, ...
            'Serial', EBSDData.GrainGroupSerial );
        EBSDData.GrainGroupSelection = ...
            [ EBSDData.GrainGroupSelection, EBSDData.GrainGroupSerial ];
        obj.EBSD.Data( EBSDIndex ) = EBSDData;
        app.Projects( ProjectIndex ) = obj;
        close(UIFigure)
        createGrainSelectionTreeNodes( EBSDData, app )
        GrainSelectionTreeCheckedNodesChangedFcn( ...
            app.GrainSelectionTree, [], app )
        
    end


end
function MainNewMenuSelectedFcn(menu,~,app)


ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );%app.CurrentProjectSelection
obj = app.Projects( ProjectIndex );
EBSDData = [];
GrianNumbers = [];

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
% ********** CREATE UI **********
ButtonSize = app.ConstantValues.TextedButtonSize;
EditSize = app.ConstantValues.EditSize;
DropDownHeight = app.ConstantValues.DropDownHeight;
LabelWidth = 80; LabelHeight = 15;
NameEditWidth = 100;
SIZE = [300,400];
PhasePanelHeight = 60;

% ---------- UIFigure ----------
UIFigure = uifigure( ...
    'Name', DisplayNames.cm_New, ...
    'WindowStyle', 'alwaysontop', ...alwaysontop
    'Icon', app.ConstantValues.IconSource, ...
    'Resize', 'off' );
UIFigure.Position = getMiddlePosition( app.UIFigure.Position, ...
    SIZE );

% ---------- GridLayoutMain ----------
GridLayoutMain = uigridlayout( UIFigure, ...
    'RowHeight',    { EditSize(2), DropDownHeight, ...
                      LabelHeight, 60, '1x', ButtonSize(2) }, ...
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
    'Text', DisplayNames.ProjectNewMenuSelectedFcn_prompt );
NameLabel.Layout.Column = 1;

% ---------- NameEdit ----------
Name = [ app.TreeNodeTypes( app.Default.LanguageSelection ).Main, ...
        '-', num2str( app.Serial + 1 ) ];
NameEdit = uieditfield( GridLayoutName, ...
    'Value', Name );
NameEdit.Layout.Column = 2;

% ---------- GridLayoutButtons ----------
GridLayoutButtons = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1), ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutButtons.Layout.Row = 6;

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

% ---------- GridLayoutEBSDData ----------
GridLayoutEBSDData = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { LabelWidth, '1x' }, ...
    'Padding', zeros(1,4) );
GridLayoutEBSDData.Layout.Row = 2;

% ---------- EBSDDataLabel ----------
EBSDDataLabel = uilabel( GridLayoutEBSDData, ...
    'Text', DisplayNames.MainNewMenu_EBSDDataLabel_Text );
EBSDDataLabel.Layout.Column = 1;

% ---------- EBSDDataDropDown ----------
EBSDDataDropDown = uidropdown( GridLayoutEBSDData, ...
    'Items', {obj.EBSD.Data.DisplayName}, ...
    'ItemsData', 1:length(obj.EBSD.Data), ...
    'Value', 1, ...
    'ValueChangedFcn', @EBSDDataDropDownValueChangedFcn );
EBSDData = obj.EBSD.Data(1);
EBSDDataDropDown.Layout.Column = 2;
    function EBSDDataDropDownValueChangedFcn(dropdown,~)
        EBSDData = obj.EBSD.Data(dropdown.Value);
        GrianNumbers = [];
        if ~ManualButton.Value
            ConfirmButton.Enable = 'off';
        end
        delete( NumberTree.Children )
        if EBSDData.Flag.Adjusted
            IncludeDICCheckBox.Value = 1;
            % IncludeDICCheckBox.Enable = 'off';
        else
            IncludeDICCheckBox.Value = 0;
            % IncludeDICCheckBox.Enable = 'on';
        end
        if ~EBSDData.Flag.Polygonized
            NumberButton.Enable = 'off';
            NumberPanel.Enable = 'off';
            PhaseButton.Enable = 'off';
            PhasePanel.Enable = 'off';
            OptionPanel.Enable = 'off';
            MethodButtonGroup.SelectedObject = ManualButton;
            ConfirmButton.Enable = 'on';
        else
            NumberButton.Enable = 'on';
            % NumberPanel.Enable = 'on';
            PhaseButton = 'on';
            % PhasePanel.Enable = 'on';
            if ~any( NumberEdit.Value == [EBSDData.Map.grains.ID] )
                NumberEdit.Value = EBSDData.Map.grains(1).ID;
            end
        end
    end

% ---------- GridLayoutIncludeDIC ----------
GridLayoutIncludeDIC = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { LabelWidth, '1x' }, ...
    'Padding', zeros(1,4) );
GridLayoutIncludeDIC.Layout.Row = 3;

% ---------- IncludeDICCheckBox ----------
IncludeDICCheckBox = uicheckbox( GridLayoutIncludeDIC, ...
    'Text', DisplayNames.MainNewMenu_IncludeDICCheckBox_Text, ...
    'Enable', 'off' );
IncludeDICCheckBox.Layout.Column = 2;

% ---------- MethodButtonGroup ----------
MethodButtonGroup = uibuttongroup( GridLayoutMain, ...
    'Title', DisplayNames.MainNewMenu_MethodButtonGroup_Title, ...
    'SelectionChangedFcn', @MethodButtonGroupSelectionChangedFcn );
MethodButtonGroup.Layout.Row = 4;
ButtonSize = [80,20];
NumberButton = uiradiobutton( MethodButtonGroup, ...
    'Text', DisplayNames.GrainSelection_NumberButton_Text, ...
    'Position', [15,10,ButtonSize], ...
    'Value', true, ...
    'UserData', 'Number' );
PhaseButton = uiradiobutton( MethodButtonGroup, ...
    'Text', DisplayNames.GrainSelection_PhaseButton_Text, ...
    'Position', [15+ButtonSize(1),10,ButtonSize], ...
    'UserData', 'Phase' );
ManualButton = uiradiobutton( MethodButtonGroup, ...
    'Text', DisplayNames.MainNewMenu_ManualButton_Text, ...
    'Position', [2*ButtonSize(1),10,ButtonSize], ...
    'UserData', 'Manual' );
    function MethodButtonGroupSelectionChangedFcn(~,event)
        switch event.NewValue.UserData
            case 'Number'
                NumberPanel.Enable = 'on';
                PhasePanel.Enable = 'off';
                OptionPanel.Enable = 'on';
                if isempty( GrianNumbers ); ConfirmButton.Enable = 'off'; end
            case 'Phase'
                NumberPanel.Enable = 'off';
                PhasePanel.Enable = 'on';
                ConfirmButton.Enable = 'on';
                OptionPanel.Enable = 'on';
            case 'Manual'
                NumberPanel.Enable = 'off';
                PhasePanel.Enable = 'off';
                OptionPanel.Enable = 'off';
                ConfirmButton.Enable = 'on';
        end
    end

% ---------- GridLayout2 ----------
GridLayout2 = uigridlayout( GridLayoutMain, ...
    'ColumnWidth', {'1x', '1x'}, ...
    'RowHeight', {'1x'}, ...
    'ColumnSpacing', 5, ...
    'Padding', [0,0,0,0] );
GridLayout2.Layout.Row = 5;

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
NumberEdit = uieditfield( GridLayoutNumber3,'numeric', ...
    'ValueChangedFcn', @ NumberEditValueChangedFcn, ...
    'AllowEmpty','on');
NumberEdit.Layout.Column = 1;
if EBSDData.Flag.Polygonized
    NumberEdit.Value = EBSDData.Map.grains(1).ID;
end
    function NumberEditValueChangedFcn( ~, event )
        if ~any( event.Value == [EBSDData.Map.grains.ID] )
            uialert( UIFigure, ...
                DisplayNames.invalidvalue_title, ...
                UIFigure.Name )
        end

    end

% ---------- NumberAddButton ----------
NumberAddButton = uibutton( GridLayoutNumber3, ...
    'Text', '', 'Icon', 'add.png', ...
    'ButtonPushedFcn', @ NumberAddBButtonPushedFcn );
NumberAddButton.Layout.Column = 3;
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

% ---------- NumberMinusButton ----------
NumberMinusButton = uibutton( GridLayoutNumber3, ...
    'Text', '', 'Icon', 'minus.png', ...
    'ButtonPushedFcn', @ NumberMinusButtonPushedFcn );
NumberMinusButton.Layout.Column = 4;
    function NumberMinusButtonPushedFcn( ~, ~ )
        node = NumberTree.SelectedNodes;
        if ~isempty( node )
            GrianNumbers = setdiff( GrianNumbers, node.NodeData );
            delete( node )
        end
        if isempty( GrianNumbers ); ConfirmButton.Enable = 'off'; end
    end

% ---------- GridLayout3 ----------
GridLayout3 = uigridlayout( GridLayout2, ...
    'ColumnWidth', {'1x'}, ...
    'RowHeight', {PhasePanelHeight,'1x'}, ...
    'Padding', 0*[1,1,1,1] );
GridLayout3.Layout.Column = 2;

% ---------- PhasePanel ----------
PhasePanel = uipanel( GridLayout3, ...
    "Title", DisplayNames.GrainSelection_PhaseButton_Text, ...
    'Enable', 'off' );
PhasePanel.Layout.Row = 1;

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

% ---------- OptionPanel ----------
OptionPanel = uipanel( GridLayout3, ...
    "Title", DisplayNames.MainNewMenu_OptionPanel_Title );
OptionPanel.Layout.Row = 2;

% ---------- GridLayoutOption ----------
GridLayoutPhase = uigridlayout( OptionPanel, ...
    'ColumnWidth', {75,30}, ...
    'RowHeight', {'1x','1x'}, ...
    'RowSpacing', 5, ...
    'Padding', 10*[1,1,1,1] );

% ---------- IncludeOtherGrainsCheckBox ----------
IncludeOtherGrainsCheckBox = uicheckbox( GridLayoutPhase, ...
    'Text', DisplayNames.MainNewMenu_IncludeOtherGrainsCheckBox_Text, ...
    'Value', true );
IncludeOtherGrainsCheckBox.Layout.Row = 1;
IncludeOtherGrainsCheckBox.Layout.Column = [1,3];

% ---------- PaddingCheckBox ----------
PaddingCheckBox = uicheckbox( GridLayoutPhase, ...
    'Text', DisplayNames.MainNewMenu_PaddingCheckBox_Text, ...
    'ValueChangedFcn', @ PaddingCheckBoxValueChangedFcn);
PaddingCheckBox.Layout.Row = 2;
PaddingCheckBox.Layout.Column = 1;
    function PaddingCheckBoxValueChangedFcn(~,event)
        if event.Value
            PaddingEdit.Enable = 'on';
        else; PaddingEdit.Enable = 'off';
        end

    end

% ---------- PaddingEdit ----------
PaddingEdit = uieditfield( GridLayoutPhase, 'numeric', ...
    'Value', 10, ...
    'Enable', 'off' );
PaddingEdit.Layout.Row = 2;
PaddingEdit.Layout.Column = 2;



EBSDDataDropDownValueChangedFcn( EBSDDataDropDown, [] )
OldEnableStates = [];
PreviousWindowButtonMotionFcn = [];

    function ConfirmButtonPushedFcn( ~, ~ )
        if OptionPanel.Enable % by Grain Selection
            if NumberButton.Value
                Index = arrayfun(@(val) ...
                    find(val == [EBSDData.Map.grains.ID]), GrianNumbers);
            else
                i = find(strcmp( PhaseDropdown.Value, EBSDData.PhaseNames ));
                Index = find( i == [EBSDData.Map.grains.phase] );
            end
            
            objName = NameEdit.Value;
            EBSDDataind = EBSDDataDropDown.Value;
            DICFlag = IncludeDICCheckBox.Value;
            dlg = uiprogressdlg( app.UIFigure );
            IncludeOtherFlag = IncludeOtherGrainsCheckBox.Value;
            if PaddingCheckBox.Value
                Padding = PaddingEdit.Value;
            else; Padding = [];
            end
    
            delete( UIFigure )
    
            obj.createbyGrianSelection( ...
                objName, Index, EBSDDataind, ...
                DICFlag, IncludeOtherFlag, Padding, ...
                app.ConstantValues.EBSDVariables, app, dlg )

        else % Manual

            UIFigure.Visible = 'off';

            if strcmp(app.TabGroup.SelectedTab.Tag,'1') % DIC
                axe = app.UIAxesImages;
            else; axe = app.UIAxesImages2;
            end
            if isempty(axe.Children) || ...
                    app.CurrentProjectSelection ~= menu.Parent.UserData.Serial ...
                    || getEBSDIndex( app.CurrentEBSDSelection, obj ) ...
                        ~= EBSDDataDropDown.Value
                uialert( app.UIFigure, ...
                    DisplayNames.MainNewMenu_uialert_Message, ...
                    DisplayNames.cm_New, ...
                    'CloseFcn', {@uialertCloseFcn,UIFigure})
                return
            end
            

            OldEnableStates = setUIsOff(app);
            % axe.Visible = 'on';

            axe.UserData = struct( ...
                'Lines', [], ...
                'Pos1', [], ...
                'Pos2', [], ...
                'ContextMenu', axe.Children(end).ContextMenu );
            % axe.Children(end).ContextMenu = '';
            app.CurrentImage2.ContextMenu = '';
            cm = uicontextmenu( app.UIFigure );
            uimenu( cm, ...
                'Text', app.OtherDisplayNames( app.Default.LanguageSelection ). ...
                            Adjust_Complete, ...
                'MenuSelectedFcn', ...
                    {@ createbyManualCompleteMenuSelectedFcn, axe} )

            PreviousWindowButtonMotionFcn = app.UIFigure.WindowButtonMotionFcn;
            app.UIFigure.WindowButtonMotionFcn = ...
                { @ createbyManualWindowButtonMotionFcn, axe, app };
            app.UIFigure.KeyPressFcn = ...
                { @ createbyManualKeyPressFcn, axe, OldEnableStates, app, UIFigure };
            app.UIFigure.WindowButtonDownFcn = ...
                { @ createbyManualWindowButtonDownFcn, axe, app, cm };
            

        end

    end

    function uialertCloseFcn(~,~,UIFigure)
        set(UIFigure,'Visible','on')
    end

    function createbyManualCompleteMenuSelectedFcn(~,~,axe)

        objName = NameEdit.Value;
        EBSDDataind = EBSDDataDropDown.Value;
        DICFlag = IncludeDICCheckBox.Value;
        Bounding = [ axe.UserData.Pos1, axe.UserData.Pos2 ];

        delete(axe.UserData.Lines)
        setUIsOn( OldEnableStates, app )
        app.UIFigure.WindowButtonMotionFcn = PreviousWindowButtonMotionFcn;
        app.UIFigure.WindowButtonDownFcn = '';
        app.UIFigure.KeyPressFcn = { @UIFigureKeyPressFcn, app };
        axe.Children(end).ContextMenu = axe.UserData.ContextMenu;
        axe.UserData = [];
        delete( UIFigure )

        dlg = uiprogressdlg( app.UIFigure );

        obj.createbyBounding( ...
            objName, Bounding, EBSDDataind, ...
            DICFlag, ...
            app.ConstantValues.EBSDVariables, app, dlg )

    end

end
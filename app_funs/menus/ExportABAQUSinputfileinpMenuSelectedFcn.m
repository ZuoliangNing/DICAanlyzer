function ExportABAQUSinputfileinpMenuSelectedFcn( ~, ~, app )

objs = app.Projects;
if isempty(objs); return; end

% ********** CREATE UI **********
DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
ButtonSize = app.ConstantValues.TextedButtonSize;
EditSize = app.ConstantValues.EditSize;
DropDownHeight = app.ConstantValues.DropDownHeight;
PanelHeight = 60; EditHeight = 25;
LabelHeight = 15;
TableHeight = 120;
SIZE = [ 320, ...
    DropDownHeight*3+PanelHeight+EditHeight*2 +...
    LabelHeight*2+ButtonSize(2) + 10 ...
    + 10*12 + 10 + TableHeight + LabelHeight*2 ];


% ---------- UIFigure ----------
UIFigure = uifigure( ...
    'Name', DisplayNames.ExportABAQUSinputfileinpMenu_UIFigure, ...
    'WindowStyle', 'alwaysontop', ...alwaysontop
    'Icon', app.ConstantValues.IconSource, ...
    'Resize', 'off' );
UIFigure.Position = getMiddlePosition( app.UIFigure.Position, ...
    SIZE );

% ---------- GridLayoutMain ----------
GridLayoutMain = uigridlayout( UIFigure, ...
    'RowHeight',    { DropDownHeight,DropDownHeight, ...
                      PanelHeight, ...
                      EditHeight, EditHeight, LabelHeight, LabelHeight, ...
                      TableHeight, ...
                      LabelHeight, ...
                      LabelHeight, DropDownHeight, ...
                      ButtonSize(2) }, ...
    'ColumnWidth',  { '2x','3x','1x' }, ...
    'Padding', 15*ones(1,4));

% ---------- GridLayoutButtons ----------
GridLayoutButtons = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1), ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutButtons.Layout.Row = 12;
GridLayoutButtons.Layout.Column = [2,3];

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

% ---------- ProjectDropDown ----------
ind = find( logical( arrayfun( @(obj) obj.Flag.EBSDData, objs ) ) );
temp = 1:length(objs);
ProjectDropDown = uidropdown( GridLayoutMain, ...
    'Items', {objs(ind).DisplayName}, ...
    'ItemsData', temp(ind), ...
    'Value', temp(ind(1)), ...
    'ValueChangedFcn', @ ProjectDropDownValueChangedFcn );
ProjectDropDown.Layout.Row = 1;
ProjectDropDown.Layout.Column = [2,3];

% ---------- EBSDLabel ----------
EBSDLabel = uilabel( GridLayoutMain, ...
    'Text', DisplayNames.ExportDataMenu_EBSDPanel_Title );
EBSDLabel.Layout.Row = 2;

% ---------- EBSDDropDown ----------
EBSDDropDown = uidropdown( GridLayoutMain, ...
    'ValueChangedFcn', @ EBSDDropDownValueChangedFcn );
EBSDDropDown.Layout.Row = 2;
EBSDDropDown.Layout.Column = [2,3];

% ---------- DICPanel ----------
DICPanel = uipanel( GridLayoutMain, ...
    "Title", DisplayNames.ExportDataMenu_DICPanel_Title );
DICPanel.Layout.Row = 3;
DICPanel.Layout.Column = [1,3];

% ---------- GridLayoutDIC ----------
GridLayoutDIC = uigridlayout( DICPanel, ...
    'ColumnWidth', {'2x','1x','2x'}, ...
    'RowHeight', {'1x'}, ...
    'ColumnSpacing', 5, ...
    'Padding', 5*[1,1,1,1] );

% ---------- IncludeDipsBCCheckBox ----------
IncludeDipsBCCheckBox = uicheckbox( GridLayoutDIC, ...
    'Text', 'Include disp BCs', ...
    'Value', true  );
IncludeDipsBCCheckBox.Layout.Column = 1;

% ---------- DICStageLabel ----------
DICStageLabel = uilabel( GridLayoutDIC, ...
    'Text', DisplayNames.ExportDataMenu_DICStageLabel_text, ...
    'HorizontalAlignment', 'right' );
DICStageLabel.Layout.Column = 2;

% ---------- DICStageDropDown ----------
DICStageDropDown = uidropdown( GridLayoutDIC );
DICStageDropDown.Layout.Column = 3;

% ---------- MaxNumberLabel ----------
MaxNumberLabel = uilabel( GridLayoutMain, ...
    'Text', 'Maximum element number on edges:' );
MaxNumberLabel.Layout.Row = 4;
MaxNumberLabel.Layout.Column = [1,2];

% ---------- MaxNumberEdit ----------
MaxNumberEdit = uieditfield( GridLayoutMain, 'numeric',...
    'Value', app.Default.Options.ExportData.MaxElemNumberOnEdge );
MaxNumberEdit.Layout.Row = 4;
MaxNumberEdit.Layout.Column = 3;

% ---------- ZLayerLabel ----------
ZLayerLabel = uilabel( GridLayoutMain, ...
    'Text', 'Number of layers in Z direction:' );
ZLayerLabel.Layout.Row = 5;
ZLayerLabel.Layout.Column = [1,2];

% ---------- ZLayerEdit ----------
ZLayerEdit = uieditfield( GridLayoutMain, 'numeric',...
    'Value', app.Default.Options.ExportData.ZLayerNumber );
ZLayerEdit.Layout.Row = 5;
ZLayerEdit.Layout.Column = 3;

% ---------- ParametersLabel ----------
ParametersLabel = uilabel( GridLayoutMain, ...
    'Text', 'Parameters:' );
ParametersLabel.Layout.Row = 7;
ParametersLabel.Layout.Column = [1,2];

% ---------- ParametersTable ----------
InpParametersTable = uitable( GridLayoutMain, 'ColumnEditable', true );
InpParametersTable.Layout.Row = 8;
InpParametersTable.Layout.Column = [1,3];

% ---------- CoincideCoordsCheckBox ----------
CoincideCoordsCheckBox = uicheckbox( GridLayoutMain, ...
    'Text', 'Use coincident Sample & Image coordinates', ...
    'Value', true  );
CoincideCoordsCheckBox.Layout.Column = [1,3];
CoincideCoordsCheckBox.Layout.Row = 6;

% ---------- PlotCheckBox ----------
PlotCheckBox = uicheckbox( GridLayoutMain, ...
    'Text', 'Plot Shapes and Disps before & after deformation', ...
    'Value', true  );
PlotCheckBox.Layout.Column = [1,3];
PlotCheckBox.Layout.Row = 9;

% ---------- UserMaterialLabel ----------
UserMaterialLabel = uilabel( GridLayoutMain, ...
    'Text', 'Format of user material constants:' );
UserMaterialLabel.Layout.Row = 10;
UserMaterialLabel.Layout.Column = [1,3];

% ---------- UserMaterialDropDown ----------
ItemsData = fieldnames( app.ConstantValues.UserMaterialFormats );
Items = cellfun( @(str) ...
    app.ConstantValues.UserMaterialFormats.(str).Name, ...
    ItemsData, 'UniformOutput', false );
UserMaterialDropDown = uidropdown( GridLayoutMain, ...
    'Items', Items, ...
    'ItemsData', ItemsData, ...
    'Value', ItemsData{ app.Default.Options.ExportData.UserMaterialFormatSelection }, ...
    'ValueChangedFcn', @ UserMaterialDropDownValueChangedFcn);

UserMaterialDropDown.Layout.Row = 11;
UserMaterialDropDown.Layout.Column = [2,3];

% ---------- TextArea ----------
TextArea = uitextarea( GridLayoutMain );
TextArea.Layout.Row = [11,12];
TextArea.Layout.Column = 1;

% *********************************

ProjectDropDownValueChangedFcn( ProjectDropDown ,[] )
EBSDDropDownValueChangedFcn( EBSDDropDown , [] )
UserMaterialDropDownValueChangedFcn( UserMaterialDropDown , [] )

InpParametersTable.RowName = { 'Time Period', 'Initial Increment', ...
    'Min Increment', 'Max Increment', 'Max Number of Increments', ...
    'Part Name'};
InpParametersTable.ColumnName = [];
InpParametersTable.Data = app.Default.Options.ExportData.InpParameters';


% *********************************

    function ProjectDropDownValueChangedFcn( dropdown , ~ )
        obj = objs( dropdown.Value );
    
        if ~obj.Flag.EBSDData
            EBSDDropDown.Items = {};
            EBSDDropDown.Enable = 'off';
            ConfirmButton.Enable = 'off';
        else
            Names = {obj.EBSD.Data.DisplayName};
            EBSDDropDown.Items = Names;
            EBSDDropDown.ItemsData = 1:length(Names);
            EBSDDropDown.Enable = 'on';
            ConfirmButton.Enable = 'on';
        end
    
        EBSDDropDownValueChangedFcn( EBSDDropDown , [] )

    end

    function EBSDDropDownValueChangedFcn( dropdown , ~ )
        obj = objs( ProjectDropDown.Value );
        EBSDData = obj.EBSD.Data( dropdown.Value );
        if EBSDData.Flag.Adjusted
            DICPanel.Enable = 'on';
            PlotCheckBox.Enable = 'on';
            DICStageDropDown.Items = arrayfun( ...
                @num2str, 1:obj.DIC.StageNumber, 'UniformOutput', false );
            DICStageDropDown.ItemsData = 1:obj.DIC.StageNumber;
            DICStageDropDown.Value = DICStageDropDown.ItemsData(end);
            if obj.DIC.StageNumber > 1
                DICStageDropDown.Items = [ 'All', ...
                    DICStageDropDown.Items ];
                DICStageDropDown.ItemsData = [ 0, ...
                    DICStageDropDown.ItemsData ];
                DICStageDropDown.Value = DICStageDropDown.ItemsData(1);
            end
        else
            DICPanel.Enable = 'off';
            PlotCheckBox.Enable = 'off';
            DICStageDropDown.Items = {};
        end

    end

    function UserMaterialDropDownValueChangedFcn( dropdown , ~ )

        TextArea.Value = app.ConstantValues. ...
            UserMaterialFormats.( dropdown.Value ).Info;

    end

    function ConfirmButtonPushedFcn( ~, ~ )
        
        obj = objs( ProjectDropDown.Value );
        EBSDData = obj.EBSD.Data( EBSDDropDown.Value );

        % ------ SELECT Path ------
        path = uigetdir( app.Default.Path.ExportABAQUSinputfile, ...
            DisplayNames.ExportABAQUSinputfileinpMenu_UIFigure );
        if ~path; UIFigure.WindowStyle = 'alwaysontop'; return; end
        app.Default.Path.ExportABAQUSinputfile = path;

        % NewFileName = [ obj.DisplayName,'-',EBSDData.DisplayName ];
        NewFileName = obj.DisplayName;
        NewFileName = [ path, '\', NewFileName, '.inp' ];

        Threshold = MaxNumberEdit.Value;
        app.Default.Options.ExportData.MaxElemNumberOnEdge = Threshold;

        zVox = ZLayerEdit.Value;
        app.Default.Options.ExportData.ZLayerNumber = zVox;

        CoincideCoordsFlag = CoincideCoordsCheckBox.Value;

        InpParameters = InpParametersTable.Data';
        app.Default.Options.ExportData.InpParameters = InpParameters;

        PlotFlag = PlotCheckBox.Value;
        
        UserMaterialFormat = UserMaterialDropDown.Value;
        app.Default.Options.ExportData.UserMaterialFormatSelection = ...
            find( strcmp( UserMaterialFormat, UserMaterialDropDown.ItemsData ) );
        UserMaterialFormatFun = app.ConstantValues. ...
            UserMaterialFormats.( UserMaterialFormat ).fun;

        % ------ DIC Data ------
        if DICPanel.Enable && IncludeDipsBCCheckBox.Value
            DICStage = DICStageDropDown.Value;
        else; DICStage = [];
        end
       
        % ------ Write inp file ------
        close( UIFigure )

        dlg = uiprogressdlg( app.UIFigure, ...
            'Indeterminate', 'on', ...
            'Title', DisplayNames.ExportABAQUSinputfileinpMenu_UIFigure );

        exportInpFile( obj, EBSDData, NewFileName, ...
            Threshold, zVox, CoincideCoordsFlag, InpParameters, ...
            PlotFlag, UserMaterialFormatFun, DICStage, dlg )

    end


end
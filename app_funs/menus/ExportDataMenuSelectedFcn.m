function ExportDataMenuSelectedFcn( ~, ~, app )

objs = app.Projects;
if isempty(objs); return; end

% ********** CREATE UI **********
DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
SIZE = [420,420];
ButtonSize = app.ConstantValues.TextedButtonSize;
EditSize = app.ConstantValues.EditSize;
DropDownHeight = app.ConstantValues.DropDownHeight;
LabelWidth = 80; LabelHeight = 15;

% ---------- UIFigure ----------
UIFigure = uifigure( ...
    'Name', DisplayNames.ExportDataMenu_UIFigure, ...
    'WindowStyle', 'alwaysontop', ...alwaysontop
    'Icon', app.ConstantValues.IconSource, ...
    'Resize', 'off' );
UIFigure.Position = getMiddlePosition( app.UIFigure.Position, ...
    SIZE );

% ---------- GridLayoutMain ----------
GridLayoutMain = uigridlayout( UIFigure, ...
    'RowHeight',    { LabelHeight, DropDownHeight, ...
                      '1x', LabelHeight, LabelHeight, LabelHeight, ButtonSize(2) }, ...
    'ColumnWidth',  { '1x','1x' }, ...
    'Padding', 15*ones(1,4));

% ---------- GridLayoutButtons ----------
GridLayoutButtons = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1), ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutButtons.Layout.Row = 7;
GridLayoutButtons.Layout.Column = 2;

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
ProjectLabel.Layout.Column = 1;

% ---------- ProjectDropDown ----------
ProjectDropDown = uidropdown( GridLayoutMain, ...
    'Items', {objs.DisplayName}, ...
    'ItemsData', 1:length(objs), ...
    'Value', 1, ...
    'ValueChangedFcn', @ ProjectDropDownValueChangedFcn );
ProjectDropDown.Layout.Row = 2;
ProjectDropDown.Layout.Column = 1;

% ---------- EBSDPanel ----------
EBSDPanel = uipanel( GridLayoutMain, ...
    "Title", DisplayNames.ExportDataMenu_EBSDPanel_Title );
EBSDPanel.Layout.Row = [2,3];
EBSDPanel.Layout.Column = 2;

% ---------- GridLayoutEBSD ----------
GridLayoutEBSD = uigridlayout( EBSDPanel, ...
    'ColumnWidth', {'1x'}, ...
    'RowHeight', {DropDownHeight,'1x'}, ...
    'Padding', 10*[1,1,1,1] );

% ---------- EBSDDropDown ----------
EBSDDropDown = uidropdown( GridLayoutEBSD, ...
    'ValueChangedFcn', @ EBSDDropDownValueChangedFcn );
EBSDDropDown.Layout.Row = 1;

% ---------- EBSDTree ----------
EBSDTree = uitree( GridLayoutEBSD, 'checkbox', ...
    'CheckedNodesChangedFcn', @(~,~) checkConfirmButton );
EBSDTree.Layout.Row = 2;

% ---------- DICPanel ----------
DICPanel = uipanel( GridLayoutMain, ...
    "Title", DisplayNames.ExportDataMenu_DICPanel_Title );
DICPanel.Layout.Row = 3;
DICPanel.Layout.Column = 1;

% ---------- GridLayoutDIC ----------
GridLayoutDIC = uigridlayout( DICPanel, ...
    'ColumnWidth', {'1x'}, ...
    'RowHeight', {'1x',DropDownHeight}, ...
    'Padding', 10*[1,1,1,1] );

% ---------- DICTree ----------
DICTree = uitree( GridLayoutDIC, 'checkbox', ...
    'CheckedNodesChangedFcn', @(~,~) checkConfirmButton );
DICTree.Layout.Row = 1;

% ---------- GridLayoutDICStage ----------
GridLayoutDICStage = uigridlayout( GridLayoutDIC, ...
    'ColumnWidth', {'1x',50}, ...
    'RowHeight', {'1x'}, ...
    'Padding', 0*[1,1,1,1] );
GridLayoutDICStage.Layout.Row = 2;

% ---------- DICStageLabel ----------
DICStageLabel = uilabel( GridLayoutDICStage, ...
    'Text', DisplayNames.ExportDataMenu_DICStageLabel_text, ...
    'HorizontalAlignment', 'right' );
DICStageLabel.Layout.Column = 1;

% ---------- DICStageDropDown ----------
DICStageDropDown = uidropdown( GridLayoutDICStage );
DICStageDropDown.Layout.Column = 2;

% ---------- ExportDICSeparatelyCheckBox ----------
% ExportDICSeparatelyCheckBox = uicheckbox( GridLayoutMain, ...
%     'Text', DisplayNames.ExportDataMenu_ExportDICSeparatelyCheckBox_Text, ...
%     'Value', app.Default.Options.ExportData.ExportDICSeparately );
% ExportDICSeparatelyCheckBox.Layout.Row = 4;

% ---------- UsePolygonizedIDCheckBox ----------
UsePolygonizedIDCheckBox = uicheckbox( GridLayoutMain, ...
    'Text', DisplayNames.ExportDataMenu_UsePolygonizedCheckBox_Text, ...
    'Value', app.Default.Options.ExportData.UsePolygonizedID  );
UsePolygonizedIDCheckBox.Layout.Row = 4;
UsePolygonizedIDCheckBox.Layout.Column = 2;

% ---------- BoundaryOnlyCheckBox ----------
BoundaryOnlyCheckBox = uicheckbox( GridLayoutMain, ...
    'Text', DisplayNames.ExportDataMenu_BoundaryOnlyCheckBox_Text, ...
    'Value', app.Default.Options.ExportData.BoundaryOnly );
BoundaryOnlyCheckBox.Layout.Row = 4;
BoundaryOnlyCheckBox.Layout.Column = 1;

% ---------- FormatButtonGroup ----------
% FormatButtonGroup = uibuttongroup( GridLayoutMain, ...
%     'Title', DisplayNames.ExportDataMenu_FormatButtonGroup_Title, ...
%     'SelectionChangedFcn', @ MethodButtonGroupSelectionChangedFcn );
% FormatButtonGroup.Layout.Row = [6,7];

% ---------- GridLayoutMaxNumber ----------
GridLayoutMaxNumber = uigridlayout( GridLayoutMain, ...
    'ColumnWidth', {'1x',40}, ...
    'RowHeight', {'1x'}, ...
    'Padding', 5*[1,1,1,1] );
GridLayoutMaxNumber.Layout.Row = [5,6];
GridLayoutMaxNumber.Layout.Column = 2;

% ---------- MaxNumberLabel ----------
MaxNumberLabel = uilabel( GridLayoutMaxNumber, ...
    'Text', DisplayNames.MaximumElementNumber_Text, ...
    'HorizontalAlignment', 'right', ...
    'WordWrap', 'on' );
MaxNumberLabel.Layout.Column = 1;

% ---------- MaxNumberEdit ----------
MaxNumberEdit = uieditfield( GridLayoutMaxNumber, 'numeric',...
    'Value', app.Default.Options.ExportData.MaxElemNumberOnEdge );
MaxNumberEdit.Layout.Column = 2;


% *********************************

obj = []; EBSDData = [];
ProjectDropDownValueChangedFcn( ProjectDropDown, [] )



% *********************************

    function ProjectDropDownValueChangedFcn( dropdown ,~ )
        obj = objs( dropdown.Value );

        delete( DICTree.Children )
        delete( EBSDTree.Children )

        if ~obj.Flag.EBSDData
            EBSDPanel.Enable = 'off';
            EBSDDropDown.Items = {''};
            UsePolygonizedIDCheckBox.Enable = 'off';
        else
            EBSDPanel.Enable = 'on';
            Names = {obj.EBSD.Data.DisplayName};
            EBSDDropDown.Items = Names;
            EBSDDropDown.ItemsData = 1:length(Names);
            EBSDDropDownValueChangedFcn( EBSDDropDown, [] )
            % UsePolygonizedIDCheckBox.Enable = 'on';
        end
        if ~obj.Flag.DICPreprocess
            DICPanel.Enable = 'off';
            BoundaryOnlyCheckBox.Enable = 'off';
            % ExportDICSeparatelyCheckBox.Enable = 'off';
            DICStageDropDown.Enable = 'off';
        else
            DICPanel.Enable = 'on';
            BoundaryOnlyCheckBox.Enable = 'on';
            % ExportDICSeparatelyCheckBox.Enable = 'on';
            DICStageDropDown.Enable = 'on';
            Names = fieldnames( obj.TreeNodes.DICData );
            for j = 1:length( Names )
                node = obj.TreeNodes.DICData.( Names{j} );
                uitreenode( DICTree, ...
                    'Text', node.Text, ...
                    'NodeData', Names{j} );
            end
            DICStageDropDown.Items = arrayfun( ...
                @num2str, 1:obj.DIC.StageNumber, 'UniformOutput', false );
            DICStageDropDown.ItemsData = 1:obj.DIC.StageNumber;
        end
        checkConfirmButton()
    end

    function EBSDDropDownValueChangedFcn( dropdown ,~ )
        delete( EBSDTree.Children )
        ind = dropdown.Value;
        EBSDData = obj.EBSD.Data( ind );
        Texts = app.ConstantValues.EBSDVariableNames ...
            ( app.Default.LanguageSelection );

        Names = fieldnames( obj.TreeNodes.EBSDData(ind) );
        ind2 = structfun( @(node) ...
            node.NodeData.Enable, obj.TreeNodes.EBSDData(ind) );
        Names = setdiff( Names(ind2), 'IPF' );
        % 'IPF' cannot be exported!
        Names = [ 'Coords', 'EulerAngles', Names' ];
        % 'EulerAngles' and 'Coords' need to be added!
        for k = 1:length( Names )
            uitreenode( EBSDTree, ...
                'Text', Texts.( Names{k} ), ...
                'NodeData', Names{k} );
        end

    end

    function checkConfirmButton()
        if isempty( EBSDTree.CheckedNodes ) && isempty( DICTree.CheckedNodes )
            ConfirmButton.Enable = 'off';
        else
            ConfirmButton.Enable = 'on';
        end
    end

    function ConfirmButtonPushedFcn(~,~)

        % ------ SELECT Path ------
        path = uigetdir( app.Default.Path.ExportData, ...
            DisplayNames.ExportDataMenu_UIFigure );
        if ~path; UIFigure.WindowStyle = 'alwaysontop'; return; end
        
        app.Default.Path.ExportData = path;

        app.TextArea.Value = {''};
        
        Threshold = MaxNumberEdit.Value;
        app.Default.Options.ExportData.MaxElemNumberOnEdge = Threshold;

        if ~isempty( DICTree.CheckedNodes )
            DICNames = { DICTree.CheckedNodes.NodeData };
        else; DICNames = [];
        end
        if ~isempty( EBSDTree.CheckedNodes )
            EBSDNames = { EBSDTree.CheckedNodes.NodeData };
        else; EBSDNames = [];
        end
        DICStage = DICStageDropDown.Value;
        BoundaryOnlyFlag = BoundaryOnlyCheckBox.Value;
        UsePolygonizedIDFlag = UsePolygonizedIDCheckBox.Value;
        close( UIFigure )

        dlg = uiprogressdlg( app.UIFigure, ...
                'Indeterminate', 'on', ...
                'Title', DisplayNames.ExportDataMenu_UIFigure );

        if ~isempty( DICNames )

            % ------ GENERATE DIC Data ------
            
            DICData = obj.DIC.Data( DICStage );
            
            app.Default.Options.ExportData.BoundaryOnly = BoundaryOnlyFlag;

            DefaultDICVariables = app.ConstantValues.DICVariables;
            DefaultDICVariableNames = app.ConstantValues.DICVariableNames ...
                ( app.Default.LanguageSelection );
            UserDICVariables = app.DICPreprocessMethods. ...
                ( obj.DIC.PreprocessMethod ).VariableNames;
            if ~isempty( UserDICVariables )
                TitleTexts = cellfun( @(name) setfield( ...
                    DefaultDICVariableNames, name, name ), UserDICVariables );
            else
                TitleTexts = DefaultDICVariableNames;
            end
            ClaculatedDICVariables = setdiff( fieldnames( obj.DIC.Data ), ...
                [ DefaultDICVariables, UserDICVariables ] );
            if ~isempty( ClaculatedDICVariables )
                for i = 1:length( ClaculatedDICVariables )
                    VariableName = ClaculatedDICVariables{i};
                    Name = app.DICCalculateMethods.( VariableName ). ...
                        Name{app.Default.LanguageSelection};
                    TitleTexts.(VariableName) = Name;
                end
            end
            temp = app.ConstantValues.EBSDVariableNames ...
                ( app.Default.LanguageSelection ).Coords;
            TitleTexts.X = [ temp, '-X' ];
            TitleTexts.Y = [ temp, '-Y' ];
            dlg.Message = 'Generating DIC data ...';

            % **** get DIC DATA ****
            allData = getExportDICData( DICData, obj.DIC.XData, obj.DIC.YData, ...
                obj.DIC.DataValueRange, Threshold, BoundaryOnlyFlag );

            DICNames = [ 'X', 'Y', DICNames ];
            Title = cellfun( @(name) TitleTexts.( name ), ...
                DICNames, 'UniformOutput', false );
            Data = cell2mat( cellfun( @(name) allData.( name ), ...
                DICNames, 'UniformOutput', false ) );

            % ------ SAVE DIC Data ------
            FileName = [ obj.DisplayName, ...
                '-Stage ',num2str(DICStage),'-Exported_DIC' ];
            FileName = [ path, '\', FileName, '.txt' ];
    
            dispText( app.TextArea, 'Export DIC Data File: ' )
            dispText( app.TextArea, FileName )

            dlg.Message = ['Exporting DIC data ', FileName, ' ...'];
    
            Title = arrayfun( @(i)[num2str(i),'-',Title{i}], ...
                1:length(Title),'UniformOutput',false);
            writecell( Title, FileName, ...
                'WriteMode', 'overwrite', ...
                'Delimiter', '\t' )
            writematrix( Data, FileName, ...
                'WriteMode', 'append', ...
                'Delimiter', '\t' )

        end

        if ~isempty( EBSDNames )

            % ------ GENERATE EBSD Data ------
            
            TitleTexts = app.ConstantValues.EBSDVariableNames ...
                ( app.Default.LanguageSelection );
            Data = []; Title = {};
            
            dlg.Message = 'Generating EBSD data ...';
    
            % **** get EBSD DATA ****
            allData = getExportEBSDData( ...
                EBSDData, Threshold, UsePolygonizedIDFlag );
    
            if any(strcmp( 'Coords', EBSDNames ))
                EBSDNames = setdiff( EBSDNames, 'Coords' );
                Data = [ Data, allData.X, allData.Y ];
                Title = [ Title, ...
                    [TitleTexts.Coords,'-X'], [TitleTexts.Coords,'-Y'] ];
            end
            if any(strcmp( 'EulerAngles', EBSDNames ))
                EBSDNames = setdiff( EBSDNames, 'EulerAngles' );
                Data = [ Data, allData.phi1, allData.PHI, allData.phi2 ];
                Title = [ Title, ...
                    [TitleTexts.EulerAngles,'-phi1'], ...
                    [TitleTexts.EulerAngles,'-PHI'], ...
                    [TitleTexts.EulerAngles,'-phi2'] ];
            end
    
            Phase = [];
            for name = EBSDNames
                Title = [ Title, TitleTexts.(name{1})];
                if ~ strcmp( 'Phase', name{1} )
                    Data = [ Data, allData.(name{1}) ];
                else
                    Phase = EBSDData.PhaseNames( allData.Phase );
                end
            end
    
            % ------ SAVE EBSD Data ------
            FileName = [ obj.DisplayName, '-', ...
                EBSDData.DisplayName, '-Exported_EBSD' ];
            FileName = [ path, '\', FileName, '.txt' ];
    
            dispText( app.TextArea, 'Export EBSD Data File: ' )
            dispText( app.TextArea, FileName )
    
            dlg.Message = ['Exporting EBSD data ', FileName, ' ...'];
    
            Title = arrayfun( @(i)[num2str(i),'-',Title{i}], ...
                1:length(Title),'UniformOutput',false);
            Title = [ '#', Title ];
            writecell( Title, FileName, 'Delimiter', ' ' )
    
            fileID = fopen( FileName, 'a' );
            formatSpec = repmat( {'%.3f\t'}, 1, length(Title)-1 ); % '#'
            if ~isempty(Phase)
                formatSpec{end} = '%s';
            end
            formatSpec = cell2mat( formatSpec );
    
            if ~isempty(Phase)
                for i = 1:size(Data,1)
                    fprintf( fileID, formatSpec, Data(i,:), Phase{i} );
                    fprintf( fileID, '\n' );
                end
            else
                for i = 1:size(Data,1)
                    fprintf( fileID, formatSpec, Data(i,:) );
                    fprintf( fileID, '\n' );
                end
            end
    
            fclose( fileID );

        end

        

    end 

    function val = DataFun( data, ind1, ind2, prec )
        val = data( ind1, ind2 );
        if ~isnan(prec); val = round( val(:), prec );
        else; val = val(:);
        end
    end

end
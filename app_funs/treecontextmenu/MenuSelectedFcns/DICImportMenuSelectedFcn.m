function DICImportMenuSelectedFcn( menu, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

%
AllPreprocessMethods = fieldnames( app.DICPreprocessMethods );
PreprocessMethod = app.Default.Options.DICPreprocessMethod;
ParameterValues = ...
    app.Default.Parameters.DICPreprocessMethods.(PreprocessMethod);
FileFormatSelection = app.Default.Options.DICFileFormatSelection;

% -------/// CREATE INTERFACE ///-------
[ UIFigure, ...
  SelectFilesButton, FileFormatDropdown, PreprocessMethodDropdown, ...
  PreprocessParametersListbox, ConfirmButton, ...
  FileTable, PreprocessInfoTextArea, PreprocessParametersTable ] ...
    = createDIC_UI( FileFormatSelection, PreprocessMethod, app );

SelectFilesButton.ButtonPushedFcn = @ SelectFilesButton_ButtonPushedFcn;
PreprocessMethodDropdown.ValueChangedFcn = ...
    @ PreprocessMethodDropdownValueChangedFcn;
PreprocessParametersListbox.ValueChangedFcn = ...
    @ PreprocessParametersListboxValueChangedFcn;
FileFormatDropdown.ValueChangedFcn = ...
    @ FileFormatDropdownValueChangedFcn;
ConfirmButton.ButtonPushedFcn = @ Button_ok_ButtonPushedFcn;


% ------//// GLOBAL VARIABLES ////------

Files = []; FileFormat = '';
row = []; column = [];


% --------------------------------------

PreprocessMethodDropdownValueChangedFcn( ...
    PreprocessMethodDropdown, [] )

% //////////////// CALL BACKS ////////////////////

% ---------- ButtonSelectFile ----------
    function SelectFilesButton_ButtonPushedFcn( ~, ~ )
        
        UIFigure.WindowStyle = 'normal';
        UIFigure.WindowStyle = 'modal';

        FileFormat = FileFormatDropdown.Value;
        [ ~, suffix ] = getSuffix( FileFormat );

        % ------ SELECT FILES ------

        [ Files, path ] = uigetfile( ...
            [ app.Default.Path.DICImport, '*.', suffix ], ...
            DisplayNames.DICImport_SelectFilesButton_Text, ...
            'MultiSelect', 'on' );
        if ~path; UIFigure.WindowStyle = 'alwaysontop'; return; end
        
        if ~iscell( Files ); Files = {Files}; end
        
        app.Default.Path.DICImport = path;
        

        % ------ ASSIGN POSITION ------
        [ row, column ] = getFilePosition( Files, FileFormat );
        
        % ------ REFRESH TABLE ------
        refreshFileTable( FileTable, Files, row, column )
        
        ConfirmButton.Enable = 'on';

        UIFigure.WindowStyle = 'alwaysontop';
        
    end


% ---------- FileFormatDropdown ----------
    function FileFormatDropdownValueChangedFcn( dropdown, ~ )

        FileFormat = dropdown.Value;


        if ~isempty( Files )

            % ------ ASSIGN POSITION ------
            [ row, column ] = getFilePosition( Files, FileFormat );
    
            % ------ REFRESH TABLE ------
            refreshFileTable( FileTable, Files, row, column )

        end

    end


% ---------- PreprocessMethodDropdown ----------
    function PreprocessMethodDropdownValueChangedFcn( dropdown, ~ )

        PreprocessMethod = AllPreprocessMethods{ dropdown.ValueIndex };

        Parameters = app.DICPreprocessMethods.(PreprocessMethod).Parameters;
        ParameterValues = ...
            app.Default.Parameters.DICPreprocessMethods.(PreprocessMethod);
        
        % --- REFRESH 'PreprocessParametersListbox'
        PreprocessParametersListbox.Items = Parameters;
        
        if ~isempty( PreprocessParametersListbox.Items )
            PreprocessParametersListbox.Value = Parameters{1};
        end

        % --- REFRESH 'PreprocessParametersTable'
        PreprocessParametersListboxValueChangedFcn( ...
            PreprocessParametersListbox, [] )
        
        % --- REFRESH 'PreprocessInfoTextArea'
        PreprocessInfoTextArea.Value = ...
            app.DICPreprocessMethods.(PreprocessMethod).Info;
        
    end


% ---------- PreprocessParametersListbox ----------
    function PreprocessParametersListboxValueChangedFcn( Listbox, event )
        
        if ~isempty( Listbox.ValueIndex )
            
            if ~isempty( event )
                
                data = PreprocessParametersTable.Data;
                if iscell( data ); data = data{1}; end

                ParameterValues.(event.PreviousValue) = data;

            end


            data = ParameterValues.(Listbox.Value);

            if isa( data,'char' ); data = {data}; end

            PreprocessParametersTable.Data = data;
        
        else
            PreprocessParametersTable.Data = [];
        end

    end


% ---------- ConfirmButton ----------
    function Button_ok_ButtonPushedFcn( ~, ~ )
        
        % refresh current data
        data = PreprocessParametersTable.Data;
        if iscell( data ); data = data{1}; end

        if ~isempty( PreprocessParametersListbox.Value )
            ParameterValues.(PreprocessParametersListbox.Value) = data;
        end

        % ---------- Set app defaults ----------

        app.Default.Options.DICFileFormatSelection = ...
            FileFormatDropdown.ValueIndex;
        app.Default.Parameters.DICPreprocessMethods.(PreprocessMethod) = ...
            ParameterValues;
        app.Default.Options.DICPreprocessMethod = PreprocessMethod;

        % ---------- ASSIGN VALUES in project object 'obj' ----------

        path = app.Default.Path.DICImport;

        obj.DIC.FileNames = fullfile( path, Files );
        obj.DIC.FileNumber = length(Files);
        obj.DIC.FileFormat = FileFormat;
        obj.DIC.FilePosition = [ row, column ];

        obj.DIC.PreprocessMethod = PreprocessMethod;
        obj.DIC.PreprocessPars = ParameterValues;
        obj.DIC.UserVariableNames = ...
            app.DICPreprocessMethods.(PreprocessMethod).VariableNames;

        %   --- load data dlg --- 
        
        dlg = uiprogressdlg( UIFigure );
        UIFigure.CloseRequestFcn = '';
       

        % in 'obj.LoadDICData'
        %   1 - Load ALL data
        %   2 - Perform data preprocess
        %   3 - Create tree nodes

        % ***********************************
        [ obj, Report ] = LoadDICData( obj, dlg, app );
        
        if ~ isempty( Report )
            uialert( UIFigure, Report, ...
                     DisplayNames.error, ...
                     'Interpreter', "html" );
            UIFigure.CloseRequestFcn = 'closereq';
            return
        end
        % ***********************************
        
        app.Projects( ProjectIndex ) = obj;

        EnableDisableNode( app, obj.TreeNodes.DIC, 'on' )
        app.Tree.SelectedNodes = obj.TreeNodes.DIC;
        
        TreeSelectionChangedFcn( app.Tree, [], app )

        UIFigure.CloseRequestFcn = 'closereq';
        close( UIFigure )

    end


end
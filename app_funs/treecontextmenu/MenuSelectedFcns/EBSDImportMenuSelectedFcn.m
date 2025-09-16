function EBSDImportMenuSelectedFcn( menu, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );


% ------//// GLOBAL VARIABLES ////------
AllDataMethods = fieldnames( app.EBSDPreprocessMethods );
PreprocessMethod = app.Default.Options.EBSDPreprocessMethod;
ParameterValues = ...
    app.Default.Parameters.EBSDPreprocessMethods.( PreprocessMethod );
File = [];


% -------/// CREATE INTERFACE ///-------
[ UIFigure, ...
  SelectFilesButton, DataMethodDropdown, ...
  DataMethodParametersListbox, ConfirmButton, ...
  FileTable, DataMethodInfoTextArea, DataMethodParametersTable ] ...
    = createEBSD_UI( PreprocessMethod, app );

SelectFilesButton.ButtonPushedFcn = @ SelectFilesButton_ButtonPushedFcn;
DataMethodDropdown.ValueChangedFcn = ...
    @ DataMethodDropdownValueChangedFcn;
DataMethodParametersListbox.ValueChangedFcn = ...
    @ DataMethodParametersListboxValueChangedFcn;
ConfirmButton.ButtonPushedFcn = @ Button_ok_ButtonPushedFcn;

% --------------------------------------

DataMethodDropdownValueChangedFcn( ...
    DataMethodDropdown, [] )

% //////////////// CALL BACKS ////////////////////

% ---------- ButtonSelectFile ----------
    function SelectFilesButton_ButtonPushedFcn( ~, ~ )

        UIFigure.WindowStyle = 'normal';
        UIFigure.WindowStyle = 'modal';

        % ------ SELECT FILES ------

        [ File, path ] = uigetfile( ...
            [ app.Default.Path.EBSDImport, '*.*' ], ...
            DisplayNames.DICImport_SelectFilesButton_Text, ...
            'MultiSelect', 'off' );

        if ~path
            UIFigure.WindowStyle = 'alwaysontop';
            return
        end

        app.Default.Path.EBSDImport = path;
        
        % ------ REFRESH TABLE ------
        FileTable.Data = { path; File };
        
        ConfirmButton.Enable = 'on';

        UIFigure.WindowStyle = 'alwaysontop';

    end



% ---------- DataMethodDropdown ----------
    function DataMethodDropdownValueChangedFcn( dropdown, ~ )

        PreprocessMethod = AllDataMethods{ dropdown.ValueIndex };
        
        Parameters = app.EBSDPreprocessMethods.( PreprocessMethod ).Parameters;
        ParameterValues = ...
            app.Default.Parameters.EBSDPreprocessMethods.( PreprocessMethod );
        
        % --- REFRESH 'DataMethodParametersListbox'
        DataMethodParametersListbox.Items = Parameters;

        if ~isempty( DataMethodParametersListbox.Items )
            DataMethodParametersListbox.Value = Parameters{1};
        end
        
        % --- REFRESH 'DataMethodParametersTable'
        DataMethodParametersListboxValueChangedFcn( ...
            DataMethodParametersListbox, [] )
        
        % --- REFRESH 'DataMethodInfoTextArea'
        DataMethodInfoTextArea.Value = ...
            app.EBSDPreprocessMethods.( PreprocessMethod ).Info;

    end



% ---------- DataMethodParametersListbox ----------
    function DataMethodParametersListboxValueChangedFcn( Listbox, event )

        if ~isempty( Listbox.ValueIndex )

            if ~isempty( event )

                data = DataMethodParametersTable.Data;
                if iscell( data ); data = data{1}; end
    
                ParameterValues.(event.PreviousValue) = data;

            end
        

        data = ParameterValues.(Listbox.Value);

        if isa( data,'char' ); data = {data}; end

        DataMethodParametersTable.Data = data;

        else
            DataMethodParametersTable.Data = [];
        end

    end


% ---------- ConfirmButton ----------
    function Button_ok_ButtonPushedFcn( ~, ~ )

        % refresh current data
        data = DataMethodParametersTable.Data;
        if iscell( data ); data = data{1}; end

        if ~isempty( DataMethodParametersListbox.Value )
            ParameterValues.(DataMethodParametersListbox.Value) = data;
        end

        % ---------- Set app defaults ----------

        app.Default.Parameters.EBSDPreprocessMethods.( PreprocessMethod ) = ...
            ParameterValues;
        app.Default.Options.EBSDDataMethod = PreprocessMethod;

        % ---------- ASSIGN VALUES in project object 'obj' ----------

        path = app.Default.Path.EBSDImport;
        
        obj.EBSD.FileName = fullfile( path, File );
        
        obj.EBSD.PreprocessMethod     = PreprocessMethod;
        obj.EBSD.PreprocessPars       = ParameterValues;

        %   --- load data dlg --- 

        dlg = uiprogressdlg( UIFigure,  ...
            'Title', DisplayNames.EBSDImport_UIFigure, ...
            'Indeterminate', 'on' );
        UIFigure.CloseRequestFcn = '';

        % in 'obj.LoadEBSDData'
        %   1 - Load and process data
        %   2 - Create tree nodes
        
        % ***********************************
        [ obj, Report ] = LoadEBSDData( obj, dlg, app );

        if ~ isempty( Report )
            uialert( UIFigure, Report, ...
                     DisplayNames.error, ...
                     'Interpreter', "html" );
            UIFigure.CloseRequestFcn = 'closereq';
            return
        end
        % ***********************************
        
        EnableDisableNode( app, obj.TreeNodes.EBSD, 'on' )
        app.Tree.SelectedNodes = obj.TreeNodes.EBSD;
        
        TreeSelectionChangedFcn( app.Tree, [], app )
        scroll( app.Tree, 'bottom' )
        
        app.Projects( ProjectIndex ) = obj;

        UIFigure.CloseRequestFcn = 'closereq';
        close( UIFigure )

    end


end
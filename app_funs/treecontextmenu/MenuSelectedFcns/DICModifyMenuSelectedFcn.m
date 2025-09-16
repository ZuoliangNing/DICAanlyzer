function DICModifyMenuSelectedFcn(menu,~,app)

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

%
AllPreprocessMethods = fieldnames( app.DICPreprocessMethods );
PreprocessMethod = obj.DIC.PreprocessMethod;
ParameterValues = obj.DIC.PreprocessPars;
FileFormatSelection = ...
    find( strcmp( obj.DIC.FileFormat, app.DICFileFormats ));

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

ConfirmButton.Enable = 'on';

% ------//// GLOBAL VARIABLES ////------

[ path, name, ext ] = fileparts( obj.DIC.FileNames );
path = [ path{1}, '\' ];

Files = arrayfun( @(i) [ name{i}, ext{i} ], ...
    1:obj.DIC.FileNumber, 'UniformOutput', false );
FileFormat = obj.DIC.FileFormat;
row = obj.DIC.FilePosition(:,1);
column = obj.DIC.FilePosition(:,2);


% ------ REFRESH TABLE ------
refreshFileTable( FileTable, Files, row, column )

% --------------------------------------

PreprocessMethodDropdownValueChangedFcn( ...
    PreprocessMethodDropdown, [] )

% //////////////// CALL BACKS ////////////////////


% ---------- ButtonSelectFile ----------
    function SelectFilesButton_ButtonPushedFcn( ~, ~ )

        [ ~, suffix ] = getSuffix( FileFormat );

        % ------ SELECT FILES ------

        [ TempFiles, Temppath ] = uigetfile( ...
            [ path, '*.', suffix ], ...
            DisplayNames.DICImport_SelectFilesButton_Text, ...
            'MultiSelect', 'on' );

        if ~ Temppath
            return
        else
            Files = TempFiles; path = Temppath;
        end

        app.Default.Path.DICImport = path;

        % ------ ASSIGN POSITION ------
        [ row, column ] = getFilePosition( Files, FileFormat );

        % ------ REFRESH TABLE ------
        refreshFileTable( FileTable, Files, row, column )

    end


% ---------- FileFormatDropdown ----------
    function FileFormatDropdownValueChangedFcn( dropdown, ~ )

        FileFormat = dropdown.Value;

        % ------ ASSIGN POSITION ------
        [ row, column ] = getFilePosition( Files, FileFormat );

        % ------ REFRESH TABLE ------
        refreshFileTable( FileTable, Files, row, column )

    end


% ---------- PreprocessMethodDropdown ----------
    function PreprocessMethodDropdownValueChangedFcn( dropdown, ~ )

        PreprocessMethod = AllPreprocessMethods{ dropdown.ValueIndex };

        if ~strcmp( PreprocessMethod, obj.DIC.PreprocessMethod )

            ParameterValues = app.Default. ...
                Parameters.DICPreprocessMethod.(PreprocessMethod);
        else
            ParameterValues = obj.DIC.PreprocessPars;
        end

        Parameters = ...
                app.DICPreprocessMethods.(PreprocessMethod).Parameters;

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
        
        obj.Flag.DICLoadData = 0;
        obj.Flag.DICPreprocess = 0;

        TempFileNames = fullfile( path, Files );
        if all( strcmp( TempFileNames, obj.DIC.FileNames ) )

            obj.Flag.DICLoadData = 1;

            objDICVariableNames = fieldnames( obj.DIC.Data );

            if strcmp( FileFormat, obj.DIC.FileFormat ) && ...
                    all( obj.DIC.FilePosition == [ row, column ], 'all' ) && ...
                    strcmp( PreprocessMethod, obj.DIC.PreprocessMethod ) && ...
                    ifequalParameterValues( ...
                        ParameterValues, obj.DIC.PreprocessPars ) && ...
                        all( cellfun( @(name) ...
                            any( strcmp( name, objDICVariableNames ) ), ...
                            app.DICPreprocessMethods. ...
                                (PreprocessMethod).VariableNames ) )
                

                obj.Flag.DICPreprocess = 1;
                
                close( UIFigure )
                return
                
            else

                obj.DIC.FileFormat = FileFormat;
                obj.DIC.FilePosition = [ row, column ];
        
                obj.DIC.PreprocessMethod = PreprocessMethod;
                obj.DIC.PreprocessPars = ParameterValues;

                obj.DIC.Data = struct();
                
            end

        else

            obj.DIC.FileNames = TempFileNames;
            obj.DIC.FileNumber = length(Files);

            obj.DIC.FileFormat = FileFormat;
            obj.DIC.FilePosition = [ row, column ];
    
            obj.DIC.PreprocessMethod = PreprocessMethod;
            obj.DIC.PreprocessPars = ParameterValues;
            
            obj.DIC.Data = struct();

        end

        %   --- load data dlg --- 
        
        dlg = uiprogressdlg( UIFigure,  ...
            'Title', DisplayNames.DICImport_UIFigure );
        UIFigure.CloseRequestFcn = '';

        % ***********************************
        obj = LoadDICData( obj, dlg, app );
        % ***********************************

        EnableDisableNode( app, obj.TreeNodes.DIC, 'on' )
        % app.Tree.SelectedNodes = [];
        
        TreeSelectionChangedFcn( app.Tree, [], app )

        app.Projects( ProjectIndex ) = obj;

        UIFigure.CloseRequestFcn = 'closereq';
        close( UIFigure )

        % refreshCurrentImage(app)

    end



end
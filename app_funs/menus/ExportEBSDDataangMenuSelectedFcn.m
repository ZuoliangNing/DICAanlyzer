function ExportEBSDDataangMenuSelectedFcn( ~, ~, app )

objs = app.Projects;
if isempty(objs); return; end

% ********** CREATE UI **********
DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
SIZE = [260,290];
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
                      LabelHeight, DropDownHeight, ...
                      25, 40, ButtonSize(2) }, ...
    'ColumnWidth',  { '1x' }, ...
    'Padding', 15*ones(1,4));

% ---------- GridLayoutButtons ----------
GridLayoutButtons = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1), ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutButtons.Layout.Row = 7;

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

% ---------- ProjectLabel ----------
ProjectLabel = uilabel( GridLayoutMain, ...
    'Text', DisplayNames.ProjectSave_ProjectLabel_Text );
ProjectLabel.Layout.Row = 1;

% ---------- ProjectDropDown ----------
ProjectDropDown = uidropdown( GridLayoutMain, ...
    'Items', {objs.DisplayName}, ...
    'ItemsData', 1:length(objs), ...
    'Value', 1, ...
    'ValueChangedFcn', @ ProjectDropDownValueChangedFcn );
ProjectDropDown.Layout.Row = 2;

% ---------- EBSDLabel ----------
EBSDLabel = uilabel( GridLayoutMain, ...
    'Text', DisplayNames.ExportDataMenu_EBSDPanel_Title );
EBSDLabel.Layout.Row = 3;

% ---------- EBSDDropDown ----------
EBSDDropDown = uidropdown( GridLayoutMain );
EBSDDropDown.Layout.Row = 4;

% ---------- GridLayoutTemplate ----------
GridLayoutTemplate = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', 25 }, ...
    'Padding', zeros(1,4) );
GridLayoutTemplate.Layout.Row = 5;

% ---------- TemplateLabel ----------
TemplateLabel = uilabel( GridLayoutTemplate, ...
    'Text', DisplayNames.ExportEBSDDataangMenu_TemplateLabel_Text );
TemplateLabel.Layout.Column = 1;

% ---------- TemplateButton ----------
TemplateButton = uibutton( GridLayoutTemplate, 'push', ...
    'Text', '', ...
    'Icon', 'add.png', ...
    'ButtonPushedFcn', @ TemplateButtonPushedFcn );
TemplateButton.Layout.Column = 2;

% ---------- TemplateTextArea ----------
TemplateTextArea = uitextarea( GridLayoutMain,  ...
    'Editable', 'off' );
TemplateTextArea.Layout.Row = 6;

% *********************************

ProjectDropDownValueChangedFcn( ProjectDropDown ,[] )

% *********************************

    function ProjectDropDownValueChangedFcn( dropdown ,~ )
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
            if ~isempty(TemplateTextArea.Value{1})
                ConfirmButton.Enable = 'on';
            end
        end
    
    end

    function TemplateButtonPushedFcn(~,~)
    
        % ------ SELECT FILES ------
        [ Files, path ] = uigetfile( ...
            [ app.Default.Path.ExportEBSDDataangTemplate, '*.ang' ], ...
              DisplayNames.ExportEBSDDataangMenu_TemplateButton_uigetfile );
        if ~path; return; end
        app.Default.Path.ExportEBSDDataangTemplate = path;
    
        TemplateTextArea.Value = [ path, Files ];
        ConfirmButton.Enable = 'on';
    
    end

    function ConfirmButtonPushedFcn(~,~)

        obj = objs( ProjectDropDown.Value );
        EBSDData = obj.EBSD.Data( EBSDDropDown.Value );

        
        % ------ SELECT Path ------
        path = uigetdir( app.Default.Path.ProjectSave, ...
            DisplayNames.ProjectSave_UIFigure );
        if ~path; UIFigure.WindowStyle = 'alwaysontop'; return; end
        app.Default.Path.ProjectSave = path;

        NewFileName = [ obj.DisplayName,'-', ...
            EBSDData.DisplayName,'-Exported_Ang'];
        NewFileName = [ path, '\', NewFileName, '.ang' ];

        % ------ GENERATE EBSD Data ------

        Threshold = 500;
        UsePolygonizedIDFlag = true;

        FileName = TemplateTextArea.Value{1};
        close( UIFigure )
        dlg = uiprogressdlg( app.UIFigure, ...
            'Indeterminate', 'on', 'Title', DisplayNames.ExportDataMenu_UIFigure, ...
            'Message', 'Generating data ...');

        % **** get DATA ****
        allData = getExportEBSDData( ...
            EBSDData, Threshold, UsePolygonizedIDFlag );

        Data = [ allData.phi1, allData.PHI, allData.phi2, ...
            allData.X, allData.Y, allData.IQ, allData.CI, ...
            allData.Phase, allData.sem_signal, allData.fit ];


        % ------ SAVE EBSD Data ------
        
        dlg.Message = ['Exporting data ', FileName, ' ...'];

        fileID = fopen( FileName );
        NumHeaderLines = 0;
        while 1
            tline = fgetl( fileID );
            if ~ strcmp( tline(1), '#' ); break; end
            NumHeaderLines = NumHeaderLines + 1;
            Header{ NumHeaderLines, 1 } = tline;
        end
        fclose( fileID );

        i = find( contains( Header, '# GRID' ) );
        Header{i} = '# GRID: SqrGrid';
        Header{i+1} = ['# XSTEP: ',num2str(allData.XSTEP)];
        Header{i+2} = ['# YSTEP: ',num2str(allData.YSTEP)];
        Header{i+3} = ['# NCOLS_ODD: ',num2str(allData.NCOLS)];
        Header{i+4} = ['# NCOLS_EVEN: ',num2str(allData.NCOLS)];
        Header{i+5} = ['# NROWS: ',num2str(allData.NROWS)];

        writecell( Header, NewFileName, ...
            'FileType', 'text', 'WriteMode', 'overwrite', ...
            'QuoteStrings', 'none' )
        writematrix( Data, NewFileName, ...
            'FileType', 'text', 'WriteMode', 'append', ...
            'Delimiter', '\t' )

        % fileID = fopen( NewFileName, 'a' );
        % formatSpec = cell2mat( repmat( {'%.3f\t'}, 1, 10 ) );
        % for i = 1:size(Data,1)
        %     fprintf( fileID, formatSpec, Data(i,:) );
        %     fprintf( fileID, '\n' );
        % end
        % fclose( fileID );

    end

    function val = DataFun( data, ind1, ind2, prec )
        val = data( ind1, ind2 );
        if ~isnan(prec); val = round( val(:), prec );
        else; val = val(:);
        end
    end

end
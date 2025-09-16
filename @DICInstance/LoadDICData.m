function [ obj, Report ] = LoadDICData( obj, dlg, app )
% Load ALL data & Perform data preprocess with updating 'dlg'
%
%
% ** 1 ** - Load ALL data /// Define 'obj.DIC.OriginalData' ///
%           possibly involved properties:
%               'obj.DIC.FileNames'
%               'obj.DIC.FileFormat'
%           possibly involved funs:
%               'data = getDICFileData( FileName, format )'
%           defined properties
%               'obj.DIC.OriginalData'
%
% ** 2 ** - Perform data preprocess :
%           possibly involved properties:
%               'obj.DIC.FilePosition'
%               'obj.DIC.PreprocessMethod'
%               'obj.DIC.PreprocessPars'
%           possibly involved methods:
%               '[ obj, Flag ] = DICPreprocess( obj )'
%           defined properties
%               'obj.DIC.Data'
%               'obj.DIC.StageNumber'
%
% ** 3 ** - Create tree nodes :
%           children nodes of 'obj.TreeNodes.DIC'
%
%   dlg   - 'uiprogressdlg' object

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );


%% 1 & 2
if ~ obj.Flag.DICPreprocess

    % Values from 'app'
    val = app.Default.Options.ValueRanges;
    obj.DIC.DataValueRange = struct( ...
        'u', val(1),    'v', val(1), ...
        'exx', val(2),  'exy', val(2), 'eyy', val(2) );

    dlg.Title = ...
        [ DisplayNames.DICImport_uiprogressdlg_Message2, ' - ', ...
            obj.DIC.PreprocessMethod ];


    [ obj, Report ] = DICPreprocess( obj, dlg, app );

    if ~ isempty( Report ); return ; end

    obj.Flag.DICPreprocess = 1;

end
% ******** relase 'obj.DIC.OriginalData'
obj.DIC.OriginalData = {struct()};
obj.Flag.DICLoadData = 0;

%% 3 Create tree nodes

if ~ isempty( obj.TreeNodes.DIC.Children )
    arrayfun( @ delete, obj.TreeNodes.DIC.Children )
end

obj = createDICNodes( obj, app );

expand( obj.TreeNodes.DIC )
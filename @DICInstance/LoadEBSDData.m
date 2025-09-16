function [ obj, Report ] = LoadEBSDData( obj, dlg, app )
% Load EBSD data & Perform data preprocess with updating 'dlg'
%
% Based on method selection     'obj.EBSD.PreprocessMethod'
%   and parameters              'obj.EBSD.PreprocessPars'
%
% ** 1 ** - Load and process data /// Define 'obj.EBSD.Data' ///
%           possibly involved properties:
%               'obj.EBSD.FileName'
%
% ** 2 ** - Create tree nodes :
%           children nodes of 'obj.TreeNodes.EBSD'
%
%   dlg   - 'uiprogressdlg' object

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

%% 1 Load and process data
if ~ obj.Flag.EBSDData

    dlg.Message = ...
        { DisplayNames.DICImport_uiprogressdlg_Message2, ...
        obj.EBSD.PreprocessMethod };

    [ obj, Report ] = EBSDPreprocess( obj, dlg );
    
    if ~ isempty( Report ); return ; end
    
    obj.Flag.EBSDData = 1;

end
%% 2 Create tree nodes

if ~ isempty( obj.TreeNodes.EBSD.Children )
    arrayfun( @ delete, obj.TreeNodes.EBSD.Children )
end

% default variables
DefaultEBSDVariables = app.ConstantValues.EBSDVariables;
DefaultEBSDVariableNames = app.ConstantValues.EBSDVariableNames ...
    ( app.Default.LanguageSelection );

% obj.EBSD.Serial = obj.EBSD.Serial + 1;


obj.EBSD.Data.DisplayName = 'Original Data';

NodeEBSD2 = uitreenode( obj.TreeNodes.EBSD, ...
    'Text',         obj.EBSD.Data.DisplayName, ...
    'UserData',     struct( 'Parent',       'Tree', ...
                            'NodeType',     'EBSD2' ), ...
    'NodeData',     struct( 'Serial', obj.Serial, ...
                            'Enable', true, ...
                            'EBSDSerial', obj.EBSDSerial ), ...
    'ContextMenu',  app.TreeContextMenu.EBSD2 );

% if ~isfield( obj.TreeNodes, 'EBSD2' )
%     obj.TreeNodes.EBSD2 = [];
% end
obj.TreeNodes.EBSD2 = [ obj.TreeNodes.EBSD2, NodeEBSD2 ];


if ~isfield( obj.TreeNodes, 'EBSD2' )
    N = 1; % obj.EBSDSerial;
else
    N = getEBSDIndex( obj.EBSDSerial, obj );
end


for i = 1:length( DefaultEBSDVariables )

    VariableName = DefaultEBSDVariables{i};
    
    Node = uitreenode( NodeEBSD2, ...
        'Text',         DefaultEBSDVariableNames.( VariableName ), ...
        'UserData',     struct( 'Parent',       'Tree', ...
                                'NodeType',     'EBSDData', ...
                                'VariableName',  VariableName ), ...
        'NodeData',     struct( 'Serial', obj.Serial, ...
                                'Enable', true, ...
                                'EBSDSerial', obj.EBSDSerial ));
    % , ...
    %     'ContextMenu',  app.TreeContextMenu.EBSDData 
    
    if ~isempty( obj.EBSD.Data.(VariableName) )
        EnableDisableNode( app, Node, 'on' )
    else
        EnableDisableNode( app, Node, 'off' )
    end

    obj.TreeNodes.EBSDData(N).(VariableName) = Node;


end

expand( obj.TreeNodes.EBSD2(N) )
function EBSD2DeleteMenuSelectedFcn( menu, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

node = app.UIFigure.CurrentObject;
EBSDSerial = getEBSDIndex( node.NodeData.EBSDSerial, obj );

Name = obj.EBSD.Data( EBSDSerial ).DisplayName;

msg = {[ DisplayNames.DeleteMenuSelectedFcn_uiconfirm_msg, ...
        ' ', app.TreeNodeTypes( app.Default.LanguageSelection ).EBSD, '?' ], ...
        [ obj.DisplayName, ': ', Name ] };
title = DisplayNames.cm_Delete;
selection = uiconfirm( app.UIFigure, msg, title, ...
           'Options', { DisplayNames.uiopt_yes, DisplayNames.uiopt_no }, ...
           'DefaultOption', 2 );
if strcmp( selection, DisplayNames.uiopt_no ); return; end
% ------------------------------

obj.EBSD.Data( EBSDSerial ) = [];

obj.TreeNodes.EBSD2( EBSDSerial ) = [];
obj.TreeNodes.EBSDData( EBSDSerial ) = [];

delete( node )

delete( app.CurrentImage2 )
delete( app.GBsPlot )
delete( app.GrainLabels )

if isempty( obj.TreeNodes.EBSD.Children )
    EnableDisableNode( app, obj.TreeNodes.EBSD, 'off' )
    obj.Flag.EBSDData = 0;
end

app.Projects( ProjectIndex ) = obj;
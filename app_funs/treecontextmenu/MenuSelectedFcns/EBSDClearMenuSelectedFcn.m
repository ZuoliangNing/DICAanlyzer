function EBSDClearMenuSelectedFcn( menu, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

msg = DisplayNames.DeleteMenuSelectedFcn_uiconfirm_msg;
title = DisplayNames.cm_Delete;
selection = uiconfirm( app.UIFigure, msg, title, ...
           'Options', { DisplayNames.uiopt_yes, DisplayNames.uiopt_no }, ...
           'DefaultOption', 2 );
if strcmp( selection, DisplayNames.uiopt_no ); return; end
% ------------------------------

obj.EBSD.FileName = '';
obj.EBSD.Data = getEmptyEBSDData();
obj.EBSD.PreprocessMethod = '';
obj.EBSD.PreprocessPars = struct();
obj.EBSD.Serial = 0;

obj.Flag.EBSDData = 0;
EnableDisableNode( app, obj.TreeNodes.EBSD, 'off' )

arrayfun( @ delete, obj.TreeNodes.EBSD2 )
obj.TreeNodes.EBSD2 = [];

if ishandle(app.CurrentImage2); delete(app.CurrentImage2); end

app.Projects( ProjectIndex ) = obj;
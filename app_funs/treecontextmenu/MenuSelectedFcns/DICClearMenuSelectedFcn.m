function DICClearMenuSelectedFcn( menu, ~, app )

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

obj.DIC = getEmptyDIC( obj.DIC );

obj.StageSelection = 1;

obj.Flag.DICLoadData = 0;
obj.Flag.DICPreprocess = 0;

structfun( @ delete, obj.TreeNodes.DICData )

EnableDisableNode( app, obj.TreeNodes.DIC, 'off' )

delete( app.CurrentImage )

app.Projects( ProjectIndex ) = obj;
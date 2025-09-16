function ProjectClearMenuSelectedFcn(~,~,app)

if isempty( app.Projects ); return; end

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

% ---------- Creat uiconfirm ----------
msg = DisplayNames.ClearButtonPushedFcn_uiconfirm_msg;
title = DisplayNames.cm_Delete;
selection = uiconfirm( app.UIFigure, msg, title, ...
           'Options',{ DisplayNames.uiopt_yes, DisplayNames.uiopt_no }, ...
           'DefaultOption',2);
if strcmp(selection,DisplayNames.uiopt_no); return; end
% -------------------------------------

arrayfun( @delete, app.Projects )

app.Projects = [];

deleteAllImages(app)
app.TextArea.Value = '';
if ishandle(app.CurrentImage2); delete(app.CurrentImage2); end
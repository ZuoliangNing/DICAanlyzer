function MaxResolutionMenuSelectedFcn( ~, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
prompt = DisplayNames.MaxResolutionMenuSelectedFcn_prompt ;
dlgtitle = app.UIControlDisplayNames( app.Default.LanguageSelection ). ...
    MaxResolutionMenu;

% ---------- Creat inputdlg ----------
answer = inputdlg( prompt, dlgtitle, ...
    [1 35], { num2str( app.Default.Options.MaxResolution ) } );
if isempty(answer); return; end
% ------------------------------------

val = str2double( answer{1} );
if val <= 100
    uialert( app.UIFigure, ...
        DisplayNames.invalidvalue_title, ...
        dlgtitle )
    return
end

app.Default.Options.MaxResolution = val;

% if ishandle( app.CurrentImage )
%     refreshCurrentImage(app)
% end
% if ishandle( app.CurrentImage2 )
%     refreshCurrentImage2(app)
% end
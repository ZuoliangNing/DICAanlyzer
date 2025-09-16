function OverlayOpacityMenuSelectedFcn( ~, ~, app )


DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
prompt = DisplayNames.OverlayOpacityMenuSelectedFcn_prompt ;
dlgtitle = DisplayNames. cm_OverlayOpacity;

% ---------- Creat inputdlg ----------
answer = inputdlg( prompt, dlgtitle, ...
    [1 35], { num2str( app.Default.Options.OverlayOpacity ) } );
if isempty(answer); return; end
% ------------------------------------

val = str2double( answer{1} );
if val <= 0 || val >= 1
    uialert( app.UIFigure, ...
        DisplayNames.invalidvalue_title, ...
        DisplayNames.cm_OverlayOpacity )
    return
end

app.Default.Options.OverlayOpacity = val;

if ishandle( app.OverlayImage )
    refreshCurrentImage2( app )
end
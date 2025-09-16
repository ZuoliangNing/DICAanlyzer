function MinimumGrainSizeMenuSelectedFcn( ~, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
prompt = DisplayNames.MinimumGrainSizeMenuSelectedFcn_prompt ;
dlgtitle = app.UIControlDisplayNames( app.Default.LanguageSelection ). ...
    MinimumGrainSizeMenu;

% ---------- Creat inputdlg ----------
answer = inputdlg( prompt, dlgtitle, ...
    [1 35], { num2str( app.Default.Options.MinimumGrainSize ) } );
if isempty(answer); return; end
% ------------------------------------

val = str2double( answer{1} );
if val < 1
    uialert( app.UIFigure, ...
        DisplayNames.invalidvalue_title, ...
        dlgtitle )
    return
end

app.Default.Options.MinimumGrainSize = val;
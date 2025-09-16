function ValueRangesMenuSelectedFcn( ~, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
prompt = DisplayNames.ValueRangesMenuSelectedFcn_prompt ;
dlgtitle = app.UIControlDisplayNames( app.Default.LanguageSelection ). ...
    ValueRangesMenu;

% ---------- Creat inputdlg ----------
answer = inputdlg( prompt, dlgtitle, ...
    [1 35], { 
    num2str( app.Default.Options.ValueRanges(1) ), ...
    num2str( app.Default.Options.ValueRanges(2) )} );
if isempty(answer); return; end
% ------------------------------------

val = str2double( answer );
if any( val <= 0 )
    uialert( app.UIFigure, ...
        DisplayNames.invalidvalue_title, ...
        DisplayNames.cm_CLim )
end

app.Default.Options.ValueRanges = val';
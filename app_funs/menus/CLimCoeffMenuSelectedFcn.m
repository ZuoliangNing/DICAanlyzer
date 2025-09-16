function CLimCoeffMenuSelectedFcn( ~, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
prompt = DisplayNames.CLimCoeffMenuSelectedFcn_prompt ;
dlgtitle = app.UIControlDisplayNames( app.Default.LanguageSelection ). ...
    CLimCoeffMenu;

% ---------- Creat inputdlg ----------
answer = inputdlg( prompt, dlgtitle, ...
    [1 35], { num2str( app.Default.Options.DICCLimCoeff ) } );
if isempty(answer); return; end
% ------------------------------------

val = str2double( answer{1} );
if val < 0
    uialert( app.UIFigure, ...
        DisplayNames.invalidvalue_title, ...
        DisplayNames.cm_CLim )
    return
end


app.Default.Options.DICCLimCoeff = val;

% if ishandle(app.CurrentImage)
%     refreshCLimSlider(app)
% end
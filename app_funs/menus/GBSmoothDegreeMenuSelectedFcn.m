function GBSmoothDegreeMenuSelectedFcn( ~, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
prompt = DisplayNames.GBSmoothDegreeMenuSelectedFcn_prompt ;
dlgtitle = app.UIControlDisplayNames( app.Default.LanguageSelection ). ...
    GBSmoothDegreeMenu;

% ---------- Creat inputdlg ----------
answer = inputdlg( prompt, dlgtitle, ...
    [1 35], { num2str( app.Default.Options.GBSmoothDegree ) } );
if isempty(answer); return; end
% 

val = str2double( answer{1} );
if val < 0 || val > 10
    uialert( app.UIFigure, ...
        DisplayNames.invalidvalue_title, ...
        dlgtitle )
    return
end

app.Default.Options.GBSmoothDegree = val;

if ishandle( app.GBsPlot )
            
    GBsSmoothButtonValueChangedFcn( [], [], app )

end

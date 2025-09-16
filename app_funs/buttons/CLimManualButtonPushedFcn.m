function CLimManualButtonPushedFcn( button, ~, app )


DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

% ---------- Creat inputdlg ----------
answer = inputdlg( ...
    { DisplayNames.cm_Max, DisplayNames.cm_Min }, ...
    DisplayNames.cm_CLim, ...
    [1 35; 1 35], ...
    { num2str( app.UIAxesImages.CLim(2) ), ...
      num2str( app.UIAxesImages.CLim(1) ) } );

if isempty(answer); return; end
% ------------------------------------

try

    CLim = [ ...
        str2double( answer{2} ), ...
        str2double( answer{1} ) ];
    
    app.UIAxesImages.CLim = CLim;
    
    refreshCLimSlider( app, CLim )

catch

    uialert( app.UIFigure, ...
        DisplayNames.invalidvalue_title, ...
        DisplayNames.cm_CLim )

end
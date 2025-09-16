function UIAxesDisplayMiniatureMenuSelectedFcn( Image, ~, app )

delete( app.UIAxesImages3.Children )

% Image = app.UIFigure.CurrentObject;
if isa( app.UIFigure.CurrentObject, 'matlab.ui.control.UIAxes' )
    axe = app.UIFigure.CurrentObject;
    axis( app.UIAxesImages3, 'normal' )
    app.UIAxesImages3.Visible = 'on';
    visualizeAxes( app.UIAxesImages3, 'on' )
    app.UIAxesImages3.XLabel.String = axe.XLabel.String;
    app.UIAxesImages3.YLabel.String = axe.YLabel.String;
else
    axe = app.UIFigure.CurrentObject.Parent;
    axis( app.UIAxesImages3, 'image' )
    app.UIAxesImages3.Visible = 'off';
    visualizeAxes( app.UIAxesImages3, 'off' )
    app.UIAxesImages3.XLabel.String = '';
    app.UIAxesImages3.YLabel.String = '';
end

% ProjectIndex = getProjectIndex( Image.UserData.Serial, app );
% obj = app.Projects( ProjectIndex );

app.UIAxesImages3.Colormap = axe.Colormap;
app.UIAxesImages3.CLim = axe.CLim;

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
dlg = uiprogressdlg(app.UIFigure,'Indeterminate','on');
dlg.Title = DisplayNames.cm_UIAxesDisplay;
dlg.Message = DisplayNames.cm_UIAxesDisplay_Message;

arrayfun(@(obj)copyobj( obj, app.UIAxesImages3 ),flip(axe.Children))

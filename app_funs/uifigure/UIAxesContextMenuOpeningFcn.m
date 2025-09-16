function UIAxesContextMenuOpeningFcn( contextmenu, ~, app )

Image = app.UIFigure.CurrentObject;

if isa( Image, 'matlab.ui.control.UIAxes' ) ...
        || strcmp( Image.Parent.Tag, 'Sub' )

    contextmenu.Children(2).Enable = 'off';

else
    contextmenu.Children(2).Enable = 'on';
end

if app.DisplayIndependentFlag
    contextmenu.Children(1).Enable = 'off';
else
    contextmenu.Children(1).Enable = 'on';
end
function createbyManualKeyPressFcn( fig, event, axe, OldEnableStates, app, UIFigure )


if strcmp( event.Key, 'escape' )
    delete(axe.UserData.Lines)
    setUIsOn( OldEnableStates, app )
    app.UIFigure.WindowButtonMotionFcn = '';
    app.UIFigure.WindowButtonDownFcn = '';
    app.UIFigure.KeyPressFcn = { @UIFigureKeyPressFcn, app };
    axe.Children(end).ContextMenu = axe.UserData.ContextMenu;
    axe.UserData = [];
    UIFigure.Visible = 'on';
end
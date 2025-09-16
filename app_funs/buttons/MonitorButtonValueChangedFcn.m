function MonitorButtonValueChangedFcn( button, ~, app )


DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
if button.Value

    UIFigureSize = [375,71];

    % ---------- MonitorUIFigure ----------
    app.MonitorUIFigure = uifigure( ...
        'Name', DisplayNames.MonitorButton_UIFigure, ...
        'WindowStyle', 'alwaysontop', ...alwaysontop
        'Icon', app.ConstantValues.IconSource, ...
        'Resize', 'off', ...
        'CloseRequestFcn', @ UIFigureCloseRequestFcn );
    app.MonitorUIFigure.Position = getMiddlePosition( ...
        app.UIFigure.Position, UIFigureSize );

    % ---------- MonitorTable ----------
    app.MonitorTable = uitable( app.MonitorUIFigure, ...
        'Position', [ 10, 10, 355, 51 ], ...
        'ColumnWidth', {'1x','1x','1x','1x','1x'}, ...
        'RowName', '' );

    app.MonitorTable.ColumnName = { 'Mean', 'Max', 'Min', 'Std',' Pixels' };

    gobjs = app.TabGroup.SelectedTab.Children.Children.Children;
    ind = arrayfun( @(a) isa( a, 'matlab.graphics.primitive.Image' ), gobjs );
    if any( ind )
        im = gobjs( ind );
        if strcmp( im.UserData.Type, 'DICData' )
            updateMonitorTable( true, im.CData, app )
        end
    end

else
    delete( app.MonitorUIFigure )
end



function UIFigureCloseRequestFcn( fig, ~ )
    app.MonitorButton.Value = false;
    delete( fig )
end


end
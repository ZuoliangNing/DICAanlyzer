function updateMonitorTable( flag, Value, app )


if ~ishandle( app.MonitorUIFigure ); return; end

if ~flag
    app.MonitorTable.Data = [];
    return
end

Value = Value( ~isnan( Value ) );
Value = Value(:);

% Value = Value( abs(Value)<0.15 );

Mean = mean( Value );
Max  = max( Value );
Min  = min( Value );
Std  = std( Value );
Pixels = numel( Value );

app.MonitorTable.Data = [ Mean, Max, Min, Std, Pixels ];

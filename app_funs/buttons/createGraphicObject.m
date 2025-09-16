function StatisticResult = createGraphicObject( ...
    StatisticResult, Size, axe )


GraphicObjectLinWidth = 1;
GraphicObjectFontSize = 18;

% ----- GRAPHIC objects -----
Pos1 = StatisticResult.Pos(1,:);
Pos2 = StatisticResult.Pos(2,:);

if strcmp( StatisticResult.Type, 'line' )

    StatisticResult.GraphicObject(1) = line( axe, ...
        [Pos1(1),Pos2(1)], [Pos1(2),Pos2(2)], ...
        'Color', 'w', 'LineWidth', GraphicObjectLinWidth, ...
        'UserData', 'GraphicObject' );
    
    if Pos1(1) > Pos2(1)
        mx = Pos1(1); my = Pos1(2);
    else
        mx = Pos2(1); my = Pos2(2);
    end
    mx = mx + Size(1) * 0.01;

else

    w = abs( Pos1(1) - Pos2(1) );
    h = abs( Pos1(2) - Pos2(2) );
    x = min( [ Pos1(1), Pos2(1) ] ) ;
    y = min( [ Pos1(2), Pos2(2) ] );
    StatisticResult.GraphicObject(1) = rectangle( axe, ...
        'Position', [ x, y, w, h ], ...
        'EdgeColor', 'w', 'LineWidth', GraphicObjectLinWidth, ...
        'UserData', 'GraphicObject' );

    mx = x + Size(1) * 0.01;
    my = y + h - Size(2) * 0.03;

end

StatisticResult.GraphicObject(2) = text( axe, ...
    mx, my, ...
    StatisticResult.DisplayName, ...
    'Color', 'w', ...
    'FontSize', GraphicObjectFontSize, ...
    'UserData', 'GraphicObject' );

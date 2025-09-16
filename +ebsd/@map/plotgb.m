function h = plotgb( emap, selection, axe, Color, LineWidth, SmoothFlag )

    dev0 = [ ...
        emap.pixels.XData(2)-emap.pixels.XData(1), ...
        emap.pixels.YData(2)-emap.pixels.YData(1) ];
    dev = dev0 * 0.1;
    range = [ emap.pixels.XData(1)+dev(1), emap.pixels.XData(end)-dev(1), ...*
              emap.pixels.YData(1)+dev(2), emap.pixels.YData(end)-dev(2) ];

    if SmoothFlag


        v = cell2mat( arrayfun( @(g) ...
            [ funNew( g.liveVertices, range, g.diam ); nan, nan ], ...
            emap.grains(selection), 'UniformOutput', false ) );

    else

        v = cell2mat( arrayfun( @(g) ...
            [ funNew( ...
            vertcat(g.Orignialverticemembers.vertice), range, g.diam ); ...
            nan, nan ], ...
            emap.grains(selection), 'UniformOutput', false ) ) ...
            - 1*dev0;

    end

    if isempty(v)
        h = gobjects(1);
        return
    end

    h = plot( axe, v(:,1), v(:,2), ...
            'Color', Color, 'LineWidth', LineWidth, ...
            'PickableParts', 'none' );

    function pos = funNew( pos, range, diam )
        ind =  pos(:,1) >= range(1) ...
             & pos(:,1) <= range(2) ...
             & pos(:,2) >= range(3) ...
             & pos(:,2) <= range(4);
        pos(~ind,:) = nan;

        % temp = abs( diff( pos ) );
        % i = any( temp > 3.0, 2 );
        % pos(i,:) = nan;

    end

end
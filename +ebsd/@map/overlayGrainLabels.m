function h = overlayGrainLabels( emap, selection, ax, Color, FontSize )


    Grains = emap.grains(selection);
    polys = vertcat( Grains.polygon );

    if isempty( polys )
        h = gobjects(1);
        return
    end

    IDs = vertcat( Grains.ID );
    [ x, y ] = polys.centroid;
    h = text( ax, x, y, num2str(IDs), ...
        'FontSize', FontSize, 'Color', Color, ...
        'Clipping', 'on' ,'PickableParts','none' );

end
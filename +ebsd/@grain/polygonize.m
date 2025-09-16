function eg = polygonize( eg, pixels, ebsdpara, dlg, TextArea, ParaFlag )


    dlg.Title = 'Polygonizing the pixel data';
    
    if ParaFlag
        % parallel
        dlg.Message = 'Polygonizing the pixel data';
        dlg.Indeterminate = 'on';
        parfor i = 1:length(eg)
            [grpixelsx, grpixelsy] = ...
                buildcells( pixels, ebsdpara, eg(i).pixelInds );
            poly = polyshape( grpixelsx, grpixelsy, 'Simplify', false );
            poly = simplify(poly);
            nholes = poly.NumHoles;
            if nholes
                poly = poly.rmholes;
            end

            val = poly.Vertices;
            eg(i).vertices = val;
        end
        dlg.Indeterminate = 'off';
    else
        % single thread
        for i = 1:length(eg)
            [grpixelsx, grpixelsy] = ...
                buildcells( pixels, ebsdpara, eg(i).pixelInds );
            poly = polyshape( grpixelsx, grpixelsy, 'Simplify', false );
            poly = simplify(poly);

            nholes = poly.NumHoles;
            if nholes
                % holes = poly.holes;
                % holes = holes( holes.area<1.5 );
                % if ~isempty( holes )
                %     poly = union( [poly; holes] );
                % end

                poly = poly.rmholes;
                dispText( TextArea, ...
                    [num2str(nholes), ...
                    ' holes removed from grain ', num2str(eg(i).ID)] );
            end

            eg(i).vertices = poly.Vertices;
            dlg.Value = i/length(eg);
            dlg.Message = [num2str(length(eg)-i-1), ...
                ' grains to be polygonized'];
        end
    end

    dispText( TextArea, ...
        [num2str(length(eg)), ' grains were polygonized'] );

end
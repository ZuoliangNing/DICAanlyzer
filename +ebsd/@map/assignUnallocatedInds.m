function assignUnallocatedInds( map, X, Y, Size, UnallocatedInds, dlg )

dlg.Title = 'Assigning unallocated pixels ...';

N = numel( UnallocatedInds );
[ x, y ] = arrayfun( @(g) g.polygon.centroid, map.grains );
Centroids = [x';y'];
num = 1;

for i = 1:N 
    flag = false;
    for j = 1 : map.numgrains
        Grain = map.grains(j);
        if ismember( UnallocatedInds(i), Grain.FrontierInds )
            Grain.IntrinsicInds = [ ...
                Grain.IntrinsicInds; UnallocatedInds(i) ];
            flag = true;
            break
        end
    end

    % MIN DISTANCE METHOD
    % if ~flag
    %     Distance = vecnorm( ...
    %         [ X( UnallocatedInds(i) );
    %           Y( UnallocatedInds(i) ) ] - Centroids );
    %     [ ~, ind ] = min( Distance );
    %     map.grains( ind(1) ).IntrinsicInds = [ ...
    %         map.grains( ind(1) ).IntrinsicInds; UnallocatedInds(i) ];
    % end

    if ~flag

        Distance = vecnorm( ...
            [ X( UnallocatedInds(i) );
              Y( UnallocatedInds(i) ) ] - Centroids );
        [ ~, I ] = sort( Distance );

        dev = 1;
        flag2 = false;
        while dev<50
            for j = I( 1 : min( 20,length(I) ) )
                Grain = map.grains(j);
                [ row, col ] = ind2sub( Size, Grain.FrontierInds );
                val = [ col+dev,  row   ;
                        col,      row+dev ; ...
                        col-dev,  row   ; ...
                        col,      row-dev  ];
                col = val(:,1); row = val(:,2);

                r = row > 0 & row <= Size(1) & col > 0 & col <= Size(2) ;
                row = row(r); col = col(r);
                ExtendedFrontierInds = sub2ind( Size, row, col );
                if ismember( UnallocatedInds(i), ExtendedFrontierInds )
                    Grain.IntrinsicInds = [ ...
                        Grain.IntrinsicInds; UnallocatedInds(i) ];
                    flag2 = true;
                    break
                end
            end
            if flag2; break; end
            dev = dev + 1;
        end
        if ~flag2
            % MIN DISTANCE METHOD
            Distance = vecnorm( ...
                [ X( UnallocatedInds(i) );
                  Y( UnallocatedInds(i) ) ] - Centroids );
            [ ~, ind ] = min( Distance );
            map.grains( ind(1) ).IntrinsicInds = [ ...
                map.grains( ind(1) ).IntrinsicInds; UnallocatedInds(i) ];
        end
    end


    dlgval = num * N * 0.01;
    if i > dlgval
        dlg.Value = dlgval / N ;
        dlg.Message = [ num2str(round(dlgval)), ' out of ', ...
            num2str(N),' pixels completed...' ];
        num = num + 1;
    end
end
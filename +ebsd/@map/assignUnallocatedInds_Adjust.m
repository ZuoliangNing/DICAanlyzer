function assignUnallocatedInds_Adjust( map, X, Y, UnallocatedInds, dlg )

dlg.Title = 'Assigning unallocated pixels ...';

N = numel( UnallocatedInds );
[ x, y ] = arrayfun( @(g) g.polygon.centroid, map.grains );
Centroids = [x';y'];
num = 1;

for i = 1:N 

    Distance = vecnorm( ...
        [ X( UnallocatedInds(i) );
          Y( UnallocatedInds(i) ) ] - Centroids );
    [ ~, ind ] = min( Distance );
    map.grains( ind(1) ).IntrinsicInds = [ ...
        map.grains( ind(1) ).IntrinsicInds; UnallocatedInds(i) ];

    dlgval = num * N * 0.01;
    if i > dlgval
        dlg.Value = dlgval / N ;
        dlg.Message = [ num2str(round(dlgval)), ' out of ', ...
            num2str(N),' pixels completed...' ];
        num = num + 1;
    end

end
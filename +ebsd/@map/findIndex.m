function findIndex( map, dlg, TextArea, ParaFlag )



x = map.pixels.x;
y = map.pixels.y;
siz = [ length(map.pixels.XData), length(map.pixels.YData) ]; % inverse!
% N = length(x);

Msg = 'Finding pixel index ...';
dlg.Title = Msg;


coeff = 0.01;
grains = map.grains;

if ParaFlag
    % parallel
    dlg.Message = Msg;
    dlg.Indeterminate = 'on';
    parfor i = 1 : map.numgrains
    
        Poly = grains(i).polygon;
    
        Range = [ ...
            ( 1 - coeff ) * min( Poly.Vertices ); 
            ( 1 + coeff ) * max( Poly.Vertices ) ];
    
        ind = find( ...
              x > Range(1,1) & x < Range(2,1) ...
            & y > Range(1,2) & y < Range(2,2) );
    
        [ ind_TFin, ind_TFon ] = isinterior( Poly, x(ind), y(ind) );
       
        TFin = ind( ind_TFin );
        TFon = ind( ind_TFon );
    
        TFin = setdiff( TFin, TFon );
        TF = union( grains(i).pixelInds, TFin );
    
        grains(i).InteriorInds = TFin;
        grains(i).FrontierInds = TFon;
        grains(i).IntrinsicInds = TF;
    
    end
    map.grains = grains;
    dlg.Indeterminate = 'off';

else
    % single thread
    for i = 1 : map.numgrains
        Grain = map.grains(i);
        Poly = Grain.polygon;
        Range = [ ...
            ( 1 - coeff ) * min( Poly.Vertices ); 
            ( 1 + coeff ) * max( Poly.Vertices ) ];
        ind = find( ...
              x > Range(1,1) & x < Range(2,1) ...
            & y > Range(1,2) & y < Range(2,2) );
        [ ind_TFin, ind_TFon ] = isinterior( Poly, x(ind), y(ind) );
        TFin = ind( ind_TFin );
        TFon = ind( ind_TFon );
        TFin = setdiff( TFin, TFon );
        TF = union( Grain.pixelInds, TFin );
        Grain.InteriorInds = TFin;
        Grain.FrontierInds = TFon;
        Grain.IntrinsicInds = TF;
        Msg = [ num2str(length(TFin)), ' inner pixels and ', ...
            num2str(length(TFon)), ' boundary pixels found inside grain ', ...
            num2str(Grain.ID) ];
        dlg.Value = i / map.numgrains;
        dlg.Message = [ 'Searching grain ', num2str(Grain.ID) ];
        dispText( TextArea, Msg );
    end

end


allIDs = [map.grains.ID];
val = cell2mat( arrayfun( @(g) ...
    [ g.FrontierInds, ...
      find( g.ID == allIDs ) * ones(size(g.FrontierInds)) ], ...
    map.grains, 'UniformOutput', false ));
% val:  FrontierInds / Grain ind
allIntrinsicInds = cell2mat( arrayfun( @(g) ...
    g.IntrinsicInds, map.grains, 'UniformOutput', false ) );
[ ~, ia ] = setdiff( val(:,1), allIntrinsicInds );
val = val( ia, : );
[ ~, ia ] = unique( val(:,1) );
val = val( ia, : );
arrayfun( @(i) set( map.grains( val(i,2) ), ...
    'IntrinsicInds', ...
    [ map.grains(val(i,2)).IntrinsicInds; val(i,1) ] ), ...
    1:size(val,1) )


% ****** UNALLOCATED ******
AllocatedInds = cell2mat( arrayfun( @(g) g.IntrinsicInds, ...
        map.grains, 'UniformOutput', false ) );
UnallocatedInds = setdiff( map.pixels.index + 1 , AllocatedInds );
assignUnallocatedInds( ...
    map, map.pixels.x, map.pixels.y, ...
    siz, UnallocatedInds, dlg )


% ****** OVER ALLOCATED - 1 NEW ******
allIDs = [map.grains.ID];
val = cell2mat( arrayfun( @(g) ...
    [ g.IntrinsicInds, ...
      find( g.ID == allIDs ) * ones(size(g.IntrinsicInds)) ], ...
    map.grains, 'UniformOutput', false ));
allIntrinsicInds = val(:,1);
tbl = tabulate( allIntrinsicInds );
OverallocatedInds = tbl( tbl(:,2)>1, 1 );
if ~isempty( OverallocatedInds )
    val = val( ismember( val(:,1), OverallocatedInds ), : );
    % val:  OverallocatedInds / Grain ind
    tbl = tabulate( val(:,2) );
    tbl = sortrows( tbl( tbl(:,2)>0, : ), 2, 'descend' );
    % tbl:  Grain ind / Number of OverallocatedInds in this grain / frequency
    for i = 1:size(tbl,1)
        gind = tbl(i,1);
        g = map.grains( gind );
        if tbl(i,2) > 0.8 * numel( g.IntrinsicInds )
            % g.IntrinsicInds = setdiff( g.IntrinsicInds, ...
            %     val( val(:,2) == gind, 1 ) );
            ind1 = val(:,2) == gind;
            ind2 = xor( ismember( val(:,1), val(ind1,1) ), ind1 );
            tempval = val(ind2,:);
            parentgind = unique( tempval(:,2) );
            for ind = parentgind
                map.grains( ind ).IntrinsicInds = setdiff( ...
                    map.grains( ind ).IntrinsicInds, ...
                    tempval( tempval(:,2) == ind, 1 ) );
            end
        end
    end
end


% OVER ALLOCATED - 1
% ind = find( arrayfun( @(g) isscalar(g.neighbours), map.grains ) );
% for i = ind'
%     g = map.grains(i); % small
%     gn = map.grains( [map.grains.ID] == g.neighbours ); % big
%     gtemp = intersect( g.polygon, gn.polygon );
%     if gtemp.NumRegions > 0
%         gn.IntrinsicInds = ...
%             setdiff( gn.IntrinsicInds, g.IntrinsicInds );
%         gn.InteriorInds = ...
%             setdiff( gn.InteriorInds, g.IntrinsicInds );
%     end
% end

% ****** OVER ALLOCATED - 2 ******
allIDs = [map.grains.ID];
val = cell2mat( arrayfun( @(g) ...
    [ g.IntrinsicInds, ...
      find( g.ID == allIDs ) * ones(size(g.IntrinsicInds)) ], ...
    map.grains, 'UniformOutput', false ));
allIntrinsicInds = val(:,1);
tbl = tabulate( allIntrinsicInds );
OverallocatedInds = tbl( tbl(:,2)>1, 1 );
if ~isempty( OverallocatedInds )
    for ind = OverallocatedInds'
        grains = map.grains( val( allIntrinsicInds == ind, 2 ) );
        for g = grains(2:end)
            g.IntrinsicInds = setdiff( ...
                    g.IntrinsicInds, ind );
            % Poly = g.polygon;
            % if ~ isinterior( Poly, x(ind), y(ind) )
            % end
        end
    end
end



% **************** for original data ****************
% element number in 'map.pixels.YData' is 1 more greater than
% 'EBSDData.YData'
% 
    function Ind = tempfun( val, siz )
        [ row, col ] = ind2sub( siz, val );
        r = row <= siz(1) & col <= siz(2)-1 ;
        row = row(r); col = col(r);
        Ind = sub2ind( [siz(2)-1,siz(1)], col, row );
    end

for i = 1 : map.numgrains
    
    Grain = map.grains(i);
    % [ Grain.IntrinsicInds.row, ...
    %   Grain.IntrinsicInds.col ] = ind2sub( siz, Grain.IntrinsicInds.ind );
    
    Grain.InteriorInds = tempfun( Grain.InteriorInds, siz );
    Grain.FrontierInds = tempfun( Grain.FrontierInds, siz );
    Grain.IntrinsicInds = tempfun( Grain.IntrinsicInds, siz );

end


end

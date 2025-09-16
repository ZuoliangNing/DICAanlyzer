function [ minval, maxval ] = getCLim( data, n )

if n
    m = mean( data(:), 'omitnan' );
    s = std ( data(:), 'omitnan' ) / 10;
    
    temp = n*s;
    minval = m - temp ;
    maxval = m + temp ;
    
    if isnan( minval )
        minval = 0 ;
        maxval = 1 ;
    end
else
    [ minval, maxval ] = bounds( data, "all" );
end

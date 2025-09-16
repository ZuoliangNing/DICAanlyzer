function Data = getExportDICData( DICData, XData, YData, ...
    DataValueRange, Threshold, BoundaryOnlyFlag )

VariableNames = fieldnames( DICData );

% Data simplification
Size = size( DICData.( VariableNames{1} ) );
if any( Size > Threshold )
    Span = round( max( Size ) / Threshold );
else; Span = 1;
end
ind1 = 1 : Span : Size(1);
ind2 = 1 : Span : Size(2);

Data = struct();
prec = 4;

% Coords
% ----- set origin to zero and rebuild X/Y data

XData = XData(ind2); YData = YData(ind1);

XSTEP = round( XData(2) - XData(1), 3 );
YSTEP = round( YData(2) - YData(1), 3 );

XData = ( 0 : length( XData ) - 1 ) * XSTEP;
YData = ( 0 : length( YData ) - 1 ) * YSTEP;

[ X ,Y ] = meshgrid( XData, YData );

for i = 1:numel( VariableNames )
    name = VariableNames{i};
    if isfield( DataValueRange, name )
        val = restoreData( ...
            DICData.( name ), ...
            DataValueRange.( name ) );
    end
    Data.( name ) = DataFun_all( val, ind1, ind2, prec );
end

if BoundaryOnlyFlag
    Data.X = getBoundaryValue( X );
    Data.Y = getBoundaryValue( Y );
    for i = 1:numel( VariableNames )
        name = VariableNames{i};
        Data.( name ) = getBoundaryValue( Data.( name ) );
    end
else
    Data.X = X(:); Data.Y = Y(:);
    for i = 1:numel( VariableNames )
        name = VariableNames{i};
        Data.( name ) = Data.( name )(:);
    end
end




    function val = DataFun_all( data, ind1, ind2, prec )
        val = data( ind1, ind2 );
        if ~isnan(prec)
            val = round( val, prec );
        end
    end

    function val = getBoundaryValue( val )
        val = [ val( 1, 1:end-1 )';    val( 1:end-1, end ); 
                val( end, 2:end )'; val( 2:end, 1 ) ];
    end

end
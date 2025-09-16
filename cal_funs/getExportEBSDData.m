function Data = getExportEBSDData( ...
    EBSDData, Threshold, UsePolygonizedIDFlag )


if UsePolygonizedIDFlag
    map = EBSDData.Map;
    allIDs = [map.grains.ID];
    val = cell2mat( arrayfun( @(g) ...
        [ g.IntrinsicInds, ...
          g.ID * ones(size(g.IntrinsicInds)), ...
          find( g.ID == allIDs ) * ones(size(g.IntrinsicInds)) ], ...
        map.grains, 'UniformOutput', false ));
    val = sortrows( val );

    EBSDData.GrainID = reshape( val(:,2), EBSDData.DataSize(1:2) );
    EBSDData.Phase = reshape( [ map.grains( val(:,3) ).phase ], ...
        EBSDData.DataSize(1:2) );
    Names = {'meanphi1','meanPHI','meanphi2'};
    for i = 1:3
        EBSDData.EulerAngles(:,:,i) = ...
            reshape( [ map.grains( val(:,3) ).(Names{i}) ], ...
                EBSDData.DataSize(1:2) );
    end

end

% Data simplification
Size = EBSDData.DataSize(1:2);
if any( Size > Threshold )
    Span = round( max( Size ) / Threshold );
else; Span = 1;
end
ind1 = 1 : Span : Size(1);
ind2 = 1 : Span : Size(2);

N = numel(ind1) * numel(ind2);

% precision
prec = 3;

% Coords
% ----- set origin to zero and rebuild X/Y data

XData = EBSDData.XData(ind2); YData = EBSDData.YData(ind1);
XSTEP = round( XData(2) - XData(1), 3 );
NCOLS = length( XData );
YSTEP = round( YData(2) - YData(1), 3 );
NROWS = length( YData );

XData = ( 0 : length( XData ) - 1 ) * XSTEP;
YData = ( 0 : length( YData ) - 1 ) * YSTEP;

[ X ,Y ] = meshgrid( XData, YData );
X = X(:); Y = Y(:);

% Euler angles
phi1 = DataFun( EBSDData.EulerAngles(:,:,1), ind1, ind2, prec );
PHI =  DataFun( EBSDData.EulerAngles(:,:,2), ind1, ind2, prec );
phi2 = DataFun( EBSDData.EulerAngles(:,:,3), ind1, ind2, prec );

% IQ ----- default: 0
if ~isempty( EBSDData.IQ )
    iq = DataFun( EBSDData.IQ, ind1, ind2, prec );
else; iq = zeros(N,1);
end

% CI ----- default: 0
if ~isempty( EBSDData.CI )
    ci = DataFun( EBSDData.CI, ind1, ind2, prec );
else; ci = zeros(N,1);
end

% EdgeIndex ----- default: 0
if ~isempty( EBSDData.EdgeIndex )
    EdgeIndex = DataFun( EBSDData.EdgeIndex, ind1, ind2, nan );
else; EdgeIndex = zeros(N,1);
end

% sem_signal & fit
sem_signal = ones(N,1);
fit = zeros(N,1);

% phase ----- default: 1
if ~isempty( EBSDData.Phase )
    phase = DataFun( EBSDData.Phase, ind1, ind2, nan );
else; phase = ones(N,1);
end

% GrainID ----- default: 1
if ~isempty( EBSDData.GrainID )
    GrainID = DataFun( EBSDData.GrainID, ind1, ind2, nan );
else; GrainID = ones(N,1);
end

Data = struct( ...
    'X',    X, ...
    'XSTEP',XSTEP, ...
    'Y',    Y, ...
    'YSTEP',YSTEP, ...
    'NCOLS',NCOLS, ...
    'NROWS',NROWS, ...
    'phi1', phi1, ...
    'PHI',  PHI, ...
    'phi2', phi2, ...
    'IQ',   iq, ...
    'CI',   ci, ...
    'EdgeIndex', EdgeIndex, ...
    'sem_signal', sem_signal, ...
    'fit',  fit, ...
    'Phase', phase, ...
    'GrainID', GrainID );






    function val = DataFun( data, ind1, ind2, prec )
        val = data( ind1, ind2 );
        if ~isnan(prec); val = round( val(:), prec );
        else; val = val(:);
        end
    end



end
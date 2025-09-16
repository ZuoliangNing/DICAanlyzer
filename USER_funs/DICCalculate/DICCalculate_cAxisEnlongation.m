function DIC = DICCalculate_cAxisEnlongation( ...
    DIC, EBSDData, dlg )


dlg.Message = 'Calculating ''Enlongation Along c-axis''...';

map = EBSDData.Map;
grains = map.grains;
GrainNumber = length( grains );
pixelsize = [ mean( diff( DIC.XData ) ), mean( diff( DIC.YData ) ) ];

N = DIC.DataSize(1:2);

EulerAngls = nan( GrainNumber, 3 );

if ~isequal( EBSDData.SampleCoordOri.X, [1,0] ) || ...
        ~isequal( EBSDData.SampleCoordOri.Y, [0,-1] )
    if isequal( EBSDData.SampleCoordOri.X, [0,1] ) && ...
        isequal( EBSDData.SampleCoordOri.Y, [-1,0] )
        % OIM default
        % adjust method is the same as in 
        % 'EBSDPreprocess_Method_AssignColumn.m'
        % G_ima2sam -- Image Coord -> OIM Sample Coord
        G_ima2sam = [0,-1,0;-1,0,0;0,0,-1];
        for i = 1:GrainNumber
            Angles = [ grains(i).meanphi1, ...
                grains(i).meanPHI, grains(i).meanphi2 ];
            % R -- OIM Sample Coord -> Crystal Coord
            R = EulerAngle2TransferMatrix( Angles );
            % R_new -- Image Coord -> Crystal Coord
            R_new = R * G_ima2sam;
            [ phi1, PHI, phi2 ] = TransferMatrix2EulerAngle( R_new );
            EulerAngls(i,:) = [ phi1, PHI, phi2 ];
        end
    else
        erorr( 'Update this script!' )
    end
else
    for i = 1:GrainNumber
        EulerAngls(i,:) = [ grains(i).meanphi1, ...
            grains(i).meanPHI, grains(i).meanphi2 ];
    end
end


for n = 1:DIC.StageNumber
    
    u = restoreData( DIC.Data(n).u, DIC.DataValueRange.u );
    v = restoreData( DIC.Data(n).v, DIC.DataValueRange.v );
    [ Hxx, Hxy ] = gradient( u, pixelsize(1), pixelsize(2) );
    [ Hyx, Hyy ] = gradient( v, pixelsize(1), pixelsize(2) );

    Fxx = Hxx(:) + 1;   Fxy = Hxy(:);
    Fyx = Hyx(:);       Fyy = Hyy(:) + 1;
    Hzz = - Hxx - Hyy;
    % Fzz = 1./ ( Fxx(:).* Fyy(:) - Fxy(:).* Fyx(:) );
    Fzz = Hzz(:) + 1;

    % Cxx = Fxx.^2 + Fyx.^2;
    % Cxy = Fxx.* Fxy + Fyx.* Fyy;
    % Cyx = Cxy;
    % Cyy = Fyy.^2 + Fxy.^2;
    % Czz = Fzz.^2;

    Value = nan( N );

    for i = 1:GrainNumber
        g = map.grains(i);
        ind = g.IntrinsicInds;
        
        R = EulerAngle2TransferMatrix( EulerAngls(i,:) ); % sam -> cry
        dir0 = R' * [ 0, 0, 1 ]';

        % val = arrayfun( @(i) ...
        %     sqrt( dir0' * ...
        %     blkdiag( [ Cxx(i), Cxy(i); Cyx(i), Cyy(i) ], Czz(i) ) ...
        %     * dir0 ) - 1, ind );

        dir = [ ...
            Fxx(ind) * dir0(1) + Fxy(ind) * dir0(2), ...
            Fyx(ind) * dir0(1) + Fyy(ind) * dir0(2), ...
            Fzz(ind) * dir0(3) ]'; % zeros(length(ind),1)
        val = vecnorm(dir) - 1;

        % temp = val * ( norm( dir0(1:2) ) > 0.8 );
        % temp( abs( temp ) > 0.5 ) = nan;
        % temp = mean( temp, 'omitmissing' );
        % Value(ind) = temp;

        % val( abs( val ) < 0.01 ) = 0;
        % Value(ind) = abs( val * ( norm( dir0(1:2) ) > cosd(60) ) );
        %  
        Value(ind) = val;

    end

    DIC.Data(n).cAxisEnlongation = Value;

end
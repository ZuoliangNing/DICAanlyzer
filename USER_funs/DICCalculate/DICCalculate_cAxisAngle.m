function DIC = DICCalculate_cAxisAngle( ...
    DIC, EBSDData, dlg )


dlg.Message = 'Calculating ''Angle between c-axis and xy-plane''...';

map = EBSDData.Map;
grains = map.grains;
GrainNumber = length( grains );

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

Value = nan( N );
for i = 1:GrainNumber
    g = map.grains(i);
    ind = g.IntrinsicInds;
    
    R = EulerAngle2TransferMatrix( EulerAngls(i,:) ); % sam -> cry
    dir0 = R' * [ 0, 0, 1 ]';

    temp = acosd( norm( dir0(1:2) ) );
    % if temp > 10 && temp < 80
    %     Value(ind) = 0;
    % else
    %     Value(ind) = temp; % acosd( norm( dir0(1:2) ) );
    % end
    Value(ind) = temp;
end

for n = 1:DIC.StageNumber
    DIC.Data(n).cAxisAngle = Value;
end
function [ phi1, PHI, phi2 ] = TransferMatrix2EulerAngle( R )


if R(3,3) == 1
    PHI = 0;
    phi1 = atan2( R(1,2), R(1,1) );
    phi2 = 0;
else
    PHI = acos( R(3,3) );
    phi1 = atan2( R(3,1) / sin(PHI), -R(3,2) / sin(PHI) );
	phi2 = atan2( R(1,3) / sin(PHI),  R(2,3) / sin(PHI) );
end
function AdjustEBSD_TEST( obj, ~, ~, app )
% ( obj, EBSDSerial, PointCoords, app )

close all

val(:,:,1) = 1.0e+03 * [ ...
    1.0415    0.2065
    1.4869    0.4515
    2.3471    2.0277
    1.5562    1.8580 ];

val(:,:,2) = [ ...
    133.9331   21.5392
    177.2744   34.7367
    249.3315  128.5960
    169.8363  122.6203 ];

PointCoords = val; % ( PointSetNum )( x / y )( DIC / EBSD )

fixedPoints  = PointCoords( :, :, 1 ); % [ n, 2 ] ( PointSetNum )( x / y )
movingPoints = PointCoords( :, :, 2 ); % 

Colors = [ ...
    1, 1, 1; 
    0, 0, 0; 
    1, 0, 1; 
    1, 1, 0 ];
Size = 100;

% ******* DIC Image *******
n = 4;
VariableName = 'exx';
[ axe, fig ] = getAxe( 'XPos', 1300 );
DICValue = obj.DIC.Data(n).( VariableName );
SIZE = size( DICValue );

% dev = [ obj.DIC.XData(1), obj.DIC.YData(1) ];
% fixedPoints = fixedPoints - dev;

image( ...
    axe, DICValue, ...
    'CDataMapping','scaled' );
    
axis image; axe.YDir = 'reverse';
[ minval, maxval ] = getCLim( ...
    DICValue, app.Default.Options.DICCLimCoeff );
axe.CLim = [ minval, maxval ];
colormap( axe, app.Default.Options.DICColormap )

%   --- fixedPoints ---
scatter( axe, fixedPoints(:,1), fixedPoints(:,2), ...
    Size, Colors, 'filled' )

% ******* EBSD Image *******
EBSDSerial = 1;
EBSDData = obj.EBSD.Data( EBSDSerial );
[ axe2, fig ] = getAxe( fig, 'FigPos', 'bottom' );
axis image; axe2.YDir = 'reverse';
EBSDValue = permute( EBSDData.IPF{ 3 }, [2,1,3] );
dY = EBSDData.YData(2) - EBSDData.YData(1); % um / pixel
dX = EBSDData.XData(2) - EBSDData.XData(1); % um / pixel
axe2.DataAspectRatio(2) = dX / dY;
image( axe2, EBSDValue );

%   --- movingPoints ---
scatter( axe2, movingPoints(:,1), movingPoints(:,2), ...
    Size, Colors, 'filled' )


tformType = 'affine'; % "similarity"; projective
tform = fitgeotform2d( ...
    movingPoints, fixedPoints, tformType );


AdjustedEBSDValue = imwarp( ...
    EBSDValue, tform, ...
    OutputView = imref2d( SIZE ), ...
    FillValues = nan );



R = tform.A( 1:2, 1:2 ); t = tform.A( 1:2, 3 );


AdjustedmovingPoints = ( R * movingPoints' + t )' ;



% ******* Adjusted EBSD Image *******
axe3 = getAxe( fig, 'FigPos', 'left' );
axis image; axe3.YDir = 'reverse';
AlphaData = ~isnan( AdjustedEBSDValue(:,:,1) ) * 0.7 ;

im1 = image( axe3, DICValue, 'CDataMapping','scaled' );
im2 = image( axe3, AdjustedEBSDValue, 'AlphaData', AlphaData );



[ minval, maxval ] = getCLim( ...
    DICValue, app.Default.Options.DICCLimCoeff );
axe3.CLim = [ minval, maxval ];
colormap( axe3, app.Default.Options.DICColormap )

%   --- fixedPoints ---
% scatter( axe3, AdjustedmovingPoints(:,1), AdjustedmovingPoints(:,2), ...
%     Size, Colors, 'filled' )


temp = R * [ 1, 0 ]';
theta = atan2( temp(2), temp(1) );
Xratio_1 = dX * cos( theta ) / temp(1); % um / pixel
Yratio_1 = dX * sin( theta ) / temp(2); % um / pixel

temp = R * [ 0, 1 ]';
theta = atan2( temp(2), temp(1) );
Xratio_2 = dY * cos( theta ) / temp(1);
Yratio_2 = dY * sin( theta ) / temp(2);


Xratio = mean( [ Xratio_1, Xratio_2 ] );
Yratio = mean( [ Yratio_1, Yratio_2 ] );

im1.XData = [ 0, SIZE(2) * Xratio ];
im1.YData = [ 0, SIZE(1) * Yratio ];
im2.XData = [ 0, SIZE(2) * Xratio ];
im2.YData = [ 0, SIZE(1) * Yratio ];


pause(1)
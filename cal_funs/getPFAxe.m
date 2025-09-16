function PFAxe = getPFAxe( parent, ori )


PFAxe = polaraxes( parent, 'NextPlot', 'add' );
PFAxe.FontName = 'Times New Roman'; PFAxe.FontSize = 18;
grid( PFAxe, 'off' )
axis( PFAxe, 'tight' )
PFAxe.RTick = []; PFAxe.ThetaTick = [];
temptheta = 0 : 0.01 : 2*pi;
r = ones( 1, length( temptheta ) );
polarplot( PFAxe, temptheta, r, 'LineWidth', 1, 'Color', 'black' );
PFAxe.RLim = [0,1];
% cross lines
polarplot( PFAxe, [0,pi], [1,1], 'LineWidth', 0.5, 'Color', 'black' );
polarplot( PFAxe, [pi/2,3*pi/2], [1,1], 'LineWidth', 0.5, 'Color', 'black' );
% sample coord labels
[ theta_1, rho_1 ] = cart2pol( ori.X(1), ori.X(2) );
text( PFAxe, theta_1, rho_1*1.2, 'A1', ...
    'FontSize', 12, 'VerticalAlignment', 'cap' );
[ theta_2, rho_2 ] = cart2pol( ori.Y(1), ori.Y(2) );
text( PFAxe, theta_2, rho_2*1.2, 'A2', ...
    'FontSize', 12, 'VerticalAlignment', 'cap' );
% text( PFAxe, pi/2, 1.1, 'A1', 'FontSize', 12 );
% text( PFAxe, pi, 1.25, 'A2', 'FontSize', 12 );
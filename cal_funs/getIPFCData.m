function C = getIPFCData( x, y, z, Phase, PhaseNames )
%
%   PhaseNames  - (N,1) cell
%   x, y, z     - (N,1) double
%
%   Vector [x,y,z] is unit vectors in CRYSTAL coord
%       translated from a direction in SAMPLE coord
%   Possible to be of any direction
%
%   'vecnorm([x,y,z]) == 1'


[ FCC_PhaseNames, BCC_PhaseNames, HCP_PhaseNames ] ...
    = getPhaseNames();

C = nan( length(x), 3 );

% use HCP as default
if isempty( PhaseNames )
    
    PhaseNames = HCP_PhaseNames(1);
    Phase = ones(size(x));

end

% *********** Cubic: FCC & BCC ***********

Cubic_ind = find( cellfun( @(s) ...
    any( strcmp( s, [ FCC_PhaseNames, BCC_PhaseNames ] ) ), PhaseNames ) );

if ~isempty( Cubic_ind )

    Cubic_ind = any( Phase == Cubic_ind', 2 );
    
    X = x( Cubic_ind ); Y = y( Cubic_ind ); Z = z( Cubic_ind );
    
    % --- adjust vector based on symmetry ---
    %           should be ( X, Y, Z >= 0 ) && ( X >= Y ) && ( Z >= X )
    
    X = abs(X); Y = abs(Y); Z = abs(Z);  % ( X, Y, Z > 0 )
    

    ind = Z < X; t = Z(ind); Z(ind) = X(ind); X(ind) = t; % ( Z >= X )

    ind = X < Y; t = X(ind); X(ind) = Y(ind); Y(ind) = t; % ( X >= Y )
    
    ind = Z < X; t = Z(ind); Z(ind) = X(ind); X(ind) = t; % ( Z >= X )
    % !!!

    % close all
    % figure
    % axe = axes();
    % scatter3( X, Y, Z, 10, 'k', 'filled' )
    % axis equal
    % axe.XLim(1) = 0; axe.YLim(1) = 0; axe.ZLim(1) = 0;

    % --- stereographic projection ---
    [ theta, r ] = getProjection( X, Y, Z );
    
    % --- get color ---
    rMax = max( r ) * 0.8;
    
    c(:,1) = 1 - ( r / rMax ).^ 0.7 ;
    
    c(:,3) = theta * 4 / pi ;
    c(:,2) = 1 - c(:,3);
    c(:,2:3) = c(:,2:3).* r + 0.1;
    c(c > 1) = 1;
    temp = max( c, [], 2 );
    c = c./ temp;
    
    C( Cubic_ind, : ) = c;

end

c = [];

% ***************************


% *********** HCP ***********

HCP_ind = find( cellfun( @(s) ...
    any( strcmp( s, HCP_PhaseNames ) ), PhaseNames ) );

if ~isempty( HCP_ind )

    HCP_ind = any( Phase == HCP_ind', 2 );

    X = x( HCP_ind ); Y = y( HCP_ind ); Z = z( HCP_ind );
    
    % --- adjust vector based on symmetry ---
    %           'theta' should be within ( 0 ~ pi/6 )
    
    % --- stereographic projection ---
    
    [ theta, r ] = getProjection( X, Y, Z );
    
    % --- adjust theta based on symmetry ---
    
    theta = rem( theta, pi/3 ); % theta -> ( 0 ~ pi/3 )
    ind = theta > pi/6;
    theta(ind) = pi/3 - theta(ind); % theta -> ( 0 ~ pi/6 )
    
    c(:,1) = 1 - r.^ 0.7 + 0.1;
    c(:,3) = theta * 6 / pi ;
    c(:,2) = 1 - c(:,3);
    c(:,2:3) = c(:,2:3).* r + 0.1;
    c( c > 1 ) = 1;
    temp = max( c, [], 2 );
    c = c./ temp;
    
    C( HCP_ind, : ) = c;

end
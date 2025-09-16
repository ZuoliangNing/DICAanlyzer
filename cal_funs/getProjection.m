function [ theta, r ] = getProjection( x, y, z )
% Stereographic projection
%
%   x, y, z - (N,1) double
%
%   Vector [x,y,z] should be on the Unit Sphere
%   i.e. 'vecnorm([x,y,z]) == 1'
%
%   theta   - (N,1) double - within ( 0 ~ 2pi )
%   r       - (N,1) double - within ( 0 ~ 1 )

ind = z < 0;
x(ind) = -x(ind); y(ind) = -y(ind); z(ind) = -z(ind);

[ theta, rho ] = cart2pol( x, y );          % theta -> ( -pi ~ pi )
theta( theta<0 ) = theta( theta<0 ) + 2*pi; % theta -> ( 0 ~ 2pi )

r = rho./ ( 1 + z );
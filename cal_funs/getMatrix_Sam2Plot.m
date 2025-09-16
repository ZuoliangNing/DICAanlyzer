function G = getMatrix_Sam2Plot( ori )


% 'G' -- tranfer matrix from Smaple Coord -> Plot Coord
%     -- Plot Coord : X-right, Y-up
if isequal( ori.X, [0,1] ) && isequal( ori.Y, [-1,0] )
    % sample definitoin --- OIM default
    G = [0,-1,0;1,0,0;0,0,1];
elseif isequal( ori.X, [1,0] ) && isequal( ori.Y, [0,-1] )
    % sample definitoin --- coincide with the Image Coord 
    %                   --- X-right, Y-down
    G = diag([1,-1,-1]);
else
    error( 'Update this script!' )
end
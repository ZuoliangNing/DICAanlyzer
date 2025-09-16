function UserMaterialFormats_OXFORD_UMAT( inpFile, grains )


% Number of Solution Dependent State Variables
DepvarNumber = 230;
% Number of User Material Constants
UserMaterialConstantsNumber = 6;

for i = 1:numel( grains )

	fprintf( inpFile, '\n*Material, name=Grain-%d', grains(i).ID );
	fprintf( inpFile, '\n*Depvar' );
    % set proper number of state variables
	fprintf( inpFile, ['\n    ',num2str(DepvarNumber),','] );
	fprintf( inpFile, ['\n*User Material, constants=',num2str(UserMaterialConstantsNumber)] );
	
    Angles = rad2deg( ...
        [ grains(i).meanphi1, grains(i).meanPHI, grains(i).meanphi2 ] );
    
    % fprintf( inpFile, ...
    %     '\n%6.0f,%6.0f,%6.5f,%6.5f,%6.5f,', ...
    %     grains(i).ID, grains(i).phase, Angles );


    fprintf( inpFile, ...
        '\n%6.5f,%6.5f,%6.5f,%6.0f,%6.0f,', ...
        Angles, grains(i).ID, 4 - grains(i).phase );
    % phase : hcp 1 -> 3 / fcc 2 -> 2

end
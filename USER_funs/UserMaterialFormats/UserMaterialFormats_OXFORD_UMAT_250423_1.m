function UserMaterialFormats_OXFORD_UMAT_250423_1( inpFile, grains )


%% Parameter Definition

% Number of Solution Dependent State Variables
DepvarNumber = 230;
% Number of User Material Constants
numConstants = 274;

temp = zeros( 1, numConstants );
%% Output Selection: statev_outputs
temp(99)    = 1;
temp(100)   = 1;
temp(101)   = 1;
temp(102)   = 1;
temp(103)   = 1;
temp(104)   = 1;
temp(107)   = 1;
temp(108)   = 1;
temp(110)   = 1;
temp(111)   = 1;
temp(112)   = 1;
temp(115)   = 1;
temp(116)   = 1;
temp(117)   = 1;
temp(118)   = 1;
temp(119)   = 1;
temp(120)   = 1;
temp(121)   = 1;
temp(122)   = 1;
temp(123)   = 1;
temp(124)   = 1;


[ mcHCP, mcFCC ] = deal( temp );

%% ******** Parameters for HCP phase (Material id == 3) ********
phaid           = 3;
nslip           = 30;
nscrew          = 9;
cubicslip       = 0;
gf              = 0.4;
C11             = 136000;
C12             = 65000;
C44             = 32000;
C13             = 47000;
C33             = 154000;
caratio         = 1.593;
alpha1          = 0;
alpha2          = 0;
alpha3          = 0;
slipmodel       = 1;
slipparam_1     = 0;
slipparam_2     = 0;
slipparam_3     = 1;
slipparam_4     = 0.01;
slipparam_5     = 5e-20; % delta_F
slipparam_6     = 1e11;
slipparam_7     = 1;
slipparam_8     = 20.93; % delta_V
creepmodel      = 0;
hardeningmodel  = 2;
hardeningparam_1 = 1e-20;
irradiationmodel = 0;
backstressparam_1 = 8000;
backstressparam_2 = 100;
rho_0           = 0.01;
burger1         = 3.2e-4;
burger2         = 6.1e-4;
xtauc1          = 129.01; % basal
xtauc2          = 97.0; % prismatic
xtauc3          = 5000.0; % pyramidal
xtauc4          = 337.56; % pyramidal-1
xtauc5          = 5000.0; % pyramidal-2

mcHCP(5) = phaid; % Material id: matid
mcHCP(6) = 1; % readfromprops
mcHCP(7) = phaid; % Phase id: phaid
mcHCP(8) = nslip;
mcHCP(9) = nscrew;
mcHCP(10) = cubicslip;
mcHCP(11) = gf;
mcHCP(12) = C11;
mcHCP(13) = C12;
mcHCP(14) = C44;
mcHCP(15) = C13;
mcHCP(16) = C33;
mcHCP(21) = caratio;
mcHCP(22) = alpha1;
mcHCP(23) = alpha2;
mcHCP(24) = alpha3;
mcHCP(25) = slipmodel;
mcHCP(26) = slipparam_1;
mcHCP(27) = slipparam_2;
mcHCP(28) = slipparam_3;
mcHCP(29) = slipparam_4;
mcHCP(30) = slipparam_5;
mcHCP(31) = slipparam_6;
mcHCP(32) = slipparam_7;
mcHCP(33) = slipparam_8;
mcHCP(40) = creepmodel;
mcHCP(55) = hardeningmodel;
mcHCP(56) = hardeningparam_1;
mcHCP(70) = irradiationmodel;
mcHCP(85) = backstressparam_1;
mcHCP(86) = backstressparam_2;
mcHCP(129:158) = rho_0;
mcHCP(177:182) = burger1;
mcHCP(183:206) = burger2;
mcHCP(225:227) = xtauc1;
mcHCP(228:230) = xtauc2;
mcHCP(231:236) = xtauc3;
mcHCP(237:248) = xtauc4;
mcHCP(249:254) = xtauc5;


%% ******** Parameters for FCC phase (Material id == 2) ********
phaid           = 2;
nslip           = 12;
nscrew          = 6;
cubicslip       = 0;
gf              = 0.28;
C11             = 114800;
C12             = 74200;
C44             = 47640;
caratio         = 1;
alpha1          = 0.0393;
alpha2          = 0.0393;
alpha3          = 0.0393;
slipmodel       = 1;
slipparam_1     = 0;
slipparam_2     = 0;
slipparam_3     = 1;
slipparam_4     = 0.01;
slipparam_5     = 7.210e-20;
slipparam_6     = 1e11;
slipparam_7     = 0;
slipparam_8     = 11.1;
creepmodel      = 0;
hardeningmodel  = 2;
hardeningparam_1 = 1e-20;
irradiationmodel = 0;
backstressparam_1 = 8000;
backstressparam_2 = 100;
rho_0           = 0.01;
burger1         = 3.37e-4;
xtauc1          = 196.0;

mcFCC(5) = phaid; % Material id: matid
mcFCC(6) = 1; % readfromprops
mcFCC(7) = phaid; % Phase id: phaid
mcFCC(8) = nslip;
mcFCC(9) = nscrew;
mcFCC(10) = cubicslip;
mcFCC(11) = gf;
mcFCC(12) = C11;
mcFCC(13) = C12;
mcFCC(14) = C44;
mcFCC(21) = caratio;
mcFCC(22) = alpha1;
mcFCC(23) = alpha2;
mcFCC(24) = alpha3;
mcFCC(25) = slipmodel;
mcFCC(26) = slipparam_1;
mcFCC(27) = slipparam_2;
mcFCC(28) = slipparam_3;
mcFCC(29) = slipparam_4;
mcFCC(30) = slipparam_5;
mcFCC(31) = slipparam_6;
mcFCC(32) = slipparam_7;
mcFCC(33) = slipparam_8;
mcFCC(40) = creepmodel;
mcFCC(55) = hardeningmodel;
mcFCC(56) = hardeningparam_1;
mcFCC(70) = irradiationmodel;
mcFCC(85) = backstressparam_1;
mcFCC(86) = backstressparam_2;
mcFCC(129:158) = rho_0;
mcFCC(177:206) = burger1;
mcFCC(225:254) = xtauc1;




%% Write Inp

for i = 1:numel( grains )

	fprintf( inpFile, '\n*Material, name=Grain-%d', grains(i).ID );
	fprintf( inpFile, '\n*Depvar' );
    % set proper number of state variables
	fprintf( inpFile, ['\n    ',num2str( DepvarNumber ),','] );
	fprintf( inpFile, ...
        '\n*User Material, constants=%d\n', ...
        numConstants );
	
    Angles = rad2deg( ...
        [ grains(i).meanphi1, grains(i).meanPHI, grains(i).meanphi2 ] );

    if grains(i).phase == 1 % g.phase : hcp 1 / fcc 2
        materialConstants = mcHCP;
    elseif grains(i).phase == 2
        materialConstants = mcFCC;
    end
    materialConstants(1:3)  = Angles;
    materialConstants(4)    = grains(i).ID;

    for j = 1:numConstants

        % Adjust '%.8e' for desired precision/format
        fprintf( inpFile, '%.8e', materialConstants(j) );
    
        % Add a comma if it's not the last constant on the line or the very last constant
        if mod(j, 8) ~= 0 && j ~= numConstants
            fprintf( inpFile, ', ' );
        % Add a newline character if 8 constants have been written or it's the last constant
        elseif mod(j, 8) == 0 || j == numConstants
            fprintf( inpFile, '\n' );
            % if j ~= numConstants % Avoid extra blank line at the end if numConstants is a multiple of 8
            %     fprintf('Wrote constants %d to %d\n', j-7, j);
            % else
            %     fprintf('Wrote final constants up to %d\n', j);
            % end
        end
    end

    % fprintf( inpFile, ...
    %     '\n%6.5f,%6.5f,%6.5f,%6.5f,%6.0f,%6.0f,', ...
    %     Angles, const, 0, 3 - grains(i).phase );
    

end
function ThetaRange = getIPFThetaRange( PhaseName )
%
% 'PhaseName'   - (N,1) cell

ThetaRange = nan( size( PhaseName ) );

FCC_PhaseNames = { 'TitaniumHydride' };
HCP_PhaseNames = { 'Titanium(Alpha)' };

FCC_ind = strcmp( PhaseName, FCC_PhaseNames );
HCP_ind = strcmp( PhaseName, HCP_PhaseNames );

ThetaRange( FCC_ind ) = pi / 4;
ThetaRange( HCP_ind ) = pi / 6;
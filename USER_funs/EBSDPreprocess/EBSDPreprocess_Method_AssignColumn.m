function EBSD = EBSDPreprocess_Method_AssignColumn( EBSD, dlg, varargin )
%
%    ----- 'Method_AssignColumn' -----
%
%   PARAMETERS:      
%       'Column_Coords'         - (2,1)
%       'Column_EulerAngles'    - (3,1)
%       'Column_IQ'             - (1,1)
%       'Column_CI'             - (1,1)
%       'Column_GrainID'        - (1,1)
%       'Column_PhaseName'      - (2,1)
%       'AngleUnit'             - string
%
%   DEFINE:
%   EBSDData   - (1,1)   struct
%
%   ----------- Values read from file -------------
%       'Coords'        - (N,2) double
%       'EulerAngles'   - (N,3) double
%       'IQ'            - (N,1) double
%       'CI'            - (N,1) double
%       'GrainID'       - (N,1) int16
%       'EdgeIndex'     - (N,1) int8
%       'PhaseName'     - (N,1) cell
%
%   obj.EBSD.IPF    - (1,1)   struct
%   ----------- Computed values -------------------
%       'IPF.CData'      - (1,3) cell -> (nx,ny,3)
%       'IPF.XData'      - (nx,1) double
%       'IPF.YData'      - (ny,1) double
%
%   ----------------- varargin --------------------
%       varargin{1}      - CoincideCoordsFlag

%% DEFINE 'EBSDData'

EBSDData = getEmptyEBSDData();

Pars = EBSD.PreprocessPars;

temp = fieldnames( Pars ); ind = contains( temp, 'Column_' );

Variablefnames = temp(ind);
VariableNames = cellfun( ...
    @(s) s(8:end), temp(ind), 'UniformOutput', false );

ColumnIndex = cellfun( @(s) ...
    Pars.(s), Variablefnames, 'UniformOutput', false );

ValidInd = cellfun( @ all, ColumnIndex );
VariableNames = VariableNames( ValidInd );
ColumnIndex   = ColumnIndex( ValidInd );

ALLStringVariableNames = {'PhaseName'};
StringIndex = cellfun( @(s) ...
    strcmp( s, ALLStringVariableNames ), VariableNames );

DoubleVariableNames = VariableNames( ~StringIndex );
StringVariableNames = VariableNames(  StringIndex );

ColumnIndexDouble = ColumnIndex( ~StringIndex );
ColumnIndexString = ColumnIndex( StringIndex );

temp = cell2mat(ColumnIndexString);
temp = temp(~isnan(temp));

Data = getEBSDFileData( ...
    EBSD.FileName, ...
    cell2mat(ColumnIndexDouble), temp );

Num = cellfun( @(s) length(s), ColumnIndexDouble );
for i = 1:length(Num)
    ind = sum( Num(1:i-1) ) + ( 1:Num(i) );
    EBSDData.( DoubleVariableNames{i} ) = cell2mat( Data(ind) );
end
Num0 = sum(Num);

Num = cellfun( @(s) length(s(~isnan(s))), ColumnIndexString );
for i = 1:length(Num)
    ind = Num0 + sum( Num(1:i-1) ) + ( 1:Num(i) );
    EBSDData.( StringVariableNames{i} ) = strcat( Data{ind} );
end

% pars.Column_PhaseName -> Data.Phase & Data.PhaseNames
if strcmp( 'PhaseName', StringVariableNames )

    [ EBSDData.PhaseNames, ~, EBSDData.Phase ] = ...
        unique( EBSDData.PhaseName );

    EBSDData = rmfield( EBSDData, 'PhaseName' );

    [ FCC_PhaseNames, BCC_PhaseNames, HCP_PhaseNames ] = getPhaseNames();
    EBSDData.HCPPhase = arrayfun( @(name) ...
        ismember( name, HCP_PhaseNames ), EBSDData.PhaseNames );
    EBSDData.FCCPhase = arrayfun( @(name) ...
        ismember( name, FCC_PhaseNames ), EBSDData.PhaseNames );
    EBSDData.BCCPhase = arrayfun( @(name) ...
        ismember( name, BCC_PhaseNames ), EBSDData.PhaseNames );

end

% adjust 'EulerAngles' from degree to rad
if strcmp( Pars.AngleUnit, 'degree' )
  EBSDData.EulerAngles = deg2rad( EBSDData.EulerAngles );
end

% adjust 'EulerAngles', make the Sample Coord in which they're defined
%       coincide with the Image Coord (X-right,Y-down)
%       Original definition of Smaple Coord is 'OIM default'
if nargin > 2 && varargin{1}
    % G_ima2sam -- Image Coord -> OIM Sample Coord
    G_ima2sam = [0,-1,0;-1,0,0;0,0,-1];
    for i = 1:size(EBSDData.EulerAngles,1)
        % R -- OIM Sample Coord -> Crystal Coord
        R = EulerAngle2TransferMatrix( ...
            EBSDData.EulerAngles(i,:) ); % sam -> cry
        % R_new -- Image Coord -> Crystal Coord
        R_new = R * G_ima2sam;
        [ phi1, PHI, phi2 ] = TransferMatrix2EulerAngle( R_new );
        EBSDData.EulerAngles(i,:) = [ phi1, PHI, phi2 ];
    end
    EBSDData.SampleCoordOri = struct('X',[1,0],'Y',[0,-1]);
end

% adjust 'Coords' ---- some value are close but not equal (1e-5)
EBSDData.Coords = round( EBSDData.Coords, 4 );

% adjust 'CI' ---- some value are negative -> 0
if ~isempty( EBSDData.CI )
    EBSDData.CI( EBSDData.CI < 0 ) = 0;
end

%% CALCULATE 'EBSDData.IPF'

AllDirectionSample3 = [1,0,0; 0,1,0; 0,0,1]';

N = size( EBSDData.Coords, 1 );

% Transfer Matrix
InvertTransferMatrix = ...
    EulerAngle2InvertTransferMatrix( EBSDData.EulerAngles );

% Coordinates of IPF Images
[ EBSDData.XData, ~, XYUniqueIC(:,1) ] = ...
    unique( EBSDData.Coords(:,1) );
[ EBSDData.YData, ~, XYUniqueIC(:,2) ] = ...
    unique( EBSDData.Coords(:,2) );

EBSDData.dX = round( mean( diff( EBSDData.XData ) ), 3 );
EBSDData.dY = round( mean( diff( EBSDData.YData ) ), 3 );

EBSDData.XData = ...
    EBSDData.XData(1) + ...
    ( 0 : length( EBSDData.XData )-1 ) * EBSDData.dX ;
EBSDData.YData = ...
    EBSDData.YData(1) + ...
    ( 0 : length( EBSDData.YData )-1 ) * EBSDData.dY ;

for i = 1:3

    DirectionSample3 = AllDirectionSample3(:,i);

    DirectionsCrystal3 = reshape(...
            InvertTransferMatrix * DirectionSample3, ...
            3, N );
    
    x = DirectionsCrystal3( 1, : )';
    y = DirectionsCrystal3( 2, : )';
    z = DirectionsCrystal3( 3, : )';

    C = getIPFCData( x, y, z, ...
            EBSDData.Phase, EBSDData.PhaseNames );


    EBSDData.IPF{i} = permute( ...
        ReshapeEBSDData( XYUniqueIC, C ), ...
        [2,1,3] );

end

% Size
Size = size( EBSDData.IPF{3}, 1, 2 );
EBSDData.DataSize = [ Size, prod(Size) ];

%% RESHAPE Data

VariableNames = { 'EulerAngles', 'IQ', 'CI', 'GrainID', ...
    'EdgeIndex', 'Phase' };

for i = 1:length( VariableNames )

    varname = VariableNames{i};
    data = EBSDData.( varname );
    if ~isempty(data)
        EBSDData.( varname ) = permute( ...
            ReshapeEBSDData( ...
            XYUniqueIC, EBSDData.( varname ) ), ...
            [2,1,3] );
    end

end

%  ************ Alpha Data
EBSDData.AlphaData = ones(Size);

% End
EBSDData.Coords = []; % Property Not Used After
EBSD.Data = EBSDData;



end

% *************************************

function Data = getEBSDFileData( ...
    FileName, ColumnIndexDouble, ColumnIndexString )

    fileID = fopen( FileName );
    
    NumHeaderLines = 0;
    while 1
        tline = fgetl( fileID );
        if ~ strcmp( tline(1), '#' ); break; end
        NumHeaderLines = NumHeaderLines + 1;
    end
    
    ColumnNumber = sum( cellfun( @(val) ~isempty(val), ...
        strsplit( tline, {' ','\t'} ) ) );
    
    frewind( fileID ); for i = 1:NumHeaderLines; fgetl( fileID ); end
    
    formatSpec = repmat( {'%*s'}, 1, ColumnNumber );
    
    [ formatSpec{ ColumnIndexDouble } ] = deal('%f');
    [ formatSpec{ ColumnIndexString } ] = deal('%s');
    
    formatSpec = [ cell2mat( formatSpec ), '%*[^\n]' ];
    
    Data = textscan( fileID, formatSpec, 'TreatAsEmpty', {', '} );
    
    fclose( fileID );
    
    [~,I] = sort( [ ColumnIndexDouble; ColumnIndexString ] );
    
    Data(I) = Data;

end
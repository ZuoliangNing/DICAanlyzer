function varargout = DICPreprocess_Method_ImportAbaqus( DIC, dlg )


FileNames = DIC.FileNames{end};
pars = DIC.PreprocessPars;

dlg.Message = [ FileNames, '...' ];

data = readmatrix( FileNames );
% X / Y / u / v / exx / eyy / exy

x = unique( data(:,1) );
y = unique( data(:,2) );

nx = length( x ); ny = length( y );
if nx * ny ~= size( data, 1 )
    error( 'Mismatching element number!' )
end


fun = @(n,name) simplifyData( ...
    reshape( data(:,n), ny, nx ), DIC.DataValueRange.(name) );

DIC.StageNumber = 1;
DIC.Data.u      = fun( pars.Column_u, 'u' );
DIC.Data.v      = fun( pars.Column_v, 'v' );
DIC.Data.exx    = fun( pars.Column_exx, 'exx' );
DIC.Data.eyy    = fun( pars.Column_eyy, 'eyy' );
DIC.Data.exy    = fun( pars.Column_exy, 'exy' );
for i = 1:length( DIC.UserVariableNames )
    s = DIC.UserVariableNames{i};
    DIC.Data.(s) = reshape( data( :, pars.(['Column_',s]) ), ny, nx );
end
DIC.XData       = x;
DIC.YData       = y;

varargout{1} = DIC;
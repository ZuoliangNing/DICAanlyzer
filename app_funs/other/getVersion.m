function v = getVersion()


fileID = fopen( 'VERSION.log' );
for i = 1:3; fgetl( fileID ); end
str = fgetl( fileID );
fclose( fileID );

temp = strfind( str, ' ' );
v = str( temp(end-1)+1 : temp(end)-1 );
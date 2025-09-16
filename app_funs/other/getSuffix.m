function varargout = getSuffix( file )

% varargout - [ filename, suffix ]

ind = strfind( file, '.' );
suffix = file( ind+1:end );
filename = file( 1:ind-1 );

if nargout > 0
    varargout{2} = suffix;
    varargout{1} = filename;
end
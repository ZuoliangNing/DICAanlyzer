function DIC = DICPreprocess_Method_UseImage( DIC, dlg )
%
% size and stage number of each data should be the same

[ DIC, ind ] = DICPreprocess_Method_AutoMatch( DIC, dlg );
pos = DIC.FilePosition;

% USER VARIABLE - Image
ImageData = cell( max( pos ) );
Exts = {'jpg','bmp','tif'};
for i = 1 : DIC.FileNumber

    [ path, name ] = fileparts( DIC.FileNames{i} );

    name = cellfun( @(str) fullfile( path, [ name, '.', str ] ), ...
        Exts, 'UniformOutput', false );
    name = name{ isfile(name) };
    % if isfile
    temp = imread( name );
    ImageData{ pos( i,1 ), pos( i,2 ) } = temp( ind{1}, ind{2} );

end

SIZE = size( DIC.Data(1).exx );
ImageData = double( imresize( cell2mat( ImageData ), SIZE ) );
for i = 1 : DIC.StageNumber
    DIC.Data(i).Image = ImageData;
end
function [ row, column ] = getFilePosition( Files, FileFormat )

if iscell( Files )
            
    N = length(Files);
    [ row, column ] = deal(nan(N,1));

    for i = 1:N

        FileName = getSuffix( Files{i} );
        [ row(i), column(i) ] = ...
            getDICFilePosition( FileName, FileFormat );
        
    end

else
    Files = {Files};
    row = 1; column = 1;
end
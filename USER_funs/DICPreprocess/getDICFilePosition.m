function [ row, column ] = getDICFilePosition( FileName, format )
% Gets the row and column of the corresponding area of the file
% Based on 'format' - among 'app.ConstantValues.DICFileFormats'
%   format - 
%       'Row-Column.mat'
%       'Column-Row.mat'
%
%   row     - row number of this file
%   column  - column number of this file
%
%   /2024/11/28 - nzl

switch format
    case 'Row-Column.mat'

        C = strsplit( FileName, '-' );
        row = str2double( C{1} );
        column = str2double( C{2} );

    case 'Column-Row.mat'

        C = strsplit( FileName, '-' );
        column = str2double( C{1} );
        row = str2double( C{2} );
        
    case 'file name.txt'
    
        column = 1;
        row = 1;
        
end





function data = getDICFileData( FileName, format )
% Load data from one DIC result file
% Based on 'format' - among 'app.ConstantValues.DICFileFormats'
%   format - 
%       'Row-Column.mat'
%       'Column-Row.mat'
%
%   data     -  (1,n) struct
%            -  data read from the file (any data type)
%               must include variables: 'u', 'v', 'exx', 'eyy', 'exy'
%            - struct( 'u',   u,   'v',   v, 
%                      'exx', exx, 'eyy', eyy, 'exy', exy, 
%                      'StageNumber', n )
%
%   /2024/11/28 - nzl


switch format
    case { 'Row-Column.mat', 'Column-Row.mat' }
        
        load( FileName, 'data_dic_save' );

        n = length( data_dic_save.displacements );


        data = struct( 'u',   [], 'v',   [], ...
                       'exx', [], 'eyy', [], 'exy', [], ...
                       'StageNumber', n );
        for i = 1:n

            data(i).u = data_dic_save. ...
                displacements(i).plot_u_ref_formatted;
            data(i).v = data_dic_save. ...
                displacements(i).plot_v_ref_formatted;
            data(i).exx = data_dic_save. ...
                strains(i).plot_exx_ref_formatted;
            data(i).eyy = data_dic_save. ...
                strains(i).plot_eyy_ref_formatted;
            data(i).exy = data_dic_save. ...
                strains(i).plot_exy_ref_formatted;
            
        end



end
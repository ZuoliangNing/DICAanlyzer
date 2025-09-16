function obj = DICPreprocess_UseDefault( DIC, dlg )
%
% size and stage number of each data should be the same


pos = DIC.FilePosition;


% No data cutting

Size = size( DIC.OriginalData{1}(1).u );


obj.DIC.StageNumber = DIC.OriginalData{1}.StageNumber;

temp = zeros( max(pos(:,1)) * Size(1), ...
              max(pos(:,2)) * Size(2) );

% Field names in 'app.ConstantValues.DICVariables' must be included
obj.DIC.Data = struct( 'u',   temp, 'v',   temp, ... 
                       'exx', temp, 'eyy', temp, 'exy', temp);


for n = 1 : obj.DIC.StageNumber
    
    obj.DIC.Data(n) = obj.DIC.Data(1);

    for i = 1 : obj.DIC.FileNumber

        ir = ( pos(i,1) - 1 ) * Size(1) + ( 1:Size(1) ) ;
        ic = ( pos(i,2) - 1 ) * Size(2) + ( 1:Size(2) ) ;

        obj.DIC.Data(n).u( ir, ic ) = obj.DIC.OriginalData{i}(n).u;
        obj.DIC.Data(n).v( ir, ic ) = obj.DIC.OriginalData{i}(n).v;
        obj.DIC.Data(n).exx( ir, ic ) = obj.DIC.OriginalData{i}(n).exx;
        obj.DIC.Data(n).eyy( ir, ic ) = obj.DIC.OriginalData{i}(n).eyy;
        obj.DIC.Data(n).exy( ir, ic ) = obj.DIC.OriginalData{i}(n).exy;

    end

end
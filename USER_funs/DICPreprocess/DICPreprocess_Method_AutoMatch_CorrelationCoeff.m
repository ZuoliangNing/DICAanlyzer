function DIC = DICPreprocess_Method_AutoMatch_CorrelationCoeff( DIC, dlg )
%
% size and stage number of each data should be the same

[ DIC, ind ] = DICPreprocess_Method_AutoMatch( DIC, dlg );
pos = DIC.FilePosition;

% USER VARIABLE - CorrelationCoeff
FileNames = DIC.FileNames;
Value = cell( [max( pos ),DIC.StageNumber] );
for i = 1 : DIC.FileNumber


    load( FileNames{i}, 'data_dic_save' );

    for n = 1:DIC.StageNumber
        temp = data_dic_save.displacements(n).plot_corrcoef_dic;
        Value{ pos( i,1 ), pos( i,2 ), n } = temp( ind{1}, ind{2} );
    end

end

for n = 1:DIC.StageNumber
    SIZE = size( DIC.Data(1).exx );
    temp = double( imresize( cell2mat( Value(:,:,n) ), SIZE ) );
    DIC.Data(n).CorrelationCoeff = temp;
end
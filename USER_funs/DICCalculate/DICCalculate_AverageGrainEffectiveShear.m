function DIC = DICCalculate_AverageGrainEffectiveShear( ...
    DIC, EBSDData, dlg )


dlg.Message = 'Calculating ''Average Grain Effective Shear Strain''...';

map = EBSDData.Map;
GrainNumber = length( map.grains );

for n = 1:DIC.StageNumber

    Value = nan( DIC.DataSize(1:2) );

    exx = restoreData( DIC.Data(n).exx, DIC.DataValueRange.exx );
    eyy = restoreData( DIC.Data(n).eyy, DIC.DataValueRange.eyy );
    exy = restoreData( DIC.Data(n).exy, DIC.DataValueRange.exy );

    EffectiveShear = sqrt( ( exx - eyy ).^2 / 4 + exy.^2 );

    for i = 1:GrainNumber
        g = map.grains(i);
        ind = g.IntrinsicInds;
        Value(ind) = mean( EffectiveShear( ind ) );
    end
    
    DIC.Data(n).AverageGrainEffectiveShear = Value;

end
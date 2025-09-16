function DIC = DICCalculate_EquivalentStrain( DIC, dlg )


dlg.Message = 'Calculating ''Equivalent Strain''...';
for n = 1:DIC.StageNumber

    exx = restoreData( DIC.Data(n).exx, DIC.DataValueRange.exx );
    eyy = restoreData( DIC.Data(n).eyy, DIC.DataValueRange.eyy );
    exy = restoreData( DIC.Data(n).exy, DIC.DataValueRange.exy );

    DIC.Data(n).EquivalentStrain = ...
        2 / sqrt(3) * sqrt( exx.^2 + exx.* eyy + eyy.^2 + exy.^2 );

end
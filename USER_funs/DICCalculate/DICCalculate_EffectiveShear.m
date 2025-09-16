function DIC = DICCalculate_EffectiveShear( DIC, dlg )


dlg.Message = 'Calculating ''Effective Shear Strain''...';
for n = 1:DIC.StageNumber

    exx = restoreData( DIC.Data(n).exx, DIC.DataValueRange.exx );
    eyy = restoreData( DIC.Data(n).eyy, DIC.DataValueRange.eyy );
    exy = restoreData( DIC.Data(n).exy, DIC.DataValueRange.exy );

    DIC.Data(n).EffectiveShear = sqrt( ( exx - eyy ).^2 / 4 + exy.^2 );

end
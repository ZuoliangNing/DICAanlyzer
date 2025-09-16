function DIC = DICCalculate_Hxy( DIC, dlg )


dlg.Message = 'Calculating ''Hxy''...';
for n = 1:DIC.StageNumber

    u = restoreData( DIC.Data(n).u, DIC.DataValueRange.u );
    % v = restoreData( DIC.Data(n).v, DIC.DataValueRange.v );

    pixelsize = [ mean( diff( DIC.XData ) ), mean( diff( DIC.YData ) ) ];
    % calculate numerical gradients (displacement gradient tensor components)
    [ ~, Hxy ] = gradient( u, pixelsize(1), pixelsize(2) );
    % [ Hyx, Hyy ] = gradient( v, pixelsize(1), pixelsize(2) );
    
    DIC.Data(n).Hxy = Hxy;
end
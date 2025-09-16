function DIC = DICCalculate_Recalculated_eyy( DIC, dlg )


dlg.Message = 'Calculating ''Recalculated eyy''...';
for n = 1:DIC.StageNumber

    % u = restoreData( DIC.Data(n).u, DIC.DataValueRange.u );
    v = restoreData( DIC.Data(n).v, DIC.DataValueRange.v );

    pixelsize = [ mean( diff( DIC.XData ) ), mean( diff( DIC.YData ) ) ];
    % calculate numerical gradients (displacement gradient tensor components)
    % [ Hxx, ~ ] = gradient( u, pixelsize(1), pixelsize(2) );
    [ ~, Hyy ] = gradient( v, pixelsize(1), pixelsize(2) );
    
    DIC.Data(n).Recalculated_eyy = Hyy;
end
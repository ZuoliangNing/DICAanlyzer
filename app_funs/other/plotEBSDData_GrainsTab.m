function plotEBSDData_GrainsTab( app, EBSDData )

if EBSDData.Flag.Polygonized

    map = EBSDData.Map;

    if app.GBsCheckBox.Value

        delete( app.GBsPlot )

        app.GBsPlot = map.plotgb( ...
            EBSDData.GrainSelection, ...
            app.UIAxesImages2, 'k', 1 );

    end

    if app.LabelsCheckBox.Value

        delete( app.GrainLabels )

        app.GrainLabels = map.overlayGrainLabels( ...
            EBSDData.GrainSelection, ...
            app.UIAxesImages2, 'k', 18 );

    end

end


% g = map.grains(1);
function disableGrainsTab( app )

app.ImagePolygonize.ImageSource = app.ConstantValues.EmptyImage;
app.ImageAdjust.ImageSource = app.ConstantValues.EmptyImage;

app.GrainSelectionPanel.Enable = 'off';
app.BoundaryPanel.Enable = 'off';
app.DICPanel.Enable = 'off';

delete( app.GrainSelectionTree.Children )
delete( app.DICTree.Children )

delete( app.GrainLabels )
delete( app.GBsPlot )
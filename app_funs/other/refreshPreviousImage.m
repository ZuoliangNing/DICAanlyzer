function refreshPreviousImage( Image, app )

delete( app.UIAxesImages3.Children )

app.UIAxesImages3.Colormap = Image.Parent.Colormap;
app.UIAxesImages3.CLim = Image.Parent.CLim;

Image.Parent = app.UIAxesImages3;

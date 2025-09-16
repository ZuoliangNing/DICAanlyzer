function DICColormapMenuSelectedFcn( menu, ~, app )

if menu.Checked; return; end

ind = strcmp( app.ConstantValues.ColormapsNames, menu.Text );

NewMap = app.ConstantValues.Colormaps{ind};

app.Default.Options.DICColormapIndex = find(ind);

menu.Checked = "on";

menus = flip( app.DICColormapMenu.Children );
arrayfun( @(m) set( m, 'Checked', 'off' ), menus(~ind) )

colormap( app.UIAxesImages, NewMap )

if ishandle( app.OverlayImage ) || ...
        ( app.ShowButton.Value && app.DICPanel.Enable )
    app.UIAxesImages2.Colormap = app.UIAxesImages.Colormap;
end
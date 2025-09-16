function DICFileFormatMenuSelectedFcn( menu, ~, app )

if menu.Checked; return; end

menus = app.DICFileFormatMenu.Children;
ind = strcmp( menu.Text, {menus.Text} ); % menu selected

app.Default.Options.DICFileFormatSelection = find(ind);

menus(ind).Checked = "on";
arrayfun( @(m) set( m, 'Checked', 'off' ), menus(~ind) )
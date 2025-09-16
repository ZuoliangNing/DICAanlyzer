function LanguageMenuSelectedFcn( menu, ~, app )
% 1 - English / 2 - Chinese

if menu.Checked; return; end

menus = app.LanguageMenu.Children;
ind = strcmp( menu.Text, {menus.Text} ); % menu selected

app.Default.LanguageSelection = find(ind);

menus(ind).Checked = "on";
menus(~ind).Checked = "off";

setUIControlDisplayNames(app)

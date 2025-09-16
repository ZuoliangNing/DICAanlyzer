function ShowAxesMenuSelectedFcn( menu, ~, app )

switch menu.Tag
    case 'DIC'
        AxesFlagName = 'DICAxesFlag';
        Axe = app.UIAxesImages;
    case 'EBSD'
        AxesFlagName = 'EBSDAxesFlag';
        Axe = app.UIAxesImages2;
end

if menu.Checked

    app.Default.Options.( AxesFlagName ) = false;

    Axe.XAxis.Visible = 'off';
    Axe.YAxis.Visible = 'off';
    Axe.XTick = [];
    Axe.YTick = [];

    menu.Checked = 'off';

else

    app.Default.Options.( AxesFlagName ) = true;

    Axe.XAxis.Visible = 'on';
    Axe.YAxis.Visible = 'on';
    Axe.XTickMode = 'auto';
    Axe.YTickMode = 'auto';

    menu.Checked = 'on';

end

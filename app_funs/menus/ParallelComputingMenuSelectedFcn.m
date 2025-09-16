function ParallelComputingMenuSelectedFcn( menu, ~, app )

if menu.Checked

    app.Default.Options.ParallelComputing = false;
    menu.Checked = 'off';

else

    app.Default.Options.ParallelComputing = true;
    menu.Checked = 'on';

end
function ButtonFoldButtonPushedFcn( button, ~, app )

switch button.UserData
    case 'up'
        app.UIAxesImages3.Visible = 'on';
        app.UIAxesImages3.XAxis.Visible = 'off';
        app.UIAxesImages3.YAxis.Visible = 'off';
        app.GridLayout9.Layout.Row = 1;
        button.Parent = app.GridLayout11;
        button.Icon = 'down.png';
        button.UserData = 'down';
        app.GridLayout11.Visible='on';
    case 'down'
        app.UIAxesImages3.Visible = 'off';
        app.GridLayout9.Layout.Row = [1,3];
        button.Parent = app.GridLayout10;
        button.Icon = 'up.png';
        button.UserData = 'up';
        app.GridLayout11.Visible='off';
end
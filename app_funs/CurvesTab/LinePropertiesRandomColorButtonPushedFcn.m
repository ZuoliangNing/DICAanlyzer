function LinePropertiesRandomColorButtonPushedFcn( button, ~, app )


gobj = app.CurvesTab.UserData;

Colors = app.ConstantValues.Colormaps{2};
c = Colors(randi(256),:);

app.LinePropertiesColorButton.BackgroundColor = c;
gobj.MarkerFaceColor = c;
gobj.Color = c;

if ~strcmp( gobj.Marker, 'none' )
    Markers = { 's','o','^','v','>','<','+','*','.','x','_','|', ...
        'square','diamond','pentagram','hexagram' };
    mk = Markers{randi(length(Markers))};
    gobj.Marker = mk;
end

app.TabGroup.SelectedTab = gobj.Parent.Parent.Parent;
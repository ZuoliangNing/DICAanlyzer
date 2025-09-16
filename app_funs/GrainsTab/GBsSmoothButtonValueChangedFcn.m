function GBsSmoothButtonValueChangedFcn( ~, ~, app )

ProjectIndex = getProjectIndex( app.CurrentProjectSelection, app );
obj = app.Projects( ProjectIndex );
EBSDIndex = getEBSDIndex( app.CurrentEBSDSelection, obj );
map = obj.EBSD.Data( EBSDIndex ).Map;


if map.GBSmoothDegree ~= app.Default.Options.GBSmoothDegree

    map.GBSmoothDegree = app.Default.Options.GBSmoothDegree;

    dlg = uiprogressdlg( app.UIFigure );
    map.grains.smoothgb( {map.GBSmoothDegree}, dlg, app.TextArea )

    % app.Projects( ProjectIndex ).EBSD.Data( EBSDIndex ).Map = map;

end

plotEBSDGBs( app, app.Projects( ProjectIndex ).EBSD.Data( EBSDIndex ) )
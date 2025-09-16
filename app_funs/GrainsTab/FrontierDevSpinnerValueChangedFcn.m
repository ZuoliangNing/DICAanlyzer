function FrontierDevSpinnerValueChangedFcn( spinner, ~, app )

Node = app.Tree.SelectedNodes;
ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
obj = app.Projects( ProjectIndex );

if spinner.Value < 0
    spinner.Value = 0;
end

if spinner.Value > 10
    spinner.Value = 10;
end

obj.EBSD.Data( getEBSDIndex( Node.NodeData.EBSDSerial, obj ) ) ...
    .FrontierDev = spinner.Value;

app.Projects( ProjectIndex ) = obj;

refreshCurrentImage2(app)
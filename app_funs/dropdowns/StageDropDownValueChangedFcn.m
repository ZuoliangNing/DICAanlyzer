function StageDropDownValueChangedFcn( dropdown, ~, app )
 

Node = app.Tree.SelectedNodes;
ind = getProjectIndex( Node.NodeData.Serial, app );
obj = app.Projects( ind );
obj.StageSelection = dropdown.ValueIndex;
app.Projects( ind ) = obj;

if app.DICPanel.Enable && app.ShowButton.Value
    refreshCurrentImage2(app)
else
    refreshCurrentImage(app)
end




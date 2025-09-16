function DICDataOpeningFcn( contextmenu, ~, app )

if isscalar( app.Tree.SelectedNodes ) || ...
        isempty( app.Tree.SelectedNodes )

    setSingleContextmenuSerial( contextmenu, app )

    obj = app.Projects( ...
        getProjectIndex( contextmenu.UserData.Serial, app ) );

    node = app.UIFigure.CurrentObject;

    flag = any( strcmp( ...
        node.UserData.VariableName, ...
        [ app.ConstantValues.DICVariables, ...
        app.DICPreprocessMethods. ...
        ( obj.DIC.PreprocessMethod ).VariableNames ] ) );
    

    if flag; flag = 'off'; else; flag = 'on'; end

else

    flag = 'off';
    
end

arrayfun( @(ui) set( ui, 'Enable', flag ), contextmenu.Children )
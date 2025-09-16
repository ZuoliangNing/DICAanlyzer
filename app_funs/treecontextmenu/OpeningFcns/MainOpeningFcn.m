function MainOpeningFcn( contextmenu, ~, app )

if isscalar( app.Tree.SelectedNodes )
    
    setSingleContextmenuSerial( contextmenu, app )
    
    obj = app.Projects( ...
        getProjectIndex( contextmenu.UserData.Serial, app ) );
    
    arrayfun( @(ui) set( ui, 'Enable', 'on' ), contextmenu.Children )

    if obj.Flag.EBSDData < 1
        %contextmenu.Children(2).Enable = 'off'; % 'DataMeasure'
        contextmenu.Children(2).Enable = 'off'; % 'New'
    else
        %contextmenu.Children(2).Enable = 'on';
        contextmenu.Children(2).Enable = 'on';
    end

else

    setMultiContextmenuSerial( contextmenu, app )

    arrayfun( @(ui) set( ui, 'Enable', 'off' ), contextmenu.Children )

    contextmenu.Children(1).Enable = 'on';
    
end
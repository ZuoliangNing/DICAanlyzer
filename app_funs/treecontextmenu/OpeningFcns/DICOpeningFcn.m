function DICOpeningFcn( contextmenu, ~, app )

if isscalar( app.Tree.SelectedNodes ) || ...
        isempty( app.Tree.SelectedNodes )

    setSingleContextmenuSerial( contextmenu, app )
    
    obj = app.Projects( ...
        getProjectIndex( contextmenu.UserData.Serial, app ) );
    
    arrayfun( @(ui) set( ui, 'Enable', 'on' ), contextmenu.Children )
    
    if obj.Flag.DICPreprocess < 1
        contextmenu.Children(1).Enable = 'off'; % 'Clear'
        contextmenu.Children(2).Enable = 'off'; % 'Calculate'
        contextmenu.Children(3).Enable = 'off'; % 'Modify'
        contextmenu.Children(4).Enable = 'on';  % 'Import'
    else
        contextmenu.Children(1).Enable = 'on';
        contextmenu.Children(2).Enable = 'on';
        contextmenu.Children(3).Enable = 'on';
        contextmenu.Children(4).Enable = 'off';
    end

else

    arrayfun( @(ui) set( ui, 'Enable', 'off' ), contextmenu.Children )
    
end
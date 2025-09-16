function EBSD2OpeningFcn( contextmenu, ~, app )

if isscalar( app.Tree.SelectedNodes ) || ...
        isempty( app.Tree.SelectedNodes )

    setSingleContextmenuSerial( contextmenu, app )

    ProjectIndex = getProjectIndex( contextmenu.UserData.Serial, app );
    obj = app.Projects( ProjectIndex );

    node = app.UIFigure.CurrentObject;
    EBSDSerial = getEBSDIndex( node.NodeData.EBSDSerial, obj );

    if obj.Flag.DICPreprocess < 1
        contextmenu.Children(3).Enable = 'off'; % Adjust
    else
        contextmenu.Children(3).Enable = 'on';
    end

    if obj.EBSD.Data( EBSDSerial ).Flag.Adjusted
        contextmenu.Children(2).Enable = 'off';
    else
        contextmenu.Children(2).Enable = 'on'; % Polygonize
    end

    % if ~isempty( obj.EBSD.Data( EBSDSerial ).GrainID ) ...
    %         && ~obj.EBSD.Data( EBSDSerial ).Flag.Polygonized
    %     contextmenu.Children(2).Enable = 'on'; % Polygonize
    % else
    %     contextmenu.Children(2).Enable = 'off';
    % end

else

    arrayfun( @(ui) set( ui, 'Enable', 'off' ), contextmenu.Children )

end
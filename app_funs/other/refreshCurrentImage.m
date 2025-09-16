function refreshCurrentImage(app)
% DIC Image !


delete( app.CurrentImage )

Node = app.Tree.SelectedNodes;

if ~isempty( Node ) && isscalar( Node )

    % if strcmp( Node.UserData.NodeType, 'DICData' )
        obj = app.Projects( ...
            getProjectIndex( Node.NodeData.Serial, app ) );
        
    
        VariableName = Node.UserData.VariableName;
        n = app.StageDropDown.ValueIndex;
    
        if isfield( obj.DIC.DataValueRange, VariableName )
            val = simplifyCData( restoreData( ...
                obj.DIC.Data(n).( VariableName ), ...
                obj.DIC.DataValueRange.( VariableName ) ), ...
                app.Default.Options.MaxResolution );
        else
            val = simplifyCData( ...
                obj.DIC.Data(n).( VariableName ), ...
                app.Default.Options.MaxResolution );
        end
    
    
        app.CurrentImage = image( ...
            app.UIAxesImages, val, ...
            'XData', obj.DIC.XData, ... [ 1, obj.DICSize(2) ], ...
            'YData', obj.DIC.YData, ... [ 1, obj.DICSize(1) ], ...
            'CDataMapping','scaled' );
    
        app.CurrentImage.UserData = struct( ...
            'Serial', obj.Serial, ...
            'Variable', VariableName, ...
            'Type', 'DICData' );
    
        app.CurrentImage.ContextMenu = app.UIAxesContextMenu;

        CLim = obj.DIC.CLim(n).( VariableName );
        app.UIAxesImages.CLim = CLim;
        setStyleUIs( app, CLim )


        app.UIAxesImages.Children = [ ...
            app.UIAxesImages.Children(2:end); ...
            app.UIAxesImages.Children(1) ];

end

updateMonitorTable( true, val, app )
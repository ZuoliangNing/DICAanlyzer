function refreshCurrentImage2(app)
% EBSD Image !

delete( app.CurrentImage2 )

Node = app.Tree.SelectedNodes;

DICFlag = false; value = [];

if ~isempty( Node ) && isscalar( Node )

    obj = app.Projects( ...
        getProjectIndex( Node.NodeData.Serial, app ) );
    
    EBSDSerial = getEBSDIndex( Node.NodeData.EBSDSerial, obj );
    EBSDData = obj.EBSD.Data( EBSDSerial );

    if strcmp( Node.UserData.NodeType, 'EBSDData' )

        % ****************************************************************
        % ****************************************************************
    
        VariableName = Node.UserData.VariableName;

        [ value, AlphaData, ind1, ind2, DICFlag, VariableName ] = ...
            getEBSDCData( ...
                VariableName, app.Default.Options.MaxResolution, ...
                EBSDData, obj, app );
    
        XData = EBSDData.XData; YData = EBSDData.YData;
    
        if ~isempty(ind1)
            XData = EBSDData.XData( ind2 );
            YData = EBSDData.YData( ind1 );
        end
    
        app.CurrentImage2 = image( ...
            app.UIAxesImages2, value, ...
            'CDataMapping','scaled', ...
            'XData', XData, ...
            'YData', YData, ...
            'AlphaData', AlphaData );
        
        app.CurrentImage2.UserData = struct( ...
            'Serial', obj.Serial, ...
            'Variable', VariableName, ...
            'EBSDSerial', Node.NodeData.EBSDSerial, ...
            'Type', 'EBSDData' );
    
        %%%%
        if EBSDData.Flag.Polygonized
            if ~ishandle( app.GrainLabels(1) ) && app.LabelsCheckBox.Value
                plotEBSDGrainLabels( app, EBSDData )
            end
            if ~ishandle( app.GBsPlot ) && app.GBsCheckBox.Value
                plotEBSDGBs( app, EBSDData )
            end
        end
    
        app.UIAxesImages2.Children = [ ...
            app.UIAxesImages2.Children(2:end); ...
            app.UIAxesImages2.Children(1) ];
    
        % ****************************************************************
        % **************************************************************** 
    
        %
        if DICFlag
        
            app.CurrentImage2.UserData.Type = 'DICData';

            CLim = obj.DIC.CLim ...
                    ( obj.StageSelection ).( EBSDData.DICSelection );
            if CLim(2) <= CLim(1)
                CLim(2) = CLim(1) + 0.1;
            end
            app.UIAxesImages2.CLim = CLim;
            setStyleUIs( app, CLim )

            app.UIAxesImages2.Colormap = app.UIAxesImages.Colormap;

            app.StageDropDown.Enable = 'on';
            app.StageDropDownLabel.Enable = 'on';
            
            app.StatisticButton.Enable = 'on';
            app.StageDropDown.ValueIndex = obj.StageSelection;
            
        else

            setStyleUIsEnable( app, 'off' )
            app.StatisticButton.Enable = 'off';

            if strcmp( VariableName, 'IPF' )
        
                app.EBSDDropDown.Enable = 'on';
                app.EBSDDropDownLabel.Enable = 'on';
        
            else
                
                switch VariableName
                    case { 'CI', 'IQ' }
                        colormap( app.UIAxesImages2, 'gray' )
                        clim( app.UIAxesImages2, 'auto' )
                    case 'GrainID'
                        colormap( app.UIAxesImages2, 'lines' )
                        % clim( app.UIAxesImages2, [0,2000] )
                    case 'Phase'
                        colormap( app.UIAxesImages2, 'jet' )
                        clim( app.UIAxesImages2, 'auto' )
                    case 'EdgeIndex'
                        colormap( app.UIAxesImages2, 'lines' )
                        clim( app.UIAxesImages2, 'auto' )
                end
                
            end
    
        end
    
        app.CurrentImage2.ContextMenu = app.UIAxesContextMenu;

        % *********** Overlay DIC Image ***********
        delete( app.OverlayImage )
    
        if app.OverlayDICButton.Value && app.OverlayDICButton.Enable ...
                && ishandle( app.CurrentImage )
    
            CurrentImage2Alpha = 0.3;

            app.CurrentImage2.AlphaData = ...
                app.CurrentImage2.AlphaData * app.Default.Options.OverlayOpacity;
    
            value = app.CurrentImage.CData;
            CLim = app.UIAxesImages.CLim;
            n = size( app.UIAxesImages.Colormap, 1 );
            XData = app.CurrentImage.XData;
            YData = app.CurrentImage.YData;

            value( value>CLim(2) ) = CLim(2);
            value( value<CLim(1) ) = CLim(1);
            value = ind2rgb( ...
                round( rescale( value, 1, n ) ), app.UIAxesImages.Colormap );
    
    
            app.OverlayImage = image( ...
                    app.UIAxesImages2, value, ...
                    'XData', XData, ... [ 0, EBSDData.XData(end) ], ...
                    'YData', YData, ... [ 0, EBSDData.YData(end) ], ...
                    'AlphaData', 1-CurrentImage2Alpha );
    
            uistack( app.OverlayImage, 'bottom' )
        end

    end

    if any(strcmp( Node.UserData.NodeType, {'EBSD2','EBSDData'} ))

        % *********** Overlay Grain Polygons ***********
        delete( app.OverlayImage2 )
    
        if app.OverlayPolygons.Value && app.OverlayPolygons.Enable
    
            GrainSelection = EBSDData.GrainSelection;
            app.OverlayImage2 = plot( app.UIAxesImages2, ...
                [EBSDData.Map.grains(GrainSelection).polygon], ...
                'PickableParts', 'none' );

            if ~ishandle( app.GrainLabels(1) ) && app.LabelsCheckBox.Value
                plotEBSDGrainLabels( app, EBSDData )
            end
        end
    end


end

updateMonitorTable( DICFlag, value, app )
function TreeSelectionChangedFcn( tree, ~, app )

Node = tree.SelectedNodes;
% DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
% strs = app.TextAreaStrings( app.Default.LanguageSelection );

app.StatisticButton.Enable = 'off';

clearAllGraphicObjects( app )

if isempty( Node ) || ~ isscalar( app.Tree.SelectedNodes )

    deleteAllImages(app)

else
    
    app.TextArea.Value = '';
    
    ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
    obj = app.Projects( ProjectIndex );
    

    app.StageDropDown.Items = arrayfun( ...
        @ num2str, 1:obj.DIC.StageNumber, 'UniformOutput', false );
    

    app.EBSDDropDown.Enable = 'off';
    app.EBSDDropDownLabel.Enable = 'off';
    app.OverlayDICButton.Enable = 'off';
    app.OverlayPolygons.Enable = 'off';

    % ******
    if ~strcmp( Node.UserData.NodeType, 'EBSDData' )
        disableGrainsTab( app )
        
    end
    if ~strcmp( Node.UserData.NodeType, 'DICData' )
        app.StageDropDown.Enable = 'off';
        app.StageDropDownLabel.Enable = 'off';
    end


    switch Node.UserData.NodeType
    
        case 'DIC'
            
            deleteAllImages(app)
            setStyleUIsEnable( app, 'off' )
            if ~Node.NodeData.Enable; return; end

        case 'DICData'
            
            app.TabGroup.SelectedTab = app.ImagesTab;

            app.StageDropDown.ValueIndex = obj.StageSelection;
            
            app.StageDropDown.Enable = 'on';
            app.StageDropDownLabel.Enable = 'on';
            app.StatisticButton.Enable = 'on';

            % if ~ app.DICColorbar.Visible
            %     visualizeDICColorbar( app, 'on' )
            % end

            if app.Default.Options.DICAxesFlag
                visualizeAxes( app.UIAxesImages, 'on' )
            end

            refreshCurrentImage(app)
            
            updateStatisticResulGraphicObjects( ProjectIndex, Node, app )

        case { 'EBSD', 'EBSD2', 'Main' }
                   
            deleteAllImages(app)
            setStyleUIsEnable( app, 'off' )

            app.CurrentImage2 = gobjects(1);

            visualizeAxes( app.UIAxesImages2, 'off' )

        case 'EBSDData'

            app.TabGroup.SelectedTab = app.Images2Tab;

            if ~Node.NodeData.Enable

                delete( app.CurrentImage2 )
                delete( app.OverlayImage )
                app.CurrentImage2 = gobjects(1);

                visualizeAxes( app.UIAxesImages2, 'off' )
                
                return
            end
            
            if app.Default.Options.EBSDAxesFlag
                visualizeAxes( app.UIAxesImages2, 'on' )
            end
            
            EBSDData = obj.EBSD.Data( getEBSDIndex( ...
                Node.NodeData.EBSDSerial, obj ) );

            if EBSDData.Flag.Adjusted
                app.OverlayDICButton.Enable = 'on';
            end

            if EBSDData.Flag.Polygonized

                if EBSDData.Flag.Adjusted
                    app.DICPanel.Enable = 'on';
                    app.DICTree.Enable = app.Default.Options.GrainsTab.DICFlag;
                    
                end

                % ***** set UIs of GrainsTab *****
                % upon EBSDData selection changed

                if any(app.CurrentProjectSelection ~= ProjectIndex) ...
                 || any(app.CurrentEBSDSelection ~= Node.NodeData.EBSDSerial) ...
                 || ~app.GrainSelectionPanel.Enable

                    app.GrainSelectionPanel.Enable = 'on';
                    app.BoundaryPanel.Enable = 'on';

                    createGrainSelectionTreeNodes( EBSDData, app )
                    
                    %
                    app.FrontierDevSpinner.Value = EBSDData.FrontierDev;
    
                    % LabelsCheckBox
                    if app.GBsCheckBox.Value
                        plotEBSDGBs( app, EBSDData )
                    else
                        delete( app.GBsPlot )
                    end
    
                    % Labels
                    if app.LabelsCheckBox.Value
                        plotEBSDGrainLabels( app, EBSDData )
                    else
                        delete( app.GrainLabels )
                    end
                    
                    if EBSDData.Flag.Adjusted
                        app.DICPanel.Enable = 'on';
                        if app.Default.Options.GrainsTab.DICFlag
                            app.StageDropDownLabel.Enable = 'on';
                            app.StageDropDown.Enable = 'on';
                        end
                        VariableNames = fieldnames( obj.DIC.Data );
                        delete( app.DICTree.Children )
                        Names = structfun( @(val) val.Text, ...
                            obj.TreeNodes.DICData, 'UniformOutput', false);
                        
                        DICNodes = cellfun( @(name) ...
                            uitreenode( app.DICTree, ...
                                'Text', Names.(name), ...
                                'NodeData', name ), ...
                                VariableNames );
                        app.DICTree.SelectedNodes = DICNodes( strcmp( ...
                            EBSDData.DICSelection, VariableNames ) );
                    else
                        delete( app.DICTree.Children )
                        app.DICPanel.Enable = 'off';
                    end

                end

            else
                disableGrainsTab( app )
            end
            
            updateStatisticResulGraphicObjects( ProjectIndex, Node, app )

    end

    % ***** SET TEXTAREA, IMAGE
    if any( strcmp( Node.UserData.NodeType, {'EBSD2','EBSDData'} ) )

        EBSDData = obj.EBSD.Data( getEBSDIndex( ...
            Node.NodeData.EBSDSerial, obj ) );

        ImageSource = {'EmptyImage','SuccessImage'};
        app.ImagePolygonize.ImageSource = app.ConstantValues. ...
            ( ImageSource{ EBSDData.Flag.Polygonized+1 } );
        app.ImageAdjust.ImageSource = app.ConstantValues. ...
            ( ImageSource{ EBSDData.Flag.Adjusted+1 } );
        if ~EBSDData.Flag.Polygonized && EBSDData.Flag.Adjusted
            app.ImagePolygonize.ImageSource = ...
                app.ConstantValues.FailImage;
        end

        if EBSDData.Flag.Polygonized
            app.OverlayPolygons.Enable = 'on';
        end

        app.CurrentEBSDSelection = Node.NodeData.EBSDSerial;

        % ****** TEXT AREA EBSD ******
        app.TextArea.Value = getEBSDInfo( EBSDData );

        refreshCurrentImage2(app)

    elseif any( strcmp( Node.UserData.NodeType, {'DIC','DICData'} ) )

        % ****** TEXT AREA DIC ******
        app.TextArea.Value = getDICInfo( obj.DIC );
        if strcmp( Node.UserData.NodeType, 'DICData' )
            app.TextArea.Value = [ app.TextArea.Value; ...
                [ '* Mean Value: ', ...
                num2str( mean( app.CurrentImage.CData, 'all' ) ) ] ];
        end

    elseif strcmp( Node.UserData.NodeType, 'Main' )
        
        % ****** TEXT AREA DIC ******
        app.TextArea.Value = getMainInfo( obj );
        
    end


    app.CurrentProjectSelection = Node.NodeData.Serial; % ProjectIndex;

end


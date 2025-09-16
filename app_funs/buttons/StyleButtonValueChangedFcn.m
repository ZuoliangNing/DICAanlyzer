function StyleButtonValueChangedFcn( button, ~, app )


DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
if button.Value

    [ app.StyleUIs.UIFigure, ...
        app.StyleUIs.CMapDropDown, app.StyleUIs.CLimButtonGroup, CLimCoeffLabel, ...
        MaxLabel, MinLabel, app.StyleUIs.TempAxe, ...
        app.StyleUIs.CLimCoeffEdit, ...
        app.StyleUIs.MaxEdit, ...
        app.StyleUIs.MinEdit, ...
        app.StyleUIs.CLimSlider, ...
        app.StyleUIs.ColorBar, ...
        app.StyleUIs.CLimPanel, ...
        app.StyleUIs.CMapLabel, ...
        app.StyleUIs.AllStageCheckBox ] = ...
            createStyleButton_UI( app );

    app.StyleUIs.UIFigure.CloseRequestFcn = @ UIFigureCloseRequestFcn;
    app.StyleUIs.CMapDropDown.ValueChangedFcn = @ CMapDropDownValueChangedFcn;
    app.StyleUIs.CLimButtonGroup.SelectionChangedFcn = @ CLimButtonGroupSelectionChangedFcn;
    app.StyleUIs.CLimCoeffEdit.ValueChangedFcn = @ CLimCoeffEditValueChangedFcn;
    app.StyleUIs.MaxEdit.ValueChangedFcn = @ MaxMinEditValueChangedFcn;
    app.StyleUIs.MinEdit.ValueChangedFcn = @ MaxMinEditValueChangedFcn;
    app.StyleUIs.AllStageCheckBox.ValueChangedFcn = @ AllStageCheckBoxValueChangedFcn;
    app.StyleUIs.CLimSlider.ValueChangedFcn = @ CLimSliderValueChangedFcn;

    colormap( app.StyleUIs.TempAxe, app.ConstantValues.Colormaps ...
        { app.Default.Options.DICColormapIndex } )
    % app.StyleUIs.CLimCoeffEdit.Value = obj.DIC.
    
    

    if ishandle( app.CurrentImage )
        setStyleUIs( app, app.UIAxesImages.CLim );
    elseif app.DICPanel.Enable && app.ShowButton.Value
        setStyleUIs( app, app.UIAxesImages2.CLim );
    else
        setStyleUIsEnable( app, 'off' )
    end


else
    delete( app.StyleUIs.UIFigure )
end



% ------- CLimButtonGroup ------
function CLimButtonGroupSelectionChangedFcn( ButtonGroup, flag )
    if strcmp( ButtonGroup.SelectedObject.UserData, 'auto' )
        CLimCoeffLabel.Enable = 'on';
        app.StyleUIs.CLimCoeffEdit.Enable = 'on';
        MaxLabel.Enable = 'off';
        app.StyleUIs.MaxEdit.Enable = 'off';
        MinLabel.Enable = 'off';
        app.StyleUIs.MinEdit.Enable = 'off';
        % app.StyleUIs.CLimSlider.Enable = 'off';
        if ~isempty( flag )
            CLimCoeffEditValueChangedFcn( app.StyleUIs.CLimCoeffEdit, [] )
        end
    else
        CLimCoeffLabel.Enable = 'off';
        app.StyleUIs.CLimCoeffEdit.Enable = 'off';
        MaxLabel.Enable = 'on';
        app.StyleUIs.MaxEdit.Enable = 'on';
        MinLabel.Enable = 'on';
        app.StyleUIs.MinEdit.Enable = 'on';
        % app.StyleUIs.CLimSlider.Enable = 'on';
        AllStageCheckBoxValueChangedFcn( app.StyleUIs.AllStageCheckBox, [] )
    end
    
end


% ------- CMapDropDown ------
function CMapDropDownValueChangedFcn( DropDown, ~ )

    NewMap = app.ConstantValues.Colormaps{ DropDown.Value };
    app.Default.Options.DICColormapIndex = DropDown.Value;
    colormap( app.StyleUIs.TempAxe, NewMap )

    arrayfun( @(menu) set( menu, 'Checked', 'off' ), ...
        app.DICColormapMenu.Children )
    temp = flip( app.DICColormapMenu.Children );
    temp( DropDown.Value ).Checked = 'on';

    colormap( app.UIAxesImages, NewMap )
    colormap( app.UIAxesImages2, NewMap )
end


% ------- CLimCoeffEdit ------
function CLimCoeffEditValueChangedFcn( edit, ~)
    
    if edit.Value < 0
        uialert( app.StyleUIs.UIFigure, ...
            DisplayNames.invalidvalue_title, ...
            DisplayNames.cm_CLim )
        return
    end

    ProjectIndex = app.StyleUIs.UIFigure.UserData.ProjectIndex;
    obj = app.Projects( ProjectIndex );
    name = app.StyleUIs.UIFigure.UserData.VariableName;
    axe = app.StyleUIs.UIFigure.UserData.axe;
    n = str2double( app.StageDropDown.Value );

    CLimCoeff = edit.Value;
    obj.DIC.CLimCoeff( n ).( name ) = CLimCoeff;
    obj.DIC.CLimMethod( n ).( name ) = 'auto';

    if isfield( obj.DIC.DataValueRange, name )
        val = restoreData( ...
            obj.DIC.Data(n).( name ), obj.DIC.DataValueRange.( name ) );
    else
        val = obj.DIC.Data(n).( name );
    end
    [ minval, maxval ] = getCLim( val, CLimCoeff );
    CLim = [ minval, maxval ];
    obj.DIC.CLim(n).( name ) = CLim;

    if app.StyleUIs.AllStageCheckBox.Value
        dlg = uiprogressdlg( app.StyleUIs.UIFigure, 'Indeterminate', 'on' );
        Stages = setdiff( 1:obj.DIC.StageNumber, n );
        for n = Stages
            if isfield( obj.DIC.DataValueRange, name )
                val = restoreData( ...
                    obj.DIC.Data(n).( name ), obj.DIC.DataValueRange.( name ) );
            else
                val = obj.DIC.Data(n).( name );
            end
            [ minval, maxval ] = getCLim( val, CLimCoeff );
            obj.DIC.CLim( n ).( name ) = [ minval, maxval ];
            obj.DIC.CLimMethod( n ).( name ) = 'auto';
        end
        close( dlg )
    end

    app.Projects( ProjectIndex ) = obj;

    % CLim = obj.DIC.CLim( str2double( app.StageDropDown.Value ) ).( name );
    setStyleUIs( app, CLim );
    axe.CLim = CLim;

end


% ------- MaxMinEdit ------
function MaxMinEditValueChangedFcn( edit, event )

    if app.StyleUIs.MaxEdit.Value <= app.StyleUIs.MinEdit.Value
        uialert( app.StyleUIs.UIFigure, ...
            DisplayNames.invalidvalue_title, ...
            DisplayNames.cm_CLim )
            edit.Value = event.PreviousValue;
        return
    end

    ProjectIndex = app.StyleUIs.UIFigure.UserData.ProjectIndex;
    obj = app.Projects( ProjectIndex );
    name = app.StyleUIs.UIFigure.UserData.VariableName;
    axe = app.StyleUIs.UIFigure.UserData.axe;
    n = str2double( app.StageDropDown.Value );

    CLim = [ app.StyleUIs.MinEdit.Value, app.StyleUIs.MaxEdit.Value ];
    obj.DIC.CLim( n ).( name ) = CLim;

    obj.DIC.CLimMethod( n ).( name ) = 'manual';

    if app.StyleUIs.AllStageCheckBox.Value
        Stages = setdiff( 1:obj.DIC.StageNumber, n );
        for n = Stages
            obj.DIC.CLim( n ).( name ) = CLim;
            obj.DIC.CLimMethod( n ).( name ) = 'manual';
        end
    end

    app.Projects( ProjectIndex ) = obj;
    setStyleUIs( app, CLim );
    axe.CLim = CLim;

end


% ------- AllStageCheckBox ------
function AllStageCheckBoxValueChangedFcn( checkbox, ~ )
    if checkbox.Value

        ProjectIndex = app.StyleUIs.UIFigure.UserData.ProjectIndex;
        obj = app.Projects( ProjectIndex );
        n = str2double( app.StageDropDown.Value );
        name = app.StyleUIs.UIFigure.UserData.VariableName;
        Stages = setdiff( 1:obj.DIC.StageNumber, n );
        
        if strcmp( app.StyleUIs.CLimButtonGroup.SelectedObject.UserData, 'auto' )
            % Auto
            CLimCoeff = app.StyleUIs.CLimCoeffEdit.Value;
            dlg = uiprogressdlg( app.StyleUIs.UIFigure, 'Indeterminate', 'on' );
            for n = Stages
                if isfield( obj.DIC.DataValueRange, name )
                    val = restoreData( ...
                        obj.DIC.Data(n).( name ), obj.DIC.DataValueRange.( name ) );
                else
                    val = obj.DIC.Data(n).( name );
                end
                [ minval, maxval ] = getCLim( val, CLimCoeff );
                obj.DIC.CLim( n ).( name ) = [ minval, maxval ];
                obj.DIC.CLimMethod( n ).( name ) = 'auto';
            end
            close( dlg )
        else
            % Manual
            CLim = [ app.StyleUIs.MinEdit.Value, app.StyleUIs.MaxEdit.Value ];
            for n = Stages
                obj.DIC.CLim( n ).( name ) = CLim;
                obj.DIC.CLimMethod( n ).( name ) = 'manual';
            end
        end

        app.Projects( ProjectIndex ) = obj;

    end
    
end

% ------- CLimSlider ------
function CLimSliderValueChangedFcn( slider, event )

    axe = app.StyleUIs.UIFigure.UserData.axe;
    axe.CLim = slider.Value;
    app.StyleUIs.TempAxe.CLim = slider.Value;

end


function UIFigureCloseRequestFcn( fig, ~ )
    app.StyleButton.Value = false;
    delete( fig )

end




end
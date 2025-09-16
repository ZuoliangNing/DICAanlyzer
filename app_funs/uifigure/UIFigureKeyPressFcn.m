function UIFigureKeyPressFcn( fig, event, app )

if ~app.StageDropDown.Enable; return; end


if strcmp( event.Key, 'downarrow' )
    CurrentStage = find( strcmp( ...
        app.StageDropDown.Value, app.StageDropDown.Items ) );
    MaxStage = str2double( app.StageDropDown.Items{end} );
    if CurrentStage < MaxStage
        app.StageDropDown.Value = ...
            app.StageDropDown.Items{ CurrentStage + 1 };
        StageDropDownValueChangedFcn( app.StageDropDown, [], app )
    end
end

if strcmp( event.Key, 'uparrow' )
    CurrentStage = find( strcmp( ...
        app.StageDropDown.Value, app.StageDropDown.Items ) );
    if CurrentStage > 1
        app.StageDropDown.Value = ...
            app.StageDropDown.Items{ CurrentStage - 1 };
        StageDropDownValueChangedFcn( app.StageDropDown, [], app )
    end
end
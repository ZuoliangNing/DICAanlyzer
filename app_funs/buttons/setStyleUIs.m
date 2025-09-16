function setStyleUIs( app, CLim )

if ~ishandle( app.StyleUIs.UIFigure ); return; end

setStyleUIsEnable( app, 'on' )


Node = app.Tree.SelectedNodes;

ProjectIndex = getProjectIndex( Node.NodeData.Serial, app );
obj = app.Projects( ProjectIndex );
n = str2double( app.StageDropDown.Value );


if isscalar( app.Tree.SelectedNodes ) && ...
        strcmp( Node.UserData.NodeType, 'DICData' )
    VariableName = Node.UserData.VariableName;
    axe = app.UIAxesImages;
else
    EBSDData = obj.EBSD.Data( getEBSDIndex( ...
        Node.NodeData.EBSDSerial, obj ) );
    VariableName = EBSDData.DICSelection;
    axe = app.UIAxesImages2;
end


app.StyleUIs.CLimCoeffEdit.Value = ...
    obj.DIC.CLimCoeff(n).( VariableName );


app.StyleUIs.UIFigure.UserData = struct( ...
    'ProjectIndex', ProjectIndex, ...
    'VariableName', VariableName, ...
    'axe', axe );


app.StyleUIs.MinEdit.Value = CLim(1);
app.StyleUIs.MaxEdit.Value = CLim(2);

app.StyleUIs.TempAxe.CLim = CLim;
refreshCLimSlider( app.StyleUIs.CLimSlider, CLim )
% app.StyleUIs.ColorBar.Ticks = linspace( ...
%     app.StyleUIs.CLimSlider.Value(1), ...
%     app.StyleUIs.CLimSlider.Value(2), 5 );

switch obj.DIC.CLimMethod(n).( VariableName )
    case 'auto'
        app.StyleUIs.CLimButtonGroup.SelectedObject = ...
            app.StyleUIs.CLimButtonGroup.Children(2);
    case 'manual'
        app.StyleUIs.CLimButtonGroup.SelectedObject = ...
            app.StyleUIs.CLimButtonGroup.Children(1);
end
app.StyleUIs.CLimButtonGroup.SelectionChangedFcn( ...
    app.StyleUIs.CLimButtonGroup, [] )



    function refreshCLimSlider( CLimSlider, CLim )
    
        CLim = round( CLim, 2, 'significant' );

        CLimSlider.Limits = CLim;
        maxval = CLim(2);
        minval = CLim(1);
        
        
        % N = ceil( log10( maxval - minval ) );
        
        % CLimSlider.Step = ....
        %     round( ( maxval - minval ) / 1000, -(N-4) );
        CLimSlider.Step = ...
            round( ( maxval - minval ) / 100, 2, 'significant' );

        CLimSlider.Value = CLimSlider.Limits;
        
        temp = round( linspace( minval, maxval, 5 ), 2, 'significant' );
        CLimSlider.MajorTicks = temp;
        
        CLimSlider.MinorTicks = cell2mat( arrayfun( ...
            @(i) linspace( temp(i), temp(i+1), 5 ), ...
            1:length(temp)-1, 'UniformOutput', false ));
    end

end
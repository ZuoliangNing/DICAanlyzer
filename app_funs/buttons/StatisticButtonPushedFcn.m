function StatisticButtonPushedFcn( button, ~, app )



ProjectIndex = getProjectIndex( app.CurrentProjectSelection, app );
obj = app.Projects( ProjectIndex );

[ app.StatisticUIFigure, MethodDropDown, NameEdit, ...
    WholeCheckBox, PhasesCheckBox, ReigonStatisticPanel, ...
    ReigonButtonGroup, StageCheckBox, GrainPartitionCheckBox, ...
    GrainPartitionPanel, GrainPartitionCoeffSpinner, GrainPartitionShowCheckBox, ...
    ConfirmButton ] = createStatisticButton_UI( app );


DefaultName = [ 'L', num2str( obj.StatisticResultsSerial + 1 ) ];
NameEdit.Value = DefaultName;

if strcmp( app.Tree.SelectedNodes.UserData.NodeType, 'DICData' )
    PhasesCheckBox.Enable = 'off';
    GrainPartitionCheckBox.Enable = 'off';
    % GrainPartsCheckBox.Enable = 'off';
end

MethodDropDown.ValueChangedFcn = @ MethodDropDownValueChangedFcn;
WholeCheckBox.ValueChangedFcn = @ CheckBoxValueChangedFcn;
PhasesCheckBox.ValueChangedFcn = @ CheckBoxValueChangedFcn;
GrainPartitionCheckBox.ValueChangedFcn = @ CheckBoxValueChangedFcn;
ConfirmButton.ButtonPushedFcn = @ ConfirmButtonPushedFcn;
GrainPartitionCoeffSpinner.ValueChangedFcn = ...
    @ GrainPartitionCoeffSpinnerValueChangedFcn;

% ------- MethodDropDown ------
function MethodDropDownValueChangedFcn( dropdoown, ~ )
    flag = strcmp( NameEdit.Value, DefaultName );
    if strcmp( dropdoown.Value, 'line' )
        ReigonStatisticPanel.Enable = 'off';
        GrainPartitionCheckBox.Enable = 'off';
        GrainPartitionPanel.Enable = 'off';
        GrainPartitionCheckBox.Value = false;
        if flag
            DefaultName(1) = 'L';
            NameEdit.Value = DefaultName;
        end
        if WholeCheckBox.Value
            PhasesCheckBox.Value = false;
        end
    else
        ReigonStatisticPanel.Enable = 'on';
        GrainPartitionCheckBox.Enable = 'on';
        if flag
            DefaultName(1) = 'A';
            NameEdit.Value = DefaultName;
        end
    end
end

% ------- CheckBox ------
function CheckBoxValueChangedFcn( box, ~ )

    if box.Value && strcmp( MethodDropDown.Value, 'line' )
        if strcmp( box.Tag, 'whole' )
            PhasesCheckBox.Value = false;
        else
            WholeCheckBox.Value = false;
        end
    end

    if GrainPartitionCheckBox.Value
        GrainPartitionPanel.Enable = 'on';
    else
        GrainPartitionPanel.Enable = 'off';
    end

    temp = [ WholeCheckBox.Value, PhasesCheckBox.Value ];
           % GrainPartsCheckBox.Value
    if any( temp )
        ConfirmButton.Enable = 'on';
    else; ConfirmButton.Enable = 'off';
    end
end

% ------- GrainPartitionCoeffSpinner ------
function GrainPartitionCoeffSpinnerValueChangedFcn( spinner, ~ )
    if spinner.Value < 0
        spinner.Value = 0;
    end
    
    if spinner.Value > 10
        spinner.Value = 10;
    end
end

% ------- ConfirmButton ------
function ConfirmButtonPushedFcn( ~, ~ )
    
    Method = MethodDropDown.Value;
    Flag.Whole = WholeCheckBox.Value;
    Flag.Phases = PhasesCheckBox.Value;
    Flag.AllStage = StageCheckBox.Value;
    Flag.ReigonMethod = ReigonButtonGroup.SelectedObject.UserData;
    Flag.GrainPartition = GrainPartitionCheckBox.Value;
    Flag.GrainPartitionCoeff = GrainPartitionCoeffSpinner.Value;
    Flag.GrainPartitionShow = GrainPartitionShowCheckBox.Value;

    app.StatisticUIFigure.WindowStyle = 'normal';
    app.StatisticUIFigure.Visible = 'off';

    

    switch Method
        case 'line'
            createLineStatistic( NameEdit.Value, Flag, app );
        case 'reigon'
            createReigonStatistic( NameEdit.Value, Flag, app );
    end

    

end


end
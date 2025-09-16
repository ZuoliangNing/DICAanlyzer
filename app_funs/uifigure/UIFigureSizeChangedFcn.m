function UIFigureSizeChangedFcn(fig,~,app)

ratio = [1,3,1];
maxsize = 300;

app.RightPanel.Parent.ColumnWidth = ...
    arrayfun(@(num)[num2str(num),'x'],ratio,'UniformOutput',false);

val = fig.Position(3)*ratio(1)/sum(ratio);
if val > maxsize
    app.RightPanel.Parent.ColumnWidth{1} = maxsize;
    app.RightPanel.Parent.ColumnWidth{3} = maxsize;
    val = maxsize;
end

% Panel
g = app.LeftPanel.Parent;
g.ColumnWidth{1} = app.ConstantValues.LeftPanelWidth;
g.ColumnWidth{3} = app.ConstantValues.RightPanelWidth;

% Name Label
app.GridLayoutLeft.RowHeight{4} = app.ConstantValues.AppNameHeight;

% IconedButton
% app.GridLayoutLeft.RowHeight{5} = app.ConstantValues.IconedButtonSize(1);
% app.GridLayout3.ColumnWidth = ...
%     num2cell( app.ConstantValues.IconedButtonSize(2) * ones(1,4) );

% pullbutton
app.GridLayoutRight.RowHeight{2} = app.ConstantValues.PullButtonSize(2);
app.GridLayout11.ColumnWidth{1} = app.ConstantValues.PullButtonSize(1);
app.GridLayoutRight.RowHeight{4} = app.ConstantValues.PullButtonSize(2);
app.GridLayout10.ColumnWidth{1} = app.ConstantValues.PullButtonSize(1);

% DropDown
app.GridLayoutLeft.RowHeight{3} = app.ConstantValues.DropDownHeight * 2;
% app.GridLayoutLeft.RowHeight{4} = app.ConstantValues.DropDownHeight;

% Label
% app.AppNameLabel.FontSize = round( app.GridLayout12.Position(4) * 0.6 );

% Slider
% app.GridLayout17.RowHeight{2} = app.ConstantValues.SliderHeight;
% app.GridLayout18.ColumnWidth{1} = 80;

% Tree2
app.GridLayoutLeft.RowHeight{2} = app.ConstantValues.Tree2Height;


%
app.GridLayout9.RowHeight{1} = app.ConstantValues.TabGroup2Height;
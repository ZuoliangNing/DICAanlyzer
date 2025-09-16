function GBStyleMenuSelectedFcn( ~, ~, app )


DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
ButtonSize = app.ConstantValues.TextedButtonSize;
EditSize = app.ConstantValues.EditSize;
LabelWidth = 25;

delete( app.GBStyleUIFigure )

% ---------- UIFigure ----------
app.GBStyleUIFigure = uifigure( ...
    'Name', DisplayNames.GBStyleMenu_UIFigure, ...
    'WindowStyle', 'alwaysontop', ...alwaysontop
    'Icon', app.ConstantValues.IconSource, ...
    'Resize', 'off' );
app.GBStyleUIFigure.Position = getMiddlePosition( app.UIFigure.Position, ...
    app.ConstantValues.PlotStyle_UIFigure_size );

% ---------- GridLayoutMain ----------
GridLayoutMain = uigridlayout( app.GBStyleUIFigure, ...
    'RowHeight',    { EditSize(2), ButtonSize(2) }, ...
    'ColumnWidth',  { '1x' }, ...
    'Padding', 15*ones(1,4));


% ---------- GridLayout2 ----------
GridLayout2 = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', LabelWidth, EditSize(1), '1x', ...
                      LabelWidth, EditSize(1), '1x' }, ...
    'Padding', zeros(1,4) );
GridLayout2.Layout.Row = 1;


% ---------- LineWidthLabel ----------
LineWidthLabel = uilabel( GridLayout2, ...
    'Text', DisplayNames.LineWidthLabel_Text );
LineWidthLabel.Layout.Column = 2;


% ---------- LineWidthEditfield ----------
LineWidthEditfield = uieditfield( GridLayout2, 'numeric', ...
    'Value', app.Default.Options.GBLineWidth );
LineWidthEditfield.Layout.Column = 3;


% ---------- ColorLabel ----------
ColorLabel = uilabel( GridLayout2, ...
    'Text', DisplayNames.ColorLabel_Text );
ColorLabel.Layout.Column = 5;


% ---------- ColorButton * ----------
ColorButton = uibutton( GridLayout2, ...
    'Text', '', ...
    'BackgroundColor', app.Default.Options.GBColor, ...
    'ButtonPushedFcn', @ ColorButtonPushedFcn );
ColorButton.Layout.Column = 6;

    function ColorButtonPushedFcn( button, ~ )

        c = uisetcolor();
        if ~c; return; end
        button.BackgroundColor = c;

    end

% ---------- GridLayoutButtons ----------
GridLayoutButtons = uigridlayout( GridLayoutMain, ...
    'RowHeight',    { '1x' }, ...
    'ColumnWidth',  { '1x', ButtonSize(1), ButtonSize(1) }, ...
    'Padding', zeros(1,4) );
GridLayoutButtons.Layout.Row = 2;


% ---------- ConfirmButton * ----------
ConfirmButton = uibutton( GridLayoutButtons, 'push', ...
    'Text', DisplayNames.uiopt_apply, ...
    'ButtonPushedFcn', @ ConfirmButtonPushedFcn );
ConfirmButton.Layout.Row = 1; ConfirmButton.Layout.Column = 2;

    function ConfirmButtonPushedFcn( ~, ~ )

        val = LineWidthEditfield.Value;
        if val <= 0
            uialert( app.UIFigure, ...
                DisplayNames.invalidvalue_title, ...
                DisplayNames.PlotGBMenu_UIFigure )
            return
        end

        app.Default.Options.GBColor = ColorButton.BackgroundColor;
        app.Default.Options.GBLineWidth = val;

        if ishandle( app.GBsPlot )
            
            % ProjectIndex = getProjectIndex( app.CurrentProjectSelection, app );
            % obj = app.Projects( ProjectIndex );
            % EBSDIndex = getEBSDIndex( app.CurrentEBSDSelection, obj );
            % EBSDData = obj.EBSD.Data( EBSDIndex );
            % 
            % plotEBSDGBs( app, EBSDData )

            app.GBsPlot.Color = ColorButton.BackgroundColor;
            app.GBsPlot.LineWidth = val;
            
        end

        % close( UIFigure )

    end

% ---------- CancelButton ----------
CancelButton = uibutton( GridLayoutButtons, 'push', ...
    'Text', DisplayNames.uiopt_close, ...
    'ButtonPushedFcn', @(~,~) close(app.GBStyleUIFigure) );
CancelButton.Layout.Row = 1; CancelButton.Layout.Column = 3;

end


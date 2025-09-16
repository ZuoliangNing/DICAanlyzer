function axe = getUIAxe( Parent, options )
% Create a new uiaxis

arguments
    Parent (1,1) = matlab.ui.container.GridLayout
    options.FontName (1,:) char ...
        {mustBeMember(options.FontName,{'Times New Roman','宋体','Arial'})} ...
        = 'Times New Roman' % font name - label & title
    options.TickSize (1,1) double = 18 % font size -- for ticks
    options.LabelSize (1,1) double % font size -- for labels
    options.XLabel (1,:) char % X label
    options.YLabel (1,:) char % Y label
    options.XLim (1,2) double % X coord limits
    options.YLim (1,2) double % Y coord limits
    options.XSpan (1,1) double
    options.YSpan (1,1) double
    options.Grid (1,1) logical = false
    options.LineWidth (1,1) double = 1
    options.YLabel2 (1,:) char
    options.YLim2 (1,2) double
    options.YSpan2 (1,1) double
    options.Color2 = 'k'
end


% create axis
axe = uiaxes( Parent, 'NextPlot', 'add', 'Box', 'on' );
axe.LineWidth = options.LineWidth;
axe.FontName = options.FontName;
axe.FontSize = options.TickSize;


% axes limits
if isfield( options, 'XLim' ); axe.XLim = options.XLim; end
if isfield( options, 'YLim' ); axe.YLim = options.YLim; end
if isfield( options, 'XSpan' )
    axe.XTick = axe.XLim(1) : options.XSpan : axe.XLim(2);
end
if isfield( options, 'YSpan' )
    axe.YTick = axe.YLim(1) : options.YSpan : axe.YLim(2);
end

% labels
if isfield( options, 'LabelSize' )
    siz = options.LabelSize;
else
    siz = options.TickSize + 2;
end
if isfield( options, 'XLabel' )
    xlabel( axe, options.XLabel, ...
        'FontSize' , siz, 'FontName', options.FontName )
end
if isfield( options, 'YLabel' )
    ylabel( axe, options.YLabel, ...
        'FontSize' , siz, 'FontName', options.FontName )
end


% grid
if isfield( options, 'Grid' ) && options.Grid
    grid(axe,"on"); grid(axe,"minor")
    Alpha = 0.75; LineWidth = 0.5;
    axe.GridAlpha = Alpha;
    axe.MinorGridAlpha = Alpha;
    axe.MinorGridLineStyle = '-';
    axe.GridLineWidth = LineWidth;
    axe.MinorGridLineWidth = LineWidth;
end

% second YAxis
if any( isfield( options, {'YLabel2','YLim2','YSpan2'} ) )

    yyaxis( axe, 'right' )

    axe.YAxis(1).Color = 'k'; % black
    axe.YAxis(2).Color = options.Color2;

    if isfield( options, 'YLabel2' )
        ylabel( options.YLabel2, ...
            'FontSize' , siz, 'FontName', options.FontName )
    end

    if isfield( options, 'YLim2' ); axe.YLim = options.YLim2; end
    if isfield( options, 'YSpan2' )
        axe.YTick = axe.YLim(1) : options.YSpan2 : axe.YLim(2);
    end
end

% legend
lgd = legend( axe );
lgd.FontName = 'Times New Roman';
lgd.FontSize = 14;
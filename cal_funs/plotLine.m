function varargout = plotLine( axe, x, y, ...
    Color, Name, LineWidth, options )
% Plot a line

%

arguments
    axe (1,1) matlab.graphics.axis.Axes = gca
    x double = 0
    y double = 0
    Color = nan
    Name (1,:) char = ''
    LineWidth (1,1) double = 1
    options.Marker (1,:) char {mustBeMember(options.Marker,{ ...
        's','o','^','v','>','<','+','*','.','x','_','|', ...
        'square','diamond','pentagram','hexagram','none'})} = 'none'
    options.MarkerColor = Color
    options.MarkerNumber (1,1) double = nan
    options.MarkerSpan (1,1) double = nan
    options.MarkerSize (1,1) double = nan
    options.LineStyle (1,:) char {mustBeMember(options.LineStyle,{ ...
        '-','--',':','-.','none'})} = '-'
end

obj = plot(axe,x,y);

% COLOR
if ~isnan(Color); obj.Color = Color; end

% DISPLAY NAME
obj.DisplayName = Name;

% LINE WIDTH
if LineWidth
    obj.LineWidth = LineWidth;
    % LINE STYLE
    obj.LineStyle = options.LineStyle;
else
    obj.LineStyle = 'none';
end

% MARKER
obj.Marker = options.Marker;
if ~isnan( options.MarkerColor )
    obj.MarkerFaceColor = options.MarkerColor; % face color
end
if ~isnan(options.MarkerNumber) % markers number
    n = length(y);
    span = floor( n / (options.MarkerNumber-1) );
    ind = 0:span:n; ind(1) = 1;
    obj.MarkerIndices = ind;
end
if ~isnan(options.MarkerSpan) % marker span
    n = length(y);
    obj.MarkerIndices = 1:options.MarkerSpan:n;
end
if ~isnan(options.MarkerSize) % marker size
    obj.MarkerSize = options.MarkerSize;
end



if nargout > 0; varargout{1} = obj; end
function varargout = simplifyCData( CData, Threshold, varargin )



SIZE = size( CData );

if nargin > 2
    varargout(2:4) = varargin(1:3);
end


if any( SIZE > Threshold )

    Span = round( max( SIZE ) / Threshold );

    ind1 = 1 : Span : SIZE(1);
    ind2 = 1 : Span : SIZE(2);

    CData = CData( ind1, ind2, : );

    if nargin > 2

        varargout{2} = varargin{1}( ind2 );       % XData
        varargout{3} = varargin{2}( ind1 );       % YData
        if ~isscalar( varargin{3} )
            varargout{4} = varargin{3}( ind1, ind2 ); % AlphaData
        end

    end


end

varargout{1} = CData;
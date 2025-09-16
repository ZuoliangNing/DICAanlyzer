function createbyManualWindowButtonMotionFcn( fig, ~, axe, app )


if ~strcmp( app.TabGroup.SelectedTab.Tag, axe.Tag )
    return
end
pos = axe.CurrentPoint( 1, 1:2 );

pos(1) = max( pos(1), axe.XLim(1) );
pos(1) = min( pos(1), axe.XLim(2) );
pos(2) = max( pos(2), axe.YLim(1) );
pos(2) = min( pos(2), axe.YLim(2) );

% if pos(1) < axe.XLim(1) || pos(1) > axe.XLim(2) ...
%         || pos(2) < axe.YLim(1) || pos(2) > axe.YLim(2)
%     return
% end

if ~isempty( axe.UserData.Pos1 ) && isempty( axe.UserData.Pos2 )
    delete(axe.UserData.Lines)
    pos1 = axe.UserData.Pos1;
    % funline = @( axe, x, y ) line( axe, x, y, ...
    %     'Color', 'w', 'LineWidth', 2, 'PickableParts', 'none' );
    % axe.UserData.Lines = [ ...
    %     funline( axe, [pos1(1),pos(1)], [ pos(2), pos(2) ] ), ...
    %     funline( axe, [ pos(1), pos(1) ], axe.YLim ) ];
    w = abs( pos(1) - pos1(1) );
    h = abs( pos(2) - pos1(2) );
    x = min([pos1(1),pos(1)]);
    y = min([pos1(2),pos(2)]);
    axe.UserData.Lines = rectangle( axe, ...
        'Position', [x,y,w,h], ...
        'EdgeColor', 'w', 'LineWidth', 2 );

end


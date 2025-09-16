function createbyManualWindowButtonDownFcn( fig, ~, axe, app, cm )


if ~strcmp( app.TabGroup.SelectedTab.Tag, axe.Tag ); return; end
if ~strcmp( fig.SelectionType, 'normal' ); return; end
pos = axe.CurrentPoint( 1, 1:2 );

pos(1) = max( pos(1), axe.XLim(1) );
pos(1) = min( pos(1), axe.XLim(2) );
pos(2) = max( pos(2), axe.YLim(1) );
pos(2) = min( pos(2), axe.YLim(2) );

% if pos(1) < axe.XLim(1) || pos(1) > axe.XLim(2) ...
%         || pos(2) < axe.YLim(1) || pos(2) > axe.YLim(2)
%     return
% end

if isempty( axe.UserData.Pos1 )
    axe.UserData.Pos1 = pos;
else
    axe.UserData.Pos2 = pos;
    % axe.Children(end).ContextMenu = cm;
    app.CurrentImage2.ContextMenu = cm;
end
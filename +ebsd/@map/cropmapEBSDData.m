function EBSDData = cropmapEBSDData( map, EBSDData, GrainSelection, dlg )


OldGrainN = map.numgrains;
OldIDs = [map.grains.ID];
OldSelectedIDs = OldIDs( GrainSelection );

% ************ Crop ************
map.cropmap( EBSDData.XData(1), EBSDData.XData(end), ...
    EBSDData.YData(1), EBSDData.YData(end), dlg )

if ~isempty( GrainSelection )
    NewIDs = OldSelectedIDs;
    map.grains( arrayfun(@(g)~any(g.ID==NewIDs),map.grains) ) = [];
    
else
    NewIDs = [map.grains.ID];
end

DiscardIndex = find( arrayfun( @(val) ~any(val==NewIDs), OldIDs ) );

EBSDData.GrainSelection = adjustGrainSelection( ...
OldGrainN, EBSDData.GrainSelection, DiscardIndex );

for i = 1:length( EBSDData.GrainGroup )
    EBSDData.GrainGroup(i).Index = adjustGrainSelection( ...
        OldGrainN, EBSDData.GrainGroup(i).Index, DiscardIndex );
end

% arrayfun( @(g) g.set( ...
%     'Orignialverticemembers', g.verticemembers.copy ), map.grains )

map.pixels.XData = EBSDData.XData;
map.pixels.YData = EBSDData.YData;

function NewSelection = adjustGrainSelection( ...
    OldGrainN, OldSelection, DiscardIndex )
    tempind = false( 1, OldGrainN );
    tempind( OldSelection ) = true;
    tempind( DiscardIndex ) = [];
    NewSelection = find( tempind );
end

end
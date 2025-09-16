function addMissingVertices( emap, tol, dlg, TextArea)
    %
    if nargin<2
        tol = 0.1*emap.stepsize;
    end
    grs = emap.grains;
    Msg = 'Adding missing vertices...';
    dlg.Title = Msg;
    dispText( TextArea, Msg )
    % h = waitbar(0, 'Adding missing vertices...');
    for i = 1:length(grs)
        for j = 1:length(grs(i).neighbours)
            indnb = find(vertcat(vertcat(grs.ID) == grs(i).neighbours(j)));
            [ons, loc, ~] = ebsd.map.isonboundary( ...
                grs(i).liveVertices, grs(indnb).liveVertices, tol );
            vc = grs(indnb).verticemembers(ons);

            if ~isempty(vc)
                set(vc,'isnode',true);
                grs(i).insertAtMultiple(loc, vc);
            end
        end
        dlg.Value = i/length(grs);
        Msg = ['Added ', num2str(length(loc)), ...
            ' missing vertices to grain ', num2str(i)];
        dlg.Message = Msg;
        if ~isempty(loc)
            dispText( TextArea, Msg )
        end
        % waitbar(i/length(grs), h, ['Added ', num2str(length(loc)), ' missing vertices to grain ', num2str(i)])
    end

end
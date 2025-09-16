function removeholes(emap, doublecheck, dlg, TextArea, ParaFlag )
    % REMOVEHOLES get ride of the dead pixels that are not indexed
    % in the original ebsd map. 
    %
    if nargin < 2
        doublecheck = false;
    end
    if ~emap.noholes || doublecheck
        % h1 = waitbar(0, 'Please wait...searching holes');
        dlg.Title = 'Please wait...searching holes';
        dlg.Value = 0;
        % SLOW: 'union' !!!
        dlg.Message = ...
            'Merging polygons to search for holes ...';
        dlg.Indeterminate = 'on';
        % if ParaFlag
        %     spmd; u = union(emap.polygons); end
        %     u = union([u{:}]);
        % else
        %     u = union(emap.polygons);
        % end

        % tic
        % u = union(emap.polygons);
        % toc

        % u = parfevalOnAll( @union, 1, emap.polygons );

        if ParaFlag
            NumWorkers = 10;
            u( 1:NumWorkers ) = parallel.FevalFuture;
            [~,~,bin] = histcounts( 1:emap.numgrains, NumWorkers );
            for N = 1 : NumWorkers
                u(N) = parfeval( @union, 1, emap.polygons(bin==N) );
            end
            u = union( fetchOutputs(u) );
        else
            u = union( emap.polygons );
        end

        dlg.Indeterminate = 'off';

        holes = u.holes;
        dispText( TextArea, ...
            [num2str(length(holes)), ' holes found'])
        % waitbar(0.01, h1, [num2str(length(holes)), ' holes found'])
        bufferholes = polybuffer(holes,0.1,'JointType', 'Miter');
        allpoly = vertcat(emap.grains.polygon);
        Msg = 'Processing holes...';
        dlg.Title = Msg;
        
        if ParaFlag
            % parallel
            dlg.Message = Msg;
            dlg.Indeterminate = 'on';
            grains = emap.grains;
            N = length( bufferholes );
            ALL_ind_eatergrain = cell(1,N);
            ALL_Vertices = cell(1,N);
            parfor i = 1:N
                inds_nbgrains = overlaps( bufferholes(i), allpoly );
                inds_grains = find( inds_nbgrains );
                nbgrains = grains( inds_nbgrains );
                if ~isempty( nbgrains )
                    nbpolygons = vertcat( nbgrains.polygon );
                    nbpolyconv = nbpolygons.convhull;
                    area_original = vertcat( nbpolyconv.area );       
                    trialpoly = repmat( polyshape, size(nbgrains) );
                    for j = 1:length( nbgrains )
                        trialpoly(j) = union( holes(i), nbpolygons(j) );
                    end
                    trialpolyconv = trialpoly.convhull;
                    area_trial = vertcat( trialpolyconv.area );
                    strangeness = area_trial - area_original;
                    [ ~, minstrange ] = min( strangeness );
                    ind_eatergrain = inds_grains( minstrange );
    
                    ALL_ind_eatergrain{i} = ind_eatergrain;
                    ALL_Vertices{i} = trialpoly( minstrange ).Vertices;
                end
            end
            for i = 1:N
                if ~isempty(ALL_ind_eatergrain{i})
                    grains( ALL_ind_eatergrain{i} ).vertices = ...
                            ALL_Vertices{i};
                end
            end
            dlg.Indeterminate = 'off';
        else
            for i = 1:length(bufferholes)
                inds_nbgrains = overlaps(bufferholes(i), allpoly);
                inds_grains = find(inds_nbgrains);
                nbgrains = emap.grains(inds_nbgrains);
                if ~isempty(nbgrains)
                    nbpolygons = vertcat(nbgrains.polygon);
                    nbpolyconv = nbpolygons.convhull;
                    area_original = vertcat(nbpolyconv.area);       
                    trialpoly = repmat(polyshape,size(nbgrains));
                    for j = 1:length(nbgrains)
                        trialpoly(j) = union(holes(i), nbpolygons(j));
                    end
                    trialpolyconv = trialpoly.convhull;
                    area_trial = vertcat(trialpolyconv.area);
                    strangeness = area_trial - area_original;
                    [~, minstrange] = min(strangeness);
                    ind_eatergrain = inds_grains(minstrange);
                    emap.grains(ind_eatergrain).vertices = trialpoly(minstrange).Vertices;
                    dlg.Value = i/length(bufferholes);
                    dlg.Message = ...
                        ['Processing the hole ', num2str(i), '...'];
                end
            end
        end

        emap.noholes = true;
    else
        dispText( TextArea, ...
            'The map is free of holes. Do not worry')
    end
end
        
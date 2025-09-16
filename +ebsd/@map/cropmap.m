function cropmap( emap,xmin, xmax, ymin, ymax, dlg )
    %
    p1 = [xmin, ymin];
    p2 = [xmax, ymin];
    p3 = [xmax, ymax]; 
    p4 = [xmin, ymax];
    aoi = polyshape(vertcat(p1,p2,p3,p4,p1));
    emap.width = abs(xmax - xmin);
    emap.height = abs(ymax - ymin);
    emap.leftedge = xmin;
    emap.rightedge = xmax;
    emap.topedge = ymax;
    emap.bottomedge = ymin;
    allpoly = vertcat(emap.grains.polygon);
    % arrayfun(@(g)copy(g.polygon),emap.grains)
    newpolys = allpoly;
    % h = waitbar(0, 'Cropping the map...');
    dlg.Title = 'Cropping the map...';
    DeactiveIndex = false(1,length(allpoly));
    for i = 1:length(allpoly)
        [newpolys(i), shapeID, vcID] = intersect(allpoly(i), aoi);
        if ~isequal(newpolys(i), allpoly(i))
            if newpolys(i).NumRegions > 0
                emap.grains(i).iscropped = true;
                emap.grains(i).isedge = true;

                if i == 62
                    aaa=1;
                end
                % vcs = copy(emap.grains(i).verticemembers);
                vcs = copy(emap.grains(i).Orignialverticemembers);
                emap.grains(i).vertices = newpolys(i).Vertices;
                

                vcso = emap.grains(i).Orignialverticemembers;

                ind = vcID > length(vcs);
                vcID(ind) = []; shapeID(ind) = [];
                n = length(vcID);

                % n = min( size( emap.grains(i).vertices,1), ...
                %     length(emap.grains(i).Orignialverticemembers) );
                % n = length( emap.grains(i).Orignialverticemembers );
                emap.grains(i).verticemembers = repmat( ...
                    ebsd.gbvc(0,0), n, 1 );
                emap.grains(i).Orignialverticemembers = repmat( ...
                    ebsd.gbvc(0,0), n, 1 );

                % ind = vcID > length(vcs);
                % vcID(ind) = []; shapeID(ind) = [];

                for j = 1:n
                    if shapeID(j) == 1
                        emap.grains(i).verticemembers(j) = vcs(vcID(j));
                        emap.grains(i).Orignialverticemembers(j) = ...
                            vcso(vcID(j));
                    else
                        v = ebsd.gbvc( ...
                            emap.grains(i).vertices(j,1), ...
                            emap.grains(i).vertices(j,2) );
                        v.isedge = true;
                        emap.grains(i).verticemembers(j) = v;
                        emap.grains(i).Orignialverticemembers(j) = v;
                        emap.verticesbank = vertcat(emap.verticesbank, v);
                    end
                end
            else
                DeactiveIndex(i) = true;
                % emap.grains(i).isactive = false;
            end
        end
        dlg.Value = i/length(allpoly);
        dlg.Message = ['Processing polygon ',num2str(i),' ...'];
        % waitbar(i/length(allpoly), h, 'Cropping the map...')
    end
    arrayfun(@(g)set(g,'isactive',false),emap.grains(DeactiveIndex));
    % waitbar(1,h, 'Cropped!');
%             emap.grains(vertcat(newpolys.NumRegions) == 0) = [];
    allvcs = vertcat(emap.verticesbank.vertice);
    vc2remove = allvcs(:,1) < emap.leftedge | allvcs(:,1) > emap.rightedge | allvcs(:,2) < emap.bottomedge | allvcs(:,2) > emap.topedge; 
    set(emap.verticesbank(vc2remove),'active', false);
    % delete(h)

    active = vertcat(emap.grains.isactive);
    activeInds = find(active);
    inactiveID = vertcat(emap.grains(~active).ID);
    dlg.Title = 'Updating the neighbours of remaining grains...';
    % h2 = waitbar(0, 'Updating the neighbours of remaining grains...');
    for i = 1:length(activeInds)
        nbsID = emap.grains(activeInds(i)).neighbours;
        nbsID(ismember(nbsID, inactiveID)) = [];
        emap.grains(activeInds(i)).neighbours = nbsID; 
        dlg.Value = i/length(activeInds);
        dlg.Message = ['Processing grain ',num2str(emap.grains(activeInds(i)).ID),' ...'];
        % waitbar(i/length(activeInds), h2, 'Updating the neighbours of remaining grains...')
    end
    % waitbar(1, h2, 'All done!')
    % delete(h2)
    emap.iscropped = true;

end
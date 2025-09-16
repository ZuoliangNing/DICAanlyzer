classdef map<matlab.mixin.Copyable%handle
    % Top-level class of the EBSD package
    % Main functions include:
    %   ** importebsdmap --- import the EBSD data from EBSD data files
    %   ** smoothgb --- smooth grain boundaries
    %   ** simplify --- repeatedly smooth grain boundaries and reduce the
    %   number of vertices on boundaries while trying to minimise the
    %   changes to the original grain shape
    %   *** PLOTTING function
    %   ** plotmap --- plot the polygons
    %   ** plotneighbours --- plot a selected grains and all its neighbours
    %   with grain number lables
    %   ** plotvertices --- plot all the vertices only 
    %   ** plotgb --- plot all the grain boundaries only
    
    properties
        grains = ebsd.grain.empty      % a vector of grain objects
        polygons    % an ebsd map including all the grain polygons
        gbs
        pixels
        width       % width of the map in um
        height      % height of the map in um
        mapsize     % size including width and height
        area        % total area of the map
        numgrains   % number of the grains
        diammean    % mean grain diameter
        diamstd     % standard deviation of the grain diameters
        diamste     % standard error of the grain diameters
        aream       % mean area of the grains
        areastd     % standard deviation of the grain area
        areaste     % standard deviation of the grain area
        verticesbank    % A bank of all the current gbvc vertices
        noholes = false;
        leftedge = 0
        rightedge
        topedge 
        bottomedge = 0
        iscropped = false
        stepsize
        Nvertices
        numXCells  % number of rows of the pixels
        numYCells  % number of columns of the pixels
        ebsdInfoTable  % the table containing EBSD parameters imported from CRC file
        warningDownSize = false;
        
        tolvc = 1e-6   % tolerance for vertice coincidence check
        tolOnBoundary   
        tolInBetween
        tolMissVertice
        tolDownSize
        
        CS1toCS0    % Transform requsition coordinate system (x-y-z) to the specimen requsition system (RD-TD-ND). 
                    % Euler angle in degree. These angles are exported from
                    % the Channel 5 project file
        % added by ME
        GBSmoothDegree
        FrontierDevRatio = 1
    end
    
    methods
        function emap = map( ebsdgrains, dlg, TextArea, ParaFlag )
            % Construction method
            if nargin > 0 
                emap.grains = ebsdgrains;
                emap.numgrains = numel(emap.grains);
                if ~emap.noholes
                    emap.removeholes( ...
                        true, dlg, TextArea, ParaFlag ); % *!*!*!*!*!
                end
                emap.gbs = ebsd.gb.empty;
                allvcs = uniquetol(vertcat(emap.grains.vertices), ...
                    emap.tolvc, 'ByRows', true, 'DataScale',1);
                vcIDs = 1:length(allvcs);
                emap.verticesbank = ...
                    ebsd.gbvc.batchCreate(allvcs(:,1),allvcs(:,2),vcIDs);
                Msg = 'Assign verticemembers to grains...';
                dlg.Title = Msg;
                dispText( TextArea, Msg )
                % h1 = waitbar(0, 'Assign verticemembers to grains...');
                for i = 1:length(emap.grains)
                    [~, inds_in_bank]  = ismembertol( ...
                        emap.grains(i).vertices, allvcs, emap.tolvc, ...
                        'ByRows', true, 'DataScale', 1 );
                    inds_in_bank = inds_in_bank(inds_in_bank>0);
                    emap.grains(i).verticemembers = emap.verticesbank(inds_in_bank);
                    set(emap.grains(i).verticemembers, 'ofgrains',  emap.grains(i).ID);
                    dlg.Value = i/length(emap.grains);
                    dlg.Message = ...
                        ['Assigning vertice members...',num2str(i), ...
                        ' grains out of ', num2str(length(emap.grains))];

                    % waitbar(i/length(emap.grains), h1, ['Assigning vertice members...',num2str(i), ' grains out of ', num2str(length(emap.grains))]);
                end
                dispText( TextArea, ...
                    ['Assigned vertices to ', num2str(emap.numgrains), ' grains.'] )
                % delete(h1);
                allpoly = vertcat(emap.grains.polygon);
                emap.polygons = allpoly;
                
                diam = vertcat(emap.grains.diam);
                area = vertcat(emap.grains.area);
                emap.numgrains = length(emap.grains);
                emap.diammean = mean(diam);
                emap.diamstd = std(diam);
                emap.diamste = std(diam,1)./sqrt(emap.numgrains);
                emap.aream = mean(area);
                emap.areastd = std(area);
                emap.areaste = std(area,1)./sqrt(emap.numgrains);
                emap.area = sum(area);
                dispText( TextArea, ...
                    'Checking the map bounding box...' )
                % combined = union(allpoly); %!!!!!!!!!!
                % [xlim, ylim] = combined.boundingbox;
                % if ~isempty(xlim) && ~isempty(ylim)
                %     emap.width = abs(xlim(2)-xlim(1));
                %     emap.height = abs(ylim(2) - ylim(1));
                % end
                VerticesCoords = vertcat(allpoly.Vertices);
                [ xmin, xmax ] = bounds( VerticesCoords(:,1) );
                [ ymin, ymax ] = bounds( VerticesCoords(:,2) );
                if ~isempty(xmin) && ~isempty(ymin)
                    emap.width = abs(xmax-xmin);
                    emap.height = abs(ymax - ymin);
                end
                dispText( TextArea, ...
                    'Map created from ebsd.grains!' )
            end
        end
        
        function c = duplicate(emap)
            c = copy(emap);
            c.grains = copy(emap.grains);
            c.gbs = copy(emap.gbs);
            c.verticesbank = copy(emap.verticesbank);
            for i = 1 : c.numgrains
                ind = [c.grains(i).verticemembers.ID];
                c.grains(i).verticemembers = ...
                    c.verticesbank( ind(ind>0) );
                c.grains(i).Orignialverticemembers = ...
                    copy(emap.grains(i).Orignialverticemembers);
            end
        end
        
        function v = get.Nvertices(emap)
            % Get the number of active vertices
            vcs = emap.verticesbank;       
            if ~isempty(vcs)
                vcs = vcs(vertcat(vcs.active));
                v = numel(vcs);
            else
                v = 0;
            end
        end
        
        function grains = get.grains(emap)
            % Get the number of active grains
            if ~isempty(emap.grains)
                if emap.iscropped
                    grains = emap.grains(vertcat(emap.grains.isactive));
                else
                    grains = emap.grains;
                end
            end
        end
 
        function value = get.numgrains(emap)
            if ~isempty(emap.grains)
                value = numel(emap.grains);
            end
        end
   
        function f = get.mapsize(emap)
            f = [emap.width, emap.height];
        end
        
        function f = get.polygons(emap)
            f = vertcat(emap.grains.polygon);
        end

        function value = ExtendFrontierInds( ...
                map, GrainSelection, siz, FrontierDev )

            grs = map.grains( GrainSelection );
            AllFrontierInds = unique( vertcat( grs.FrontierInds ) );
            [ row, col ] = ind2sub( siz, AllFrontierInds );

            val = cell( FrontierDev+1, 1 );
            val{1} = [ col, row ];

            for dev = 1 : FrontierDev
                
                dev2 = dev * map.FrontierDevRatio;
    
                val{dev+1} = ...
                    [ min(col+dev2,siz(2)),     row   ;
                      col,                      min(row+dev2,siz(1)) ; ...
                      max(col-dev2,1),          row   ; ...
                      col,                      max(row-dev2,1)  ];
            end

            val = cell2mat(val);
            row = val(:,2); col = val(:,1);

            % r = row > 0 & row <= siz(1) & col > 0 & col <= siz(2)-1 ;
            % row = row(r); col = col(r);

            value = sub2ind( siz, row, col );

        end
        EBSDData = cropmapEBSDData( map, EBSDData, GrainSelection, dlg )
        assignUnallocatedInds( map, X, Y, Size, UnallocatedInds, dlg )
        assignUnallocatedInds_Adjust( map, X, Y, UnallocatedInds, dlg )
    end
    
    methods(Static)
        [onInVq,locInVcs,members] = isonboundary(vcs,vq,tolerance)
        tf = isInBetween(pa, pb, pq, tolerance)
        [gone, verticesremained] = removeCollinear(vcs,tol)
        f = euler2matrix(phi1,phi,phi2,unit)
        [emap,grains] = importebsdmap(dotsfile, grainfile, stepsize)
        data = importCRCfile(filename)
    end 
end
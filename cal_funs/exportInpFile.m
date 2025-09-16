function exportInpFile( obj, EBSDDATA, NewFileName, ...
            Threshold, zVox, CoincideCoordsFlag, InpParameters, ...
            PlotFlag, UserMaterialFun, DICStage, dlg )


dlg.Message = 'Generating data ...';

% **** get EBSD DATA ****
EBSDData = getExportEBSDData( EBSDDATA, Threshold, true );

xVox = EBSDData.NCOLS;
yVox = EBSDData.NROWS;
% zVox
XSTEP = EBSDData.XSTEP;
YSTEP = EBSDData.YSTEP;
ZSTEP = mean( [ XSTEP, YSTEP ] );

% ElemCoords = [ Data.X, Data.Y, zeros( size(Data.X) ) ];
ElemCoords = [ ...
    repmat( [ EBSDData.X, EBSDData.Y ], zVox, 1 ), ...
    kron( ( 0:zVox-1 )' * ZSTEP, ones( size(EBSDData.X) ) ) ];

% phase = repmat( Data.Phase, zVox, 1 );
GrainID = repmat( EBSDData.GrainID, zVox, 1 );

[ ~, order ] = sortrows( ElemCoords, [1,3,2] );
% phase = phase( order );
GrainID = GrainID( order );

grains = EBSDDATA.Map.grains;
IdleID = setdiff( [grains.ID], unique( GrainID ) );
if ~isempty( IdleID )
    grains( arrayfun( @(id) find( id == [grains.ID] ), IdleID ) ) = [];
end

PhaseNumber = length( EBSDDATA.PhaseNames );
tempind = cell( 1, PhaseNumber );
for i = 1:PhaseNumber
    tempind{i} = find( [ grains.phase ] == i );
end

grains = copy( grains( cell2mat(tempind) ) );

allGrainIDs = [ grains.ID ];

% adjust (possibly) Euler Angles if 'CoincideCoordsFlag' is true
if CoincideCoordsFlag
    if ~isequal( EBSDDATA.SampleCoordOri.X, [1,0] ) || ...
            ~isequal( EBSDDATA.SampleCoordOri.Y, [0,-1] )
        if isequal( EBSDDATA.SampleCoordOri.X, [0,1] ) && ...
            isequal( EBSDDATA.SampleCoordOri.Y, [-1,0] )
            % OIM default
            % adjust method is the same as in 
            % 'EBSDPreprocess_Method_AssignColumn.m'
            % G_ima2sam -- Image Coord -> OIM Sample Coord
            G_ima2sam = [0,-1,0;-1,0,0;0,0,-1];
            for i = 1:length( grains )
                Angles = [ grains(i).meanphi1, ...
                    grains(i).meanPHI, grains(i).meanphi2 ];
                % R -- OIM Sample Coord -> Crystal Coord
                R = EulerAngle2TransferMatrix( Angles );
                % R_new -- Image Coord -> Crystal Coord
                R_new = R * G_ima2sam;
                [ grains(i).meanphi1, grains(i).meanPHI, ...
                    grains(i).meanphi2 ] = ...
                    TransferMatrix2EulerAngle( R_new );
            end
        else
            erorr( 'Update this script!' )
        end
    end
end

% generate nodes
boxmin = -0.5 * [ XSTEP, YSTEP, ZSTEP ];
boxmax = max( ElemCoords ) + 0.5 * [ XSTEP, YSTEP, ZSTEP ];

[ x, y, z ] = meshgrid( ...
    boxmin(1) : XSTEP : boxmax(1), ...
    boxmin(2) : YSTEP : boxmax(2), ...
    boxmin(3) : ZSTEP : boxmax(3) );
numNodes = numel(x);
coord = [ x(:), y(:), z(:) ];
nodes = [ ( 1:numNodes )', sortrows( coord, [1,3,2] ) ];
elem = zeros( size( ElemCoords, 1 ), 9 );
count = 1;

for ix = 1:xVox
    for iz = 1:zVox
        for iy = 1:yVox

            % get element label
            elem( count, 1 ) = count;

            % nodes on the plane with lower x
            elem( count, 2 ) = iy + ...
                ( iz - 1 ) * ( yVox + 1 ) + ...
                ( ix - 1 ) * ( yVox + 1 ) *( zVox + 1 );
            elem( count, 3 ) = elem( count, 2 ) + 1;
            elem( count, 4 ) = elem( count, 3 ) + yVox + 1;
            elem( count, 5 ) = elem( count, 2 ) + yVox + 1;

            % nodes on the plane with higher x
            elem( count, 6 ) = iy + ...
                ( iz - 1 ) * ( yVox + 1 ) + ...
                ix * ( yVox + 1 ) * ( zVox + 1 );
            elem( count, 7 ) = elem( count, 6 ) + 1;
            elem( count, 8 ) = elem( count, 7 ) + yVox + 1;
            elem( count, 9 ) = elem( count, 6) + yVox + 1;

            count = count+1;
        end
    end
end
% save( 'dic_test.mat', 'nodes', 'elem' )

% **** BC on Boundary Nodes ****
if ~isempty( DICStage )

    % **** get DIC DATA ****
    DICData = getExportDICData( obj.DIC.Data( DICStage ), ...
        obj.DIC.XData, obj.DIC.YData, ...
        obj.DIC.DataValueRange, Threshold, true );
    u = DICData.u;
    v = DICData.v;

    maxNodeX = max( nodes(:,2) ); maxNodeY = max( nodes(:,3) );
    minNodeX = min( nodes(:,2) ); minNodeY = min( nodes(:,3) );

    % EDGE 1 ~ 4
    % xVox - 1 / yVox - 1 / xVox - 1 / yVox - 1
    % element and node number on edges ( one Z layer )
    ElemNum = [ xVox-1, yVox-1, xVox-1, yVox-1 ];
    NodeNum = ElemNum + 1;
    % y=ymin / x=xmax / y=ymax / x=xmin
    xyind = [ 3, 2, 3, 2 ];
    edgeval = [ minNodeY, maxNodeX, maxNodeY, minNodeX ];
    siz = { [zVox+1,xVox+1], [yVox+1,zVox+1], ...
            [zVox+1,xVox+1], [yVox+1,zVox+1] };

    [ allNodeLabels, allNodeU, allNodeV ] = ...
        deal( nan( 2*( xVox + yVox ), zVox+1 ) );
    for i = 1:4
        ind = nodes( :, xyind(i) ) == edgeval(i); % x of nodes
        NodeLabels = nodes( ind, 1 );
        NodeLabels = reshape( NodeLabels, siz{i} );
        if size( NodeLabels, 2 ) ~= zVox+1
            NodeLabels = NodeLabels';
        end
        Nodeind = sum( NodeNum(1:i-1) ) + ( 1:NodeNum(i) );
        if i == 3 || i == 4
            allNodeLabels( Nodeind, : ) = NodeLabels( 2:end, : );
        else
            allNodeLabels( Nodeind, : ) = NodeLabels( 1:end-1, : );
        end
    
        ind = sum( ElemNum(1:i-1) ) + ( 1:ElemNum(i) );
        ElemU = u( ind ); ElemV = v( ind );
        
        allNodeU( Nodeind, : ) = repmat( ...
            Elem2NodeValues( ElemU ), 1, zVox+1 );
        allNodeV( Nodeind, : ) = repmat( ...
            Elem2NodeValues( ElemV ), 1, zVox+1 );
    end
    % allNodeLabels / allNodeU / allNodeV

    % ************ Visual ************
    if PlotFlag
        Layer = 1;
        Factor = 1;
    
        SelectedLabels = allNodeLabels( :, Layer );
        SelectedNodeU  = allNodeU( :, Layer );
        SelectedNodeV  = allNodeV( :, Layer );
        for i = 3:4
            Nodeind = sum( NodeNum(1:i-1) ) + ( 1:NodeNum(i) );
            SelectedLabels( Nodeind ) = flip( SelectedLabels( Nodeind ) );
            SelectedNodeU( Nodeind ) = flip( SelectedNodeU( Nodeind ) );
            SelectedNodeV( Nodeind ) = flip( SelectedNodeV( Nodeind ) );
        end
        [ axe, fig ] = getAxe( ...
            'XLabel', '$X, \mu m$', 'YLabel', '$Y, \mu m$');
        fig.Name = [ NewFileName,' - Deformed Shape' ];
        axe.YAxis.Direction = 'reverse'; axis equal;
        X = nodes( SelectedLabels, 2 );
        Y = nodes( SelectedLabels, 3 );
        p = patch( axe, X, Y, 'k' );
        p.FaceAlpha = 0.4;
        newX = X + SelectedNodeU * Factor;
        newY = Y + SelectedNodeV * Factor;
        p = patch( axe, newX, newY, 'r' );
        p.FaceAlpha = 0.4; p.EdgeColor = 'r';
        axe.XAxisLocation = 'origin';
        axe.YAxisLocation = 'origin';
        axe.Visible = 'off';
        axe.XAxis.Visible = 'on';
        axe.YAxis.Visible = 'on';

        
        temp1 = XSTEP * ( 0 : NodeNum(1)-1 );
        temp2 = YSTEP * ( 0 : NodeNum(2)-1 );
        X = temp1; x1 = X(end) + XSTEP;
        X = [ X, temp2 + x1 ]; x2 = X(end) + YSTEP;
        X = [ X, temp1 + x2 ]; x3 = X(end) + XSTEP;
        X = [ X, temp2 + x3 ];
        [ ymin, ymax ] = bounds( [ SelectedNodeU; SelectedNodeV ] );
        [ axe, fig ] = getAxe( fig, ...
            'XLabel', '$\rm Distance, \mu m$', ...
            'YLabel', '$\rm Displacement, \mu m$', ...
            'XLim', [0,X(end)], ...
            'YLim', 1.2*[ ymin, ymax ], ...
            'Width', 400, 'Height', 300 );
        fig.Name = [ NewFileName,' - Displacements' ];
        axe.YAxisLocation = 'origin';
        line1 = plotLine( axe, X, SelectedNodeU, nan, 'U', 1.5 );
        line2 = plotLine( axe, X, SelectedNodeV, nan, 'V', 1.5 );
        line( axe, x1*[1,1], axe.YLim, 'Color', 'k' )
        line( axe, x2*[1,1], axe.YLim, 'Color', 'k' )
        line( axe, x3*[1,1], axe.YLim, 'Color', 'k' )
        setLegend( axe, [ line1, line2 ], 'loc', 'northeast' )
    end
    % ************ END Visual ************

    allNodeLabels = allNodeLabels(:)';
    allNodeU = allNodeU(:)';
    allNodeV = allNodeV(:)';

end

%%
TimePeriod  = InpParameters{1};  % 1.0;
InitialInc  = InpParameters{2};  % 1e-5;
MinInc      = InpParameters{3};  % 1e-16;
MaxInc      = InpParameters{4};  % 0.01;
maxNumInc   = InpParameters{5};  % 1e7;
PartName    = InpParameters{6};  % SAMPLE

inpFileName = NewFileName;
% PartName = 'SAMPLE';

dlg.Message = ['Writing file ', inpFileName, ' ...'];

inpFile = fopen( inpFileName, 'wt' );

[ path, name ] = fileparts( NewFileName );
fprintf( inpFile, '*Heading\n' );
fprintf( inpFile, ['** Job name: ', name, ' Model name: ', name ] );


% ************** START PART **************
fprintf( inpFile, '**PARTS\n**\n' );
fprintf( inpFile, '*Part, name=%s\n', PartName );

% ------------ Nodes ------------
% write nodes
fprintf( inpFile, '*NODE, NSET=AllNodes\n' );
fprintf( inpFile, '%d,\t%e,\t%e, \t%e\n', nodes' );

% ------------ Elements ------------
% write elements
fprintf( inpFile, '*Element, type=C3D8, ELSET=AllElements\n' );
fprintf( inpFile, '%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d\n', elem' );

% ------------ Element Sets ------------
% create element sets containing grains
for id = allGrainIDs
    fprintf( inpFile, '\n*Elset, elset=Grain-%d\n', id );
    fprintf( inpFile, ...
        '%d, %d, %d, %d, %d, %d, %d, %d, %d\n', ...
        elem( GrainID == id )' );
end

% ------------ Sections ------------
% create sections for grains
for id = allGrainIDs
	fprintf( inpFile, ...
        '\n**Section: Section-%d\n*Solid Section, elset=Grain-%d, material=Grain-%d\n', ...
        id, id, id );
end

% ------------ Surface Node Sets ------------
% create node sets containing surface nodes for BCs
for ii = 1:3
    fprintf(  inpFile, '\n**\n*Nset, nset=NODES-%d\n', ii );
    fprintf( inpFile, ...
        '%d, %d, %d, %d, %d, %d, %d, %d, %d\n', ...
        nodes( nodes(:,ii+1) == boxmin(ii) )' );
    fprintf( inpFile, '\n**\n*Nset, nset=NODES+%d\n', ii );
    fprintf( inpFile, ...
        '%d, %d, %d, %d, %d, %d, %d, %d, %d\n', ...
        nodes( nodes(:,ii+1) == boxmax(ii) )' );
end
% ************** END PART **************



% ************** START ASSEMBLY **************
fprintf( inpFile, '\n*End Part\n**\n**\n** ASSEMBLY\n**\n*Assembly, name=Assembly\n**' );
fprintf( inpFile, '\n*Instance, name=%s, part=%s\n*End Instance\n**', PartName, PartName );

if ~isempty( DICStage )
    % create node sets for disp BCs
    for nodeid = allNodeLabels
        fprintf( inpFile, '\n*Nset, nset=NodeSet_%d, instance=%s', nodeid, PartName );
        fprintf( inpFile, '\n %d,', nodeid );
    end
end
% ************** END ASSEMBLY **************



% ************** START MATERIAL **************
fprintf( inpFile, '\n*End Assembly\n**\n** MATERIALS\n**' );

% ------------ User Material Constants ------------
UserMaterialFun( inpFile, grains )

% ************** END MATERIAL **************



% ************** START INITIAL BC **************
fprintf( inpFile, '\n**\n**BOUNDARY CONDITIONS\n**' );
fprintf( inpFile, '\n**Name: Zsymm Type: Symmetry/Antisymmetry/Encastre' );
fprintf( inpFile, '\n*Boundary\n%s.NODES+3, ZSYMM', PartName ); % on +Z surface
% ************** END INITIAL BC **************



% ************** START STEP **************

% ------------ Step Definition ------------
fprintf( inpFile, '\n**\n**STEP: Tension\n**' );
fprintf( inpFile, '\n*Step, name=Tension, nlgeom=YES, inc=%d, convert sdi=YES', maxNumInc );
fprintf( inpFile, '\n*Static\n%e, %e, %e, %e', ...
    InitialInc, TimePeriod, MinInc, MaxInc );

% ------------ BCs ------------
if ~isempty( DICStage )
    fprintf( inpFile, '\n**\n**BOUNDARY CONDITIONS\n**' );
    for i = 1 : length( allNodeLabels )
        nodeid = allNodeLabels(i);
        fprintf( inpFile, '\n** Name: BC_Node_%d Type: Displacement/Rotation', nodeid );
        fprintf( inpFile, '\n*Boundary\nNodeSet_%d, 1, 1, %f', nodeid, allNodeU(i) );
        fprintf( inpFile, '\nNodeSet_%d, 2, 2, %f', nodeid, allNodeV(i) );
    end
end

% ------------ OUTPUT REQUESTS ------------
fprintf( inpFile, '\n**\n** OUTPUT REQUESTS\n**' );
fprintf( inpFile, '\n*Restart, write, frequency=0\n**' );
fprintf( inpFile, '\n** FIELD OUTPUT: F-Output-1\n**' );
fprintf( inpFile, '\n*Output, field, number interval=50' );
fprintf( inpFile, '\n*Node Output\nCF, NT, RF, U' );
fprintf( inpFile, '\n*Element Output, directions=YES' );
fprintf( inpFile, '\nLE, MISES, PE, S, SDV, PEEQ' );
fprintf( inpFile, '\n*Output, history, frequency=0' );

% ************** END STEP **************


fprintf( inpFile, '\n*End Step' );

fclose(inpFile);

%%
FileName = fullfile( path, [ name, '-inp.log' ] );
temp = {};
for i = 1:length( EBSDDATA.PhaseNames )
    temp = [ temp, ...
        [ '  Phase ', num2str(i), ' - ', ...
          EBSDDATA.PhaseNames{i}, ': ', ...
          num2str( sum( [grains.phase] == i ) )] ]; 
end
Data = [ ...
    [ 'Element number: ', num2str( size( elem, 1 ) ) ], ...
    [ 'Nodes number: ', num2str( size( nodes, 1 ) ) ], ...
    [ 'Grain number: ', num2str( numel( allGrainIDs ) ) ], ...
    temp, ...
    [ 'XSTEP: ', num2str( XSTEP ) ], ...
    [ 'YSTEP: ', num2str( YSTEP ) ], ...
    [ 'ZSTEP: ', num2str( ZSTEP ) ], ...
    'Number of elements on each direction:', ...
    ['  X: ', num2str(xVox)], ...
    ['  Y: ', num2str(yVox)], ...
    ['  Z: ', num2str(zVox)] ];
writecell( Data', FileName, 'FileType', 'text' )



    function valNode = Elem2NodeValues( valElem )
        % valElem - N*1     - N:    element number
        % valNode - (N+1)*1 - N+1:  node number
        N = length( valElem );
        val = nan( N+1, 2 );
        val( 1:end-1, 1 ) = valElem;
        val( 2:end, 2 )   = valElem;
        valNode = sum( val, 2, "omitnan" ) ./ sum( ~isnan( val ), 2 );
    end


end
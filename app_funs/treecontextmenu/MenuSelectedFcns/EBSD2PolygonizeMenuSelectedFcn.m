function EBSD2PolygonizeMenuSelectedFcn( menu, ~, app )

ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

node = app.UIFigure.CurrentObject;
EBSDSerial = getEBSDIndex( node.NodeData.EBSDSerial, obj );

EBSDData = obj.EBSD.Data( EBSDSerial );

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

if EBSDData.Flag.Polygonized

    msg = DisplayNames.EBSD2PolygonizeMenuSelectedFcn_uiconfirm_msg;
    title = DisplayNames.cm_Polygonize;
    selection = uiconfirm( app.UIFigure, msg, title, ...
               'Options', { DisplayNames.uiopt_yes, DisplayNames.uiopt_no }, ...
               'DefaultOption', 2 );
    if strcmp( selection, DisplayNames.uiopt_no )
        return
    else
        obj.EBSD.Data( EBSDSerial ).Map = ebsd.map.empty;
    end

end

%%

% save('EBSDData.mat','EBSDData','-v7.3')
app.TextArea.Value = '';

% ***************
buffersize = 0.2;
missingVerticeTolerance = 0.2;

warning('off')
pixels = ebsd.pixcell;

%%%% *********** USE ONE ADDITIONAL DATA FOR Y ********* 24/12/24
YData = [ EBSDData.YData, EBSDData.YData(end) + EBSDData.dY ];

[ X, Y ] = meshgrid( EBSDData.XData, YData );
N = numel( X );

fun = @(val) reshape( val', numel(val), 1 );

pixels.index    = 0 : N-1;
pixels.x        = fun(X); % invX(:);
pixels.y        = fun(Y); % invY(:);
pixels.grainID  = fun(EBSDData.GrainID); % invGrainID(:);
pixels.XData = EBSDData.XData;
pixels.YData = YData;

AllGrainIDs = unique( pixels.grainID );
AllGrainIDs = AllGrainIDs( AllGrainIDs > 0 & ~isnan( AllGrainIDs ) );
% change ~= 0 to > 0 !! 

Ng = length( AllGrainIDs );


grains( Ng, 1 ) = ebsd.grain;

Angles = [ ...
    fun( EBSDData.EulerAngles(:,:,1) ), ...
    fun( EBSDData.EulerAngles(:,:,2) ), ...
    fun( EBSDData.EulerAngles(:,:,3) ) ];

if ~isempty( EBSDData.Phase )
    Phase = fun( EBSDData.Phase );
    PhaseFlag = true;
else; PhaseFlag = false;
end

tic
ParaFlag = app.Default.Options.ParallelComputing;
dlg = uiprogressdlg( app.UIFigure );

if ParaFlag
    dlg.Indeterminate = 'on';
    Msg = 'Starting parallel pool ...';
    dlg.Title = Msg;
    dlg.Message = Msg;
    gcp;
    dlg.Indeterminate = 'off';
end


dlg.Title = 'Creating grains ...';
edges_phi1 = 0:deg2rad(1):2*pi;
edges_PHI  = 0:deg2rad(1):pi;
edges_phi2 = 0:deg2rad(1):2*pi;
for i = 1:Ng

    ind = pixels.grainID == AllGrainIDs( i );

    grains(i).ID = AllGrainIDs( i );
    % MeanAngles = mean( Angles( ind, : ), 1 );

    % if AllGrainIDs( i ) ==210
    %     aaa=1;
    % end

    GrainAngles = Angles( ind, : );

    GrainAngles( GrainAngles<0 ) = GrainAngles( GrainAngles<0 ) + 2*pi;

    [ N, ~, ~, bin_phi1, binY_PHI ] = histcounts2( ...
        GrainAngles(:,1), GrainAngles(:,2), ...
        edges_phi1, edges_PHI );
    [ ~, MaxNind ] = max( N, [], 'all' );
    [ row, col ] = ind2sub( size(N), MaxNind );
    SelectedIndex = bin_phi1 == row & binY_PHI == col;
    GrainAngles = GrainAngles( SelectedIndex, : );
    [ N, ~, bin_phi2 ] = histcounts( GrainAngles(:,3), edges_phi2 );
    [ ~, MaxNind ] = max( N );
    SelectedIndex = bin_phi2 == MaxNind;
    GrainAngles = GrainAngles( SelectedIndex, : );
    MeanAngles = mean( GrainAngles, 1 );

    grains(i).meanphi1   = MeanAngles(1);
    grains(i).meanPHI    = MeanAngles(2);
    grains(i).meanphi2   = MeanAngles(3);

    if PhaseFlag
        grains(i).phase = mode( Phase(ind) );
    end

    dlg.Value = i/Ng;
    dlg.Message = ['Creating grain ',num2str(i)];

end


% --- 1 ---
grains.claimownership( ...
    pixels, app.Default.Options.MinimumGrainSize, ...
    dlg, app.TextArea )

grains = grains( vertcat( grains.isactive ) );

dispText( app.TextArea, ...
        [num2str(Ng), ' grains detected from original data'] );
dispText( app.TextArea, ...
        [num2str(length(grains)), ...
        ' grains retained based on minimum grain size of ', ...
        num2str(app.Default.Options.MinimumGrainSize)] );

parameters = struct( ...
    'xStepSize', EBSDData.dX, ...
    'yStepSize', EBSDData.dY, ...
    'numXCells', length( EBSDData.XData ), ...
    'numYCells', length( YData ) );
parameters.stepsize = parameters.xStepSize;


% --- 2 --- /para
grains = grains.polygonize( ...
    pixels, parameters, ...
    dlg, app.TextArea, ParaFlag );

map = ebsd.map( grains, dlg, app.TextArea, ParaFlag );

map.pixels = pixels;
map.stepsize = parameters.stepsize;
map.numXCells = parameters.numXCells;
map.CS1toCS0 = [0,0,0];

% --- 3 --- /para
map.grains.findneighbours( ...
    buffersize * parameters.stepsize, ...
    dlg, app.TextArea, ParaFlag );

% ind = find( arrayfun( @(g) isscalar(g.neighbours), map.grains ) );
% flag = false(1,map.numgrains);
% for i = ind'
%     g = map.grains(i);
%     gn = map.grains( [map.grains.ID] == g.neighbours );
%     gtemp = intersect( g.polygon, gn.polygon );
%     if gtemp.NumRegions>0
%         flag(i) = true;
%         gn.neighbours = setdiff( gn.neighbours, g.ID );
%     end
% end
% map.grains(flag) = [];

% --- 4 ---
map.findgbs( dlg, app.TextArea )
% --- 5 ---
map.addMissingVertices( ...
    parameters.stepsize * missingVerticeTolerance, ...
    dlg, app.TextArea );
% --- 6 ---
map.findEdgeVertices
% --- 7 ---
% added by me
map.findIndex( dlg, app.TextArea, ParaFlag )

% --- 8 ---
map.GBSmoothDegree = app.Default.Options.GBSmoothDegree;
for i = 1:map.numgrains
    map.grains(i).Orignialverticemembers = ...
        map.grains(i).verticemembers.copy;
end
map.grains.smoothgb( ...
    {map.GBSmoothDegree}, ...
    dlg, app.TextArea )

% grain area
TotalArea = max( EBSDData.YData ) * max( EBSDData.XData );
N = EBSDData.DataSize(3);
for i = 1:map.numgrains
    map.grains(i).area = TotalArea * ...
        length( map.grains(i).IntrinsicInds ) / N; % um^2
    map.grains(i).diam = sqrt( 4 * map.grains(i).area / pi );
end
map.aream = mean( [map.grains.area] );
map.diammean = mean( [map.grains.diam] );

% **************** for original data ****************
% element number in 'map.pixels.YData' is 1 more greater than
% 'EBSDData.YData'
% make them eqaual now
map.pixels.YData = YData(1:end-1);

elapsedTime = toc;

if ParaFlag
    dlg.Indeterminate = 'on';
    Msg = 'Closing parallel pool ...';
    dlg.Title = Msg;
    dlg.Message = Msg;
    delete( gcp )
    dlg.Indeterminate = 'off';
end

%% Ending
warning('on')

EBSDData.Map = map;
EBSDData.Flag.Polygonized = true;
EBSDData.PolyInfo = struct( ...
    'Time', elapsedTime, ...
    'OriginalGrainNumber', Ng, ...
    'GrainNumber', map.numgrains, ...
    'MinimumGrainSize', app.Default.Options.MinimumGrainSize, ...
    'MeanGrainArea', map.aream, ...
    'MeanGrainDiameter', map.diammean );
EBSDData.PolyInfo.Text = app.TextArea.Value;


% ***** ADDITIONAL PROPERTIES *****
EBSDData.GrainGroup = struct( ...
    'Name','All', ...
    'Index', 1:map.numgrains, ...
    'Serial', 0);

EBSDData.GrainGroupSelection = 0;
EBSDData.GrainSelection = 1 : map.numgrains;
EBSDData.FrontierDev = 0;
S = whos('EBSDData');
EBSDData.MemorySize = S.bytes * 1e-6;

obj.EBSD.Data( EBSDSerial ) = EBSDData;
app.Projects( ProjectIndex ) = obj;

% TreeSelectionChangedFcn( app.Tree, [], app )

function obj = AdjustEBSD( obj, EBSDData, PointCoords, ...
                           dlg, TextArea )

%   PointCoords -- ( PointSetNum )( x / y )( DIC / EBSD )
%               -- x,y in Pixels
%   Variables   -- app.ConstantValues.EBSDVariables;


% N = size( PointCoords, 1 );

%   fixedPoints -- [ n, 2 ] ( PointSetNum )( x / y )
%               -- from DIC
fixedPoints  = PointCoords( :, :, 1 );

%   movingPoints -- [ n, 2 ] ( PointSetNum )( x / y )
%                -- from EBSD
movingPoints = PointCoords( :, :, 2 );


tformType = 'affine';

% if N < 4 % 6
%     tformType = 'affine';
% else
%     % tformType = 'pwl'; % pwl / lwm
%     tformType = 'polynomial'; % polynomial / projective
%     if N < 10;      Degree = 2;
%     elseif N < 15;  Degree = 3;
%     else;           Degree = 4;
%     end
% end

% ****** PERFORM Transormation *******
tform = fitgeotform2d( movingPoints, fixedPoints, tformType );
tform2 = fitgeotform2d( fixedPoints, movingPoints, tformType );

% switch tformType
%     case 'affine'
%         tform = fitgeotform2d( movingPoints, fixedPoints, tformType );
%         tform2 = fitgeotform2d( fixedPoints, movingPoints, tformType );
%     case 'polynomial'
%         tform = fitgeotform2d( ...
%             movingPoints, fixedPoints, tformType, Degree );
%         tform2 = fitgeotform2d( ...
%             fixedPoints, movingPoints, tformType, Degree );
% end


% ****** GENERATE New EBSD Data ******
dlg.Title = 'Generating EBSD Data ...';

obj.EBSDSerial = max([obj.EBSD.Data.Serial]) + 1;
EBSDData.Serial = obj.EBSDSerial;

EBSDData.DisplayName = [ 'Data', num2str( EBSDData.Serial ) ];
SIZE_EBSD_0 = EBSDData.DataSize;

% New Data is mapped into the range of DIC Data
SIZE_DIC = obj.DIC.DataSize; % size( obj.DIC.Data(1).exx );

% use NaN on empty area
funNum = @( val ) imwarp( ...
    val, tform, ...
    OutputView = imref2d( SIZE_DIC ), ...
    FillValues = nan ) ;

funCat = @( val ) double( imwarp( ...
    categorical( val ), tform, ... 
    OutputView = imref2d( SIZE_DIC ) ) ) ;

Variables = {'EulerAngles','IPF','IQ','CI','GrainID','EdgeIndex','Phase'};

for i = 1:length( Variables )

    VariableName = Variables{i};
    dlg.Message = ['Processing ',VariableName,' data ...'];

    if ~isempty( EBSDData.(VariableName) )

        % *** PERFORM Translation ***
        switch VariableName
            case 'IPF'
                for j = 1:3
                    EBSDData.(VariableName){j} = ...
                        funNum( EBSDData.(VariableName){j} );
                end
            case { 'GrainID', 'EdgeIndex', 'Phase' }
                EBSDData.(VariableName) = ...
                    funCat( categorical( EBSDData.(VariableName) ) );
            otherwise
                EBSDData.(VariableName) = funNum( EBSDData.(VariableName) );
        end
    end
end

EBSDData.AlphaData = ~isnan( EBSDData.IPF{1}(:,:,1) );

% ****************** Adjust EBSD X/YData ******************
% SIZE_EBSD = size( EBSDData.IPF{1}, 1, 2 );
% Calculate Length Ratio
% function [ rx, ry ] = tempFun( tform, r0, v )
% 
%     temp = transformPointsInverse( tform, v ) ...
%         - transformPointsInverse( tform, [0,0] );
%     theta = atan2( temp(2), temp(1) );
%     rx = r0 * cos( theta ) / temp(1);
%     ry = r0 * sin( theta ) / temp(2);
% end
% 
% % USE an Uniform Tranformation
% tformTemp = fitgeotform2d( ...
%             fixedPoints, movingPoints, 'affine' );
% [ dX(1), dY(1) ] = tempFun( tformTemp, ...
%     EBSDData.dX, [ 1, 0 ] ); % um / pixel
% [ dX(2), dY(2) ] = tempFun( tformTemp, ...
%     EBSDData.dY, [ 0, 1 ] );
% 
% dX_0 = EBSDData.dX; dY_0 = EBSDData.dY;
% EBSDData.dX = round( mean(dX),3 );
% EBSDData.dY = round( mean(dY),3 );
% EBSDData.DataSize = [ SIZE_EBSD, prod(SIZE_EBSD) ];
% 
% pos_0_Zero = [ EBSDData.XData(1), EBSDData.YData(1) ];
% pos_Zero = transformPointsInverse( tform2, [1,1] ) ...
%     .* [ EBSDData.dX, EBSDData.dY ]; 
% EBSDData.XData = EBSDData.XData(1) - pos_Zero(1) ...
%     + ( 0 : SIZE_EBSD(2)-1 ) * EBSDData.dX;
% EBSDData.YData = EBSDData.YData(1) - pos_Zero(2) ...
%     + ( 0 : SIZE_EBSD(1)-1 ) * EBSDData.dY;
% pos_Zero_new = [ EBSDData.XData(1), EBSDData.YData(1) ];

% ****************** Adjust DIC ******************
% adjust DIC X/Y Data
% obj.DIC.XData = EBSDData.XData;
% obj.DIC.YData = EBSDData.YData;


% ****************** Adjust EBSD X/YData ******************
dX_0 = EBSDData.dX; dY_0 = EBSDData.dY;
pos_0_Zero = [ EBSDData.XData(1), EBSDData.YData(1) ];

EBSDData.XData = obj.DIC.XData;
EBSDData.YData = obj.DIC.YData;
EBSDData.dX = round( mean( diff( EBSDData.XData ) ), 6 );
EBSDData.dY = round( mean( diff( EBSDData.YData ) ), 6 );
SIZE_EBSD = size( EBSDData.IPF{1}, 1, 2 );
EBSDData.DataSize = [ SIZE_EBSD, prod(SIZE_EBSD) ];

pos_Zero_new = [ EBSDData.XData(1), EBSDData.YData(1) ];

% ****************** Transform map ******************
if EBSDData.Flag.Polygonized

    dlg.Title = 'Transforming polygonization result ...';

    Ratio_0 = [ dX_0, dY_0 ];
    Ratio = [ EBSDData.dX, EBSDData.dY ];
    
    %       pos_0      (untransformed, in length)  (map.verticesbank.vertice)
    %    -> pos_p_0    (untransformed, in pixel)   (./ Ratio_0)
    %    -> pos_p      (transformed, in pixel)     (transformPointsForward)
    %    -> pos        (transformed, in length)    (.* Ratio)
    
    fun = @( pos_0 ) transformPointsInverse( ...
                        tform2, ...
                        ( pos_0 - pos_0_Zero ) ./ Ratio_0 + [1,1] ) ...
                        .* Ratio + pos_Zero_new ;

    EBSDData.Map = EBSDData.Map.duplicate;
    map = EBSDData.Map;
    
    %  ---- transform active vertices
    dlg.Message = 'Transforming vertices ...';

    NewPos = fun( vertcat( map.verticesbank.vertice ) );
    n = length( map.verticesbank );
    arrayfun( @(i) set( map.verticesbank(i), 'x', NewPos(i,1) ), 1:n )
    arrayfun( @(i) set( map.verticesbank(i), 'y', NewPos(i,1) ), 1:n )

    for i = 1:map.numgrains

        NewPos = fun( vertcat( ...
            map.grains(i).Orignialverticemembers.vertice ) );
        n = length( map.grains(i).Orignialverticemembers );
        arrayfun( @(j) ...
            set( map.grains(i).Orignialverticemembers(j), ...
            'x', NewPos(j,1) ), 1:n )
        arrayfun( @(j) ...
            set( map.grains(i).Orignialverticemembers(j), ...
            'y', NewPos(j,2) ), 1:n )
    end

    arrayfun( @(g) g.set( 'vertices', fun( g.vertices ) ), map.grains )


    %  ---- transform grain index
    SIZE0 = [ length(map.pixels.YData), ...
              length(map.pixels.XData) ];
    % 'InteriorInds', etc. have been modified to 
    %  correspond to original EBSD size and shape!
    SIZE = EBSDData.DataSize(1:2);
    funNum = @( val ) find( imwarp( val, tform, ...
            OutputView = imref2d( SIZE ) ) ) ;

    map.FrontierDevRatio = round( min( SIZE ./ SIZE0 ) ); % USE MIN!
    
    dlg.Indeterminate = 'off';


    %%%%%************** CROP **************%%%%%
    EBSDData = map.cropmapEBSDData( EBSDData, [], dlg );


    %  ---- transform pixel index

    dlg.Indeterminate = 'on';
    
    allIDs = [map.grains.ID];
    Names = { 'IntrinsicInds', 'InteriorInds' };
    % axe =  []; ind = [];
    for i = 1:2

        dlg.Message = [ 'Transforming ', Names{i}, ' ...' ];

        Data = nan( SIZE0 );
        val = cell2mat( arrayfun( @(g) ...
            [ g.(Names{i}), ...
              g.ID * ones(size(g.(Names{i}))) ], ...
            map.grains, 'UniformOutput', false ));
        % val:  Inds / Grain ID
        Data( val(:,1) ) = val(:,2);

        newDataCat = imwarp( ...
            categorical( Data ), tform, ... 
            OutputView = imref2d( SIZE ) );
        ActiveGrainID = cellfun( @str2double, categories( newDataCat ) );
        newDataDouble = double( newDataCat );
        
        ind = find( ~isnan( newDataDouble ) );
        newval = [ ind, ActiveGrainID( newDataDouble(ind) ) ];

        IdleGrainID = setdiff( [map.grains.ID], ActiveGrainID );

        if i == 1 && ~all( EBSDData.AlphaData, 'all' )
            newval = newval( ...
                ismember( newval(:,1), find( EBSDData.AlphaData ) ), : );
        end

        arrayfun( @(id) set( map.grains( id == allIDs ), ...
            Names{i}, ...
            newval( newval(:,2) == id, 1 ) ), ...
            ActiveGrainID )
        arrayfun( @(id) set( map.grains( id == allIDs ), ...
            Names{i}, [] ), IdleGrainID )
    end
    % -------- FrontierInds --------
    dlg.Message = 'Transforming FrontierInds ...' ;
    
    IDsLeft = allIDs; IND = {};
    while ~isempty( IDsLeft )
        ind = []; Sequence = IDsLeft;
        while ~isempty( Sequence )
            ind = [ ind, Sequence(1) ];
            Sequence = setdiff( ...
                Sequence(2:end), ...
                map.grains( Sequence(1) == allIDs ).neighbours );
        end
        IND = [ IND, ind ];
        IDsLeft = setdiff( IDsLeft, ind );
    end
    % change to Index from ID
    IND = cellfun( @(val) arrayfun( @(id) find( id == allIDs ), val ), ...
        IND, 'UniformOutput', false );

    for i = 1:length( IND )

        Grains = map.grains( IND{i} );
        Data = nan( SIZE0 );
        val = cell2mat( arrayfun( @(g) ...
            [ g.FrontierInds, ...
              g.ID * ones(size( g.FrontierInds )) ], ...
            Grains, 'UniformOutput', false ));
        % val:  Inds / Grain ID
        Data( val(:,1) ) = val(:,2);

        newDataCat = imwarp( ...
            categorical( Data ), tform, ... 
            OutputView = imref2d( SIZE ) );
        ActiveGrainID = cellfun( @str2double, categories( newDataCat ) );
        newDataDouble = double( newDataCat );
        
        ind = find( ~isnan( newDataDouble ) );
        newval = [ ind, ActiveGrainID( newDataDouble(ind) ) ];

        IdleGrainID = setdiff( [Grains.ID], ActiveGrainID );

        arrayfun( @(id) set( map.grains( id == allIDs ), ...
            'FrontierInds', ...
            newval( newval(:,2) == id, 1 ) ), ...
            ActiveGrainID )
        arrayfun( @(id) set( map.grains( id == allIDs ), ...
            'FrontierInds', [] ), IdleGrainID )

    end

    % OLD METHODS
    % arrayfun( @(g) set( g, ...
    %     'FrontierInds', funNum( tempfun( g.FrontierInds, SIZE0 ) ) ), ...
    %     map.grains );

    % for i = 1:map.numgrains
    %     g = map.grains(i);
    %     % dlg.Value = i / map.numgrains;
    %     % dlg.Message = [ 'Transforming pixel index of grain ', ...
    %     %     num2str( g.ID ), ' ...' ];
    %         val = false( SIZE0 );
    %         val( g.FrontierInds ) = true;
    %         g.FrontierInds = funNum(val);
    % end


    %  ---- assign unallocated
    dlg.Indeterminate = 'off';

    allIntrinsicInds = unique(vertcat( map.grains.IntrinsicInds ));
    allHasvalueInds = find( EBSDData.AlphaData );
    if numel( allIntrinsicInds ) < numel( allHasvalueInds )
        UnallocatedInds = setdiff( ...
             allHasvalueInds, allIntrinsicInds );
        [X,Y] = meshgrid( EBSDData.XData, EBSDData.YData );
        X = X(:); Y = Y(:);
        assignUnallocatedInds_Adjust( map, X, Y, ...
            UnallocatedInds, dlg )
    end

    % smooth GBs
    map.grains.smoothgb( {map.GBSmoothDegree}, dlg, TextArea )

end

% Ending

EBSDData.Flag.Adjusted = true;

EBSDData.Adjust.PointCoords = PointCoords;
EBSDData.Adjust.tformType = tformType;
EBSDData.Adjust.tform = tform;
EBSDData.Adjust.tform2 = tform2;
% EBSDData.Adjust.R = R;
EBSDData.Adjust.OriginalSize = SIZE_EBSD_0;
S = whos('EBSDData');
EBSDData.MemorySize = S.bytes * 1e-6;

% save('EBSDData.mat','EBSDData','-v7.3')

obj.EBSD.Data = [ obj.EBSD.Data, EBSDData ];


end


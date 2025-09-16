function [ value, AlphaData, ind1, ind2, DICFlag, VariableName ] = ...
    getEBSDCData( VariableName, Threshold, EBSDData, obj, app )

DICFlag = false;
if EBSDData.Flag.Polygonized && EBSDData.Flag.Adjusted...
        && app.Default.Options.GrainsTab.DICFlag

    DICFlag = true;
    
    VariableName = EBSDData.DICSelection;
    if isfield( obj.DIC.DataValueRange, EBSDData.DICSelection )
        value = restoreData( ...
            obj.DIC.Data( obj.StageSelection ).( EBSDData.DICSelection ), ...
            obj.DIC.DataValueRange.( EBSDData.DICSelection ) );

    else
        value = obj.DIC.Data( obj.StageSelection ).( EBSDData.DICSelection );
    end
    dim = 1;
else

    if strcmp( VariableName, 'IPF' )
        value = EBSDData.IPF{ app.EBSDDropDown.ValueIndex };
        dim = 3;
    else
        value = EBSDData.( VariableName );
        dim = 1;
    end

end

ind1 = []; ind2 = [];
Flag = false; % flag for simplify data
SIZE = EBSDData.DataSize(1:2);
if any( SIZE > Threshold )

    Span = round( max( SIZE ) / Threshold );

    ind1 = 1 : Span : SIZE(1);
    ind2 = 1 : Span : SIZE(2);

    Size = [ length(ind1), length(ind2) ];
    N = prod(Size);

    value = value( ind1, ind2, : );

    AlphaData = EBSDData.AlphaData( ind1, ind2 ) ;

    Flag = true;

else

    AlphaData = EBSDData.AlphaData ;

    Size = EBSDData.DataSize(1:2);
    N    = EBSDData.DataSize(3);

end


if EBSDData.Flag.Polygonized

    map = EBSDData.Map;
    par = app.Default.Options.GrainsTab;

    GrainSelection = EBSDData.GrainSelection;
    

    if app.Default.Options.GrainsTab.Neighbours
        fun = @(i) find( [map.grains.ID] == i );
        GrainSelection = unique( [ GrainSelection, cell2mat(arrayfun( fun, ...
            unique( vertcat(map.grains( GrainSelection ).neighbours) ), ...
            'UniformOutput', false ))' ]);
    end

    if length( GrainSelection ) == map.numgrains ...
            && ( ( par.InteriorFlag && par.FrontierFlag ) )
        % par.IntrinsicFlag || 
        return
    end
    
    val = reshape( value, N, dim );

    adata = zeros( [ N, 1 ] ); % redefine AlphaData!

    fun = @( valname ) cell2mat( arrayfun( ...
            @(g) g.(valname), ...
            map.grains( GrainSelection ), ...
            'UniformOutput', false ) );
    Ind = nan(0,2);

    if par.FrontierFlag

        IndFrontier = ExtendFrontierInds( ...
                    map, GrainSelection, ...
                    EBSDData.DataSize(1:2), EBSDData.FrontierDev );

        % IndFrontier = cell2mat( arrayfun( ...
        %         @(g) ExtendFrontierInds( ...
        %             g, EBSDData.DataSize(1:2), EBSDData.FrontierDev ), ....
        %         map.grains( GrainSelection ), ...
        %         'UniformOutput', false ) );
    end

    if par.IntrinsicFlag
        Ind = fun( 'IntrinsicInds' );
    else
        if par.InteriorFlag && par.FrontierFlag
            % [ map.grains.FrontierDev ] = deal( EBSDData.FrontierDev );
            Ind = [ fun( 'InteriorInds' ); IndFrontier ];
        elseif par.InteriorFlag
            Ind = fun( 'InteriorInds' );
        elseif par.FrontierFlag
            % [ map.grains.FrontierDev ] = deal( EBSDData.FrontierDev );
            Ind = IndFrontier;
        end
    end
    if isempty( Ind ); Ind = nan(0,2); end

    % 'Ind' is now for original size
    if Flag

        tempval = false( EBSDData.DataSize(1:2) );
        tempval( Ind ) = true;
        tempval = tempval( ind1, ind2 );
        Ind = tempval(:);

    end

    val( ~Ind, : ) = nan;

    adata( Ind ) = 1; % 0.6;

    value = reshape( val, Size(1), Size(2), dim );
    AlphaData = AlphaData & reshape( adata, Size(1), Size(2) );


end

% if DICFlag
% 
    % [ minval, maxval ] = getCLim( ...
    %         value, ...
    %         app.Default.Options.DICCLimCoeff );
    % 
    % n = size( app.UIAxesImages.Colormap, 1 );
    % value( value>maxval ) = maxval;
    % value( value<minval ) = minval;
    % value = ind2rgb( ...
    %     round( rescale( value, 1, n ) ), app.UIAxesImages.Colormap );


    % reshape( value, [N,3] );
% 
% end


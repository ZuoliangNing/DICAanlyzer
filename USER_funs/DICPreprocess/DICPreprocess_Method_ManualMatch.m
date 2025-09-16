function DIC = DICPreprocess_Method_ManualMatch( DIC, dlg )
%
% size and stage number of each data should be the same
%
% Parameters including:
%   Bounding / MaxAbsStrain / MaxSize
Bounding = DIC.PreprocessPars.Bounding;
MaxAbsStrain = DIC.PreprocessPars.MaxAbsStrain;
MaxSize = DIC.PreprocessPars.MaxSize;

pos = DIC.FilePosition;

SIZE = [];

dlgLoadDataPercentage = 0.9 ;

FileNames = DIC.FileNames;
if ~iscell( DIC.FileNames )
    FileNames = { FileNames };
end


for i = 1 : DIC.FileNumber

    dlg.Message = [ FileNames{i}, '...' ];
    dlg.Value = i / DIC.FileNumber * dlgLoadDataPercentage ;

    Data = getDICFileData( FileNames{i}, DIC.FileFormat );

    if DIC.StageNumber == 0
        DIC.StageNumber = Data.StageNumber;
    end
    
    if isempty( SIZE )
        if ~all( Bounding(1:2) )
            SIZE(1) = size( Data(1).u, 1 );
            Bounding(1:2) = [ 1, SIZE(1) ];
        else
            SIZE(1) = Bounding(2) - Bounding(1) + 1 ;
        end
        if ~all( Bounding(3:4) )
            SIZE(2) = size( Data(1).u, 2 );
            Bounding(3:4) = [ 1, SIZE(2) ];
        else
            SIZE(2) = Bounding(4) - Bounding(3) + 1 ;
        end
        ind = { Bounding(1) : Bounding(2), ...
                Bounding(3) : Bounding(4) };
    else

    end

    
    for n = 1 : DIC.StageNumber

        % pos(i,1) - row / pos(i,2) - column
        ir = ( pos(i,1) - 1 ) * SIZE(1) + ( 1:SIZE(1) ) ;
        ic = ( pos(i,2) - 1 ) * SIZE(2) + ( 1:SIZE(2) ) ;

        for VariableName = { 'u', 'v' }
            name = VariableName{1};
            DIC.Data(n).( name )( ir, ic ) = simplifyData( ...
                Data(n).( name )( ind{1}, ind{2} ), ...
                DIC.DataValueRange.( name ) );
        end

        % modify 'u'
        if pos(i,2) > 1 % column
            data = diff( DIC.Data(n).u(ir,ic(1)-1:ic(1)), 1, 2 );
            DIC.Data(n).u( ir, ic ) = DIC.Data(n).u( ir, ic ) ...
                - mode( data );
            % if n==4
            %     axe = getAxe;
            %     data = restoreData( DIC.Data(n).u(ir,ic), DIC.DataValueRange.u );
            %     plot(axe,data(:,1))
            %     plot(DIC.Data(n).u(ir,ic(1)))
            %     figure
            %     image(data,'CDataMapping','scaled')
            %     data = Data(n).u(ind{1}, ind{2});
            %     plot(axe,data(:,1))
            %     figure
            %     image(data,'CDataMapping','scaled')
            %     figure
            %     image(DIC.Data(n).u,'CDataMapping','scaled')
            % 
            % end
            
            
            % figure
            % plot(DIC.Data(n).u(ir,ic(1)-1))
            % hold on
            % plot(DIC.Data(n).u(ir,ic(1)))
            % figure
            % image(DIC.Data(n).u(ir,ic),'CDataMapping','scaled')

        end
        % modify 'v'
        if pos(i,1) > 1 % row
            DIC.Data(n).v( ir, ic ) = DIC.Data(n).v( ir, ic ) ...
                - mode( diff( DIC.Data(n).v(ir(1)-1:ir(1),ic) ) );
            % figure
            % image(DIC.Data(n).v,'CDataMapping','scaled')
        end


        % for strain values, Limit the range of values
        for VariableName = { 'exx', 'exy', 'eyy' } % , 'k'
            name = VariableName{1};
            DIC.Data(n).( name )( ir, ic ) = simplifyData( ...
                tempfun( Data(n).( name )( ind{1}, ind{2} ) ), ...
                DIC.DataValueRange.( name ) );
        end

        % a user defined variable - 'k'
        % ALL variables should be of DOUBLE type 
        %   (after possible restorage)
        DIC.Data(n).k( ir, ic ) = ...
            double( DIC.Data(n).exx( ir, ic ) > 0 ) ;

    end

    clear('Data')

end

% Simplify data 
SIZE = size( DIC.Data(1).exx );

if any ( SIZE > MaxSize )
    Span = round( max( SIZE ) / MaxSize );
    ind1 = 1 : Span : SIZE(1);
    ind2 = 1 : Span : SIZE(2);

    Names = fieldnames( DIC.Data );
    for i = 1 : length( Names )
        for n = 1 : DIC.StageNumber
            DIC.Data(n).( Names{i} ) = ...
                DIC.Data(n).( Names{i} )( ind1, ind2 );
        end
    end
end


    function val = tempfun( val )

        absval = abs( val );
        tempind = absval > MaxAbsStrain;
        val( tempind ) = val( tempind )./ absval( tempind );

    end


end
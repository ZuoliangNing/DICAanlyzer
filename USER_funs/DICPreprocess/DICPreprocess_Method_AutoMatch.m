function varargout = DICPreprocess_Method_AutoMatch( DIC, dlg )
%
% size and stage number of each data should be the same
%
% Parameters including:
%   Bounding / MaxAbsStrain / MaxSize / ScaleFactor

% Bounding = DIC.PreprocessPars.Bounding;

MaxAbsStrain = DIC.PreprocessPars.MaxAbsStrain;
MaxSize = DIC.PreprocessPars.MaxSize;
CoordScaleFactor = DIC.PreprocessPars.CoordScaleFactor;
DispScaleFactor = DIC.PreprocessPars.DispScaleFactor;

pos = DIC.FilePosition;

SIZE = [];

dlgLoadDataPercentage = 0.9 ;

FileNames = DIC.FileNames;
if ~iscell( DIC.FileNames )
    FileNames = { FileNames };
end

Bounding = [];
for i = 1 : DIC.FileNumber

    dlg.Message = [ FileNames{i}, '...' ];
    dlg.Value = i / DIC.FileNumber * dlgLoadDataPercentage ;

    Data = getDICFileData( FileNames{i}, DIC.FileFormat );

    if isempty( Bounding )

        val = Data(1).u;
        ind = ~val;

        temp = ~all( ind, 2 );
        Bounding(1:2) = [ find( temp, 1 ), find( temp, 1, 'last' ) ];

        temp = ~all( ind );
        Bounding(3:4) = [ find( temp, 1 ), find( temp, 1, 'last' ) ];

        SIZE(1) = Bounding(2) - Bounding(1) + 1 ;
        SIZE(2) = Bounding(4) - Bounding(3) + 1 ;
        ind = { Bounding(1) : Bounding(2), ...
                Bounding(3) : Bounding(4) };

    end

    if DIC.StageNumber == 0
        DIC.StageNumber = Data.StageNumber;
    end
    
    for n = 1 : DIC.StageNumber

        % pos(i,1) - row / pos(i,2) - column
        ir = ( pos(i,1) - 1 ) * SIZE(1) + ( 1:SIZE(1) ) ;
        ic = ( pos(i,2) - 1 ) * SIZE(2) + ( 1:SIZE(2) ) ;

        for VariableName = { 'u', 'v' } % not using int now
            name = VariableName{1};
            DIC.Data(n).( name )( ir, ic ) = ...
                Data(n).( name )( ind{1}, ind{2} );
        end

        % modify 'u'
        if pos(i,2) > 1 % column
            data = diff( DIC.Data(n).u(ir,ic(1)-1:ic(1)), 1, 2 );
            dev = mode( round( data, 2 ) );
            DIC.Data(n).u( ir, ic ) = DIC.Data(n).u( ir, ic ) ...
                - dev;
        end
        % modify 'v'
        if pos(i,1) > 1 % row
            data = diff( DIC.Data(n).v(ir(1)-1:ir(1),ic) );
            dev = mode( round( data, 2 ) );
            DIC.Data(n).v( ir, ic ) = DIC.Data(n).v( ir, ic ) ...
                - dev;
            
        end

        % for strain values, Limit the range of values
        for VariableName = { 'exx', 'exy', 'eyy' } % , 'k'
            name = VariableName{1};
            DIC.Data(n).( name )( ir, ic ) = simplifyData( ...
                tempfun( Data(n).( name )( ind{1}, ind{2} ) ), ...
                DIC.DataValueRange.( name ) );
        end

    end

    clear('Data')

end


% Adjust DISP ------- DispScaleFactor
%             ------- set disp at origin to 0
DIC.DataValueRange.u = DIC.DataValueRange.u * DispScaleFactor ;
DIC.DataValueRange.v = DIC.DataValueRange.v * DispScaleFactor ;

for i = 1 : DIC.StageNumber
    DIC.Data(i).u = simplifyData( ...
        DIC.Data(i).u * DispScaleFactor, ...
        DIC.DataValueRange.u );
    DIC.Data(i).v = simplifyData( ...
        DIC.Data(i).v * DispScaleFactor, ...
        DIC.DataValueRange.v );
    DIC.Data(i).u = DIC.Data(i).u - DIC.Data(i).u(1,1);
    DIC.Data(i).v = DIC.Data(i).v - DIC.Data(i).v(1,1);
end

% Assign x,y length in µm **** ScaleFactor: µm/pixel
SIZE = size( DIC.Data(1).exx );
DIC.XData = ( 0 : SIZE(2)-1 ) * CoordScaleFactor;
DIC.YData = ( 0 : SIZE(1)-1 ) * CoordScaleFactor;


% Simplify data
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

    DIC.XData = DIC.XData(ind2);
    DIC.YData = DIC.YData(ind1);

end


% Manual Resize
% Names = fieldnames( DIC.Data );
% for i = 1 : length( Names )
%     for n = 1 : DIC.StageNumber
%         DIC.Data(n).( Names{i} ) = DIC.Data(n).( Names{i} ) ...
%             ( 12:end, 12:end );
%     end
% end



varargout{1} = DIC;
if nargout > 1
    varargout{2} = ind;
end


    function val = tempfun( val )

        absval = abs( val );
        tempind = absval > MaxAbsStrain;
        val( tempind ) = val( tempind )./ absval( tempind );

    end


end
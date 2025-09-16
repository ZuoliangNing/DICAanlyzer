function [ obj, Report ] = DICPreprocess( obj, dlg, app )
% perform preprocess of DIC data 
% Use: 
%       'obj.DIC.PreprocessMethod'
%       'obj.DIC.PreprocessPars'
% Define:
%       'obj.DIC.Data'


Report = [];


fun = eval( [ '@ DICPreprocess_', obj.DIC.PreprocessMethod ] );

% try
    tic
    DIC = fun( obj.DIC, dlg );
    elapsedTime = toc;

    Size = size( DIC.Data(1).u );
    DIC.DataSize = [ Size, prod(Size) ];

    S = whos('DIC');
    DIC.MemorySize = S.bytes * 1e-6;
    DIC.TimeSpent = elapsedTime;

    Names = fieldnames( DIC.Data );
    CLimCoeff = app.Default.Options.DICCLimCoeff;
    
    for i = 1:length( Names )
        name = Names{i};
        for n = 1 : DIC.StageNumber
            if isfield( DIC.DataValueRange, name )
                val = restoreData( ...
                    DIC.Data(n).( name ), DIC.DataValueRange.( name ) );
            else
                val = DIC.Data(n).( name );
            end
            [ minval, maxval ] = getCLim( val, CLimCoeff );
            DIC.CLim(n).( name ) = [ minval, maxval ];
            DIC.CLimCoeff(n).( name ) = CLimCoeff;
            DIC.CLimMethod(n).( name ) = 'auto';
        end
    end
    
    obj.DIC = DIC;

% catch ME
%     Report = getReport( ME );
% end
classdef DICProcessor
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明

    properties

        DisplayName     (1,:) char      % name for exhibition

        % ****** DIC ******************************************************
        
        DIC = struct( ...
            ...
            'FileNames',          {''}, ...       % full paths
            'FileNumber',         0, ...          
            'FileFormat',         '', ...         % format - in 'app.ConstantValues.DICFileFormats'
            'FilePosition',       [0,0], ...      % row & column position of files
            'Data',               struct( ...     % data as a whole (stitiched)
                                    'u',    [], ...
                                    'v',    [], ...
                                    'exx',  [], ...
                                    'eyy',  [], ...
                                    'exy',  [] ), ...
            'DataValueRange',     struct(), ...
            'PreprocessMethod',   '', ...         % 
            'PreprocessPars',     struct(), ...   % struct('varname', varvalues)
            'StageNumber',        0, ...          % number of stage
            'UserVariableNames',  {''}, ...        % user defined variable names, e.g. u, v, e_xx, ...
            'MemorySize',         0, ...
            'TimeSpent',          [], ...
            'XData',              [], ...
            'YData',              [], ...
            'DataSize',           [], ...
            'CLim',         struct( ...     % data as a whole (stitiched)
                                    'u',    [], ...
                                    'v',    [], ...
                                    'exx',  [], ...
                                    'eyy',  [], ...
                                    'exy',  [] ), ...
            'CLimMethod',         struct(), ...
            'CLimCoeff',          struct() )

            % 'DispRatio',          []
            
        DICSize

            % 'OriginalData',       {struct()}, ... % orignial dic data from files

        %   obj.DIC.OriginalData        - (1,FileNumber)    cell
        %   obj.DIC.OriginalData{i}     - (1,StageNumber)   struct
        %                          struct( 'u',   u,   'v',   v, 
        %                                  'exx', exx, 'eyy', eyy, 'exy', exy, 
        %                                  'StageNumber', n )
        %       - obj.DIC.OriginalData{ FileNumber }( StageNumber )
        %
        %
        %   obj.DIC.Data                - (1,StageNumber)   struct
        %                          struct( 'u',   u,   'v',   v, 
        %                                  'exx', exx, 'eyy', eyy, 'exy', exy )
        %       - obj.DIC.Data( StageNumber )


        %       --- Variables defined in: ---
        %           'DICImportMenuSelectedFcn' -> Button_ok_ButtonPushedFcn
        %
        %           DIC.    /FileNames     /FileNumber     /FileFormat
        %           DIC.    /FilePosition
        %           DIC.    /PreprocessMethod  /PreprocessPars



        % ****** EBSD *****************************************************
        EBSDSerial = 0
        EBSD = struct( ...
            ...
            'FileName',             '',         ...     % full path
            'Data',                 struct(),    ...
            'PreprocessMethod',     '',         ...
            'PreprocessPars',       struct(), ...
            'AdjustFlag',           false )
   
        
        %   obj.EBSD.Data   - (1,StageNumber)   struct
        %
        %       DisplayName
        %       Coords
        %       EulerAngles
        %       IQ
        %       CI
        %       GrainID
        %       EdgeIndex
        %       Phase
        %       PhaseNames
        %       IPF
        %       XData
        %       YData
        %       Serial


        % ****** FLAG *****************************************************
        Flag = struct( ... 0 - empty / 1 - success / -1 - failed
            'DICPreprocess'     , 0, ...
            'EBSDData'          , 0, ...
            'Adjust'            , 0, ...
            'Polygonize'        , 0      )
            % 'DICLoadData'       , 0, ...

    end

    methods
        function val = get.DICSize( obj )
            val = size( obj.DIC.Data(1).exx );
        end

        function obj = DICProcessor( Name )

            %
            obj.DisplayName = Name;
            obj.EBSD.Data = getEmptyEBSDData();

        end

        [ obj, Report ] = DICPreprocess( obj, dlg, app )
        

    end
end
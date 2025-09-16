classdef DICInstance < DICProcessor
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明

    properties
        
        Serial  (1,1) int16
        TreeNodes = struct( ... % in 'app.Tree'
            'Main', [], ...
            'DIC', [], ...
            'DICData', [], ...
            'EBSD', [], ...
            'EBSD2', [], ...
            'EBSDData', [] )   
        Tree2Nodes  % in 'app.Tree2'

        StatisticResults = struct( ...
            'DisplayName', '', ...
            'Type', '', ... line / reigon
            'NodeType', [], ... DICData / EBSDData
            'EBSDSerial', nan, ... only for 'EBSDData'
            'GraphicObject', gobjects(1), ... line or rect & label
            'StatisticObject', gobjects(1), ... line plot or histogram
            'Nodes', matlab.ui.container.TreeNode, ...
            'Serial', nan, ...
            'Pos', [] )
        StatisticResultsSerial (1,1) int16

        StageSelection = 1
        
    end

    methods
        function obj = DICInstance( Name, app )
            
            % ---↓↓↓---
            app.Serial = app.Serial + 1;
            % ---↑↑↑---

            obj = obj @ DICProcessor( Name );    
            obj.Serial = app.Serial;

            obj = obj.createNodes( app );

            % ---↓↓↓--- 
            app.Projects = [ app.Projects, obj ];
            % ---↑↑↑---

        end

        function delete(obj)

            deleteNodes( obj.TreeNodes )
            deleteNodes( obj.Tree2Nodes )
            % obj.EBSD = [];
            % obj.DIC = [];
            delete( [ obj.StatisticResults.GraphicObject ] )
            delete( [ obj.StatisticResults.StatisticObject ] )
            % obj.StatisticResults = [];
        end
        
        [ obj, flag ] = LoadDICData( obj, dlg, app )
        [ obj, flag ] = LoadEBSDData( obj, dlg, app )
        save( obj, path, v )
        obj = createNodes( obj, app )
        obj = createDICNodes( obj, app )

        createbyGrianSelection( obj, Name, Index, ...
            EBSDDataind, DICFlag, IncludeOtherFlag, Padding, ...
            EBSDVariables, app, dlg )
        createbyBounding( obj, Name, Bounding, ...
            EBSDDataind, DICFlag, EBSDVariables, app, dlg )

    end
    methods(Static)
        load( FileName, app )
        
    end
end
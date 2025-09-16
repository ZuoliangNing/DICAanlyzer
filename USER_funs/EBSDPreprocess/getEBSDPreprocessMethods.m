function getEBSDPreprocessMethods(app)

%   ---↓↓↓--- DEFINE data processing methods ---↓↓↓---
%       Properties including : (Identifier).(Property)
%               Name            - name for exhibition when selecting
%               Parameters      - name of Parameter variables
%               Info            - description of the method
%
%       Parameter values should be either :
%           (default values are defined in 'getDefault.m')
%               scalar
%               colum vector
%               character string

%       --- 'AssignColumn'
    Method.Method_AssignColumn.Name          = 'Assign Column of Data Arrays';
    Method.Method_AssignColumn.Parameters    = { ...
        'Column_Coords',        ... 1
        'Column_EulerAngles',   ...
        'Column_IQ',            ...
        'Column_CI',            ...
        'Column_GrainID',       ... 5
        'Column_EdgeIndex',     ...
        'Column_PhaseName',     ...
        'AngleUnit'             ... 8
        };

    Method.Method_AssignColumn.Default       = { ...
        [4,5]',     ... 1
        [1,2,3]',   ...
        6,          ...
        7,          ...
        9,          ... 5
        10,         ...
        [11,12]' ,  ...
        'rad'       ... 8
        };
    Method.Method_AssignColumn.Info          = { ...
        'Assign content of each data column', ...
        'Conternts include:', ...
        '   Coords (X,Y) / Euler Angles / Image Quality (IQ) /', ...
        '   Confidence Index (CI) / Grain ID / Edge Index / Phase', ...
        'Use 0 if the content does not exist', ...
        'To polygonize the data, ''Grain ID'' column must exist', ...
        'For ''Phase'':', ...
        '   The corresponding column is imported in ''string'' format ', ...
        '   Use two number if space exists in pahse names', ...
        '       if there is no space, set the second number to ''NaN''' };

%       --- 'Format_OIM'
    Method.Format_OIM.Name          = 'OIM Format';
    Method.Format_OIM.Parameters    = {};
    Method.Format_OIM.Default       = {};
    Method.Format_OIM.Info          = { ...
        'Applicable to the default data format exported by OIM Analysis.' };

%       --- 'Format_OIM_CoincideCoords'
    Method.Format_OIM_CoincideCoords.Name = ...
        'OIM Format - Coincident image_sample coords';
    Method.Format_OIM_CoincideCoords.Parameters = {};
    Method.Format_OIM_CoincideCoords.Default    = {};
    Method.Format_OIM_CoincideCoords.Info          = { ...
        'Based on ''Default format of OIM'' ...', ...
        'Euler angles are defined in the Image Coordinate', ...
        'indicating coincident image and sample coordinates'};

%       --- 'Reimport'
    Method.Reimport.Name = 'DIC_Analyzer Format';
    Method.Reimport.Parameters  = { };
    Method.Reimport.Default = { };
    Method.Reimport.Info = {...
        'For data format exported by this app' };

%       --- 'Reimport_CoincideCoords'
    Method.Reimport_CoincideCoords.Name = ...
        'DIC_Analyzer Format - Coincident image_sample coords';
    Method.Reimport_CoincideCoords.Parameters = {};
    Method.Reimport_CoincideCoords.Default    = {};
    Method.Reimport_CoincideCoords.Info          = { ...
        'Based on ''DIC_Analyzer Format'' ...', ...
        'Euler angles are defined in the Image Coordinate', ...
        'indicating coincident image and sample coordinates'};

%   ---↑↑↑↑↑↑↑↑↑-------------------------↑↑↑↑↑↑↑↑↑---

app.EBSDPreprocessMethods = structfun( ...
    @(m) rmfield( m, 'Default' ), Method, 'UniformOutput', false );


AllDataMethods = fieldnames( Method );
n = length( AllDataMethods );

for i = 1:n

    m = AllDataMethods{i};
    
    if ~isfield( app.Default.Parameters.EBSDPreprocessMethods, m )

            app.Default.Parameters.EBSDPreprocessMethods.(m) = ...
                struct();

    end

    for j = 1:length( Method.(m).Parameters )
        
        par = Method.(m).Parameters{j};
        
        if ~isfield( app.Default.Parameters.EBSDPreprocessMethods.(m), par )

            app.Default.Parameters.EBSDPreprocessMethods.(m).(par) = ...
                Method.(m).Default{j};
      
        end

    end

end
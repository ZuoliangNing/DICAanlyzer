function DIC = getEmptyDIC( DIC )

DIC.FileNames = {''};
DIC.FileNumber = 0;
DIC.FileFormat = '';
DIC.FilePosition = [0,0];
DIC.Data = [];
DIC.Data = struct( ...     % data as a whole (stitiched)
    'u',    [], ...
    'v',    [], ...
    'exx',  [], ...
    'eyy',  [], ...
    'exy',  [] );
DIC.DataValueRange = struct();
DIC.PreprocessMethod = '';
DIC.PreprocessPars = struct();
DIC.StageNumber = 0;
DIC.UserVariableNames = {''};
DIC.MemorySize = 0;
DIC.TimeSpent = [];
DIC.XData = [];
DIC.YData = [];
DIC.DataSize = [];
% DIC.DispRatio = [];
function [ obj, Report ] = EBSDPreprocess( obj, dlg )
% perform data process of EBSD data 
% Use: 
%       'obj.EBSD.PreprocessMethod'
%       'obj.EBSD.PreprocessPars'
% Define:
%       'obj.EBSD.Data'


Report = [];

fun = eval( [ '@ EBSDPreprocess_', obj.EBSD.PreprocessMethod ] );
try
    EBSD = fun( obj.EBSD, dlg );
    EBSD.Data.OriginalFileName = EBSD.FileName;
    EBSD.Data.PreprocessMethod = EBSD.PreprocessMethod;
    EBSD.Data.PreprocessPars = EBSD.PreprocessPars;
    S = whos('EBSD');
    EBSD.Data.MemorySize = S.bytes * 1e-6;
    obj.EBSD = EBSD;
catch ME
    Report = getReport( ME );
end
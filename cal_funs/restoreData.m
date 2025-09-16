function Data = restoreData( Data, ValueRange )

%   ValueRange --- range of absolute values

Factor = 32768 / ValueRange ;

Data = double( Data ) / Factor;
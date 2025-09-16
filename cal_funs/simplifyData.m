function Data = simplifyData( Data, ValueRange )

%   ValueRange --- range of absolute values

Factor = 32768 / ValueRange ;

Data = cast( round( Data * Factor ), 'int16' );
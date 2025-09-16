function Value = getMainInfo( obj )


n = @ num2str; r = @ round;
MemorySize = {obj.DIC.MemorySize,[obj.EBSD.Data.MemorySize]};
S = whos("obj"); % n(r(sum([MemorySize{:}]),1))
Value = { ['* Memory usage: ', n(r(S.bytes*1e-6,1)), ' MB'], ...
    ['    DIC: ',n(r(MemorySize{1},1)),' MB'], ...
    '    EBSD:' };

for i = 1:length(obj.EBSD.Data)
    Value = [ Value, ...
        ['      ', obj.EBSD.Data(i).DisplayName,': ', ...
        n(r(MemorySize{2}(i),1)),' MB'] ];
end
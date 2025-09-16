function B = addField(A,B)

subfnames = fieldnames(A);
for j = 1:length(subfnames)
    subfname = subfnames{j};
    if ~isfield(B,subfname)
        B.(subfname) = A.(subfname);
    end
end
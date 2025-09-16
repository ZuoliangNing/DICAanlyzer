function SavedDefault = updateDefault(FileName,SavedDefault)

Previous = load(FileName,'SavedDefault');
Previous = Previous.SavedDefault;
fnames = fieldnames(SavedDefault);
for i = 1:length(fnames)
    fname = fnames{i};
    if ~isfield(Previous,fname)
        Previous.(fname) = SavedDefault.(fname);
    end
end
for i = 1:length(fnames)
    fname = fnames{i};
    if isa(SavedDefault.(fname),'struct')
        Previous.(fname) = ...
            addField(SavedDefault.(fname),Previous.(fname));
    end
end
SavedDefault = Previous;
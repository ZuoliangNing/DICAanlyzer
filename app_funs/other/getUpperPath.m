function path = getUpperPath(path)
ind = strfind(path,'\');
path = path(1:ind(end-1));
function refreshFileTable( table, files, row, column )

% ------ REFRESH TABLE ------
        
sz = [ max(row), max(column) ];
ind = sub2ind( sz, row, column );
temp = cell(sz);
temp(ind) = files;
table.Data = temp;
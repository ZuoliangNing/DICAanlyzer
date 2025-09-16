function flag = ifequalParameterValues( val1, val2 )

flag = false;

fnames = fieldnames( val1 );

for i = 1:length(fnames)

    Name = fnames{i};

    if ischar( val1.(Name) )
        if ~ strcmp( val1.(Name), val2.(Name) ); return; end
    else
        if any( val1.(Name) ~= val2.(Name) ); return; end
    end

end

flag = true;
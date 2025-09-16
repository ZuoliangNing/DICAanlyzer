function deleteNodes( TreeNodes )

fnames = fieldnames( TreeNodes );

for i = 1:length(fnames)

    if isa( TreeNodes.(fnames{i}), ...
            'matlab.ui.container.TreeNode' )

        delete( TreeNodes.(fnames{i}) )

    else
        arrayfun(@(s) structfun( @delete, s ), TreeNodes.(fnames{i}) )
    end

end
function EnableDisableNode( app, nodes, opt )

arrayfun( @tempfun, nodes )

function tempfun(node)
    switch opt 
        case 'on'
            addStyle( app.(node.UserData.Parent), ...
                uistyle( 'FontColor', 'k' ), 'node', node )
            node.NodeData.Enable = true;
        case 'off'
            addStyle( app.(node.UserData.Parent), ...
                uistyle( 'FontColor', 0.5*[1,1,1] ), 'node', node )
            node.NodeData.Enable = false;
    end
end

end
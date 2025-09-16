function node = getRootNode(node)

while 1
    parent = node.Parent;
    if isa(parent.Parent,'matlab.ui.container.GridLayout'); break
    end
    node = parent;
end
%=====================================================
%
% Test function addNewNodes
%
% Author: Jess
% Created: 2018.07.16
%=====================================================

nodes       = 4;
newNodes    = 3;
newSize = nodes + newNodes;

AM = addNewNodes(ones(nodes, nodes), newNodes);

fprintf('\nAdjacency Matrix\n\n');
fprintf([repmat(' %d ', 1, newSize) '\n'], AM);

[rows, columns] = size(AM);
if rows == newSize && columns == newSize
    fprintf('\nTest addNewNodes Successful\n');
else
    assert(0,'\nTest addNewNodes Failed\n');
end

function AM = addNewNodes(AM, numNewNodes)
%=====================================================
%
% Add new, unconnected node(s) to the existing adjacency matrix
%
% AM            = Adjacency Matrix
% numNewNodes   = Number of new nodes
%
% Author: Jess
% Created: 2018.07.16
%=====================================================

% Add new unconnected node(s)
AM(:, end + numNewNodes) = 0;   % columns
AM(end + numNewNodes, :) = 0;   % rows

end


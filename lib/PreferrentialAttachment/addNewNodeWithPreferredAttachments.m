function AM = addNewNodeWithPreferredAttachments(AM, numNewAttachments)
%===================================================
%
% Add a node and connect it to a set of existing nodes using the
% preferrential attachment model.
%
% AM                = The adjacency matrix
% numNewAttachments = The number of attachments for the new node
%
% Author: Jess
% Created: 2019.03.01
%===================================================

% Calculate the node dimensions
nodeDimensions = sum(AM);

% Find the preferred nodes
preferredNodes = findPreferredNodes(nodeDimensions, numNewAttachments);

% Add the new node to the AM and attach it to the preferred nodes 
% (undirected attachment)
newNodeIndex = size(nodeDemensions') + 1;
AM = addNewNodes(AM, 1);
AM(preferredNodes, newNodeIndex) = 1;
AM(newNodeIndex, preferredNodes) = 1;

end


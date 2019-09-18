function AM = addNewNodeWithPreferentialAttachments(AM, numNewAttachments)
%===================================================
%
% Add a node and connect it to a set of existing nodes using the
% preferential attachment model.
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
fprintf('Found %d preferred attachments\n',preferredNodes);

% Add the new node to the AM and attach it to the preferred nodes 
% (undirected attachment)
newNodeIndex = size(nodeDimensions') + 1;
AM = addNewNodes(AM, 1);
AM(preferredNodes, newNodeIndex) = 1;
AM(newNodeIndex, preferredNodes) = 1;

end


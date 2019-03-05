function AM = addAttachmentsToNodeWithPreferredAttachment(AM, nodeIndex, numNewAttachments)
%===================================================
%
% Add a node and connect it to a set of existing nodes using the
% preferrential attachment model.
%
% AM                = The adjacency matrix
% nodeIndex         = The source node making new connections
% numNewAttachments = The number of attachments for the new node
%
% Author: Jess
% Created: 2019.03.01
%===================================================

% Calculate dimensions
nodeDimensions = sum(AM);

% Remove selected node by zeroing it's dimension (it should never be
% selected by findPreferredNodes below)
nodeDimensions(nodeIndex) = 0;

% Find preferred attachments
preferredNodes = findPreferredNodes(nodeDimensions, numNewAttachments);

% Add a new node AM and attach to the preferred nodes (undirected
% attachment)
AM(preferredNodes, nodeIndex) = 1;
AM(nodeIndex, preferredNodes) = 1;

end



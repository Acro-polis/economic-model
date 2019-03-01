function [AM] = addNewNodeUsingPreferentialAttachment(AM, numNewAttachments)
%===================================================
%
% Randomly (without replacement) identify a set of nodes 
% with probabilities proportional to their degrees. This is 
% the preferential attachment model. Then add a new node and make
% the (undirected) attachments.
%
% AM                = The adjacency matrix
% numNewAttachments = The number of nodes to make
%
% Author: Jess
% Created: 2019.02.28
%===================================================

numNodes = size(AM);
nodeIndexes = 1:numNodes;
selectedNodesIndexes = zeros(numNewAttachments);

nodeDimensions = sum(AM);

for i = 1:numNewAttachments
    
    % Calculate degree probabilities
    sumD = sum(nodeDimensions);
    P = nodeDimensions ./ sumD;
    
    % Calculate CDF of sorted probabilities
    [p, pIndexes] = sort(P,'descend');
    cdf = cumsum(p);
    
    % Find the index of the node that corresponds to the inverse of the CDF
    r = unifrnd(0,1);
    pIndex = find([-1 cdf] < r, 1, 'last');
    
    % Map back the selected "index" to the corresponding nodes original position
    selectedNodeIndex = pIndexes(pIndex);
    
    % Store the selected node index 
    selectedNodesIndexes(i) = nodeIndexes(selectedNodeIndex);
    
    % Remove the selected node for the next iteration (no replacement)
    nodeIndexes(selectedNodeIndex) = [];
    nodeDimensions(selectedNodeIndex) = [];    
    
end

% Now add a new node to AM and make the undirected attachments
newNodeIndex = numNodes + 1;
AM = addNewNodes(AM, 1);
AM(selectedNodesIndexes, newNodeIndex) = 1;
AM(newNodeIndex, selectedNodesIndexes) = 1;

end


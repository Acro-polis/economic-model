function selectedNodesIndexes = findPreferredNodes(nodeDimensions, numNodesToSelect)
%===================================================
%
% Randomly identify a set of nodes with probabilities proportional to their
% degree. This is the preferential attachment model.
%
% nodeDimensions    = The dimensions of each node (number of connections)
% numNodesToSelect  = The number of nodes to randomely select (without
%                     replacment)
%
% Author: Jess
% Created: 2019.02.28
%===================================================

numNodes = size(nodeDimensions');
nodeIndexes = 1:numNodes;
selectedNodesIndexes = zeros(numNodesToSelect);

for i = 1:numNodesToSelect
    
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


end


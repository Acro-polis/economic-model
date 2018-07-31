function [selectedNodes] = findPreferredNodes(Am, N, RN, randomAttachments)
%===================================================
%
% Randomly identify a set of nodes with probabilities 
% proportional to their degrees. This is the preferential 
% attachment model.
%
% Am                = Adjacency matrix from time t - 1
% N                 = Number of nodes available for attachment
% RN                = Number of random attachments to make
% randomAttachments = nodes already attached during
%                     prior t - 1 random attachment phase
%
% Author: Jess
% Created: 2018.07.19
%===================================================
assert(N >= RN,'Error in identifyPreferredNodes: N < RN')

nodes = 1:N;
selectedNodes = [];
D = sum(Am);

% Ignore nodes attached during prior random phase
nodes(randomAttachments) = [];
D(randomAttachments) = [];

%TODO - can / should this be vecorized?

for i = 1:RN
    
    % Calculate degree probabilities
    d = sum(D);
    P = D ./ d;
    
    % Calculate CDF of sorted probabilities
    [S, H] = sort(P,'descend');
    cdf = cumsum(S);
    
    % Find the index of the node that corresponds 
    % to the inverse of the CDF
    r = unifrnd(0,1);
    index = find([-1 cdf] < r, 1, 'last');
    
    % Map back the selected "index" to the corresponding nodes 
    % original position
    selectedNode = H(index);
    
    % Store the selected node, and then remove it for the next iteration
    selectedNodes = [selectedNodes nodes(selectedNode)];
    nodes(selectedNode) = [];
    D(selectedNode) = [];

end;

end


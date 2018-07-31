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
%                     prior random attachment phase
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

for i = 1:RN
    
    d = sum(D);
    P = cumsum(D ./ d);
    r = unifrnd(0,1);
    index = find([-1 P] < r, 1, 'last');
    
    selectedNodes = [selectedNodes nodes(index)];
    nodes(index) = [];
    D(index) = [];

end;

end


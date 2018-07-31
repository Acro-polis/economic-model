function [selectedNodes] = identifyPreferredNodes(Am, N, RN, randomAttachments)
%===================================================
%
% Randomly identify a node with probabilities proportional
% to their degrees. This is the preferential attachment
% model.
%
% TODO - Add more explaination
%
% Author: Jess
% Created: 2018.07.19
%===================================================
assert(N >= RN,'Error in identifyPreferredNodes: N < RN')

nodes = 1:N;
selectedNodes = [];
D = sum(Am);

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


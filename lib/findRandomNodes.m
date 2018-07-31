function [selectedNodes] = findRandomNodes(N, RN)
%=====================================================
%
% Given the set of nodes 1 to N randomly pick RN of them 
% return and the corresponding vector
% 
% N = Represents the set nodes ranging from 1 to N
% RN = The number of nodes to identify uniquely randomly
%
% Author: Jess
% Created: 2018.07.16
%=====================================================
assert(N >= RN,'Error in FindRandomNodes: N < RN')

nodes = 1:N;
selectedNodes = [];

for i = 1:RN
    index = round(unifrnd(1,size(nodes,2)));
    selectedNodes = [selectedNodes nodes(index)];
    nodes(index) = [];
end

end

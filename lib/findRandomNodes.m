function [selectedNodes] = findRandomNodes(N, RN)
%=====================================================
%
% Given a set of nodes 1 to N, randomly pick RN of 
% them and return and the resulting vector
% 
% N  = The number of nodes available to connect to
% RN = The number of unique conections to make
%
% Author: Jess
% Created: 2018.07.30
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

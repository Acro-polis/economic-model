function [selectedNodes] = findRandomNodes(N, RN)
%=====================================================
%
% Select RN nodes without replacement from the set of N 
% 
% N  = The number of nodes available for connection
% RN = The number of unique conections to make
%
% Author: Jess
% Created: 2018.07.30
%=====================================================
assert(N >= RN,'Error in FindRandomNodes: N < RN')

selectedNodes = randsample(N,RN);

end

function [avgDeg] = averageDegree(AM)
%=====================================================
%
% Calculate the average degree for the given adjacency
% matrix. 
%
% Author: Jess
% Created: 2018.07.16
%=====================================================

numberNodes = size(AM,1);
D = sum(AM);
sumD = sum(D);
avgDeg = sumD / numberNodes;

end


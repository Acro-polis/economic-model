function [returnValue] = averageDegree(Am)
%=====================================================
%
% Calculate the average degree for the given adjacency
% matrix. 
%
% Author: Jess
% Created: 2018.07.16
%=====================================================

N = size(Am,1);
D = sum(Am);
sumD = sum(D);
returnValue = sumD / N;

end


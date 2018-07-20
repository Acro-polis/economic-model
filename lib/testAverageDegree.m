%=====================================================
%
% Test function averageDegree
%
% Author: Jess
% Created: 2018.07.16
%=====================================================

N = 10;
Am = connectedGraph(N);
avgDeg = averageDegree(Am);

fprintf('For N = %d nodes, the average degree is %f\n', N, avgDeg);
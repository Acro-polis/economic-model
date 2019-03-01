%=====================================================
%
% Test function averageDegree
%
% Author: Jess
% Created: 2018.07.16
%=====================================================

N = 10;
AM = connectedGraph(N);
avgDeg = averageDegree(AM);

if avgDeg == N-1
    fprintf('\nTest averageDegree Successful\n');
else
    assert(avgDeg == N-1,'\nTest averageDegree Failed\n');
end

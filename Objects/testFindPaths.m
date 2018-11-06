%=====================================================
%
% Test Find Paths
%
%
% Author: Jess
% Created: 2018.11.5
%=====================================================

birthday = 1;
agent1 = Agent(1,birthday);

AM = connectedGraph(4);
AM(1,3) = 0;
AM(3,1) = 0;
AM(1,4) = 0;
AM(4,1) = 0;

agent1.findAllPaths(AM);


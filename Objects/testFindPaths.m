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

AM = connectedGraph(8);

fprintf("\nTest 1\n");

targetAgentId = 8;
paths = agent1.findAllNetworkPathsToAgent(AM, targetAgentId);
agent1.logPaths(paths);

fprintf("Expecting one path = [1 8]\n");
%TODO add assert

fprintf("\nTest 2\n");

% A1 does not know A4, A5, A7 & A8
AM(1,4) = 0;
AM(4,1) = 0;
AM(1,5) = 0;
AM(5,1) = 0;
AM(1,7) = 0;
AM(7,1) = 0;
AM(1,8) = 0;
AM(8,1) = 0;

% A2 does not know A3, A5, A6, A7 & A8
AM(2,3) = 0;
AM(3,2) = 0;
AM(2,5) = 0;
AM(5,2) = 0;
AM(2,6) = 0;
AM(6,2) = 0;
AM(2,7) = 0;
AM(7,2) = 0;
AM(2,8) = 0;
AM(8,2) = 0;

% A3 does not know A2, A6, A7 & A8
AM(3,2) = 0;
AM(2,3) = 0;
AM(3,6) = 0;
AM(6,3) = 0;
AM(3,7) = 0;
AM(7,3) = 0;
AM(3,8) = 0;
AM(8,3) = 0;

% A4 does not know A1, A5, A6 & A8
AM(4,1) = 0;
AM(1,4) = 0;
AM(4,5) = 0;
AM(5,4) = 0;
AM(4,6) = 0;
AM(6,4) = 0;
AM(4,8) = 0;
AM(8,4) = 0;

% A5 does not know A1, A4, A6 & A7
AM(5,1) = 0;
AM(1,5) = 0;
AM(5,4) = 0;
AM(4,5) = 0;
AM(5,6) = 0;
AM(7,5) = 0;

% A6 does not know A2, A3, A4 & A5
AM(6,2) = 0;
AM(2,6) = 0;
AM(6,3) = 0;
AM(3,6) = 0;
AM(6,4) = 0;
AM(4,6) = 0;
AM(6,5) = 0;
AM(5,6) = 0;

% A7 does not know A1, A2, A3, A5 & A8
AM(7,1) = 0;
AM(1,7) = 0;
AM(7,2) = 0;
AM(2,7) = 0;
AM(7,3) = 0;
AM(3,7) = 0;
AM(7,5) = 0;
AM(5,7) = 0;
AM(7,8) = 0;
AM(8,7) = 0;

% A8 does not know A1, A2, A3, A4 & A7
AM(8,1) = 0;
AM(1,8) = 0;
AM(8,2) = 0;
AM(2,8) = 0;
AM(8,3) = 0;
AM(3,8) = 0;
AM(8,4) = 0;
AM(4,8) = 0;
AM(8,7) = 0;
AM(7,8) = 0;

targetAgentId = 8;
paths = agent1.findAllNetworkPathsToAgent(AM, targetAgentId);
agent1.logPaths(paths);

fprintf("Expecting 3 Paths");
fprintf("[ 1 2 4 7 6 8 ]");
fprintf("[ 1 3 5 8 ]");
fprintf("[ 1 6 8 ]");

fprintf("\nTest 3\n");

targetAgentId = 7;
paths = agent1.findAllNetworkPathsToAgent(AM, targetAgentId);
agent1.logPaths(paths);


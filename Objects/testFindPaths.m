%=====================================================
%
% Test the algorthm to find all paths between any two 
% agents on the given network.
%
% Author: Jess
% Created: 2018.11.5
%=====================================================

numberOfAgents = 10; % We need to know this; cannot derive it from the connections import file (yet) 
AM = importNetworkModelFromCSV(numberOfAgents, "test_network_10_agents.csv");
time = 1;
polis = Polis(AM);
polis.createAgents(time);
polis.depositUBI(100.0, time);

fprintf("\nTest 1 - Connections between agents 10 and 9\n");
sourceAgentId = 10;
targetAgentId = 9;
paths = polis.agents(sourceAgentId).findAllNetworkPathsToAgent(AM, targetAgentId);
polis.agents(sourceAgentId).logPaths(paths);
[numPaths, ~] = size(paths);
assert(numPaths == 1,"Test 1 failed, wrong number of total paths found");
fprintf("\nGood, 1 Path From Source Agent %d To Target Agent %d\n", sourceAgentId, targetAgentId);

fprintf("\nTest 2 - Connections between agents 1 and 8\n");
sourceAgentId = 1;
targetAgentId = 8;
paths = polis.agents(sourceAgentId).findAllNetworkPathsToAgent(AM, targetAgentId);
polis.agents(sourceAgentId).logPaths(paths);
[numPaths, ~] = size(paths);
assert(numPaths == 6,"Test 2 failed, wrong number of total paths\n");
fprintf("\nGood, 6 Paths From Source Agent %d To Target Agent %d\n", sourceAgentId, targetAgentId);

fprintf("\nTest 3 - Connections between agents 1 and 10\n");
sourceAgentId = 1;
targetAgentId = 10;
paths = polis.agents(sourceAgentId).findAllNetworkPathsToAgent(AM, targetAgentId);
polis.agents(sourceAgentId).logPaths(paths);
[numPaths, ~] = size(paths);
assert(numPaths == 6,"Test 3 failed, wrong number of total paths\n");
fprintf("\nGood, 6 Paths From Source Agent %d To Target Agent %d\n", sourceAgentId, targetAgentId);

fprintf("\nTest 4 - Connections between agents 10 and 1\n");
sourceAgentId = 10;
targetAgentId = 1;
paths = polis.agents(sourceAgentId).findAllNetworkPathsToAgent(AM, targetAgentId);
polis.agents(sourceAgentId).logPaths(paths);
[numPaths, ~] = size(paths);
assert(numPaths == 6,"Test 4 failed, wrong number of total paths\n");
fprintf("\nGood, 6 Paths From Source Agent %d To Target Agent %d\n", sourceAgentId, targetAgentId);

fprintf("\nTest 5 - Connections between agents 10 and 1\n");
sourceAgentId = 1;
targetAgentId = 7;
paths = polis.agents(sourceAgentId).findAllNetworkPathsToAgent(AM, targetAgentId);
polis.agents(sourceAgentId).logPaths(paths);
[numPaths, ~] = size(paths);
assert(numPaths == 6,"Test 5 failed, wrong number of total paths\n");
fprintf("\nGood, 6 Paths From Source Agent %d To Target Agent %d\n", sourceAgentId, targetAgentId);

fprintf("\nTest 6 - Connections between agents 10 and 1\n");
sourceAgentId = 1;
targetAgentId = 4;
paths = polis.agents(sourceAgentId).findAllNetworkPathsToAgent(AM, targetAgentId);
polis.agents(sourceAgentId).logPaths(paths);
[numPaths, ~] = size(paths);
assert(numPaths == 5,"Test 6 failed, wrong number of total paths\n");
fprintf("\nGood, 5 Paths From Source Agent %d To Target Agent %d\n", sourceAgentId, targetAgentId);

fprintf("\nTest 7 - Connections between agents 10 and 1\n");
sourceAgentId = 5;
targetAgentId = 1;
paths = polis.agents(sourceAgentId).findAllNetworkPathsToAgent(AM, targetAgentId);
polis.agents(sourceAgentId).logPaths(paths);
[numPaths, ~] = size(paths);
assert(numPaths == 6,"Test 7 failed, wrong number of total paths\n");
fprintf("\nGood, 6 Paths From Source Agent %d To Target Agent %d\n", sourceAgentId, targetAgentId);

fprintf("\nTests Completed Successfully\n");

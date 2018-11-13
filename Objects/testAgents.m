%=====================================================
%
% Test suite for agent methods
%
% TODO - add missing methods, not skip methods tested
% in testAgentWallets and testTrustedTransactions
%
% Author: Jess
% Created: 10.31.2018
%=====================================================

numberOfAgents = 10; % We need to know this; cannot derive it from the connections import file (yet) 
AM = importNetworkModelFromCSV(numberOfAgents, "test_network_10_agents.csv");
time = 1;
polis = Polis(AM);
polis.createAgents(time);

fprintf("\nTesting Agents Methods\n\n");

sourceAgentId = polis.agents(1).id;
targetAgentId = polis.agents(2).id;

fprintf("Testing suite with agents %d and %d", sourceAgentId, targetAgentId);

fprintf("\nTest 1: Agent.findMutualConnectionsWithAgent\n\n");

fprintf("Seeking common connections between agents %d and %d\n", sourceAgentId, targetAgentId);
commonConnections = Agent.findMutualConnectionsWithAgent(AM, sourceAgentId, targetAgentId);
logIntegerArray("Common Connections",commonConnections);
[~, connections] = size(commonConnections);
assert(connections == 0,"Error - wrong number of connections");
fprintf("\nExpected Answer    = [ ]\n\n");

fprintf("\nTest 2: Agent.findAgentsUncommonConnections\n\n");
fprintf("Seeking uncommon connections between agents %d and %d\n", sourceAgentId, targetAgentId);
uncommonConnections = Agent.findAgentsUncommonConnections(AM, sourceAgentId, targetAgentId);
logIntegerArray("Uncommon Connections",uncommonConnections);
[~, connections] = size(uncommonConnections);
assert(connections == 1,"Error - wrong number of uncommon connections");
fprintf("\nExpected Answer      = [ 4 ]\n\n");

fprintf("\nTest 3: Agent.findMyUncommonConnectionsFromAgent\n\n");
fprintf("Seeking uncommon connections between agents %d and %d\n", sourceAgentId, targetAgentId);
uncommonConnections = Agent.findMyUncommonConnectionsFromAgent(AM, sourceAgentId, targetAgentId);
logIntegerArray("Uncommon Connections",uncommonConnections);
[~, connections] = size(uncommonConnections);
assert(connections == 2,"Error - wrong number of uncommon connections");
fprintf("\nExpected Answer      = [ 3  6 ]\n\n");

sourceAgentId = polis.agents(4).id;
targetAgentId = polis.agents(7).id;

fprintf("Testing suite with agents %d and %d", sourceAgentId, targetAgentId);

fprintf("\nTest 1: Agent.findMutualConnectionsWithAgent\n\n");

fprintf("Seeking common connections between agents %d and %d\n", sourceAgentId, targetAgentId);
commonConnections = Agent.findMutualConnectionsWithAgent(AM, sourceAgentId, targetAgentId);
logIntegerArray("Common Connections",commonConnections);
[~, connections] = size(commonConnections);
assert(connections == 0,"Error - wrong number of connections");
fprintf("\nExpected Answer    = [ ]\n\n");

fprintf("\nTest 2: Agent.findAgentsUncommonConnections\n\n");
fprintf("Seeking uncommon connections between agents %d and %d\n", sourceAgentId, targetAgentId);
uncommonConnections = Agent.findAgentsUncommonConnections(AM, sourceAgentId, targetAgentId);
logIntegerArray("Uncommon Connections",uncommonConnections);
[~, connections] = size(uncommonConnections);
assert(connections == 1,"Error - wrong number of uncommon connections");
fprintf("\nExpected Answer      = [ 6 ]\n\n");

fprintf("\nTest 3: Agent.findMyUncommonConnectionsFromAgent\n\n");
fprintf("Seeking uncommon connections between agents %d and %d\n", sourceAgentId, targetAgentId);
uncommonConnections = Agent.findMyUncommonConnectionsFromAgent(AM, sourceAgentId, targetAgentId);
logIntegerArray("Uncommon Connections",uncommonConnections);
[~, connections] = size(uncommonConnections);
assert(connections == 2,"Error - wrong number of uncommon connections");
fprintf("\nExpected Answer      = [ 2  3 ]\n\n");

fprintf("\nTests Completed Successfully\n");


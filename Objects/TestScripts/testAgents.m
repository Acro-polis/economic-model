%=====================================================
%
% Test suite that tests methods:
%
% Agent.findMutualConnectionsWithAgent()
% Agent.findAgentsUncommonConnections()
% Agent.findMyUncommonConnectionsFromAgent()
%
% TODO: Add other methods not covered by testAgentWallets
% and testTrustedTransaction
%
% Author: Jess
% Created: 10.31.2018
%=====================================================

numberOfAgents = 10; % We need to know this; cannot derive it from the connections import file (yet) 
AM = importNetworkModelFromCSV(numberOfAgents, "Wallet Test Plan 10 Agents.csv");
time = 1;
totalTimeSteps = 20;
polis = Polis(AM, 6);
polis.createAgents(time, totalTimeSteps);

fprintf("\nTesting Agents Methods\n");

%-----------------------------------------

testNumber = 1;
sourceAgentId = polis.agents(1).id;
targetAgentId = polis.agents(2).id;
expectedConnections = 0;
fprintf("\n------------------------------------------\n");
fprintf("Test Suite = %d, with agents %d and %d\n", testNumber, sourceAgentId, targetAgentId);

testMutualConnectionsWithAgent(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections);

expectedConnections = 1;
testFindAgentsUncommonConnections(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections);

expectedConnections = 2;
testFindMyUncommonConnectionsFromAgent(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections);

%-----------------------------------------

testNumber = 2;
sourceAgentId = polis.agents(4).id;
targetAgentId = polis.agents(7).id;
expectedConnections = 0;
fprintf("\n------------------------------------------\n");
fprintf("\nTest Suite = %d, with agents %d and %d\n", testNumber, sourceAgentId, targetAgentId);

testMutualConnectionsWithAgent(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections);

expectedConnections = 1;
testFindAgentsUncommonConnections(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections);

expectedConnections = 2;
testFindMyUncommonConnectionsFromAgent(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections);

%-----------------------------------------

testNumber = 3;
sourceAgentId = polis.agents(8).id;
targetAgentId = polis.agents(6).id;
expectedConnections = 0;
fprintf("\n------------------------------------------\n");
fprintf("\nTest Suite = %d, with agents %d and %d\n", testNumber, sourceAgentId, targetAgentId);

testMutualConnectionsWithAgent(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections);

expectedConnections = 2;
testFindAgentsUncommonConnections(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections);

expectedConnections = 2;
testFindMyUncommonConnectionsFromAgent(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections);

fprintf("\nTests Completed Successfully\n");

%+++++++++++++++++++++++++++++++++++++++++

function testMutualConnectionsWithAgent(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections)
    fprintf("\nTest %da: Agent.findMutualConnectionsWithAgent\n\n", testNumber);
    fprintf("Seeking common connections between agents %d and %d\n", sourceAgentId, targetAgentId);
    commonConnections = Agent.findMutualConnectionsWithAgent(polis.AM, sourceAgentId, targetAgentId);
    logIntegerArray("Common Connections",commonConnections, 2, 2);
    [~, connections] = size(commonConnections);
    assert(connections == expectedConnections,"Error: expected %d connections, found %d connections", expectedConnections, connections);
end

function testFindAgentsUncommonConnections(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections)
    fprintf("\nTest %db: Agent.findAgentsUncommonConnections\n\n", testNumber);
    fprintf("Seeking uncommon connections agent %d has from %d\n", targetAgentId, sourceAgentId);
    uncommonConnections = findUncommonConnectionsBetweenTwoAgents(polis.AM, sourceAgentId, targetAgentId);
    logIntegerArray("Uncommon Connections",uncommonConnections, 2, 2);
    [~, connections] = size(uncommonConnections);
    assert(connections == expectedConnections,"Error: expected %d uncommon connections, found %d uncommon connections", expectedConnections, connections);
end

function testFindMyUncommonConnectionsFromAgent(polis, testNumber, sourceAgentId, targetAgentId, expectedConnections)
    fprintf("\nTest %dc: Agent.findMyUncommonConnectionsFromAgent\n\n", testNumber);
    fprintf("Seeking uncommon connections agent %d has from %d\n", sourceAgentId, targetAgentId);
    uncommonConnections = Agent.findMyUncommonConnectionsFromAgent(polis.AM, sourceAgentId, targetAgentId);
    logIntegerArray("Uncommon Connections",uncommonConnections, 2, 2);
    [~, connections] = size(uncommonConnections);
    assert(connections == expectedConnections,"Error: expected %d uncommon connections, found %d uncommon connections", expectedConnections, connections);
end

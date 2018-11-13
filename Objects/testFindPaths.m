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

fprintf("\n Testing Agent.findAllNetworkPathsToAgent()\n\n");

testNumber = 1;
sourceAgentId = 10;
targetAgentId = 9;
expectedPaths = 1;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);

testNumber = 2;
sourceAgentId = 1;
targetAgentId = 8;
expectedPaths = 6;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);

testNumber = 3;
sourceAgentId = 1;
targetAgentId = 10;
expectedPaths = 6;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);

testNumber = 4;
sourceAgentId = 10;
targetAgentId = 1;
expectedPaths = 6;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);

testNumber = 5;
sourceAgentId = 1;
targetAgentId = 7;
expectedPaths = 6;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);

testNumber = 6;
sourceAgentId = 1;
targetAgentId = 4;
expectedPaths = 5;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);

testNumber = 7;
sourceAgentId = 5;
targetAgentId = 1;
expectedPaths = 6;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);

testNumber = 7;
sourceAgentId = 5;
targetAgentId = 2;
expectedPaths = 10;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);
fprintf("\nTests Completed Successfully\n");

%
% Test Function
%
function runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths)
    fprintf("\nTest %d - Testing connections between agents %d and %d\n", testNumber, sourceAgentId, targetAgentId);
    paths = polis.agents(sourceAgentId).findAllNetworkPathsToAgent(polis.AM, targetAgentId);
    polis.agents(sourceAgentId).logPaths(paths);
    [numPaths, ~] = size(paths);
    assert(numPaths == expectedPaths,"Test %d failed, expectd %d paths, found %d", testNumber, expectedPaths, numPaths);
    fprintf("\nGood, %d Path(s) From Source Agent %d To Target Agent %d\n", expectedPaths, sourceAgentId, targetAgentId);
end
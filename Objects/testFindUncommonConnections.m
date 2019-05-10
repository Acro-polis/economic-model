%=====================================================
%
% Test the algorthm to 
%
% Author: Jess
% Created: 2019.05.09
%=====================================================

numberOfAgents = 10; % We need to know this; cannot derive it from the connections import file (yet) 
AM = importNetworkModelFromCSV(numberOfAgents, "Wallet Test Plan 10 Agents.csv");
time = 1;
totalTimeSteps = 10;
maxSearchLevels = 2; % Don't subtract 2
polis = Polis(AM, maxSearchLevels);
polis.createAgents(time, totalTimeSteps);
numItems = 1;
inventoryInitialUnits = 100.0;
numberOfPassiveAgents = 0;
percentSellers = 1.0;
[numberOfBuyers, numberOfSellers] = polis.setupBuyersAndSellers(numberOfPassiveAgents, percentSellers, inventoryInitialUnits);

fprintf("\nTesting Agent.findAllNetworkPathsToAgent()\n\n");

testNumber = 1;
buyingAgentId = 1;
buyingAgent = polis.getAgentById(buyingAgentId);
buyingAgentsDirectConnections = buyingAgent.findMyConnections(AM);
buyingAgentsIndirectConnections = buyingAgentsDirectConnections;
a = {};
for i = 1:numel(buyingAgentsDirectConnections)
    targetAgentId = buyingAgentsDirectConnections(i);
    a{i} = polis.findAllIndirectConnectionsBetweenTwoAgents(0, buyingAgentsIndirectConnections, buyingAgentId, targetAgentId); 
end

stop;

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

testNumber = 8;
sourceAgentId = 1;
targetAgentId = 6;
expectedPaths = 5;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);
fprintf("\nTests Completed Successfully\n");

testNumber = 9;
sourceAgentId = 1;
targetAgentId = 3;
expectedPaths = 5;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);
fprintf("\nTests Completed Successfully\n");

testNumber = 10;
sourceAgentId = 1;
targetAgentId = 2;
expectedPaths = 5;
runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths);
fprintf("\nTests Completed Successfully\n");

%+++++++++++++++++++++++++++++++++++++++++

%
% Test Function
%
function runPathTest(polis, sourceAgentId, targetAgentId, testNumber, expectedPaths)
    fprintf("\n------------------------------------------\n");
    fprintf("\nTest %d - Testing connections between agents %d and %d\n", testNumber, sourceAgentId, targetAgentId);
    paths = polis.agents(sourceAgentId).findAllNetworkPathsToAgent(polis.AM, targetAgentId);
    polis.agents(sourceAgentId).logPaths(paths);
    [numPaths, ~] = size(paths);
    assert(numPaths == expectedPaths,"Test %d failed, expectd %d paths, found %d", testNumber, expectedPaths, numPaths);
    fprintf("\nGood, %d Path(s) From Source Agent %d To Target Agent %d\n", expectedPaths, sourceAgentId, targetAgentId);
end
%=====================================================
%
% Test finding all the direct and indirect connections that this agent has
% with that agent limited by the maxSearchLevel
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
buyingAgentId = 10;
buyingAgent = polis.getAgentById(buyingAgentId);
buyingAgentsDirectConnections = buyingAgent.findMyConnections(AM);
buyingAgentsIndirectConnections = {};
for i = 1:numel(buyingAgentsDirectConnections)
    targetAgentId = buyingAgentsDirectConnections(i);
    buyingAgentsIndirectConnections = [buyingAgentsIndirectConnections , polis.findAllIndirectConnectionsBetweenTwoAgents(0, [], buyingAgentId, targetAgentId)]; 
end
allDirectAndIndirectConnections = unique([cell2mat(buyingAgentsIndirectConnections) , buyingAgentsDirectConnections]);


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
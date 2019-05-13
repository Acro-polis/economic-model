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
expectedConnections = [5, 6, 8, 9];
runConnectionsTest(polis, AM, buyingAgentId, testNumber, expectedConnections);

testNumber = 2;
buyingAgentId = 1;
expectedConnections = [2, 3, 4, 5, 6, 7, 8, 9];
runConnectionsTest(polis, AM, buyingAgentId, testNumber, expectedConnections);

fprintf("\n\nTests Completed Successfully\n");

%+++++++++++++++++++++++++++++++++++++++++
%
% Test Function
%
function runConnectionsTest(polis, AM, buyingAgentId, testNumber, expectedConnections)
    fprintf("\n------------------------------------------\n");
    fprintf("\nTest %d - Testing buyingAgentId = %d\n", testNumber, buyingAgentId);
    buyingAgent = polis.getAgentById(buyingAgentId);
    buyingAgentsDirectConnections = buyingAgent.findMyConnections(AM);
    buyingAgentsIndirectConnections = {};
    for i = 1:numel(buyingAgentsDirectConnections)
        targetAgentId = buyingAgentsDirectConnections(i);
        buyingAgentsIndirectConnections = [buyingAgentsIndirectConnections , polis.findAllIndirectConnectionsBetweenTwoAgents(0, [], buyingAgentId, targetAgentId)]; 
    end
    allDirectAndIndirectConnections = unique([cell2mat(buyingAgentsIndirectConnections) , buyingAgentsDirectConnections]);
    assert(isequal(allDirectAndIndirectConnections,expectedConnections) == 1,"Test %d failed, expected and found connections do not match", testNumber);
    fprintf("\nGood, buyingAgentId = %d correctly has %d matched connections\n", buyingAgentId, numel(allDirectAndIndirectConnections));
end


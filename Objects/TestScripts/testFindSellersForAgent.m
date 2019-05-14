%=====================================================
%
% Test finding all sellers that an agent can transact with limited by the 
% maxSearchLevel
%
% Author: Jess
% Created: 2019.05.13
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
percentSellers = 0.0;
[numberOfBuyers, numberOfSellers] = polis.setupBuyersAndSellers(numberOfPassiveAgents, percentSellers, inventoryInitialUnits);

fprintf("\nTesting Agent.identifySellersAvailabeToBuyingAgent()\n\n");

testNumber = 1;
buyingAgentId = 10;
expectedSellers = 8;
polis.agents(8).setupAsSeller(inventoryInitialUnits)
runFindSellersTest(polis, buyingAgentId, testNumber, expectedSellers);
polis.agents(8).clearAsSeller();

testNumber = 2;
buyingAgentId = 1;
expectedSellers = [5, 6];
polis.agents(5).setupAsSeller(inventoryInitialUnits)
polis.agents(6).setupAsSeller(inventoryInitialUnits)
runFindSellersTest(polis, buyingAgentId, testNumber, expectedSellers);
polis.agents(5).clearAsSeller();
polis.agents(6).clearAsSeller();

testNumber = 3;
buyingAgentId = 1;
expectedSellers = [2, 5, 6];
polis.agents(1).setupAsSeller(inventoryInitialUnits)
polis.agents(2).setupAsSeller(inventoryInitialUnits)
polis.agents(5).setupAsSeller(inventoryInitialUnits)
polis.agents(6).setupAsSeller(inventoryInitialUnits)
runFindSellersTest(polis, buyingAgentId, testNumber, expectedSellers);
polis.agents(1).clearAsSeller();
polis.agents(2).clearAsSeller();
polis.agents(5).clearAsSeller();
polis.agents(6).clearAsSeller();

testNumber = 4;
buyingAgentId = 10;
expectedSellers = [8, 9];
polis.agents(1).setupAsSeller(inventoryInitialUnits)
polis.agents(2).setupAsSeller(inventoryInitialUnits)
polis.agents(9).setupAsSeller(inventoryInitialUnits)
polis.agents(8).setupAsSeller(inventoryInitialUnits)
runFindSellersTest(polis, buyingAgentId, testNumber, expectedSellers);
fprintf("\n\nTests Completed Successfully\n");

%+++++++++++++++++++++++++++++++++++++++++
%
% Test Function
%
function runFindSellersTest(polis, buyingAgentId, testNumber, expectedSellers)
    fprintf("\n------------------------------------------\n");
    fprintf("\nTest %d - Testing buyingAgentId = %d\n", testNumber, buyingAgentId);
    sellerIds = polis.identifySellersAvailabeToBuyingAgent(buyingAgentId);
    assert(isequal(sellerIds,expectedSellers) == 1,"Test %d failed, expected and found sellers do not match", testNumber);
    fprintf("\nGood, buyingAgentId = %d correctly has %d matched sellers\n", buyingAgentId, numel(sellerIds));
end


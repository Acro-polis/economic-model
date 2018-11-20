%=====================================================
%
% Test function testAgentWallets
%
% Unit tests for UBI, Demurrage and Buy/Sell transactions
%
% Author: Jess
% Created: 2018.10.15
%=====================================================

fprintf("\n\n----- Wallet Test Suite 1 ----\n\n");

numberOfAgents = 10; % We need to know this; cannot derive it from the connections import file (yet) 
AM = importNetworkModelFromCSV(numberOfAgents, "test_network_10_agents.csv");
time = 1;
fprintf("\nTest Agent Wallets: time = %d\n\n",time);
maxSearchLevels = 6;
polis = Polis(AM, maxSearchLevels); 
polis.createAgents(time);

% Give everybody 500
polis.depositUBI(500, time);

% Make some simple purchases

time = time + 1;
fprintf("\nTest Agent Wallets: time = %d\n",time);

agent1 = polis.agents(1);
agent2 = polis.agents(2);
agent3 = polis.agents(3);
agent4 = polis.agents(4);

% A1 buys from A2
result = agent1.submitPurchase(AM, 100, agent2, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

% A1 buys from A3
result = agent1.submitPurchase(AM, 50, agent3, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

% A3 buys from A1
result = agent3.submitPurchase(AM, 75, agent1, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

% A2 buys from A4
result = agent2.submitPurchase(AM, 200, agent4, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

agents = [agent1, agent2, agent3, agent4];
expectedBalances = [425.0, 400.0, 475.0, 700.0];
dumpLedgers(agents);
checkBalances(agents, expectedBalances);

%---------------------------------------------

time = time + 1;
fprintf("\nTest Agent Wallets: time = %d\n",time);

% Apply Demurrage
polis.applyDemurrage(time);

agent5 = polis.agents(5);
agents = [agent1, agent2, agent3, agent4, agent5];
expectedBalances = [403.75, 380.0, 451.25, 665.0, 475.0];
dumpLedgers(agents);
checkBalances(agents, expectedBalances);

%---------------------------------------------

time = time + 1;
fprintf("\nTest Agent Wallets: time = %d\n",time);

% A2 buys from A5
result = agent2.submitPurchase(AM, 250.0, agent5, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

agents = [agent1, agent2, agent3, agent4, agent5];
expectedBalances = [403.75, 130.0, 451.25, 665.0, 725.0];
dumpLedgers(agents);
checkBalances(agents, expectedBalances);

%---------------------------------------------

time = time + 1;
fprintf("\nTest Agent Wallets: Time = %d\n",time);

agent8 = polis.agents(8);
agent6 = polis.agents(6);
result = agent8.submitPurchase(AM, 100.0, agent1, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

agent8.dumpLedger();
agent6.dumpLedger();
agent1.dumpLedger();

agents = [agent1, agent2, agent3, agent4, agent5, agent6, agent8];
expectedBalances = [503.75, 130.0, 451.25, 665.0, 725.0, 475.0, 375.0];
dumpLedgers(agents);
checkBalances(agents, expectedBalances);

%---------------------------------------------

time = time + 1;
fprintf("\nTest Agent Wallets: time = %d\n",time);

agent10 = polis.agents(10);
agent9 = polis.agents(9);
result = agent10.submitPurchase(AM, 125.0, agent1, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

agents = [agent10, agent9, agent8, agent6, agent1];
expectedBalances = [350.0, 475.0, 375.0, 475.0, 628.75];
dumpLedgers(agents);
checkBalances(agents, expectedBalances);

expectedBalances = [500.0, 425.0, 403.75, 403.75, 503.75, 628.75];
checkBalancesInTime(agent1, time, expectedBalances);

fprintf("\n\n----- Wallet Test Suite 2 ----\n\n");

polis.delete
time = 1;
polis = Polis(AM, 6);
polis.createAgents(time);
polis.depositUBI(500.0, time);
agent1 = polis.agents(1);
agent2 = polis.agents(2);
agent3 = polis.agents(3);
agent4 = polis.agents(4);
agent6 = polis.agents(6);

time = time + 1;
result = agent1.submitPurchase(AM, 400.00, agent6, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

time = time + 1;
result = agent3.submitPurchase(AM, 250.00, agent1, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

time = time + 1;
result = agent1.submitPurchase(AM, 249.00, agent2, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

agents = [agent1, agent2, agent3, agent4, agent6];
expectedBalances = [101.0, 749.0, 250.0, 500.0, 900.0];
dumpLedgers(agents);
checkBalances(agents, expectedBalances);

function checkBalances(agents, expectedBalances)
    fprintf("\nChecking Balances\n");
    [~, cols] = size(agents);
    for i = 1:cols
        agent = agents(i);
        balance = agent.currentBalanceAllCurrencies;
        fprintf("Agent %d's current balance = %.2f\n", agent.id, balance);
        assert(balance == expectedBalances(i),"Error with Agent %d: Balance = %.2f, Expected Balance = %.2f", agent.id, balance, expectedBalances(i));
    end
end

function checkBalancesInTime(agent, time, expectedBalances)
    fprintf("\nChecking Balances In Time\n");
    for i = 1:time
        balance = agent.currentBalanceAllCurrenciesAtTime(i);
        fprintf("Agent %d's balance at time %d = %.2f\n", agent.id, i, balance);
        assert(balance == expectedBalances(i),"Error with Agent %d: Balance at time %d = %.2f, Expected Balance = %.2f", agent.id, i, balance, expectedBalances(i));
    end
end

function dumpLedgers(agents)
    fprintf("\n");
    [~, cols] = size(agents);
    for i = 1:cols
        agents(i).dumpLedger;
    end
end
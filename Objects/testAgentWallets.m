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

agent1.dumpLedger();
fprintf('\n');
agent2.dumpLedger();
fprintf('\n');
agent3.dumpLedger();
fprintf('\n');
agent4.dumpLedger();

a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;
a4bal = agent4.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);
fprintf('Agent4 Current Balnace = %.2f\n', a4bal);

assert(a1bal == 425,'Error in Agent 1 balance, %d != 425', a1bal);
assert(a2bal == 400,'Error in Agent 2 balance, %d != 400', a2bal);
assert(a3bal == 475,'Error in Agent 3 balance, %d != 675', a3bal);
assert(a4bal == 700,'Error in Agent 4 balance, %d != 700', a4bal);

%---------------------------------------------

time = time + 1;
fprintf("\nTest Agent Wallets: time = %d\n",time);

% Apply Demurrage
polis.applyDemurrage(time);

agent1.dumpLedger();
fprintf('\n');
agent2.dumpLedger();
fprintf('\n');
agent3.dumpLedger();
fprintf('\n');
agent4.dumpLedger();

a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;
a4bal = agent4.currentBalanceAllCurrencies;
agent5 = polis.agents(5);
a5bal = agent5.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);
fprintf('Agent4 Current Balnace = %.2f\n', a4bal);
fprintf('Agent5 Current Balnace = %.2f\n', a5bal);

assert(a1bal == 403.75,'Error in Agent 1 balance, %d != 403.75', a1bal);
assert(a2bal == 380.00,'Error in Agent 2 balance, %d != 380.00', a2bal);
assert(a3bal == 451.25,'Error in Agent 3 balance, %d != 451.25', a3bal);
assert(a4bal == 665.00,'Error in Agent 4 balance, %d != 665.00', a4bal);
assert(a5bal == 475.00,'Error in Agent 5 balance, %d != 475.00', a5bal);

%---------------------------------------------

time = time + 1;
fprintf("\nTest Agent Wallets: time = %d\n",time);

% A2 buys from A5
result = agent2.submitPurchase(AM, 250.0, agent5, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

agent1.dumpLedger();
fprintf('\n');
agent2.dumpLedger();
fprintf('\n');
agent3.dumpLedger();
fprintf('\n');
agent4.dumpLedger();
fprintf('\n');
agent5.dumpLedger();

a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;
a4bal = agent4.currentBalanceAllCurrencies;
a5bal = agent5.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);
fprintf('Agent4 Current Balnace = %.2f\n', a4bal);
fprintf('Agent5 Current Balnace = %.2f\n', a5bal);

assert(a1bal == 403.75,'Error in Agent 1 balance, %d != 403.75', a1bal);
assert(a2bal == 130.00,'Error in Agent 2 balance, %d != 1300.00', a2bal);
assert(a3bal == 451.25,'Error in Agent 3 balance, %d != 451.25', a3bal);
assert(a4bal == 665.00,'Error in Agent 4 balance, %d != 665.00', a4bal);
assert(a5bal == 725.00,'Error in Agent 5 balance, %d != 775.00', a5bal);

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

a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;
a4bal = agent4.currentBalanceAllCurrencies;
a5bal = agent5.currentBalanceAllCurrencies;
a6bal = agent6.currentBalanceAllCurrencies;
a8bal = agent8.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);
fprintf('Agent4 Current Balnace = %.2f\n', a4bal);
fprintf('Agent5 Current Balnace = %.2f\n', a5bal);
fprintf('Agent6 Current Balnace = %.2f\n', a6bal);
fprintf('Agent8 Current Balnace = %.2f\n', a8bal);

assert(a1bal == 503.75,'Error in Agent 1 balance, %d != 503.75', a1bal);
assert(a2bal == 130.00,'Error in Agent 2 balance, %d != 130.00', a2bal);
assert(a3bal == 451.25,'Error in Agent 3 balance, %d != 451.25', a3bal);
assert(a4bal == 665.00,'Error in Agent 4 balance, %d != 665.00', a4bal);
assert(a5bal == 725.00,'Error in Agent 5 balance, %d != 775.00', a5bal);
assert(a6bal == 475.00,'Error in Agent 6 balance, %d != 465.00', a6bal);
assert(a8bal == 375.00,'Error in Agent 8 balance, %d != 375.00', a8bal);


%---------------------------------------------

% TODO - finish test plan for these final two tests

time = time + 1;
fprintf("\nTest Agent Wallets: time = %d\n",time);

agent10 = polis.agents(10);
agent9 = polis.agents(9);
result = agent10.submitPurchase(AM, 12.0, agent1, time);
assert(result == TransactionType.TRANSACTION_SUCCEEDED,"Test = %d - Transaction Failed, Status = %d", time, result);

agent10.dumpLedger();
polis.agents(9).dumpLedger();
polis.agents(8).dumpLedger();
polis.agents(6).dumpLedger();
polis.agents(1).dumpLedger();


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

agent1.dumpLedger;
agent3.dumpLedger;
agent4.dumpLedger;
agent2.dumpLedger;

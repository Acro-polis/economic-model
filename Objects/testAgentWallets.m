%=====================================================
%
% Test function testAgentWallets
%
% Unit tests for UBI, Demurrage and Buy/Sell transactions
%
% Author: Jess
% Created: 2018.10.15
%=====================================================

time = 1;
fprintf("\nTest Agent Wallets: time = %d\n\n",time);

AM = connectedGraph(3);
polis = Polis(AM);
polis.createAgents(time);

agent1 = polis.agents(1);
agent2 = polis.agents(2);
agent3 = polis.agents(3);

agent1.depositUBI(500,time);
agent2.depositUBI(500,time);
agent3.depositUBI(500,time);

% A1 buys from A2
agent1.submitPurchaseWithDirectConnection(AM, 100, agent2, time);

% A2 buys from A3
agent2.submitPurchaseWithDirectConnection(AM, 200, agent3, time);

% A1 buys from A3
agent1.submitPurchaseWithDirectConnection(AM, 50, agent3, time);

% A3 buys from A1
agent3.submitPurchaseWithDirectConnection(AM, 75, agent1, time);

% Test / Output Results
a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);

assert(a1bal == 425,'Error in Agent 1 balance, %d != 425', a1bal);
assert(a2bal == 400,'Error in Agent 2 balance, %d != 400', a2bal);
assert(a3bal == 675,'Error in Agent 3 balance, %d != 675', a3bal);

agent1.dumpLedger();
fprintf('\n');
agent2.dumpLedger();
fprintf('\n');
agent3.dumpLedger();

time = 2;
fprintf("\nTest Agent Wallets: time = %d\n",time);

agent1.applyDemurrage(Polis.PercentDemurage,time);
agent2.applyDemurrage(Polis.PercentDemurage,time);
agent3.applyDemurrage(Polis.PercentDemurage,time);

% Test / Output Results

a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);

assert(a1bal == 403.75,'Error in Agent 1 balance, %d != 403.75', a1bal);
assert(a2bal == 380.00,'Error in Agent 2 balance, %d != 380.00', a2bal);
assert(a3bal == 641.25,'Error in Agent 3 balance, %d != 641.25', a3bal);

agent1.dumpLedger();
fprintf('\n');
agent2.dumpLedger();
fprintf('\n');
agent3.dumpLedger();

time = 3;
fprintf("\nTest Agent Wallets: time = %d\n",time);

result = agent2.submitPurchaseWithDirectConnection(AM, 300.0, agent3, time);
assert(result == 1,"Transaction Failed Unexpectedly");
fprintf("\nTransaction Succeeded (A2 buys from A3) = %d\n",result);

fprintf('\n');
agent1.dumpLedger();
fprintf('\n');
agent2.dumpLedger();
fprintf('\n');
agent3.dumpLedger();

a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);

time = 4;
fprintf("\nTest Agent Wallets: time = %d\n",time);

result = agent3.submitPurchaseWithDirectConnection(AM, 80.0, agent1, time);
assert(result == 1,"Transaction Failed Unexpectedly");
result = agent3.submitPurchaseWithDirectConnection(AM, 405.0, agent2, time);
assert(result == 1,"Transaction Failed Unexpectedly");
fprintf("\nTransaction Succeeded (A3 buys from A1 & A2) = %d\n",result);

fprintf('\n');
agent1.dumpLedger();
fprintf('\n');
agent2.dumpLedger();
fprintf('\n');
agent3.dumpLedger();

a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);

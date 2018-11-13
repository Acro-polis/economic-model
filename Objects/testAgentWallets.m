%=====================================================
%
% Test function testAgentWallets
%
% Unit tests for UBI, Demurrage and Buy/Sell transactions
%
% Author: Jess
% Created: 2018.10.15
%=====================================================

numberOfAgents = 10; % We need to know this; cannot derive it from the connections import file (yet) 
AM = importNetworkModelFromCSV(numberOfAgents, "test_network_10_agents.csv");
time = 1;
polis = Polis(AM);
polis.createAgents(time);

fprintf("\nTest Agent Wallets: time = %d\n\n",time);

% Give everybody 500
polis.depositUBI(500,time);

agent1 = polis.agents(1);
agent2 = polis.agents(2);
agent3 = polis.agents(3);
agent4 = polis.agents(4);

% A1 buys from A2
agent1.submitPurchase(AM, 100, agent2, time);

% A1 buys from A3
agent1.submitPurchase(AM, 50, agent3, time);

% A3 buys from A1
agent3.submitPurchase(AM, 75, agent1, time);

% A2 buys from A4
agent2.submitPurchase(AM, 200, agent4, time);

% Test / Output Results
a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;
a4bal = agent4.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);
fprintf('Agent4 Current Balnace = %.2f\n', a4bal);

agent1.dumpLedger();
fprintf('\n');
agent2.dumpLedger();
fprintf('\n');
agent3.dumpLedger();
fprintf('\n');
agent4.dumpLedger();

assert(a1bal == 425,'Error in Agent 1 balance, %d != 425', a1bal);
assert(a2bal == 400,'Error in Agent 2 balance, %d != 400', a2bal);
assert(a3bal == 475,'Error in Agent 3 balance, %d != 675', a3bal);
assert(a4bal == 700,'Error in Agent 4 balance, %d != 700', a4bal);

% Apply Demurrage
time = time + 1;
polis.applyDemurrage(time);

fprintf("\nTest Agent Wallets: time = %d\n",time);

% Test / Output Results

a1bal = agent1.currentBalanceAllCurrencies;
a2bal = agent2.currentBalanceAllCurrencies;
a3bal = agent3.currentBalanceAllCurrencies;
a4bal = agent4.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %.2f\n', a1bal);
fprintf('Agent2 Current Balnace = %.2f\n', a2bal);
fprintf('Agent3 Current Balnace = %.2f\n', a3bal);
fprintf('Agent4 Current Balnace = %.2f\n', a4bal);

assert(a1bal == 403.75,'Error in Agent 1 balance, %d != 403.75', a1bal);
assert(a2bal == 380.00,'Error in Agent 2 balance, %d != 380.00', a2bal);
assert(a3bal == 451.25,'Error in Agent 3 balance, %d != 451.25', a3bal);
assert(a4bal == 665.00,'Error in Agent 4 balance, %d != 665.00', a4bal);

agent1.dumpLedger();
fprintf('\n');
agent2.dumpLedger();
fprintf('\n');
agent3.dumpLedger();
fprintf('\n');
agent4.dumpLedger();

time = time + 1;

fprintf("\nTest Agent Wallets: time = %d\n",time);

% A2 buys from A4
result = agent2.submitPurchase(AM, 250.0, agent4, time);
assert(result == 1,"Transaction Failed Unexpectedly");
fprintf("\nTransaction Succeeded (A2 buys from A4) = %d\n",result);

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

time = 4;
fprintf("\nTest Agent Wallets: time = %d\n",time);


% -----------------------

% fprintf("\nTest 10 - Submit a purchase\n");
% 
% timestep = birthday + 1;
% transacted = agent8.submitPurchase(AM, 10.0, agent1, timestep);
% agent8.dumpLedger();
% polis.agents(6).dumpLedger();
% polis.agents(1).dumpLedger();
% 
% timestep = timestep + 1;
% targetAgent = polis.agents(2);
% agent8.submitPurchase(AM, 8.0, targetAgent, timestep);
% agent8.dumpLedger()
% polis.agents(6).dumpLedger();
% polis.agents(1).dumpLedger();
% targetAgent.dumpLedger();
% 
% timestep = timestep + 1;
% polis.applyDemurrageWithPercentage(0.5, timestep);
% agent8.dumpLedger();
% 
% targetAgent = polis.agents(6);
% agent8.submitPurchase(AM, 5.0, targetAgent, timestep);
% % result = agent8.submitPurchase(AM, paths, 10.0, targetAgentId, timestep);
% agent8.dumpLedger()
% targetAgent.dumpLedger();

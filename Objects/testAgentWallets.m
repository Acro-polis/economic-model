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

agent1 = Agent(1, time);
agent2 = Agent(2, time);
agent3 = Agent(3, time);

agent1.wallet.depositUBI(500,time);
agent2.wallet.depositUBI(500,time);
agent3.wallet.depositUBI(500,time);

% A1 buys from A2
t12 = Transaction(TransactionType.BUY, -100, agent1.id, Polis.uniqueId(), agent2.id, agent1.id, "Tran 4", time);
t21 = Transaction(TransactionType.SELL, 100, agent1.id, Polis.uniqueId(), agent1.id, agent2.id, "Tran 4", time);

agent1.wallet.submitBuySellTransaction(t12);
agent2.wallet.submitBuySellTransaction(t21);

% A2 buys from A3
t23 = Transaction(TransactionType.BUY, -200, agent2.id, Polis.uniqueId(), agent3.id, agent2.id, "Tran 5", time);
t32 = Transaction(TransactionType.SELL, 200, agent2.id, Polis.uniqueId(), agent2.id, agent3.id, "Tran 5", time);

agent2.wallet.submitBuySellTransaction(t23);
agent3.wallet.submitBuySellTransaction(t32);

% A1 buys from A3
t13 = Transaction(TransactionType.BUY, -50, agent1.id, Polis.uniqueId(), agent3.id, agent1.id, "Tran 6", time);
t31 = Transaction(TransactionType.SELL, 50, agent1.id, Polis.uniqueId(), agent1.id, agent3.id, "Tran 6", time);

agent1.wallet.submitBuySellTransaction(t13);
agent3.wallet.submitBuySellTransaction(t31);

% A3 buys from A1
t31 = Transaction(TransactionType.BUY, -75, agent3.id, Polis.uniqueId(), agent1.id, agent3.id, "Tran 7", time);
t13 = Transaction(TransactionType.SELL, 75, agent3.id, Polis.uniqueId(), agent3.id, agent1.id, "Tran 7", time);

agent3.wallet.submitBuySellTransaction(t31);
agent1.wallet.submitBuySellTransaction(t13);

% Test / Output Results
a1bal = agent1.wallet.currentBalanceAllCurrencies;
a2bal = agent2.wallet.currentBalanceAllCurrencies;
a3bal = agent3.wallet.currentBalanceAllCurrencies;

fprintf('Agent1 Current Balnace = %d\n', a1bal);
fprintf('Agent2 Current Balnace = %d\n', a2bal);
fprintf('Agent3 Current Balnace = %d\n', a3bal);

assert(a1bal == 425,'Error in Agent 1 balance, %d != 425', a1bal);
assert(a2bal == 400,'Error in Agent 2 balance, %d != 400', a2bal);
assert(a3bal == 675,'Error in Agent 3 balance, %d != 675', a3bal);

agent1.wallet.dump();
fprintf('\n');
agent2.wallet.dump();
fprintf('\n');
agent3.wallet.dump();

time = 2;
fprintf("\nTest Agent Wallets: time = %d\n",time);

agent1.wallet.applyDemurrage(Polis.PercentDemurage,time);
agent2.wallet.applyDemurrage(Polis.PercentDemurage,time);
agent3.wallet.applyDemurrage(Polis.PercentDemurage,time);

% Test / Output Results

a1bal = agent1.wallet.currentBalanceAllCurrencies;
a2bal = agent2.wallet.currentBalanceAllCurrencies;
a3bal = agent3.wallet.currentBalanceAllCurrencies;

fprintf('\nAgent1 Current Balnace = %d\n', a1bal);
fprintf('Agent2 Current Balnace = %d\n', a2bal);
fprintf('Agent3 Current Balnace = %d\n', a3bal);

assert(a1bal == 403.75,'Error in Agent 1 balance, %d != 403.75', a1bal);
assert(a2bal == 380.00,'Error in Agent 2 balance, %d != 380.00', a2bal);
assert(a3bal == 641.25,'Error in Agent 3 balance, %d != 641.25', a3bal);

agent1.wallet.dump();
fprintf('\n');
agent2.wallet.dump();
fprintf('\n');
agent3.wallet.dump();


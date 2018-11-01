%=====================================================
%
% Test function testAgentWallets
%
% Note: Work in progress
%
% Author: Jess
% Created: 2018.10.15
%=====================================================

agent1 = Agent(1, 1);
agent2 = Agent(2, 1);
agent3 = Agent(3, 1);

agent1.wallet.depositUBI(500,1);
agent2.wallet.depositUBI(500,1);
agent3.wallet.depositUBI(500,1);

% A1 buys from A2
t12 = Transaction(TransactionType.BUY, -100, agent1.id, 4, agent2.id, agent1.id, "Tran 4", 1);
t21 = Transaction(TransactionType.SELL, 100, agent1.id, 4, agent1.id, agent2.id, "Tran 4", 1);

agent1.wallet.submitBuySellTransaction(t12);
agent2.wallet.submitBuySellTransaction(t21);

% A2 buys from A3
t23 = Transaction(TransactionType.BUY, -200, agent2.id, 5, agent3.id, agent2.id, "Tran 5", 1);
t32 = Transaction(TransactionType.SELL, 200, agent2.id, 5, agent2.id, agent3.id, "Tran 5", 1);

agent2.wallet.submitBuySellTransaction(t23);
agent3.wallet.submitBuySellTransaction(t32);

% A1 buys from A3
t13 = Transaction(TransactionType.BUY, -50, agent1.id, 6, agent3.id, agent1.id, "Tran 6", 1);
t31 = Transaction(TransactionType.SELL, 50, agent1.id, 6, agent1.id, agent3.id, "Tran 6", 1);

agent1.wallet.submitBuySellTransaction(t13);
agent3.wallet.submitBuySellTransaction(t31);

% A3 buys from A1
t31 = Transaction(TransactionType.BUY, -75, agent3.id, 7, agent1.id, agent3.id, "Tran 7", 1);
t13 = Transaction(TransactionType.SELL, 75, agent3.id, 7, agent3.id, agent1.id, "Tran 7", 1);

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

% TODO - update asserts
agent1.wallet.applyDemurrage(Polis.PercentDemurage,2);
agent2.wallet.applyDemurrage(Polis.PercentDemurage,2);
agent3.wallet.applyDemurrage(Polis.PercentDemurage,2);

% Test / Output Results
fprintf('\nAgent1 Current Balnace = %d\n', agent1.wallet.currentBalanceAllCurrencies);
fprintf('Agent2 Current Balnace = %d\n', agent2.wallet.currentBalanceAllCurrencies);
fprintf('Agent3 Current Balnace = %d\n', agent3.wallet.currentBalanceAllCurrencies);

agent1.wallet.dump();
fprintf('\n');
agent2.wallet.dump();
fprintf('\n');
agent3.wallet.dump();


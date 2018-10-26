%=====================================================
%
% Test function testAgentWallets
%
% Note: Work in progress
%
% Author: Jess
% Created: 2018.10.15
%=====================================================

%{
UBI - Adding currency 
    - currencyAgentId is the owner of the currency (the agent affected)
    - sourceAgentId is Polis
    - destinationAgentId is the recipientof the addition to their currency
    - quantity is negative
Demurrage - Subtracting curreny
    - currencyAgentId is the owner of the currency (the agent affected)
    - sourceAgentId is Polis
    - destinationAgentId is the recipient of the subtraction of their currency
    - quantity is negative
Selling - subtracting currency
    - TODO
Buying - adding currency
    - currencyAgentId is the owner of the of the currency (the agent affected)
    - sourceAgentId is the agent id from where the currency is coming
    - destinationAgentId is the agent id that is deducting her currency
    - quantity is negative
%}

agent1 = Agent(1, datetime('now'));
agent2 = Agent(2, datetime('now'));
agent3 = Agent(3, datetime('now'));

% Add UBI
ubi1 = Transaction(TransactionType.UBI, 500, agent1.id, 1, Agent.PolisId, agent1.id, "Tran 1", datetime('now'));
ubi2 = Transaction(TransactionType.UBI, 500, agent2.id, 2, Agent.PolisId, agent2.id, "Tran 2", datetime('now'));
ubi3 = Transaction(TransactionType.UBI, 500, agent3.id, 3, Agent.PolisId, agent3.id, "Tran 3", datetime('now'));

agent1.wallet.submitTransaction(ubi1);
agent2.wallet.submitTransaction(ubi2);
agent3.wallet.submitTransaction(ubi3);

% A1 buys from A2
t12 = Transaction(TransactionType.BUY, -100, agent1.id, 4, agent2.id, agent1.id, "Tran 4", datetime('now'));
t21 = Transaction(TransactionType.SELL, 100, agent1.id, 4, agent1.id, agent2.id, "Tran 4", datetime('now'));

agent1.wallet.submitTransaction(t12);
agent2.wallet.submitTransaction(t21);

% A2 buys from A3
t23 = Transaction(TransactionType.BUY, -200, agent2.id, 5, agent3.id, agent2.id, "Tran 5", datetime('now'));
t32 = Transaction(TransactionType.SELL, 200, agent2.id, 5, agent2.id, agent3.id, "Tran 5", datetime('now'));

agent2.wallet.submitTransaction(t23);
agent3.wallet.submitTransaction(t32);

% A1 buys from A3
t13 = Transaction(TransactionType.BUY, -50, agent1.id, 6, agent3.id, agent1.id, "Tran 6", datetime('now'));
t31 = Transaction(TransactionType.SELL, 50, agent1.id, 6, agent1.id, agent3.id, "Tran 6", datetime('now'));

agent1.wallet.submitTransaction(t13);
agent3.wallet.submitTransaction(t31);

% A3 buys from A1
t31 = Transaction(TransactionType.BUY, -75, agent3.id, 7, agent1.id, agent3.id, "Tran 7", datetime('now'));
t13 = Transaction(TransactionType.SELL, 75, agent3.id, 7, agent3.id, agent1.id, "Tran 7", datetime('now'));

agent3.wallet.submitTransaction(t31);
agent1.wallet.submitTransaction(t13);

% Test / Output Results
a1bal = agent1.wallet.currentBalance;
a2bal = agent2.wallet.currentBalance;
a3bal = agent3.wallet.currentBalance;

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


%=====================================================
%
% Test function TestWallet
%
% Note: Work in progress
%
% Author: Jess
% Created: 2018.10.15
%=====================================================

agent1 = Agent(1,'TODO');
agent2 = Agent(2,'TODO');
agent3 = Agent(3,'TODO');

% A1 buys from A2
t12 = Transaction(TransactionType.BUY,-100,1,1,2,'TODO');
t21 = Transaction(TransactionType.SELL,100,1,1,2,'TODO');

agent1.wallet.addTransaction(t12);
agent2.wallet.addTransaction(t21);

% A2 buys from A3
t23 = Transaction(TransactionType.BUY,-200,2,2,3,'TODO');
t32 = Transaction(TransactionType.SELL,200,2,2,3,'TODO');

agent2.wallet.addTransaction(t23);
agent3.wallet.addTransaction(t32);

% A1 buys from A3
t13 = Transaction(TransactionType.BUY,-50,2,1,3,'TODO');
t31 = Transaction(TransactionType.SELL,50,2,1,3,'TODO');

agent1.wallet.addTransaction(t13);
agent3.wallet.addTransaction(t31);

a1bal = agent1.wallet.currentBalance;
a2bal = agent2.wallet.currentBalance;
a3bal = agent3.wallet.currentBalance;

fprintf('Agent1 Current Balnace = %d\n',a1bal);
fprintf('Agent2 Current Balnace = %d\n',a2bal);
fprintf('Agent3 Current Balnace = %d\n',a3bal);

assert(a1bal == -150,'Error in Agent 1 balance, balance != -150');
assert(a2bal == -100,'Error in Agent 2 balance, balance != -100');
assert(a3bal ==  250,'Error in Agent 3 balance, balance !=  250');



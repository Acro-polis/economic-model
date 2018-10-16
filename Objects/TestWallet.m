%=====================================================
%
% Test function TestWallet
%
% TODO = not finished
%
% Author: Jess
% Created: 2018.10.15
%=====================================================

agent1 = Agent(1,'TODO');
agent2 = Agent(2,'TODO');

t11 = Transaction('BUY',-100,1,1,2,'TODO');
t12 = Transaction('Sell',50,1,1,2,'TODO');

t21 = Transaction('SELL',100,2,2,1,'TODO');
t22 = Transaction('Buy',-50,2,2,1,'TODO');

agent1.Wallet.AddTransaction(t11);
agent1.Wallet.AddTransaction(t12);

agent2.Wallet.AddTransaction(t21);
agent2.Wallet.AddTransaction(t22);

fprint('Agent1 Current Balnace = %d',agent1.Wallet.CurrentBalance);
fprint('Agent2 Current Balnace = %d',agent2.Wallet.CurrentBalance);


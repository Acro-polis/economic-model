%=====================================================
%
% Test function testTrustedTransactions
%
%
% Author: Jess
% Created: 10.31.2018
%=====================================================

time = 1;

agent1 = Agent(1,time);
agent2 = Agent(2,time);
agent3 = Agent(3,time);
agent4 = Agent(4,time);

AM = connectedGraph(4);

fprintf("\nTesting with Connected Graph of 4 Agents\n\n");

agent1.wallet.depositUBI(100.0, time);
agent2.wallet.depositUBI(100.0, time);
agent3.wallet.depositUBI(100.0, time);
agent4.wallet.depositUBI(100.0, time);

% A1 buys from A2
t12 = Transaction(TransactionType.BUY, -50, agent1.id, 1, agent2.id, agent1.id, "Tran 1", time);
t21 = Transaction(TransactionType.SELL, 50, agent1.id, 1, agent1.id, agent2.id, "Tran 1", time);
agent1.wallet.submitBuySellTransaction(t12);
agent2.wallet.submitBuySellTransaction(t21);

mutualConnections = agent1.findMutualConnectionsWithAgent(AM, agent2.id);
availableBalance1 = agent1.wallet.availableBalanceForTransactionWithAgent(agent2.id, mutualConnections);
mutualConnections = agent2.findMutualConnectionsWithAgent(AM, agent1.id);
availableBalance2 = agent2.wallet.availableBalanceForTransactionWithAgent(agent1.id, mutualConnections);

fprintf("Available balance of agent 1 to transact with agent 2 = %.2f\n",availableBalance1);
agent1.wallet.dump;
fprintf("\nAvailable balance of agent 2 to transact with agent 1 = %.2f\n",availableBalance2);
agent2.wallet.dump;



%=====================================================
%
% Test function testTrustedTransactions
%
%
% Author: Jess
% Created: 10.31.2018
%=====================================================

time = 1;
AM = connectedGraph(4);
polis = Polis(AM);
polis.createAgents(time);

agent1 = polis.agents(1);
agent2 = polis.agents(2);
agent3 = polis.agents(3);
agent4 = polis.agents(4);

fprintf("\nTesting with Connected Graph of 4 Agents\n\n");

agent1.depositUBI(100.0, time);
agent2.depositUBI(100.0, time);
agent3.depositUBI(100.0, time);
agent4.depositUBI(100.0, time);

% A1 buys from A2
agent1.submitPurchaseWithDirectConnection(AM, 50, agent2, time);

mutualConnections = Agent.findMutualConnectionsWithAgent(AM, agent1.id, agent2.id);
availableBalance1 = agent1.availableBalanceForTransactionWithAgent(agent2.id, mutualConnections);
balances1 = agent1.individualBalancesForTransactionWithAgent(agent2.id, mutualConnections);

mutualConnections = Agent.findMutualConnectionsWithAgent(AM, agent2.id, agent1.id);
availableBalance2 = agent2.availableBalanceForTransactionWithAgent(agent1.id, mutualConnections);
balances2 = agent2.individualBalancesForTransactionWithAgent(agent1.id, mutualConnections);

fprintf("Available balance of agent 1 to transact with agent 2 = %.2f\n",availableBalance1);
agent1.dumpLedger;
fprintf("\nAvailable balance of agent 2 to transact with agent 1 = %.2f\n",availableBalance2);
agent2.dumpLedger;



%=====================================================
%
% Test function testAgents
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

fprintf("\nTesting Connected Graph Of 4 Agents\n\n");

commonConnections = agent1.findMutualConnectionsWithAgent(AM, agent2.id);

fprintf("Seeking common connections between agents 1 and 2\n");
fprintf("Common Connections = ");
fprintf("%d ",commonConnections);
fprintf("\nExpected Answer    = 3 4\n\n");

agentsUncommonConnections = agent1.findAgentsUncommonConnections(AM, agent2.id);

fprintf("Seeking uncommon connections of agent 2 to 1\n");
fprintf("Uncommon Connections = ");
fprintf("%d ",agentsUncommonConnections);
fprintf("\nExpected Answer      = \n\n");

myUncommonConnections = agent1.findMyUncommonConnectionsFromAgent(AM, agent2.id);

fprintf("Seeking agent1's uncommon connections from agent 2\n");
fprintf("Uncommon Connections = ");
fprintf("%d ",myUncommonConnections);
fprintf("\nExpected Answer      = \n\n");


AM(1,3) = 0;
fprintf("\nTesting Unconnected Graph Of 4 Agents, unconnecting agent 3 from agent 1\n\n");

commonConnections = agent1.findMutualConnectionsWithAgent(AM, agent2.id);

fprintf("Seeking common connections between agents 1 and 2\n");
fprintf("Common Connections = ");
fprintf("%d ",commonConnections);
fprintf("\nExpected Answer    = 4\n\n");

agentsUncommonConnections = agent1.findAgentsUncommonConnections(AM, agent2.id);

fprintf("Seeking uncommon connections of agent 2 to 1\n");
fprintf("Uncommon Connections = ");
fprintf("%d ",agentsUncommonConnections);
fprintf("\nExpected Answer      = 3\n\n");

myUncommonConnections = agent1.findMyUncommonConnectionsFromAgent(AM, agent2.id);

fprintf("Seeking agent1's uncommon connections from agent 2\n");
fprintf("Uncommon Connections = ");
fprintf("%d ",myUncommonConnections);
fprintf("\nExpected Answer      = \n\n");

AM(2,4) = 0;
fprintf("\nTesting Unconnected Graph Of 4 Agents, unconnecting agent 4 from agent 2\n\n");

commonConnections = agent1.findMutualConnectionsWithAgent(AM, agent2.id);

fprintf("Seeking common connections between agents 1 and 2\n");
fprintf("Common Connections = ");
fprintf("%d ",commonConnections);
fprintf("\nExpected Answer    = \n\n");

agentsUncommonConnections = agent1.findAgentsUncommonConnections(AM, agent2.id);

fprintf("Seeking uncommon connections of agent 2 to 1\n");
fprintf("Uncommon Connections = ");
fprintf("%d ",agentsUncommonConnections);
fprintf("\nExpected Answer      = 3\n\n");

myUncommonConnections = agent1.findMyUncommonConnectionsFromAgent(AM, agent2.id);

fprintf("Seeking agent1's uncommon connections from agent 2\n");
fprintf("Uncommon Connections = ");
fprintf("%d ",myUncommonConnections);
fprintf("\nExpected Answer      = 4\n\n");


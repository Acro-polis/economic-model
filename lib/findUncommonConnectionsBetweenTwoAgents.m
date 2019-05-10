function uncommonConnections = findUncommonConnectionsBetweenTwoAgents(AM, thisAgentId, thatAgentId)
%=====================================================
%
% Return the uncommon connections thatAgent posseses from thisAgent using
% the Adjacency Matrix.
%
% Algorithm: Subtract thatAgent's connections from thisAgents. The uncommon
% agents will be those having a quatity of +1, excluding thisAgent. If the
% agents are not connected, the returned list will be empty (as expected).
%
% Author: Jess
% Created: 2019.05.09
%=====================================================
    uncommonConnections = find((AM(thatAgentId,:) - AM(thisAgentId,:)) == 1);
    uncommonConnections = uncommonConnections(uncommonConnections ~= thisAgentId);
end


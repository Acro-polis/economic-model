function uncommonConnections = findAgentsUncommonConnections(AM, thisAgentId, thatAgentId)
    % Return the uncommon connections that agent posseses from
    % this agent. The uncommonConnections array contains the 
    % index ids of other agents in the Adjacency Matrix. 

    %
    % Algorithm: Subtract other agents connections from mine using the
    % Agency Matrix. The uncommon agents will correspond to those 
    % possessing a quantity of +1 (excluding me)
    %
    uncommonConnections = find((AM(thatAgentId,:) - AM(thisAgentId,:)) == 1);
    uncommonConnections = uncommonConnections(uncommonConnections ~= thisAgentId);
end


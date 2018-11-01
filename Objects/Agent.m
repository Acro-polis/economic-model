classdef Agent < handle
%================================================================
% Class Agent: Represents an agent in the system
%
% Created by Jess 09.13.18
%================================================================

    properties (SetAccess = private)
        id          uint32  % The agent id for this agent
        birthdate   uint32  % The birthdate for this agent = time dt
        wallet              % This agents wallet
    end
    
    properties (Constant)
    end
    
    methods
        
        function obj = Agent(id, timeStep)
            % AgentId must corresponds to a row id in an associated Agency Matrix
            assert(id ~= Polis.PolisId,'Error: Agent Id equals reserved PolisId!');
            obj.id = id;
            obj.birthdate = timeStep;
            obj.wallet = CryptoWallet(obj.id);
        end
        
        %
        % Algorithm: Sum two rows of the Agency Matrix and any element
        % that is equal to 2 is a mutual connection.
        %
        function mutualConnections = findMutualConnectionsWithAgent(obj, AM, otherAgentId)
            % Return common connections this agent shares with another.
            % The mutualConnections array contains the index numbers of
            % other agents in the Agency Matrix and excludes the other
            % agent.
            mutualConnections = find((AM(obj.id,:) + AM(otherAgentId,:)) == 2);
        end
        
        %
        % Algorithm: Subtract other agents connections from mine using the
        % Agency Matrix. The uncommon agents will correspond to those 
        % possessing a quantity of +1 (excluding me)
        %
        function uncommonConnections = findAgentsUncommonConnections(obj, AM, otherAgentId)
            % Return the uncommon connections another agent posseses from
            % this agent. The uncommonConnections array contains the index numbers of
            % other agents in the Agency Matrix. 
            uncommonConnections = find((AM(otherAgentId,:) - AM(obj.id,:)) == 1);
            uncommonConnections = uncommonConnections(uncommonConnections ~= obj.id);
        end

        %
        % Algorithm: Subtract my connections from the other agents using 
        % the Agency Matrix. The uncommon agents will correspond to those 
        % possessing a quantity of +1 (excluding the agent being tested)
        %
        function uncommonConnections = findMyUncommonConnectionsFromAgent(obj, AM, otherAgentId)
            % Return the uncommon connections this agent possesses from
            % another agent. The uncommonConnections array contains the index numbers of
            % other agents in the Agency Matrix. 
            uncommonConnections = find((AM(obj.id,:) - AM(otherAgentId,:)) == 1);
            uncommonConnections = uncommonConnections(uncommonConnections ~= otherAgentId);
        end

    end
end


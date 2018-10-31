classdef Agent < handle
%================================================================
% Class Agent
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
        
        %
        % Constructor
        %
        function obj = Agent(id, birthdate)
            assert(id ~= 0,'Error: Agent Id = reserved Polis Id');
            obj.id = id;
            obj.birthdate = birthdate;
            obj.wallet = CryptoWallet(obj.id);
        end
        
        %
        % Return the common connections I share with another agent 
        %
        % Algorithm: Sum two rows of the Agency Matrix and any element
        % that is equal to 2 is a mutual connection.
        %
        function mutualConnections = findMutualConnectionsWithAgent(obj, AM, agentId)
            % AM is the agency matrix
            mutualConnections = find((AM(obj.id,:) + AM(agentId,:)) == 2);
        end
        
        %
        % Return the uncommon connections another agent posseses from me
        %
        % Algorithm: Subtract other agents connections from mine using the
        % Agency Matrix. The uncommon agents will correspond to those 
        % possessing a quantity of +1 (excluding me)
        %
        function uncommonConnections = findAgentsUncommonConnections(obj, AM, agentId)
            % AM is the agency matrix
            uncommonConnections = find((AM(agentId,:) - AM(obj.id,:)) == 1);
            uncommonConnections = uncommonConnections(uncommonConnections ~= obj.id);
        end

        %
        % Return the uncommon connections I possess from another agent
        %
        % Algorithm: Subtract my connections from the other agents using 
        % the Agency Matrix. The uncommon agents will correspond to those 
        % possessing a quantity of +1 (excluding the agent being tested)
        %
        function uncommonConnections = findMyUncommonConnectionsFromAgent(obj, AM, agentId)
            % AM is the agency matrix
            uncommonConnections = find((AM(obj.id,:) - AM(agentId,:)) == 1);
            uncommonConnections = uncommonConnections(uncommonConnections ~= agentId);
        end

    end
end


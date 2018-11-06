classdef Agent < handle
%================================================================
% Class Agent: Represents an agent in the system
%
% Created by Jess 09.13.18
%================================================================

    properties (SetAccess = private)
        id          uint32          % The agent id for this agent
        birthdate   uint32          % The birthdate for this agent = time dt
        wallet      CryptoWallet    % This agents wallet
        paths                       % Possible network paths to sellers
    end
    
    properties (Constant)
    end
    
    methods
        
        function obj = Agent(id, timeStep)
            % AgentId must corresponds to a row id in an associated Agency Matrix
            assert(id ~= Polis.PolisId,'Error: Agent Id equals reserved PolisId!');
            obj.id = id;
            obj.birthdate = timeStep;
            obj.wallet = CryptoWallet(obj);
        end
        
        function output = findAllPaths(obj, AM)
            % Find all network paths to sellers available to this agent
            
            obj.paths = {};
            
            myConnections = obj.findMyConnections(AM);
            
            [~, indices] = size(myConnections);
            fprintf("Found %d connection(s) to start\n",indices);
            for index = 1:indices
                connection = myConnections(index);
                fprintf("Working on connection %d\n",connection);
                
                % TODO - if totally connected, take shortcut
                
                % Build all paths to other agents by recursivly finding 
                % all uncommon connections until the end of each path 
                % is reached
                output = obj.addNextConnection(AM, [obj.id, connection], obj.id, connection);
                            
            end
        end
        
        function paths = addNextConnection(obj, AM, currentPath, thisAgentId, thatAgentId)
            fprintf("Add next: CurrentPath = %d\n", currentPath);
            fprintf("Add next: This = %d, That = %d\n", thisAgentId, thatAgentId);
            uncommonConnections = obj.findAgentsUncommonConnections(AM, thisAgentId, thatAgentId);
            [~, indices] = size(uncommonConnections);
            paths = {};
            if indices > 0
            fprintf("Uncommon connections = %d, starting recursion\n",indices);
                for index = 1:indices
                    nextUncommonConnection = uncommonConnections(index);
                    fprintf("Searching uncommon connection = %d\n",nextUncommonConnection);
                    nextPath = [currentPath , nextUncommonConnection];
                    paths = [paths ; {obj.addNextConnection(AM, nextPath, thatAgentId, nextUncommonConnection)}];
                    %fprintf("New Paths = %d\n",newPaths);
                end
            else
                fprintf("Uncommon connections = 0, returning\n");
                paths = currentPath;
            end
            %fprintf("Paths = %d\n",paths);
        end
        
        %
        % Algorithm: Sum two rows of the Adjancey Matrix and any element
        % that is equal to 2 is a mutual connection.
        %
        function mutualConnections = findMutualConnectionsWithAgent(obj, AM, otherAgentId)
            % Return common connections this agent shares with another.
            % The mutualConnections array contains the index numbers of
            % other agents in the Agency Matrix and excludes the other
            % agent.
            mutualConnections = find((AM(obj.id,:) + AM(otherAgentId,:)) == 2);
        end
        
        
        function connections = findMyConnections(obj,AM)
            % Return the index number of my connections using the Adjacency
            % Matrix
            connections = find(AM(obj.id,:) ~= 0);
        end
        
    end
    
    methods (Static)
        
        function connections = findConnectionsForAgent(AM, agentId)
            % Return the index number of connections for agentId using the
            % Adjacency Matrix
            connections = find(AM(agentId,:) ~= 0);
        end
        
        %
        % Algorithm: Subtract other agents connections from mine using the
        % Agency Matrix. The uncommon agents will correspond to those 
        % possessing a quantity of +1 (excluding me)
        %
        function uncommonConnections = findAgentsUncommonConnections(AM, thisAgentId, thatAgentId)
            % Return the uncommon connections that agent posseses from
            % this agent. The uncommonConnections array contains the 
            % index ids of other agents in the Adjacency Matrix. 
            uncommonConnections = find((AM(thatAgentId,:) - AM(thisAgentId,:)) == 1);
            uncommonConnections = uncommonConnections(uncommonConnections ~= thisAgentId);
        end

        %
        % Algorithm: Subtract my connections from the other agents using 
        % the Agency Matrix. The uncommon agents will correspond to those 
        % possessing a quantity of +1 (excluding the agent being tested)
        %
        function uncommonConnections = findMyUncommonConnectionsFromAgent(AM, thisAgentId, thatAgentId)
            % Return the uncommon connections this agent possesses from
            % that agent. The uncommonConnections array contains the 
            % index ids of other agents in the Adjacency Matrix. 
            uncommonConnections = find((AM(thisAgentId,:) - AM(thatAgentId,:)) == 1);
            uncommonConnections = uncommonConnections(uncommonConnections ~= thatAgentId);
        end

    end

end


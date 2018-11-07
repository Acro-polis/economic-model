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
        allPaths                    % Possible network paths to sellers
    end
    
    properties (Constant)
        maximumSearchLevels = 10;
    end
    
    methods
        
        function obj = Agent(id, timeStep)
            % AgentId must corresponds to a row id in an associated Agency Matrix
            assert(id ~= Polis.PolisId,'Error: Agent Id equals reserved PolisId!');
            obj.id = id;
            obj.birthdate = timeStep;
            obj.wallet = CryptoWallet(obj);
        end
        
        function findAllPathsToAgent(obj, AM, targetAgentId)
            % Find all network paths to sellers available to this agent
            
            obj.allPaths = {};
            myConnections = obj.findMyConnections(AM);
            [~, indices] = size(myConnections);
            fprintf("Found %d connection(s) to start\n",indices);
            for index = 1:indices
                connection = myConnections(index);
                fprintf("Working on connection %d\n",connection);
                
                % TODO - if totally connected, take shortcut
                
                % Build all paths to other agents by recursivly finding 
                % all uncommon connections until the end of each path 
                % is reached, or the maximum search level is reached or the
                % buyer (this agent) is reached.
                obj.findNextConnection(AM, 0, [obj.id, connection], obj.id, connection, targetAgentId);
                            
            end
        end
        
        function findNextConnection(obj, AM, searchLevel, currentPath, thisAgentId, thatAgentId, targetAgentId)
            
            searchLevel = searchLevel + 1;
            if searchLevel > Agent.maximumSearchLevels
                fprintf("Maximum Search Levels Reached = %d\n",searchLevel);
                obj.allPaths = [obj.allPaths ; {currentPath}];
                return;
            end
            
            fprintf("Add next: CurrentPath = %d\n", currentPath);
            fprintf("Add next: This = %d, That = %d\n", thisAgentId, thatAgentId);
            
            uncommonConnections = obj.findAgentsUncommonConnections(AM, thisAgentId, thatAgentId);
            uncommonConnections = obj.removeBuyerIfExists(uncommonConnections);
            [~, indices] = size(uncommonConnections);
            if indices > 0 
            fprintf("----Uncommon connections = %d\n",uncommonConnections);
                for index = 1:indices
                    nextUncommonConnection = uncommonConnections(index);
                    fprintf("Searching uncommon connection = %d\n",nextUncommonConnection);
                    nextPath = [currentPath , nextUncommonConnection];
                    obj.findNextConnection(AM, searchLevel, nextPath, thatAgentId, nextUncommonConnection, targetAgentId);
                end
            else
                fprintf("Uncommon connections = 0, returning\n");
                obj.allPaths = [obj.allPaths ; {currentPath}];
            end
        end
        
        function result = removeBuyerIfExists(obj, uncommonConnections)
            % Remove this agent (the buyer) from the list, if present.
            % This prevents infinite looping should a circle of connections
            % exist (e.g A to B to C to D to A).
            result = uncommonConnections;
            indexOfMe = find(uncommonConnections(1,:) == obj.id);
            if indexOfMe > 0
                result(indexOfMe) = [];
            end
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
        
        function ouputPaths(obj)
            % Output all paths to the console
            thePaths = obj.allPaths;
            [totPaths, ~] = size(thePaths);
            fprintf("\nThere are %d total paths\n", totPaths);
            for i = 1:totPaths
                fprintf("\nPath = %d\n",i);
                aPath = cell2mat(thePaths(i,1));
                [~, segments] = size(aPath);
                fprintf("Path = ");
                for j = 1:segments
                    fprintf(" %d ",aPath(1,j));
                end
                fprintf("\n");
            end
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


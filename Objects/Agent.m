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
        maximumSearchLevels = 30;
    end
    
    methods
        
        function obj = Agent(id, timeStep)
            % AgentId must corresponds to a row id in an associated Agency Matrix
            assert(id ~= Polis.PolisId,'Error: Agent Id equals reserved PolisId!');
            obj.id = id;
            obj.birthdate = timeStep;
            obj.wallet = CryptoWallet(obj);
        end
        
        function findAllNetworkPathsToAgent(obj, AM, targetAgentId)
            % For this agent, find all possible network paths to the 
            % target agent, avoiding circular loops and limited by the 
            % maximum of search levels
            assert(targetAgentId ~= 0 && targetAgentId ~= obj.id,"Error, invalid targetAgentId");
            
            % Use cells since we expect paths to be of unequal length
            obj.allPaths = {}; 
            
            % Start with my connections and recursively discover each 
            % neighbors uncommon connections thereby building the paths 
            % to the target agent
            myConnections = obj.findMyConnections(AM);
            [~, indices] = size(myConnections);
            
            for index = 1:indices
                connection = myConnections(index);
                % TODO - if totally connected, take shortcut
                obj.findNextNetworkConnection(AM, 0, [obj.id, connection], obj.id, connection, targetAgentId);
            end
        end
        
        function findNextNetworkConnection(obj, AM, searchLevel, currentPath, thisAgentId, thatAgentId, targetAgentId)
            % Recursively explore any uncommon connections between
            % thisAgentId and thatAgentId until the targetAgentId is found
            % or we run out of uncommon connections (and ensureing we do
            % not traverse the object agent (obj.id))
            
            fprintf("\nStarting Path = [");
            fprintf(" %d ", currentPath);
            fprintf("]\nAgents: This = %d, That = %d, Target = %d, Search Level = %d\n\n", thisAgentId, thatAgentId, targetAgentId, searchLevel);
            
            if thatAgentId == targetAgentId
                % Found it, we are done!
                obj.allPaths = [obj.allPaths ; {currentPath}];
                fprintf("!!!! Done: Found Target Agent = %d !!!!\n\n",targetAgentId);
                return;
            end
            
            % If we run out of uncommon connections before we find the
            % target then we are out of luck, they are not connected and we
            % return (see below). Same if we run out of search levels
            if searchLevel > Agent.maximumSearchLevels
                % No luck, go home empty handed
                fprintf("**** Abandon Ship - Max Level Reached ****\n\n");
                return;
            else
                searchLevel = searchLevel + 1;
            end
            
            % Find the uncommon connections (remove obj.id if it exists)
            uncommonConnections = obj.removeBuyerIfExists(obj.findAgentsUncommonConnections(AM, thisAgentId, thatAgentId));
            [~, indices] = size(uncommonConnections);
            if indices > 0 
                fprintf("----Uncommon Connections = [");
                fprintf(" %d ", uncommonConnections);
                fprintf("]\n");
                for index = 1:indices
                    nextAgent = uncommonConnections(index);
                    fprintf("----Searching Uncommon Connection = %d\n",nextAgent);
                    nextPathSegment = [currentPath , nextAgent];
                    obj.findNextNetworkConnection(AM, searchLevel, nextPathSegment, thatAgentId, nextAgent, targetAgentId);
                end
            else
                % No luck, go home empty handed
                fprintf("**** Abandon Ship - No More Uncommon Connections ****\n\n");
                return;
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


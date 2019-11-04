classdef PathFinder < handle
    %PATHFINDER Encapsulates walking the adjacency matrix
    %   TODO
    
    properties (SetAccess = private)
        polis   Polis
    end
    
    methods (Access = public)
        
        function obj = PathFinder(polis)
            %PATHFINDER Construct an instance of this class
            %   TBD
            obj.polis = polis;
        end

        function allPaths = findAllNetworkPathsFromThisAgentToThatAgent(obj, thisAgent, thatAgent)
            % For thisAgent, find all possible network paths to the 
            % thatAgent avoiding circular loops and limited 
            % by the maximum of search levels. Sort results from shortest 
            % path to the longest path
            assert(thatAgent.id ~= 0 && thatAgent.id ~= thisAgent.id,"Error, Invalid Target Agent");
            
            % Use cells since we expect paths to be of unequal length
            allPaths = {};
            
            % Start with thisAgent's connections and recursively explore 
            % each neighbors uncommon connections thereby building all the 
            % existing paths to thatAgent
            myConnections = obj.findAgentsConnections(thisAgent);
            [~, indices] = size(myConnections);
            
            for index = 1:indices
                connection = myConnections(index);
                % Concatenate the return paths
                allPaths = [allPaths ; obj.findNextNetworkConnection(0, thisAgent.id, [thisAgent.id, connection], thisAgent.id, connection, thatAgent.id, {})];
%RF                 allPaths = [allPaths ; obj.findNextNetworkConnection(AM, 0, [obj.id, connection], obj.id, connection, targetAgentId, {})];
            end
            
            allPaths = PathFinder.sortPaths(allPaths);
                                   
        end
        
        function connections = findAgentsConnections(obj, theAgent)
            % Return the index number of the agents connections using the 
            % Adjacency Matrix
            connections = find(obj.polis.AM(theAgent.id,:) ~= 0);
        end
        
        function selectedPath = findALiquidPathForTheTransactionAmount(obj, paths, amount)
            % Return the first path that supports the transaction. Paths
            % should be ordered from the shortest to the longest.
            selectedPath = [];
            [indices, ~] = size(paths);
            for index = 1:indices
                path = cell2mat(paths(index, 1));
                logStatement("\nPath %d of %d\n", [index, indices], 2, obj.polis.LoggingLevel)
                logIntegerArray("Analyzing Path",path, 2, obj.polis.LoggingLevel);
                if obj.polis.pathFinder.checkIfPathIsLiquid(path, amount) 
                    selectedPath = path;
                    return;
                end
            end
        end
        
        function pathIsGood = checkIfPathIsLiquid(obj, path, amount)
            % Determine if this path carries enough balance to support the
            % transaction amount
            pathIsGood = true;
            logIntegerArray("Working on path", path, 2, obj.polis.LoggingLevel);
            [~, segments] = size(path);
            for segment = 2:segments
                thisAgentId = path(segment - 1);
                thatAgentId = path(segment);
                logStatement("Checking segment %d to %d\n", [thisAgentId, thatAgentId], 2, obj.polis.LoggingLevel);
                mutualAgentIds = PathFinder.findMutualConnectionsWithAgent(obj.polis.AM, thisAgentId, thatAgentId);
                availableBalance = obj.polis.agents(thisAgentId).availableBalanceForTransactionWithAgent(thatAgentId, mutualAgentIds);
                logStatement("Available Balance = %.2f, Amount = %.2f\n", [availableBalance, amount], 2, obj.polis.LoggingLevel);
                if availableBalance <= amount
                    logStatement("Path failed, no balance\n", [], 2, obj.polis.LoggingLevel);
                    pathIsGood = false;
                    % Record Agent that caused the liquidity failure
                    lf = LiquidityFailure(thisAgentId, thatAgentId, amount, mutualAgentIds, path, "", obj.polis.currentTime);
                    obj.polis.liquidityFailures = [obj.polis.liquidityFailures; lf];
                    %lf.dump;
                    break;
                end
            end
        end
        
        function uncommonConnectionAgentIds = findAllIndirectConnectionsBetweenTwoAgents(obj, searchLevel, uncommonConnectionAgentIds, thisAgentId, thatAgentId)
            % For two connected agents, thisAgent and thatAgent, find the
            % uncommon connections thatAgent has from thisAgent. Recursivly
            % repeat the process until the search level is reached or we
            % run out of uncommon connections. Remove any duplicates along
            % the way.
            
            logLevel = 2;
            
            if searchLevel > obj.polis.maximumSearchLevels % Must exceed search level to return
              logStatement("\nSearch Maximum Reached for This Agent = %d, That Agent = %d, Search Level = %d\n", [thisAgentId, thatAgentId, searchLevel], logLevel, obj.polis.LoggingLevel);
              return; 
            else
                searchLevel = searchLevel + 1;
            end
            
            % Find uncommon connections and remove any already found
            logStatement("\nProcessing This Agent = %d, That Agent = %d, Search Level = %d\n", [thisAgentId, thatAgentId, searchLevel], logLevel, obj.polis.LoggingLevel);
            newUncommonConnections = findUncommonConnectionsBetweenTwoAgents(obj.polis.AM, thisAgentId, thatAgentId);
            newUncommonConnections = setdiff(newUncommonConnections, uncommonConnectionAgentIds);

            if numel(newUncommonConnections) == 0
                logStatement("\nNone Found for This Agent = %d, That Agent = %d, Search Level = %d\n", [thisAgentId, thatAgentId, searchLevel], logLevel, obj.polis.LoggingLevel);
                return;
            else
                logIntegerArray("Found Uncommon Connections", newUncommonConnections, 2, obj.polis.LoggingLevel);
                
                % Accumulate what we found
                uncommonConnectionAgentIds = [uncommonConnectionAgentIds , newUncommonConnections];
                
                % Recursivley search for more indirect connections
                for i = 1:numel(newUncommonConnections)
                    uncommonConnectionAgentId = newUncommonConnections(i);
                    uncommonConnectionAgentIds = obj.findAllIndirectConnectionsBetweenTwoAgents(searchLevel, uncommonConnectionAgentIds, thatAgentId, uncommonConnectionAgentId);
                end
            end
        end
        
    end

        
    methods (Access = private)
    
       function paths = findNextNetworkConnection(obj, searchLevel, originatingAgentId, currentPath, thisAgentId, thatAgentId, targetAgentId, paths)
            % Recursively explore any uncommon connections between
            % thisAgentId and thatAgentId until the targetAgentId is found
            % or we run out of uncommon connections and ensureing we do
            % not traverse the originating agent.
            
            logIntegerArray("Starting Path", currentPath, 2, obj.polis.LoggingLevel)
            logStatement("Agents: This = %d, That = %d, Target = %d, Search Level = %d\n\n", [thisAgentId, thatAgentId, targetAgentId, searchLevel], 4, obj.polis.LoggingLevel);
            
            if thatAgentId == targetAgentId
                % Found it, we are done!
                paths = [paths ; {currentPath}];
                logStatement("!!!! Done: Found Target Agent = %d !!!!\n\n", targetAgentId, 2, obj.polis.LoggingLevel);
                return;
            end
            
            % If we run out of uncommon connections before we find the
            % target then we are out of luck, they are not connected and we
            % return (see below). Same if we run out of search levels
            % Must exceed search level to return
            if searchLevel > obj.polis.maximumSearchLevels 
                % No luck, go home empty handed
                logStatement("**** Abandon Ship - Max Level Reached ****\n\n", [], 2, obj.polis.LoggingLevel);
                return;
            else
                searchLevel = searchLevel + 1;
            end
            
            % Find the uncommon connections (remove thisAgent, if it exists)
            uncommonConnections = obj.removeThisAgentIfPresent(originatingAgentId, findUncommonConnectionsBetweenTwoAgents(obj.polis.AM, thisAgentId, thatAgentId));
            [~, indices] = size(uncommonConnections);
            if indices > 0 
                logIntegerArray("---- Uncommon Connections", uncommonConnections, 2, obj.polis.LoggingLevel)
                for index = 1:indices
                    nextAgent = uncommonConnections(index);
                    logStatement("---- Searching Uncommon Connection = %d\n", nextAgent, 2, obj.polis.LoggingLevel);
                    nextPathSegment = [currentPath , nextAgent];
                    paths = obj.findNextNetworkConnection(searchLevel, originatingAgentId, nextPathSegment, thatAgentId, nextAgent, targetAgentId, paths);
                end
            else
                % No luck, go home empty handed
                logStatement("**** Abandon Ship - No More Uncommon Connections ****\n\n", [], 2, obj.polis.LoggingLevel);
                return;
            end
       end    

       function result = removeThisAgentIfPresent(obj, thisAgentId, uncommonConnections)
            % Remove this agent (the buyer) from the list, if present.
            % This prevents infinite looping should a circle of connections
            % exist (for example: A to B to C to D to A).
            
            result = uncommonConnections;
            
            [~, indices] = size(uncommonConnections);
            if indices == 0
                % Case of no connections at all
                return;
            end
            
            indexOfThisAgent = find(uncommonConnections(1,:) == thisAgentId);
            if indexOfThisAgent > 0
                result(indexOfThisAgent) = [];
            end
       end
       
    end

    methods (Static)

        function paths = sortPaths(paths)
            % Order the the paths shortest length to longest length
            % (the expected format is that which is returned from 
            % findAllNetworkPathsToAgent()).
            [~, columns] = sort(cellfun(@length, paths));
            paths = paths(columns);
        end
        
        function mutualConnections = findMutualConnectionsWithAgent(AM, thisAgentId, thatAgentId)
            % Return common connections this agent shares with another 
            % (that agent). The mutualConnections array contains the index 
            % numbers of other agents in the Agency Matrix and excludes 
            % the other agent.
            
            %
            % Algorithm: Sum two rows of the Adjancey Matrix and any element
            % that is equal to 2 is a mutual connection.
            %
            mutualConnections = find((AM(thisAgentId,:) + AM(thatAgentId,:)) == 2);
        end
        
        function uncommonConnections = findMyUncommonConnectionsFromAgent(AM, thisAgentId, thatAgentId)
            % Return the uncommon connections this agent possesses from
            % that agent. The uncommonConnections array contains the 
            % index ids of other agents in the Adjacency Matrix. 

            %
            % Algorithm: Subtract my connections from the other agents using 
            % the Agency Matrix. The uncommon agents will correspond to those 
            % possessing a quantity of +1 (excluding the agent being tested)
            %
            uncommonConnections = find((AM(thisAgentId,:) - AM(thatAgentId,:)) == 1);
            uncommonConnections = uncommonConnections(uncommonConnections ~= thatAgentId);
        end
        
        function connections = findConnectionsForAgent(AM, agentId)
            % Return the index number of connections for agentId using the
            % Adjacency Matrix
            connections = find(AM(agentId,:) ~= 0);
        end

        function result = areAgentsConnected(AM, thisAgentId, thatAgentId)
            % Is this agent directly connected to that agent?
            if AM(thisAgentId, thatAgentId) == 1
                result = true;
            else 
                result = false;
            end
        end

        function result = isAgentCompletelyConnected(AM, agentId)
            % Is this agent connected to everybody?
            [~, connections] = size(PathFinder.findConnectionsForAgent(AM, agentId));
            [~, possibleConnections] = size(AM);
            if connections == (possibleConnections - 1)
                result = true;
            else 
                result = false;
            end
        end
        
    end
end


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
            % target agent (thatAgent), avoiding circular loops and limited 
            % by the maximum of search levels. Sort results from shortest 
            % path to the longest path
            assert(thatAgent.id ~= 0 && thatAgent.id ~= thisAgent.id,"Error, Invalid Target Agent");
            
            % Use cells since we expect paths to be of unequal length
            allPaths = {};
            
            % Start with thisAgent's connections and recursively discover 
            % each neighbors uncommon connections thereby building all the 
            % paths to thatAgent that might exist
            myConnections = obj.findAgentsConnections(thisAgent);
            [~, indices] = size(myConnections);
            
            for index = 1:indices
                connection = myConnections(index);
                % Concatenate the return paths
                allPaths = [allPaths ; obj.findNextNetworkConnection(0, thisAgent.id, [thisAgent.id, connection], thisAgent.id, connection, thatAgent.id, {})];
%RF                 allPaths = [allPaths ; obj.findNextNetworkConnection(AM, 0, [obj.id, connection], obj.id, connection, targetAgentId, {})];
            end
            
            allPaths = Agent.sortPaths(allPaths);
                                   
        end
        
        function connections = findAgentsConnections(obj, theAgent)
            % Return the index number of the agents connections using the 
            % Adjacency Matrix
            connections = find(obj.polis.AM(theAgent.id,:) ~= 0);
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

end


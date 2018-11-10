classdef Agent < handle
%================================================================
% Class Agent: Represents an agent in the system
%
% Created by Jess 09.13.18
%================================================================

    properties (SetAccess = private)
        id          uint32          % The agent id for this agent
        birthdate   uint32          % The birthdate for this agent = time dt
    end
    
    properties (GetAccess = private, SetAccess = private)
        wallet      CryptoWallet    % This agents wallet
    end
    
    properties (Constant)
        maximumSearchLevels = 10;
    end
    
    methods (Access = public)

        function obj = Agent(id, timeStep)
            % AgentId must corresponds to a row id in an associated Agency Matrix
            assert(id ~= Polis.PolisId,'Error: Agent Id equals reserved PolisId!');
            obj.id = id;
            obj.birthdate = timeStep;
            obj.wallet = CryptoWallet(obj);
        end
               
        %
        % Network exploration methods
        %
        
        function allPaths = findAllNetworkPathsToAgent(obj, AM, targetAgentId)
            % For this agent, find all possible network paths to the 
            % target agent, avoiding circular loops and limited by the 
            % maximum of search levels. Sort results from shortest path to
            % the longest path
            assert(targetAgentId ~= 0 && targetAgentId ~= obj.id,"Error, Invalid targetAgentId");
            
            % Use cells since we expect paths to be of unequal length
            allPaths = {};
            
            % Check for a direct connection. If it exists, that's all we
            % need (because if the direct connection fails then all more 
            % complicated paths will fail in a buy / sell situation too)
            if obj.areWeConnected(AM, targetAgentId)
                allPaths = {[obj.id targetAgentId]};
                fprintf("\nAgents are directly connected\n");
                return;
            end
            
            % Start with my connections (obj.id) and recursively discover 
            % each neighbors uncommon connections thereby building the 
            % paths to the target agent, if there is a path.
            myConnections = obj.findMyConnections(AM);
            [~, indices] = size(myConnections);
            
            for index = 1:indices
                connection = myConnections(index);
                % Concatenate the return paths
                allPaths = [allPaths ; obj.findNextNetworkConnection(AM, 0, [obj.id, connection], obj.id, connection, targetAgentId, {})];
            end
            
            allPaths = Agent.sortPaths(allPaths);
                                   
        end
                                
        function result = areWeConnected(obj, AM, targetAgentId)
            % Is this agent directly connected to the target agent?
            result = false;
            if AM(obj.id,targetAgentId) == 1
                result = true;
            end
        end
        
        function result = amICompletelyConnected(obj, AM)
            % Is this agent connected to everybody?
            result = false;
            [~, connections] = size(obj.findMyConnections(AM));
            [~, possibleConnections] = size(AM);
            if connections == (possibleConnections - 1)
                result = true;
            end
        end

        function connections = findMyConnections(obj, AM)
            % Return the index number of my connections using the 
            % Adjacency Matrix
            connections = find(AM(obj.id,:) ~= 0);
        end
                
        %
        % Wallet: Wrappers
        %
        
        function depositUBI(obj, amount, timeStep)
            % Deposit UBI
            obj.wallet.depositUBI(amount, timeStep);
        end
        
        function applyDemurrage(obj, percentage, timeStep)
            % Apply Demurrage
            obj.wallet.applyDemurrage(percentage, timeStep);
        end
        
        function balance = currentBalanceAllCurrencies(obj)
            % Return current balance all currencies
            balance = obj.wallet.currentBalanceAllCurrencies;
        end
        
        function balance = availableBalanceForTransactionWithAgent(obj, thatAgentId, mutualAgentIds)
            % Return the available balance for a proposed transaction with
            % thatAgent
            balance = obj.wallet.availableBalanceForTransactionWithAgent(thatAgentId, mutualAgentIds);
        end

        function [agentIds, balances] = individualBalancesForTransactionWithAgent(obj, thatAgentId, mutualAgentIds)
            % Return the currency agents and their individual balances that
            % thatAgent will accept for a transaction
            [agentIds, balances] = obj.wallet.individualBalancesForTransactionWithAgent(thatAgentId, mutualAgentIds);
        end
        
        function transacted = submitPurchaseWithDirectConnection(obj, AM, amount, thatAgent, timeStep)
            % submit a purchase transaction between two directly connected
            % agents
            % TODO - assert they are connected
            transacted = obj.wallet.submitPurchaseWithDirectConnection(AM, amount, thatAgent, timeStep);
        end

        function transacted = submitPurchase(obj, AM, paths, amount, targetAgentId, timeStep)
            % Submit a purachase - work in progress
            transacted = obj.wallet.submitPurchase(AM, paths, amount, targetAgentId, timeStep);
        end
                    
        function addTransaction(obj, transaction)
            % Submit a transaction to be added to the agents wallet. Note
            % this should never be called except by code written within the
            % wallet. Someday I'll figure out how to close this hole, or
            % not. TODO!
            obj.wallet.addTransaction(transaction);
        end
        
        function dumpLedger(obj)
            % Write the contents of the wallet's ledger to the console
            obj.wallet.dump;
        end
        
    end
        
    methods (Static)
                
        function paths = sortPaths(paths)
            % Order the the network paths shortest length to longest length
            % (the expected format is that which is returned from 
            % findAllNetworkPathsToAgent()).
            [~, columns] = sort(cellfun(@length, paths));
            paths = paths(columns);
        end
        
        function connections = findConnectionsForAgent(AM, agentId)
            % Return the index number of connections for agentId using the
            % Adjacency Matrix
            connections = find(AM(agentId,:) ~= 0);
        end
                
        function mutualConnections = findMutualConnectionsWithAgent(AM, thisAgent, thatAgentId)
            % Return common connections this agent shares with another 
            % (that agent). The mutualConnections array contains the index 
            % numbers of other agents in the Agency Matrix and excludes 
            % the other agent.
            
            %
            % Algorithm: Sum two rows of the Adjancey Matrix and any element
            % that is equal to 2 is a mutual connection.
            %
            mutualConnections = find((AM(thisAgent,:) + AM(thatAgentId,:)) == 2);
        end

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
      
        function logPaths(paths)
            % Output all paths to the console (format is a cell array with
            % each element being an integer array signifying a path through
            % the network from one agent to another and the path lentghs
            % are expected to be different).
            [totPaths, ~] = size(paths);
            fprintf("\nThere are %d total paths\n", totPaths);
            for i = 1:totPaths
                fprintf("\nPath = %d\n",i);
                aPath = cell2mat(paths(i,1));
                logIntegerArray("Path",aPath);
            end
        end

    end

    methods (Access = private)

       function paths = findNextNetworkConnection(obj, AM, searchLevel, currentPath, thisAgentId, thatAgentId, targetAgentId, paths)
            % Recursively explore any uncommon connections between
            % thisAgentId and thatAgentId until the targetAgentId is found
            % or we run out of uncommon connections (and ensureing we do
            % not traverse the object agent (obj.id))
            
            logIntegerArray("Starting Path", currentPath)
            fprintf("Agents: This = %d, That = %d, Target = %d, Search Level = %d\n\n", thisAgentId, thatAgentId, targetAgentId, searchLevel);
            
            if thatAgentId == targetAgentId
                % Found it, we are done!
                paths = [paths ; {currentPath}];
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
            
            % Find the uncommon connections (remove this agent (obj.id), if it exists)
            uncommonConnections = obj.removeMeIfIAmPresent(obj.findAgentsUncommonConnections(AM, thisAgentId, thatAgentId));
            [~, indices] = size(uncommonConnections);
            if indices > 0 
                logIntegerArray("---- Uncommon Connections", uncommonConnections)
                for index = 1:indices
                    nextAgent = uncommonConnections(index);
                    fprintf("---- Searching Uncommon Connection = %d\n",nextAgent);
                    nextPathSegment = [currentPath , nextAgent];
                    paths = obj.findNextNetworkConnection(AM, searchLevel, nextPathSegment, thatAgentId, nextAgent, targetAgentId, paths);
                end
            else
                % No luck, go home empty handed
                fprintf("**** Abandon Ship - No More Uncommon Connections ****\n\n");
                return;
            end
        end

       function result = removeMeIfIAmPresent(obj, uncommonConnections)
            % Remove this agent (me, the buyer) from the list, if present.
            % This prevents infinite looping should a circle of connections
            % exist (for example: A to B to C to D to A).
            
            result = uncommonConnections;
            
            [~, indices] = size(uncommonConnections);
            if indices == 0
                % Case of no connections at all
                return;
            end
            
            indexOfMe = find(uncommonConnections(1,:) == obj.id);
            if indexOfMe > 0
                result(indexOfMe) = [];
            end
       end
       
    end
    
end


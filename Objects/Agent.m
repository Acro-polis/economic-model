classdef Agent < handle
%================================================================
% Class Agent: 
%
% Represents an Agent in the system
%
% Created by Jess 09.13.18
%================================================================

    properties (SetAccess = public, GetAccess = public)
        
    end
    
    properties (SetAccess = private)
        id                  uint32          % The agent id for this agent
        birthdate           uint32          % The birthdate for this agent = time dt
        polis               Polis           % Store a reference to the gods
        numberItemsSold                     % Array of items sold each time step
        numberItemsPurchased                % Array of items purchased each time step
        initialInventory    uint32          % Initial inventory
        isBuyer             uint32          % Is a buyer, true or false
        isSeller            uint32          % Is a seller, true or false
    end
    
    properties (GetAccess = private, SetAccess = private)
        wallet      CryptoWallet    % This agents wallet
    end
    
    properties (Constant)
        % Agent Commerce Types
        TYPE_BUYER_SELLER            = 3000;
        TYPE_BUYER_ONLY              = 3001;
        TYPE_SELLER_ONLY             = 3002;
        TYPE_NONPARTICIPANT          = 3003;
    end
    
    properties (Dependent)
        availabeInventory
        agentCommerceRoleType
    end

    methods
        
        function inventory = get.availabeInventory(obj)
            inventory = obj.initialInventory - sum(obj.numberItemsSold(1,:));
        end
        
        function type = get.agentCommerceRoleType(obj)
            if obj.isBuyer && obj.isSeller 
                type = Agent.TYPE_BUYER_SELLER;
            elseif obj.isBuyer 
                type = Agent.TYPE_BUYER_ONLY;
            elseif obj.isSeller 
                type = Agent.TYPE_SELLER_ONLY;
            else
                type = Agent.TYPE_NONPARTICIPANT;
            end
        end
    end
    
    methods (Access = public)

        function obj = Agent(id, polis, birthdate, totalTimeSteps)
            % AgentId must corresponds to a row id in an associated 
            % Adjacency Matrix. Agents should only be created by the Polis
            % object which maintains the list of all agents in the system.
            assert(id ~= Polis.PolisId,'Error: Agent Id equals reserved PolisId!');
            obj.id = id;
            obj.birthdate = birthdate;
            obj.polis = polis;
            obj.wallet = CryptoWallet(obj);
            obj.isBuyer = false;
            obj.isSeller = false;
            obj.numberItemsSold = zeros(1,totalTimeSteps);
            obj.numberItemsPurchased = zeros(1,totalTimeSteps);
            obj.initialInventory = 0;
        end
               
        %
        % Seller / Buyer related
        %
        
        function setupAsSeller(obj, initialInventory)
            % Setup agent as a seller
            obj.isSeller = true;
            obj.initialInventory = initialInventory;
        end
        
        function recordSale(obj, numItems, timeStep)
            % Record a sale
            assert(obj.availabeInventory >= numItems,"Error: unexpectedly out of inventory");
            obj.numberItemsSold(1,timeStep) = obj.numberItemsSold(1,timeStep) + numItems;
        end
        
        function recordPurchase(obj, numItems, timeStep)
            % Record a purchase
            obj.numberItemsPurchased(1,timeStep) = obj.numberItemsPurchased(1,timeStep) + numItems;
        end
        
        function setupAsBuyer(obj)
            % Setup agent as a buyer
            obj.isBuyer = true;
        end

        function inventory = availabeInventoryAtTimestep(obj, timeStep)
            % Return the available inventory at time timeStep
            inventory = obj.initialInventory - sum(obj.numberItemsSold(1,1:timeStep));
        end

        function sales = totalSalesAtTimestep(obj, timeStep)
            % Return the total purchases through time timeStep
            sales = sum(obj.numberItemsSold(1,1:timeStep));
        end
        
        function purchases = totalPurchasesAtTimestep(obj, timeStep)
            % Return the total purchases through time timeStep
            purchases = sum(obj.numberItemsPurchased(1,1:timeStep));
        end
        
        function sales = salesAtTimestep(obj, timeStep)
            % Return the total purchases at time timeStep
            sales = obj.numberItemsSold(1,timeStep);
        end
        
        function purchases = purchasesAtTimestep(obj, timeStep)
            % Return the total purchases at time timeStep
            purchases = obj.numberItemsPurchased(1,timeStep);
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
               
        function selectedPath = findALiquidPathForTheTransactionAmount(obj, AM, paths, amount)
            % Return the first path that supports the transaction. Paths
            % should be ordered from the shortest to the longest.
            selectedPath = [];
            [indices, ~] = size(paths);
            for index = 1:indices
                path = cell2mat(paths(index, 1));
                fprintf("\nPath %d of %d\n", index, indices);
 %Log               logIntegerArray("Analyzing Path",path);
                if obj.checkIfPathIsValid(AM, path, amount) 
                    selectedPath = path;
                    return;
                end
            end
        end
                
        function result = areWeConnected(obj, AM, targetAgentId)
            % Is this agent directly connected to the target agent?
            result = false;
            if AM(obj.id, targetAgentId) == 1
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
        % Transaction methods
        %
        
        function result = submitPurchase(obj, AM, numberItems, amount, targetAgent, timeStep)
            % Submit a purachase between this agent (obj.id) and the 
            % targetAgent. The transaction may require intermediary agents
            % to complete the transaction. Validate the transaction and if
            % it passes complete the transaction.

            result = TransactionType.FAILED_UNKNOWN;
            
            % Insure seller has enough inventory
            if targetAgent.availabeInventory < numberItems
                result = TransactionType.FAILED_NO_INVENTORY;
                return;
            end
            
            % Find all possible paths
            paths = obj.findAllNetworkPathsToAgent(AM, targetAgent.id);
%Log            obj.logPaths(paths);
            if isempty(paths)
                result = TransactionType.FAILED_NO_PATH_FOUND;
                return;
            end
            
            % Find a path that satisfies the transaction criteria (e.g. all
            % agents have enough balance)
            path = obj.findALiquidPathForTheTransactionAmount(AM, paths, amount);
%Log            logIntegerArray("Ths selected path is",path);
            if isempty(path) 
                result = TransactionType.FAILED_NO_LIQUIDITY;
                return;
            end

            % Okay, we are good to go.
            [~, numberAgents] = size(path);
            if numberAgents == 2
                targetAgent = obj.polis.agents(path(1,2));
                mutualAgentIds = Agent.findMutualConnectionsWithAgent(AM, obj.id, targetAgent.id);
                obj.wallet.commitPurchaseWithDirectConnection(amount, targetAgent, mutualAgentIds, timeStep);
            else
                % Create an array of Agents from the paths array
                agents = Agent.empty;
                for i = 2:numberAgents
                    agents = [agents , obj.polis.agents(path(1,i))];
                end
                obj.wallet.commitPurchaseWithIndirectConnection(AM, amount, agents, timeStep);
            end
            result = TransactionType.TRANSACTION_SUCCEEDED;
        end
        
        %
        % Wallet: Wrappers 
        %        

        %
        % Methods supporting transactions
        %
                
        function depositUBI(obj, amount, timeStep)
            % Deposit UBI
            obj.wallet.depositUBI(amount, timeStep);
        end
        
        function applyDemurrage(obj, percentage, timeStep)
            % Apply Demurrage
            obj.wallet.applyDemurrage(percentage, timeStep);
        end
        
        function addTransaction(obj, transaction)
            % Submit a transaction to be added to the agents wallet. Note
            % this should never be called except by code written within the
            % wallet. Someday I'll figure out how to close this hole, or
            % not. It's due to the design appraoch to write into two
            % different agents ledgers at the same time. One simplification
            % creates a different hurdle. TODO!
            obj.wallet.addTransaction(transaction);
        end

        
        function commitPurchaseSegment(obj, amount, thatAgent, mutualAgentIds, buyTransactionType, sellTransactionType, tramsactionId, timeStep)
            % Submit a transaction to be added to the agents wallet. Note
            % this should never be called except by code written within the
            % wallet. Someday I'll figure out how to close this hole, or
            % not. It's due to the design appraoch to write into two
            % different agents ledgers at the same time. One simplification
            % creates a different hurdle. TODO!
            obj.wallet.commitPurchaseSegment(amount, thatAgent, mutualAgentIds, buyTransactionType, sellTransactionType, tramsactionId, timeStep);
        end

        %        
        % Methods supporting balance calculations
        %

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
                    
        function balance = balanceAllTransactionsAtTimestep(obj, timeStep)
            % Return the balance at time timeStep, all currencies
            balance = obj.wallet.balanceAllTransactionsAtTimestep(timeStep);
        end

        function balance = balanceForTransactionTypeAtTimestep(obj, transactionType, timeStep)
            % Return the balance at time timeStep for the transactionType
            balance = obj.wallet.balanceForTransactionTypeAtTimestep(transactionType, timeStep);
        end
        
        %        
        % Methods supporting data logging
        %
        
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
        
        function pathIsGood = checkIfPathIsValid(obj, AM, path, amount)
            % Determine if this path carries enough balance to support the
            % transaction amount
            pathIsGood = true;
            logIntegerArray("Working on path",path);
            [~, segments] = size(path);
            for segment = 2:segments
                thisAgentId = path(segment - 1);
                thatAgentId = path(segment);
                fprintf("Checking segment %d to %d\n",thisAgentId, thatAgentId);
                mutualAgentIds = Agent.findMutualConnectionsWithAgent(AM, thisAgentId, thatAgentId);
                availableBalance = obj.polis.agents(thisAgentId).availableBalanceForTransactionWithAgent(thatAgentId, mutualAgentIds);
                fprintf("Available Balance = %.2f, Amount = %.2f\n",availableBalance, amount);
                if availableBalance <= amount
                    fprintf("Path failed, no balance\n");
                    pathIsGood = false;
                    break;
                end
            end
        end
        
       function paths = findNextNetworkConnection(obj, AM, searchLevel, currentPath, thisAgentId, thatAgentId, targetAgentId, paths)
            % Recursively explore any uncommon connections between
            % thisAgentId and thatAgentId until the targetAgentId is found
            % or we run out of uncommon connections (and ensureing we do
            % not traverse the object agent (obj.id))
            
            %logIntegerArray("Starting Path", currentPath)
            %fprintf("Agents: This = %d, That = %d, Target = %d, Search Level = %d\n\n", thisAgentId, thatAgentId, targetAgentId, searchLevel);
            
            if thatAgentId == targetAgentId
                % Found it, we are done!
                paths = [paths ; {currentPath}];
                %fprintf("!!!! Done: Found Target Agent = %d !!!!\n\n",targetAgentId);
                return;
            end
            
            % If we run out of uncommon connections before we find the
            % target then we are out of luck, they are not connected and we
            % return (see below). Same if we run out of search levels
            if searchLevel > obj.polis.maximumSearchLevels
                % No luck, go home empty handed
                %fprintf("**** Abandon Ship - Max Level Reached ****\n\n");
                return;
            else
                searchLevel = searchLevel + 1;
            end
            
            % Find the uncommon connections (remove this agent (obj.id), if it exists)
            uncommonConnections = obj.removeMeIfIAmPresent(obj.findAgentsUncommonConnections(AM, thisAgentId, thatAgentId));
            [~, indices] = size(uncommonConnections);
            if indices > 0 
                %logIntegerArray("---- Uncommon Connections", uncommonConnections)
                for index = 1:indices
                    nextAgent = uncommonConnections(index);
                    %fprintf("---- Searching Uncommon Connection = %d\n",nextAgent);
                    nextPathSegment = [currentPath , nextAgent];
                    paths = obj.findNextNetworkConnection(AM, searchLevel, nextPathSegment, thatAgentId, nextAgent, targetAgentId, paths);
                end
            else
                % No luck, go home empty handed
                %fprintf("**** Abandon Ship - No More Uncommon Connections ****\n\n");
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


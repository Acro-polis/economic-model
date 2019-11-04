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
        wallet              Wallet    % This agents wallet
    end
    
    properties (Constant)
        % Agent Commerce Types
        TYPE_BUYER_SELLER            = 3000;
        TYPE_BUYER_ONLY              = 3001;
        TYPE_SELLER_ONLY             = 3002;    % Deprecated in V1.3.0
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
    
       output = findAgentsUncommonConnections(arg1, arg2, arg3);

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
            obj.wallet = Wallet(obj);
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
% Refactor - moved to PathFinder        
%         function allPaths = findAllNetworkPathsToAgent(obj, AM, targetAgentId)
%             % For this agent, find all possible network paths to the 
%             % target agent, avoiding circular loops and limited by the 
%             % maximum of search levels. Sort results from shortest path to
%             % the longest path
%             assert(targetAgentId ~= 0 && targetAgentId ~= obj.id,"Error, Invalid targetAgentId");
%             
%             % Use cells since we expect paths to be of unequal length
%             allPaths = {};
%             
%             % Start with my connections (obj.id) and recursively discover 
%             % each neighbors uncommon connections thereby building the 
%             % paths to the target agent, if there is a path.
%             myConnections = obj.findMyConnections(AM);
%             [~, indices] = size(myConnections);
%             
%             for index = 1:indices
%                 connection = myConnections(index);
%                 % Concatenate the return paths
%                 allPaths = [allPaths ; obj.findNextNetworkConnection(AM, 0, [obj.id, connection], obj.id, connection, targetAgentId, {})];
%             end
%             
%             allPaths = Agent.sortPaths(allPaths);
%                                    
%         end
               
% Refactor - Moved to PathFinder        
%         function selectedPath = findALiquidPathForTheTransactionAmount(obj, paths, amount)
%             % Return the first path that supports the transaction. Paths
%             % should be ordered from the shortest to the longest.
%             selectedPath = [];
%             [indices, ~] = size(paths);
%             for index = 1:indices
%                 path = cell2mat(paths(index, 1));
%                 logStatement("\nPath %d of %d\n", [index, indices], 2, obj.polis.LoggingLevel)
%                 logIntegerArray("Analyzing Path",path, 2, obj.polis.LoggingLevel);
%                 if obj.polis.pathFinder.checkIfPathIsLiquid(path, amount) 
%                     selectedPath = path;
%                     return;
%                 end
%             end
%         end
        
% Refactor - Moved to PathFinder        
%         function result = areWeConnected(obj, AM, targetAgentId)
%             % Is this agent directly connected to the target agent?
%             result = false;
%             if AM(obj.id, targetAgentId) == 1
%                 result = true;
%             end
%         end
        
% Refactor - Moved to PathFinder        
%         function result = amICompletelyConnected(obj, AM)
%             % Is this agent connected to everybody?
%             result = false;
%             [~, connections] = size(obj.findMyConnections(AM));
%             [~, possibleConnections] = size(AM);
%             if connections == (possibleConnections - 1)
%                 result = true;
%             end
%         end
        
% Refactor - Moved to Path Finder        
%         function connections = findMyConnections(obj, AM)
%             % Return the index number of my connections using the 
%             % Adjacency Matrix
%             connections = find(AM(obj.id,:) ~= 0);
%         end
        
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

        function commitPurchaseWithDirectConnection(obj, amount, targetAgent, mutualAgentIds, time)
            obj.wallet.commitPurchaseWithDirectConnection(amount, targetAgent, mutualAgentIds, time); 
        end
        
        function commitPurchaseWithIndirectConnection(obj, amount, agentsOnPath, time)
            obj.wallet.commitPurchaseWithIndirectConnection(obj.polis.AM, amount, agentsOnPath, time);
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
        
        function [agentIds, balances] = currenciesInWalletByAgent(obj, timeStep)
            % Return the balance for all currencies in the wallet at the
            % time = timeStep
            [agentIds, balances] = obj.wallet.currenciesInWalletByAgent(timeStep);
        end

        %        
        % Methods supporting data logging
        %
        
        function total = totalLedgerRecords(obj)
            % Return the total number of ledger records
            total = obj.wallet.totalLedgerRecords;
        end
        
        function total = totalLedgerRecordsForTransactionTypeSeries(obj, transactionTypeSeries, timeStep)
            % Return the total number of ledger records that correspond to
            % the TransactionTypeSeries
            assert(transactionTypeSeries == TransactionType.BUY_SELL_SERIES || transactionTypeSeries == TransactionType.BUY_SELL_TRANSITIVE_SERIES,"Error: This method is not yet set up for series provided!");
            total = obj.wallet.totalLedgerRecordsForTransactionTypeSeries(transactionTypeSeries, timeStep);
        end
        
        function dumpLedger(obj)
            % Write the contents of the wallet's ledger to the console
            obj.wallet.dump;
        end

        %
        % Intended for testing or debugging
        %
        function clearAsSeller(obj)
            % Remove seller designation
            obj.isSeller = false;
        end

        function resetSellerStatus(obj, sellerStatus, inventory)
            % state = true or false
            obj.isSeller = sellerStatus;
            obj.initialInventory = inventory;
        end
        
        function resetBuyerStatus(obj, buyerStatus)
            obj.isBuyer = buyerStatus;
        end

    end

    methods (Static)
         
% Refactor - Moved to PathFinder                   
%         function paths = sortPaths(paths)
%             % Order the the network paths shortest length to longest length
%             % (the expected format is that which is returned from 
%             % findAllNetworkPathsToAgent()).
%             [~, columns] = sort(cellfun(@length, paths));
%             paths = paths(columns);
%         end
        
%         function connections = findConnectionsForAgent(AM, agentId)
%             % Return the index number of connections for agentId using the
%             % Adjacency Matrix
%             connections = find(AM(agentId,:) ~= 0);
%         end
                
% Refactor - Moved to PathFinder
%         function mutualConnections = findMutualConnectionsWithAgent(AM, thisAgentId, thatAgentId)
%             % Return common connections this agent shares with another 
%             % (that agent). The mutualConnections array contains the index 
%             % numbers of other agents in the Agency Matrix and excludes 
%             % the other agent.
%             
%             %
%             % Algorithm: Sum two rows of the Adjancey Matrix and any element
%             % that is equal to 2 is a mutual connection.
%             %
%             mutualConnections = find((AM(thisAgentId,:) + AM(thatAgentId,:)) == 2);
%         end

%         function uncommonConnections = findAgentsUncommonConnections(AM, thisAgentId, thatAgentId)
%             % Return the uncommon connections that agent posseses from
%             % this agent. The uncommonConnections array contains the 
%             % index ids of other agents in the Adjacency Matrix. 
% 
%             %
%             % Algorithm: Subtract other agents connections from mine using the
%             % Agency Matrix. The uncommon agents will correspond to those 
%             % possessing a quantity of +1 (excluding me)
%             %
%             uncommonConnections = find((AM(thatAgentId,:) - AM(thisAgentId,:)) == 1);
%             uncommonConnections = uncommonConnections(uncommonConnections ~= thisAgentId);
%         end

% Refactor - Moved to PathFinder
%         function uncommonConnections = findMyUncommonConnectionsFromAgent(AM, thisAgentId, thatAgentId)
%             % Return the uncommon connections this agent possesses from
%             % that agent. The uncommonConnections array contains the 
%             % index ids of other agents in the Adjacency Matrix. 
% 
%             %
%             % Algorithm: Subtract my connections from the other agents using 
%             % the Agency Matrix. The uncommon agents will correspond to those 
%             % possessing a quantity of +1 (excluding the agent being tested)
%             %
%             uncommonConnections = find((AM(thisAgentId,:) - AM(thatAgentId,:)) == 1);
%             uncommonConnections = uncommonConnections(uncommonConnections ~= thatAgentId);
%         end
      
    end

    methods (Access = private)
              
% Refactor - moved to PathFinder        
%         function pathIsGood = checkIfPathIsValid(obj, AM, path, amount)
%             % Determine if this path carries enough balance to support the
%             % transaction amount
%             pathIsGood = true;
%             logIntegerArray("Working on path", path, 2, obj.polis.LoggingLevel);
%             [~, segments] = size(path);
%             for segment = 2:segments
%                 thisAgentId = path(segment - 1);
%                 thatAgentId = path(segment);
%                 logStatement("Checking segment %d to %d\n", [thisAgentId, thatAgentId], 2, obj.polis.LoggingLevel);
%                 mutualAgentIds = PathFinder.findMutualConnectionsWithAgent(AM, thisAgentId, thatAgentId);
%                 availableBalance = obj.polis.agents(thisAgentId).availableBalanceForTransactionWithAgent(thatAgentId, mutualAgentIds);
%                 logStatement("Available Balance = %.2f, Amount = %.2f\n", [availableBalance, amount], 2, obj.polis.LoggingLevel);
%                 if availableBalance <= amount
%                     logStatement("Path failed, no balance\n", [], 2, obj.polis.LoggingLevel);
%                     pathIsGood = false;
%                     % Record Agent that caused the liquidity failure
%                     lf = LiquidityFailure(thisAgentId, thatAgentId, amount, mutualAgentIds, path, "", obj.polis.currentTime);
%                     obj.polis.liquidityFailures = [obj.polis.liquidityFailures; lf];
%                     %lf.dump;
%                     break;
%                 end
%             end
%         end
        
% Refactor - moved to PathFinder        
%        function paths = findNextNetworkConnection(obj, AM, searchLevel, currentPath, thisAgentId, thatAgentId, targetAgentId, paths)
%             % Recursively explore any uncommon connections between
%             % thisAgentId and thatAgentId until the targetAgentId is found
%             % or we run out of uncommon connections (and ensureing we do
%             % not traverse the object agent (obj.id))
%             
%             logIntegerArray("Starting Path", currentPath, 2, obj.polis.LoggingLevel)
%             logStatement("Agents: This = %d, That = %d, Target = %d, Search Level = %d\n\n", [thisAgentId, thatAgentId, targetAgentId, searchLevel], 4, obj.polis.LoggingLevel);
%             
%             if thatAgentId == targetAgentId
%                 % Found it, we are done!
%                 paths = [paths ; {currentPath}];
%                 logStatement("!!!! Done: Found Target Agent = %d !!!!\n\n", targetAgentId, 2, obj.polis.LoggingLevel);
%                 return;
%             end
%             
%             % If we run out of uncommon connections before we find the
%             % target then we are out of luck, they are not connected and we
%             % return (see below). Same if we run out of search levels
%             % Must exceed search level to return
%             if searchLevel > obj.polis.maximumSearchLevels 
%                 % No luck, go home empty handed
%                 logStatement("**** Abandon Ship - Max Level Reached ****\n\n", [], 2, obj.polis.LoggingLevel);
%                 return;
%             else
%                 searchLevel = searchLevel + 1;
%             end
%             
%             % Find the uncommon connections (remove this agent (obj.id), if it exists)
%             uncommonConnections = obj.removeMeIfIAmPresent(findUncommonConnectionsBetweenTwoAgents(AM, thisAgentId, thatAgentId));
%             [~, indices] = size(uncommonConnections);
%             if indices > 0 
%                 logIntegerArray("---- Uncommon Connections", uncommonConnections, 2, obj.polis.LoggingLevel)
%                 for index = 1:indices
%                     nextAgent = uncommonConnections(index);
%                     logStatement("---- Searching Uncommon Connection = %d\n", nextAgent, 2, obj.polis.LoggingLevel);
%                     nextPathSegment = [currentPath , nextAgent];
%                     paths = obj.findNextNetworkConnection(AM, searchLevel, nextPathSegment, thatAgentId, nextAgent, targetAgentId, paths);
%                 end
%             else
%                 % No luck, go home empty handed
%                 logStatement("**** Abandon Ship - No More Uncommon Connections ****\n\n", [], 2, obj.polis.LoggingLevel);
%                 return;
%             end
%         end

% Refactor - Moved to PathFinder
%        function result = removeMeIfIAmPresent(obj, uncommonConnections)
%             % Remove this agent (me, the buyer) from the list, if present.
%             % This prevents infinite looping should a circle of connections
%             % exist (for example: A to B to C to D to A).
%             
%             result = uncommonConnections;
%             
%             [~, indices] = size(uncommonConnections);
%             if indices == 0
%                 % Case of no connections at all
%                 return;
%             end
%             
%             indexOfMe = find(uncommonConnections(1,:) == obj.id);
%             if indexOfMe > 0
%                 result(indexOfMe) = [];
%             end
%        end
       
    end
    
end


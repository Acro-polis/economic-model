classdef Agent < handle
%================================================================
%AGENT Represents an Agent in the system
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
            % Submit a transaction to be added to the agents wallet. This
            % should be called from the TransactionManager only.
            obj.wallet.addTransaction(transaction);
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
    end

    methods (Access = private)       
    end
    
end


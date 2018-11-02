classdef CryptoWallet < handle
%================================================================
% Class CryptoWallet
%
% Created by Jess 10.15.18
%================================================================    
%{ 

Transaction conventions

UBI - Adding UBI
    - currencyAgentId correspnds to the currency type 
    - sourceAgentId is Polis
    - destinationAgentId is the recipient agent
    - quantity is positive
Demurrage - Subtracting Demurrage
    - currencyAgentId correspnds to the currency type 
    - sourceAgentId is Polis
    - destinationAgentId is the recipient agent
    - quantity is negative
Selling - subtracting currency
    - currencyAgentId correspnds to the currency type 
    - sourceAgentId coressponds to the buying agent
    - destinationAgentId is the recipient agent
    - quantity is positive
Buying - adding currency
    - currencyAgentId correspnds to the currency type 
    - sourceAgentId coressponds to the selling agent
    - destinationAgentId is the recipient agent
    - quantity is negative

%}

    properties (SetAccess=private)
        agentId         % Agent who owns this wallet            
        transactions    % This wallets ledger
    end
    
    properties (Dependent)
        currentBalanceAllCurrencies  % Current balance for all currencies
    end
    
    methods
        
        function obj = CryptoWallet(agentId)
            % The agentId is the agent who owns this wallet
            obj.agentId = agentId;
            obj.transactions = Transaction.empty;
        end
        
        %
        % Transactional Functions
        %

        function depositUBI(obj, amount, timeStep)
            % Deposit UBI into this wallet
            % TODO - make transaction id unique and the datetime = dt
            % (time)
            obj.addTransaction(Transaction(TransactionType.UBI, amount, obj.agentId, Polis.uniqueId(), Polis.PolisId, obj.agentId, "UBI", timeStep));
        end
        
        function applyDemurrage(obj, percentage, timeStep)
            % Subtract demurrage from this account
            
            %
            % Find the unique set of agent currency types
            %
            agentIds = unique(cell2mat(get(obj.transactions,'currencyAgentId')));
            
            %
            % Loop over each type and apply demurrage
            %
            [indices, ~] = size(agentIds);
            for index = 1:indices
                %
                % Calculate the balance for this agent
                %
                amount = -1.0*percentage*obj.balanceForAgentsCurrency(agentIds(index));
                
                %
                % Record the transaction
                %
                % TODO - make transaction id unique
                t = Transaction(TransactionType.DEMURRAGE, amount, agentIds(index), Polis.uniqueId(), Polis.PolisId, obj.agentId, "DEMURRAGE", timeStep);
                obj.addTransaction(t);
            end
        end
        
        function submitBuySellTransaction(obj, newTransaction)
            % TODO - rewrite for transitive trust, encapusulate the sell
            % portion and make the method just a buy signature
            if newTransaction.type ~= TransactionType.BUY && newTransaction.type ~= TransactionType.SELL
                %
                % TODO - Raise error
                %
            else
                obj.addTransaction(newTransaction);
            end
        end
        
        function submitPurchase(obj, amount, agentPath)
            % Process a purchase
            
            % 1. Test that there is enough money avaiable for each path
            % 2. Build transaction set for each path (Buy and Sell)
            % 3. Record transactions
            
        end
        
        
        %
        % Balance Calculations
        %
        
        function balance = availableBalanceForTransactionWithAgent(obj, agentId, mutualAgentIds)
            % Total balance available to transact from common agents
            % including target agent (agentId) and oneself (obj.Id)
            balance = 0.0;
            balance = balance + obj.balanceForCurrencyAgentId(obj.agentId);
            balance = balance + obj.balanceForCurrencyAgentId(agentId);
            [~, numIndexes] = size(mutualAgentIds);
            for index = 1:numIndexes
                balance = balance + obj.balanceForAgentsCurrency(mutualAgentIds(index));
            end
        end
        
        function currentBalance = get.currentBalanceAllCurrencies(obj)
            % Total balance, irrespective of agent dependencies
            currentBalance = sum([obj.transactions.amount]);
        end
       
        %
        % Output
        %
        
        function dump(obj)
            % Log this agents complete ledger
            fprintf('\nLedger for Agent Id = %d\n',obj.agentId);
            fprintf('id\t type amount\t a/s/d/t\t note\t date\n');
            [rows, ~] = size(obj.transactions);
            for i = 1:rows
                obj.transactions(i).dump();
            end
        end
        
    end
    
    methods (Access = private)
                
        function addTransaction(obj, newTransaction)
            % Add a ledger record (building a vector (N x 1 transactions))
            obj.transactions = [obj.transactions ; newTransaction]; 
        end

        function balance = balanceForAgentsCurrency(obj, agentId)
            % Total balance of this agents currency
            results = findobj(obj.transactions,'currencyAgentId', agentId);
            balance = sum([results.amount]);
        end

    end

end


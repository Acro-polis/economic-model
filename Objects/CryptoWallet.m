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
        agent         Agent % Agent who owns this wallet            
        transactions        % This wallets ledger
    end
    
    properties (Dependent)
        currentBalanceAllCurrencies  % Current balance for all currencies
    end
    
    methods
        
        function obj = CryptoWallet(agent)
            % This wallet belongs to this agent
            obj.agent = agent;
            obj.transactions = Transaction.empty;
        end
        
        %
        % Transactional Functions
        %

        function depositUBI(obj, amount, timeStep)
            % Deposit UBI into this wallet
            t = Transaction(TransactionType.UBI, amount, obj.agent.id, Polis.uniqueId(), Polis.PolisId, obj.agent.id, "UBI", timeStep);
            obj.addTransaction(t);
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
                if amount < 0.0
                    t = Transaction(TransactionType.DEMURRAGE, amount, agentIds(index), Polis.uniqueId(), Polis.PolisId, obj.agent.id, "DEMURRAGE", timeStep);
                    obj.addTransaction(t);
                end
            end
        end
               
        function transacted = submitPurchaseWithDirectConnection(obj, amount, AM, agent, timeStep)
            % Process a purchase transaction with a direct connection. 
            % 1. Test that there is enough money for the transaction
            % 2. Build the transaction set (Buy and Sell) for each currency
            % 3. Record transactions
            assert(obj.agent.id ~= agent.id,"Attempting a transaction with yourself - Preposterous!");
            
            mutualAgentIds = obj.agent.findMutualConnectionsWithAgent(AM, agent.id);
            availableBalance = obj.availableBalanceForTransactionWithAgent(agent.id, mutualAgentIds);
            
            if availableBalance >= amount
                
                [agentIds, balances] = obj.individualBalancesForTransactionWithAgent(agent.id, mutualAgentIds);
                [indices, ~] = size(balances);
                remainingAmount = amount;
                
                for index = 1:indices
                    
                    currencyAgentId = agentIds(index);
                    balance = balances(index);
                    assert(balance >= 0,"Wallet.submitPurchase, balance < 0)!");
                    
                    if balance ~= 0 
                        if remainingAmount > balance
                            % Buy/Sell using balance and continue
                            tAB = Transaction(TransactionType.BUY, -balance, currencyAgentId, Polis.uniqueId(), obj.agent.id, agent.id, "BUY", timeStep);
                            obj.addTransaction(tAB);
                            tBA = Transaction(TransactionType.SELL, balance, currencyAgentId, Polis.uniqueId(), agent.id, obj.agent.id, "SELL", timeStep);
                            agent.wallet.addTransaction(tBA);
                            remainingAmount = remainingAmount - balance;
                        else
                            % Buy/Sell using remainingAmount and break
                            tAB = Transaction(TransactionType.BUY, -remainingAmount, currencyAgentId, Polis.uniqueId(), obj.agent.id, agent.id, "BUY", timeStep);
                            obj.addTransaction(tAB);
                            tBA = Transaction(TransactionType.SELL, remainingAmount, currencyAgentId, Polis.uniqueId(), agent.id, obj.agent.id, "SELL", timeStep);
                            agent.wallet.addTransaction(tBA);
                            break;
                        end
                    end
                end
                transacted = true;
            else
                transacted = false;
            end
            
        end
        
        %
        % Balance Calculations
        %
        function [agentIds, balances] = individualBalancesForTransactionWithAgent(obj, agentId, mutualAgentIds)
            % Return the balance for each individual currency from common
            % agents, the target agent (agentId) and oneself (obj.Id). 
            % Order by agentId, common agents, then onself.
            agentIds = agentId;
            balances = obj.balanceForAgentsCurrency(agentId);
            [~, indices] = size(mutualAgentIds);
            for index = 1:indices
                mutualAgentId = mutualAgentIds(index);
                agentIds = [agentIds ; mutualAgentId];
                balances = [balances ; obj.balanceForAgentsCurrency(mutualAgentId)];
            end
            agentIds = [agentIds ; obj.agent.id];
            balances = [balances ; obj.balanceForAgentsCurrency(obj.agent.id)];
        end
        
        function balance = availableBalanceForTransactionWithAgent(obj, agentId, mutualAgentIds)
            % Total balance available to transact from common agents
            % including target agent (agentId) and oneself (obj.Id)
            balance = 0.0;
            balance = balance + obj.balanceForAgentsCurrency(obj.agent.id);
            balance = balance + obj.balanceForAgentsCurrency(agentId);
            [~, numIndexes] = size(mutualAgentIds);
            for index = 1:numIndexes
                balance = balance + obj.balanceForAgentsCurrency(mutualAgentIds(index));
            end
        end
        
        function currentBalance = get.currentBalanceAllCurrencies(obj)
            % Total balance, irrespective of agent dependencies
            currentBalance = sum([obj.transactions.amount]);
        end

        function addTransaction(obj, newTransaction)
            % Add a ledger record (building a vector (N x 1 transactions))
            obj.transactions = [obj.transactions ; newTransaction]; 
        end

        %
        % Output
        %
        
        function dump(obj)
            % Log this agents complete ledger
            fprintf('\nLedger for Agent Id = %d\n',obj.agent.id);
            fprintf('id\t type amount\t c/s/d/t\t note\t date\n');
            [rows, ~] = size(obj.transactions);
            for i = 1:rows
                obj.transactions(i).dump();
            end
        end
        
    end
    
    methods (Access = private)
                
        function balance = balanceForAgentsCurrency(obj, agentId)
            % Total balance of this agents currency
            results = findobj(obj.transactions,'currencyAgentId', agentId);
            balance = sum([results.amount]);
        end

    end

end


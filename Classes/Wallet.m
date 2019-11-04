classdef Wallet < handle
%================================================================
%WALLET This is a wallet. Each Agent has one. 
% It's designed to be a private attribute of each Agent
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
Selling - adding currency
    - currencyAgentId corresponds to the currency type 
    - sourceAgentId corresponds to the buying agent
    - destinationAgentId is the recipient agent
    - quantity is positive
Buying - subtracting currency
    - currencyAgentId correspnds to the currency type 
    - sourceAgentId coressponds to the selling agent
    - destinationAgentId is the recipient agent
    - quantity is negative

%}

    properties (SetAccess=private)
        agent         Agent     % Agent who owns this wallet            
        transactions            % This wallets ledger
        currencyAgentBalances   % Denormalize the balance by currencyAgentId for performance reasons
    end
    
    properties (Dependent)
        currentBalanceAllCurrencies  % Current balance for all currencies
    end
    
    methods
        
        function obj = Wallet(agent)
            % This wallet belongs to this agent
            obj.agent = agent;
            obj.transactions = Transaction.empty;
            obj.currencyAgentBalances = zeros(agent.polis.numberOfAgents,2);
        end
                
        function addTransaction(obj, newTransaction)
            % Add a ledger record (building a vector (N x 1 transactions))
            obj.transactions = [obj.transactions ; newTransaction];
            
            % Update the running balance - this denormalization is done purely for performance,
            % See Wallet.balanceForAgentsCurrency
            currencyAgentId = newTransaction.currencyAgentId;
            newBalance = obj.currencyAgentBalances(currencyAgentId,2) + newTransaction.amount;
            obj.currencyAgentBalances(currencyAgentId, 2) = newBalance;
        end
        
        function depositUBI(obj, amount, timeStep)
            % Deposit UBI into this wallet
            t = Transaction(TransactionType.UBI, amount, obj.agent.id, obj.agent.polis.uniqueId(), Polis.PolisId, obj.agent.id, "UBI", timeStep);
            obj.addTransaction(t);
        end

        function applyDemurrage(obj, percentage, timeStep)
            % Subtract demurrage from this account
            
            %
            % Find the unique set of agent currency types
            %
            agentIds = get(obj.transactions,'currencyAgentId');
            if iscell(agentIds)
                agentIds = unique(cell2mat(agentIds));
            else
                % Edge case of one transaction only
                agentIds = unique(agentIds);
            end
            
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
                % Record the transaction (remember demurrage is negative)
                %
                if amount < 0.0
                    t = Transaction(TransactionType.DEMURRAGE, amount, agentIds(index), obj.agent.polis.uniqueId(), Polis.PolisId, obj.agent.id, "DEMURRAGE", timeStep);
                    obj.addTransaction(t);
                end
            end
        end
        
        %
        % Balance Calculations
        %
        
        function [agentIds, balances] = individualBalancesForTransactionWithAgent(obj, targetAgentId, mutualAgentIds)
            % Return the balance for each individual currency from common
            % agents, the target agent (agentId) and oneself (obj.Id). 
            % Order by agentId, common agents, then onself.
            [~, indices] = size(mutualAgentIds);
            N = indices + 2;
            agentIds = zeros(N, 1);
            balances = zeros(N, 1);
            agentIds(1) = targetAgentId; 
            balances(1) = obj.balanceForAgentsCurrency(targetAgentId);
            for index = 1:indices
                mutualAgentId = mutualAgentIds(index);
                agentIds(index + 1) = mutualAgentId;
                balances(index + 1) = obj.balanceForAgentsCurrency(mutualAgentId);
            end
            agentIds(N) = obj.agent.id;
            balances(N) = obj.balanceForAgentsCurrency(obj.agent.id);
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
            % Total balance, all currencies (irrespective of agent 
            % dependencies)
            currentBalance = sum([obj.transactions.amount]);
        end
                        
        function balance = balanceAllTransactionsAtTimestep(obj, timeStep)
            % Balance at time timeStep, all transactions

            function result = withinTimePeriod(obj)
                % obj is a Transaction
                if obj.dateCreated <= timeStep
                    result = true;
                else
                    result = false;
                end
            end                        
            functionHandle = @withinTimePeriod;
            
            matchingTransactions = findobj(obj.transactions,'-function', functionHandle);
            balance = sum([matchingTransactions.amount]);
        end
        
        function balance = balanceForTransactionTypeAtTimestep(obj, transactionType, timeStep)
            % Balance at time timeStep for the transactionType

            function result = withinTimePeriod(obj)
                % obj is a Transaction
                if obj.dateCreated <= timeStep && obj.type == transactionType
                    result = true;
                else
                    result = false;
                end
            end            
            functionHandle = @withinTimePeriod;
            
            matchingTransactions = findobj(obj.transactions,'-function', functionHandle);            
            balance = sum([matchingTransactions.amount]);
        end
        
        function [agentIds, balances] = currenciesInWalletByAgent(obj, timeStep)
            % Return the distribution of currencies in this wallet at the
            % time = timeStep excluding transitive transactions
            
            % Get all the non-transtivie records <= timeStep
            function result = withinTimePeriodNoTransitive(obj)
                % obj is a Transaction
                if obj.dateCreated <= timeStep && ...
                   (obj.type ~= TransactionType.BUY_TRANSITIVE || ...
                   obj.type ~= TransactionType.SELL_TRANSITIVE)
                    result = true;
                else
                    result = false;
                end
            end            
            functionHandle = @withinTimePeriodNoTransitive;
            matchingTransactions = findobj(obj.transactions,'-function', functionHandle);            

            %
            % Find the unique set of agent currency types
            %
            agentIds = get(matchingTransactions,'currencyAgentId');
            if iscell(agentIds)
                agentIds = unique(cell2mat(agentIds));
            else
                % Edge case of one transaction only
                agentIds = unique(agentIds);
            end
            
            %
            % Loop over each agent, calculate & record the balance
            %
            agents = numel(agentIds);
            balances = zeros(agents,1);
            for a = 1:agents
                balances(a) = obj.balanceForAgentsCurrency(agentIds(a));
            end
            
        end
        
        %
        % Output / Logging
        %
        
        function total = totalLedgerRecords(obj)
            % Return the total number of records currently in the ledger
            [total, ~] = size(obj.transactions);
        end
        
        function total = totalLedgerRecordsForTransactionTypeSeries(obj, transactionTypeSeries, timeStep)
            % Find all the transactions corresponding to the
            % TransactionTypeSeries and the total number of their occurrance. 
            
            function result = withinTimePeriod(obj)
                % obj is a Transaction
                if obj.dateCreated <= timeStep && obj.type > transactionTypeSeries && obj.type < (transactionTypeSeries + 1000)
                    result = true;
                else
                    result = false;
                end
            end            
            functionHandle = @withinTimePeriod;

            matchingTransactions = findobj(obj.transactions,'-function', functionHandle);            
            [total, ~] = size(matchingTransactions);
        end
        
        function dump(obj)
            % Log this agents complete ledger
            [rows, ~] = size(obj.transactions);
            logStatement('\nLedger for Agent Id = %d, # records = %d\n', [obj.agent.id, rows], 0, obj.agent.polis.LoggingLevel);
            logStatement('id\t tranId\t time\t type amount\t cur\t src\t dest\t note\t\n', [], 0, obj.agent.polis.LoggingLevel);
            for i = 1:rows
                obj.transactions(i).dump();
            end
        end
                        
    end
    
    methods (Static)
    end
    
    methods (Access = private, Static)   
    end
    
    methods (Access = private)
                
        function balance = balanceForAgentsCurrency(obj, agentId)
            % Total balance of this agents currency

            % This is the original, un-normalized code
            % results = findobj(obj.transactions,'currencyAgentId', agentId);
            % balance = sum([results.amount]);

            % Use the lookup for a large performance improvement, see
            % Wallet.addTransaction
            balance = obj.currencyAgentBalances(agentId,2);
        end
        
    end
    
end    


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
        
        function transacted = submitPurchase(obj, amount, AM, paths, targetAgentId, timeStep)
            % Process a buy transaction, if possible
            assert(obj.agent.id ~= targetAgentId,"Attempting a transaction with yourself - Preposterous!");
            % TODO - ensure ends of the paths correspond to the agent id's
            % of the agents in question.
            
            %
            % Loop through paths and segments, seeking one that works
            % TODO - maybe this should be its own method
            %
            [~, indices] = size(paths);
            path = [];
            for index = 1:indices
                path = cell2mat(paths(1, index));
                logIntegerArray("Working on path",path);
                [~, segments] = size(path);
                pathHasBalance = true;
                for segment = 2:segments
                    thisAgentId = path(segment - 1);
                    thatAgentId = path(segment);
                    fprintf("Checking segment %d to %d\n",thisAgentId, thatAgentId);
                    mutualAgentIds = obj.agent.findMutualConnectionsWithAgent(AM, thisAgentId, thatAgentId);
                    availableBalance = obj.availableBalanceForTransactionWithAgent(thatAgentId, mutualAgentIds);
                    fprintf("Available Balance = %.2f, Amount = %.2f\n",availableBalance, amount);
                    if availableBalance < amount
                        fprintf("Path failed, no balance\n");
                        pathHasBalance = false;
                        break;
                    end
                end
                if pathHasBalance
                    fprintf("Path Passed - Let's use it\n");
                    break;
                end
            end
            
            if isempty(path)
                fprintf("All Paths Failed - Goodbye\n");
                transacted = false;
                return;
            end
            
            % Okay, let's record the puchase
            [~, segments] = size(path);
            for segment = 2:segments
                thisAgentId = path(segment - 1);
                thatAgentId = path(segment);
                % TODO - implement transaction segment by segment
            end
            
            transacted = true;
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
        % Use Agent wrappers
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
                % Record the transaction
                %
                if amount < 0.0
                    t = Transaction(TransactionType.DEMURRAGE, amount, agentIds(index), Polis.uniqueId(), Polis.PolisId, obj.agent.id, "DEMURRAGE", timeStep);
                    obj.addTransaction(t);
                end
            end
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
    
    methods (Static)
        
        function transacted = submitPurchaseWithDirectConnection(AM, amount, thisAgent, thatAgent, timeStep)
            % Process a purchase transaction with a direct connection (if
            % there is enough currency to support it)
            assert(thisAgent.id ~= thatAgent.id,"Attempting a transaction with yourself - Preposterous!");

            transacted = false;
            
            % Find available balance for this agent to transact with
            % another using currencies from all mutual connections, that
            % agents curreny and ones own currency.
            mutualAgentIds = thisAgent.findMutualConnectionsWithAgent(AM, thisAgent.id, thatAgent.id);
            availableBalance = thisAgent.availableBalanceForTransactionWithAgent(thatAgent.id, mutualAgentIds);

            if availableBalance >= amount
                % Commit the transaction
                CryptoWallet.commitPurchaseWithDirectConnection(amount, thisAgent, thatAgent, mutualAgentIds, timeStep);
                transacted = true;
            end
       
        end

    end
    
    methods (Access = private, Static)
        
        function commitPurchaseSegment(amount, thisAgent, thatAgent, mutualAgentIds, buyTransactionType, sellTransactionType, timeStep)
            % Record an approved transaction segment between two agents 
            % (that will typically be a part of a larger set but could 
            % simply be between just two).
            fprintf("thisAgentId = %d, thatAgentId = %d\n", thisAgent.id, thatAgent.id);
            assert(thisAgent.id ~= thatAgent.id,"Attempting a transaction the same agent - Preposterous!");
            assert(buyTransactionType == TransactionType.BUY || TransactionType.BUY_TRANSITIVE,"Wrong BUY transaction type provided");
            assert(buyTransactionType == TransactionType.SELL || TransactionType.SELL_TRANSITIVE,"Wrong SELL transaction type provided");
            
            % The money is available so let's get the balance for each
            % individually available currency
            [agentIds, balances] = thisAgent.wallet.individualBalancesForTransactionWithAgent(thatAgent.id, mutualAgentIds);
            [indices, ~] = size(balances);
            remainingAmount = amount;

            % Loop over each currency and satisfy the purchase amount
            % in the order provided (e.g. thatAgent, mutual agents, finally
            % ones own currenty
            for index = 1:indices
                currencyAgentId = agentIds(index);
                balance = balances(index);
                assert(balance >= 0,"Wallet.submitPurchase, balance < 0)!");
                if balance ~= 0 
                    if remainingAmount > balance
                        % Record Buy/Sell using balance and continue
                        % Buy
                        tAB = Transaction(buyTransactionType, -balance, currencyAgentId, Polis.uniqueId(), thisAgent.id, thatAgent.id, "BUY", timeStep);
                        thisAgent.wallet.addTransaction(tAB);
                        % Sell
                        tBA = Transaction(sellTransactionType, balance, currencyAgentId, Polis.uniqueId(), thatAgent.id, thisAgent.id, "SELL", timeStep);
                        thatAgent.wallet.addTransaction(tBA);
                        remainingAmount = remainingAmount - balance;
                    else
                        % Record Buy/Sell using remainingAmount and
                        % break, the purchase amount has been
                        % satisfied.
                        % Buy
                        tAB = Transaction(buyTransactionType, -remainingAmount, currencyAgentId, Polis.uniqueId(), thisAgent.id, thatAgent.id, "BUY", timeStep);
                        thisAgent.wallet.addTransaction(tAB);
                        % Sell
                        tBA = Transaction(sellTransactionType, remainingAmount, currencyAgentId, Polis.uniqueId(), thatAgent.id, thatAgent.id, "SELL", timeStep);
                        thatAgent.wallet.addTransaction(tBA);
                        break;
                    end
                end
            end
        end
    
        function commitPurchaseWithDirectConnection(amount, thisAgent, thatAgent, mutualAgentIds, timeStep)
            % Record an approved transaction between two directly connected
            % agents.
            assert(thisAgent.id ~= thatAgent.id,"Attempting a transaction with yourself - Preposterous!");
            CryptoWallet.commitPurchaseSegment(amount, thisAgent, thatAgent, mutualAgentIds, TransactionType.BUY, TransactionType.SELL, timeStep);
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


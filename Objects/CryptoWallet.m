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
    - sourceAgentId corresponds to the buying agent
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
        function transacted = commitPurchaseWithIndirectConnection(obj, AM, amount, agentsInPath, timeStep)
            % Commit a transaction that spans more than two connected
            % agents. Note the agent array represents the path but is
            % missing the buyer (this agent) from its list. So the total 
            % number of agents is really numberAgents + 1. The last agent
            % is the selling agent.
            
            transacted = true;
            
            [~, numberAgents] = size(agentsInPath);
            assert(numberAgents > 1,"Error: use submitPurchaseWithDirectConnection instead");

            % Record the first leg
            thatAgent = agentsInPath(1);
            mutualAgentIds = Agent.findMutualConnectionsWithAgent(AM, obj.agent.id, thatAgent.id);
            fprintf("\nFirst Leg:  id 1 = %d, id 2 = %d\n", obj.agent.id, thatAgent.id);
            obj.commitPurchaseSegment(amount, thatAgent, mutualAgentIds, TransactionType.BUY, TransactionType.SELL_TRANSITIVE, timeStep);
            
            % Record the intermediate legs, if needed
            if numberAgents > 2
                for leg = 1:(numberAgents - 2)
                    thisAgent = agentsInPath(leg);
                    thatAgent = agentsInPath(leg + 1);
                    fprintf("Middle Leg: id %d = %d, id %d = %d\n", leg, thisAgent.id, leg + 1, thatAgent.id);
                    thisAgent.commitPurchaseSegment(amount, thatAgent, mutualAgentIds, TransactionType.BUY_TRANSITIVE, TransactionType.SELL_TRANSITIVE, timeStep);            
                end
            end
            
            % Record the last leg
            thisAgent = agentsInPath(numberAgents - 1);
            thatAgent = agentsInPath(numberAgents);
            mutualAgentIds = Agent.findMutualConnectionsWithAgent(AM, thisAgent.id, thatAgent.id);
            fprintf("Last Leg:   id %d = %d, id %d = %d\n", numberAgents - 1, thisAgent.id, numberAgents, thatAgent.id);
            thisAgent.commitPurchaseSegment(amount, thatAgent, mutualAgentIds, TransactionType.BUY_TRANSITIVE, TransactionType.SELL, timeStep);            
            
        end

        function transacted = submitPurchaseWithDirectConnection(obj, AM, amount, thatAgent, timeStep)
            % Process a purchase transaction with a direct connection (if
            % there is enough currency to support it)
            assert(obj.agent.id ~= thatAgent.id,"Attempting a transaction with yourself - Preposterous!");

            transacted = false;
            
            % Find available balance for this agent to transact with
            % another using currencies from all mutual connections, that
            % agents curreny and ones own currency.
            mutualAgentIds = Agent.findMutualConnectionsWithAgent(AM, obj.agent.id, thatAgent.id);
            availableBalance = obj.availableBalanceForTransactionWithAgent(thatAgent.id, mutualAgentIds);

            if availableBalance >= amount
                % Commit the transaction
                obj.commitPurchaseWithDirectConnection(amount, thatAgent, mutualAgentIds, timeStep);
                transacted = true;
            end
       
        end

        function commitPurchaseSegment(obj, amount, thatAgent, mutualAgentIds, buyTransactionType, sellTransactionType, timeStep)
            % Record an approved transaction segment between two agents 
            % (that will typically be a part of a larger set but could 
            % simply be between just two).
            assert(obj.agent.id ~= thatAgent.id,"Attempting a transaction the same agent - Preposterous!");
            assert(buyTransactionType == TransactionType.BUY || TransactionType.BUY_TRANSITIVE,"Wrong BUY transaction type provided");
            assert(buyTransactionType == TransactionType.SELL || TransactionType.SELL_TRANSITIVE,"Wrong SELL transaction type provided");
            
            % The money is available so let's get the balance for each
            % individually available currency
            [agentIds, balances] = obj.individualBalancesForTransactionWithAgent(thatAgent.id, mutualAgentIds);
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
                        tAB = Transaction(buyTransactionType, -balance, currencyAgentId, Polis.uniqueId(), obj.agent.id, thatAgent.id, "BUY", timeStep);
                        obj.addTransaction(tAB);
                        % Sell
                        tBA = Transaction(sellTransactionType, balance, currencyAgentId, Polis.uniqueId(), thatAgent.id, obj.agent.id, "SELL", timeStep);
                        thatAgent.addTransaction(tBA);
                        remainingAmount = remainingAmount - balance;
                    else
                        % Record Buy/Sell using remainingAmount and
                        % break, the purchase amount has been
                        % satisfied.
                        % Buy
                        tAB = Transaction(buyTransactionType, -remainingAmount, currencyAgentId, Polis.uniqueId(), obj.agent.id, thatAgent.id, "BUY", timeStep);
                        obj.addTransaction(tAB);
                        % Sell
                        tBA = Transaction(sellTransactionType, remainingAmount, currencyAgentId, Polis.uniqueId(), thatAgent.id, obj.agent.id, "SELL", timeStep);
                        thatAgent.addTransaction(tBA);
                        break;
                    end
                end
            end
        end
        
        function addTransaction(obj, newTransaction)
            % Add a ledger record (building a vector (N x 1 transactions))
            obj.transactions = [obj.transactions ; newTransaction]; 
        end
        
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
    end
    
    methods (Access = private, Static)   
    end
    
    methods (Access = private)

        function commitPurchaseWithDirectConnection(obj, amount, thatAgent, mutualAgentIds, timeStep)
            % Record an approved transaction between two directly connected
            % agents.
            assert(obj.agent.id ~= thatAgent.id,"Attempting a transaction with yourself - Preposterous!");
            obj.commitPurchaseSegment(amount, thatAgent, mutualAgentIds, TransactionType.BUY, TransactionType.SELL, timeStep);
        end
                
        function balance = balanceForAgentsCurrency(obj, agentId)
            % Total balance of this agents currency
            results = findobj(obj.transactions,'currencyAgentId', agentId);
            balance = sum([results.amount]);
        end
        
    end

end


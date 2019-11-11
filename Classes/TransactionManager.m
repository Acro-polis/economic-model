classdef TransactionManager < handle
    %TRANSACTIONMANAGER Facilitates transactions between two or more agents
    %   Contains logic for recording a transaction between a buyer and a
    %   seller which may include intermediate agents supporting a
    %   transitive-transaction. Note these methods assume the proposed
    %   transaction has already been checked for liquidity.
    
    properties (SetAccess = private)
        polis   Polis
    end
    
    methods (Access = public)
        
        function obj = TransactionManager(polis)
            %TRANSACTIONMANAGER Construct an instance of this class
            % This is a singleton class managed by the Polis object
            obj.polis = polis;
        end
        
        function commitPurchaseWithDirectConnection(obj, amount, thisAgent, thatAgent, mutualAgentIds, timeStep)
            %COMMITPURCHASEWITHDIRECTCONNECTION Commit a transaction  
            % between two directly connected agents
            obj.commitPurchaseSegment(amount, thisAgent, thatAgent, mutualAgentIds, TransactionType.BUY, TransactionType.SELL, obj.polis.uniqueId(), timeStep);
        end
        
        function commitPurchaseWithIndirectConnection(obj, amount, agentBuying, agentsInPath, timeStep)
            %COMMITPURCHASEWITHINDIRECTCONNECTION Commit a transaction that 
            % spans more than two connected agents. Note the agent array 
            % represents the path but is missing the buyer (agentBuying) 
            % from its list. So the total number of agents is really 
            % numberAgents + 1. The last agent is the selling agent.
            
            [~, numberAgents] = size(agentsInPath);
            transactionId = obj.polis.uniqueId();
            
            % Record the first leg
            thatAgent = agentsInPath(1);
            mutualAgentIds = PathFinder.findMutualConnectionsWithAgent(obj.polis.AM, agentBuying.id, thatAgent.id);
            logStatement("\nFirst Leg:  id 1 = %d, id 2 = %d\n", [agentBuying.id, thatAgent.id], 2, obj.polis.LoggingLevel);
            obj.commitPurchaseSegment(amount, agentBuying, thatAgent, mutualAgentIds, TransactionType.BUY, TransactionType.SELL_TRANSITIVE, transactionId, timeStep);
            
            % Record the intermediate legs, if needed
            if numberAgents > 2
                for leg = 1:(numberAgents - 2)
                    thisAgent = agentsInPath(leg);
                    thatAgent = agentsInPath(leg + 1);
                    mutualAgentIds = PathFinder.findMutualConnectionsWithAgent(obj.polis.AM, thisAgent.id, thatAgent.id);
                    logStatement("Middle Leg: id %d = %d, id %d = %d\n", [leg, thisAgent.id, leg + 1, thatAgent.id], 2, obj.polis.LoggingLevel);
                    obj.commitPurchaseSegment(amount, thisAgent, thatAgent, mutualAgentIds, TransactionType.BUY_TRANSITIVE, TransactionType.SELL_TRANSITIVE, transactionId, timeStep);            
                end
            end
            
            % Record the last leg
            thisAgent = agentsInPath(numberAgents - 1);
            thatAgent = agentsInPath(numberAgents);
            mutualAgentIds = PathFinder.findMutualConnectionsWithAgent(obj.polis.AM, thisAgent.id, thatAgent.id);
            logStatement("Last Leg:   id %d = %d, id %d = %d\n", [numberAgents - 1, thisAgent.id, numberAgents, thatAgent.id], 2, obj.polis.LoggingLevel);
            obj.commitPurchaseSegment(amount, thisAgent, thatAgent, mutualAgentIds, TransactionType.BUY_TRANSITIVE, TransactionType.SELL, transactionId, timeStep);            
            
        end
                
    end

    methods (Access = private)

        function commitPurchaseSegment(obj, amount, thisAgent, thatAgent, mutualAgentIds, buyTransactionType, sellTransactionType, transactionId, timeStep)
            % COMMITPURCHASESEGMENT Record an approved transaction segment 
            % between two agents (that will typically be a part of a larger 
            % set but could simply be between just these two).
            assert(buyTransactionType == TransactionType.BUY || TransactionType.BUY_TRANSITIVE,"Wrong BUY transaction type provided");
            assert(buyTransactionType == TransactionType.SELL || TransactionType.SELL_TRANSITIVE,"Wrong SELL transaction type provided");
            
            % The money is available so let's get the balance for each
            % individually available currency
            [agentIds, balances] = thisAgent.individualBalancesForTransactionWithAgent(thatAgent.id, mutualAgentIds);
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
                        tAB = Transaction(buyTransactionType, -balance, currencyAgentId, transactionId, thatAgent.id, thisAgent.id, "BUY", timeStep);
                        thisAgent.addTransaction(tAB);
                        % Sell
                        tBA = Transaction(sellTransactionType, balance, currencyAgentId, transactionId, thisAgent.id, thatAgent.id, "SELL", timeStep);
                        thatAgent.addTransaction(tBA);
                        remainingAmount = remainingAmount - balance;
                    else
                        % Record Buy/Sell using remainingAmount and
                        % break, the purchase amount has been
                        % satisfied.
                        % Buy
                        tAB = Transaction(buyTransactionType, -remainingAmount, currencyAgentId, transactionId, thatAgent.id, thisAgent.id, "BUY", timeStep);
                        thisAgent.addTransaction(tAB);
                        % Sell
                        tBA = Transaction(sellTransactionType, remainingAmount, currencyAgentId, transactionId, thisAgent.id, thatAgent.id, "SELL", timeStep);
                        thatAgent.addTransaction(tBA);
                        break;
                    end
                end
            end
        end
        
    end
end


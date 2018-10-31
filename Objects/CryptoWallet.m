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
        agentId             
        transactions        
    end
    
    properties (Dependent)
        currentBalance
    end
    
    methods
        
        %
        % Transactional Functions
        %
        function obj = CryptoWallet(agentId)
            obj.agentId = agentId;
            obj.transactions = Transaction.empty;
        end
        
        function depositUBI(obj, amount)
            % TODO - make transaction id unique
            obj.addTransaction(Transaction(TransactionType.UBI, amount, obj.agentId, 1, Polis.PolisId, obj.agentId, "UBI", datetime('now')));
        end
        
        function applyDemurrage(obj, percentage)
            %
            % Find the unique set of agent currency types
            %
            agentIds = unique(cell2mat(get(obj.transactions,'currencyAgentId')));
            
            %
            % Loop over each type and apply demurrage
            %
            [agents, ~] = size(agentIds);
            for caId = 1:agents
                %
                % Calculate the balance for this agent
                %
                amount = -1.0*percentage*obj.balanceForCurrencyAgentId(caId);
                
                %
                % Record the transaction
                %
                % TODO - make transaction id unique
                t = Transaction(TransactionType.DEMURRAGE, amount, caId, 1, Polis.PolisId, obj.agentId, "DEMURRAGE", datetime('now'));
                obj.addTransaction(t);
            end
        end
        
        function submitBuySellTransaction(obj, newTransaction)
            % TODO - encapsulate more of the setup here
            if newTransaction.type ~= TransactionType.BUY && newTransaction.type ~= TransactionType.SELL
                %
                % TODO - Raise error
                %
            else
                obj.addTransaction(newTransaction);
            end
        end
                
        %
        % Balance Calculations
        %
        function currentBalance = get.currentBalance(obj)
            currentBalance = sum([obj.transactions.amount]);
        end

        function balance = balanceForCurrencyAgentId(obj, agentId)
            results = findobj(obj.transactions,'currencyAgentId', agentId);
            balance = sum([results.amount]);
        end
       
        %
        % Output
        %
        function dump(obj)
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
            % Building a vector (N x 1 transactions)
            obj.transactions = [obj.transactions ; newTransaction]; 
        end

    end

end


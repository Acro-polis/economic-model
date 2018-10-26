classdef CryptoWallet < handle
%================================================================
% Class CryptoWallet
%
% Created by Jess 09.13.18
%================================================================    

    properties (SetAccess=private)
        agentId             
        transactions        
    end
    
    properties (Dependent)
        currentBalance
    end
    
    methods
        
        function obj = CryptoWallet(agentId)
            obj.agentId = agentId;
            obj.transactions = Transaction.empty;
        end
        
        function submitTransaction(obj, newTransaction)
            if newTransaction.type == TransactionType.DEMURRAGE
                obj.applyDemurrage(newTransaction);
            else
                obj.addTransaction(newTransaction);
            end
        end
                
        function CurrentBalance = get.currentBalance(obj)
            CurrentBalance = sum([obj.transactions.amount]);
        end
        
        function balance = balanceForSourceAgentId(obj, agentId)
            results = findobj(obj.transactions,'soureAgentId', agentId);
            balance = sum([results.Amount]);
        end

        function balance = balanceForTransactionType(obj, transactionType)
            results = findobj(obj.transactions,'type', transactionType);
            balance = sum([results.Amount]);
        end
        
        % '-and' & '-or' are logical operations that can be added
        % Function getBalanceForSource
        % Function getBalanceForDestination
        % etc.
        
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
        
        function applyDemurrage(obj, demurrageTransaction)
            %
            % Find the unique set of agent id's representing the
            % unique types of currencies contained in the wallet
            %
            agentIds = unique(cell2mat(get(obj.transactions,'currencyAgentId')));
            
            %
            % Loop over each type and apply demurrage
            %
            [rows, ~] = size(agentIds);
            for i = 1:rows
                %
                % Calculate the balance
                %
                % TODO
                
                %
                % Create the demurrage transaction for this balance
                %
                % TODO
                
                %
                % Record the transaction
                %
                %obj.addTransaction(demurrageTransaction);
            end
        end
        
        function addTransaction(obj, newTransaction)
            % Building a vector (N x 1 transactions)
            obj.transactions = [obj.transactions ; newTransaction]; 
        end

    end

end


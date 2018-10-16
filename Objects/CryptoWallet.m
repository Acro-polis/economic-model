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
        
        function addTransaction(obj, newTransaction)
            obj.transactions = [obj.transactions newTransaction]; % Adding to end of array
        end
        
        function CurrentBalance = get.currentBalance(obj)
            CurrentBalance = sum([obj.transactions.amount]);
        end
        
        function balance = balanceForTransactionType(obj, transactionType)
            % '-and' & '-or' are logical operations that can be added
            results = findobj(obj.transactions,'Type', transactionType);
            balance = sum([results.Amount]);
        end
        
        % Function getBalanceForSource
        % Function getBalanceForDestination
        % etc.
        
        function dump(obj)
            fprintf('\nLedger for Agent Id = %d\n',obj.agentId);
            fprintf('id\t type amount\t a/s/d\t date\n');
            [~, col] = size(obj.transactions);
            for i = 1:col
                obj.transactions(i).dump();
            end
        end
                        
    end
end


classdef CryptoWallet < handle
%================================================================
% Class CryptoWallet
%
% Created by Jess 09.13.18
%================================================================    

    properties (SetAccess=private)
        AgentId             
        Transactions        
    end
    
    properties (Dependent)
        CurrentBalance
    end
    
    methods
        
        function obj = CryptoWallet(AgentId)
            obj.AgentId = AgentId;
            obj.Transactions = Transaction.empty;
        end
        
        function addTransaction(obj, NewTransaction)
            obj.Transactions = [obj.Transactions, NewTransaction];
        end
        
        function CurrentBalance = get.CurrentBalance(obj)
            CurrentBalance = sum([obj.Transactions.Amount]);
        end
        
        function balance = BalanceByTransactionType(obj, TransactionType)
            % '-and' & '-or' are logical operations that can be added
            results = findobj(obj.Transactions,'Type', TransactionType);
            balance = sum([results.Amount]);
        end
        
        % Function getBalanceForSource
        % Function getBalanceForDestination
        % etc.
                        
    end
end


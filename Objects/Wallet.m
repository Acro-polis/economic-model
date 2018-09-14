classdef Wallet < handle
%================================================================
% Class Wallet
%
% Created by Jess 09.13.18
%================================================================    
    
    properties
        Id             
        Transactions        
    end
    
    methods
        
        function obj = Wallet(Id)
            obj.Id = Id;
            obj.Transactions = Transaction.empty;
        end
        
        function obj = addTransaction(wallet, transaction)
            obj.Transactions = [wallet.Transactions, transaction];
        end
        
        function balance = currentBalance(wallet)
            balance = sum(get(wallet.Transactions, Amount));
        end
        
        % Function getBalanceForType
        % Function getBalanceForSource
        % Function getBalanceForDestination
        % etc.
                        
    end
end


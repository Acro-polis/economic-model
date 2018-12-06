classdef TransactionType
%================================================================
% Class TransactionType
%
% Transactions are distiguished by type
%
% Created by Jess 10.16.18
%================================================================

    properties (Constant)
        
        % Transaction Type Series
        BUY_SELL_SERIES             = 6000
        BUY_SELL_TRANSITIVE_SERIES  = 7000
        
        % Purchase transaction codes
        UBI                     = 3000
        DEMURRAGE               = 4000
        BUY                     = 6001
        SELL                    = 6002
        BUY_TRANSITIVE          = 7001
        SELL_TRANSITIVE         = 7002
        
        % Transaction status codes
        TRANSACTION_SUCCEEDED   = 9000;
        FAILED_NO_PATH_FOUND    = 9001;
        FAILED_NO_LIQUIDITY     = 9002;
        FAILED_NO_INVENTORY     = 9003;
        FAILED_UNKNOWN          = 9004
        
    end
    
end


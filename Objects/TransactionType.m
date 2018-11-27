classdef TransactionType
%================================================================
% Class TransactionType
%
% Created by Jess 10.16.18
%================================================================

    properties (Constant)
        
        % Purchase transaction codes
        UBI                  = 6001
        DEMURRAGE            = 6002
        BUY                  = 6003
        SELL                 = 6004
        BUY_TRANSITIVE       = 7001
        SELL_TRANSITIVE      = 7002
        
        % Transaction status codes
        TRANSACTION_SUCCEEDED   = 5000;
        FAILED_NO_PATH_FOUND    = 5001;
        FAILED_NO_LIQUIDITY     = 5002;
        FAILED_UNKNOWN          = 5003;
        
    end
    
end


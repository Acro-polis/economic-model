classdef Agent < handle
%================================================================
% Class Agent
%
% Created by Jess 09.13.18
%================================================================

    properties (SetAccess = private)
        Id
        Birthdate
        Wallet
    end
    
    methods
        
        %
        % Constructor
        %
        function obj = Agent(Id, Birthdate)
            obj.Id = Id;
            obj.Birthdate = Birthdate;
            obj.Wallet = CryptoWallet(obj.Id);
        end
        
        %
        % 
        %
    end
end


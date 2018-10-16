classdef Agent < handle
%================================================================
% Class Agent
%
% Created by Jess 09.13.18
%================================================================

    properties (SetAccess = private)
        id
        birthdate
        wallet
    end
    
    methods
        
        %
        % Constructor
        %
        function obj = Agent(id, birthdate)
            obj.id = id;
            obj.birthdate = birthdate;
            obj.wallet = CryptoWallet(obj.id);
        end
        
        %
        % 
        %
    end
end


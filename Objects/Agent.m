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
    
    properties (Constant)
        PolisId = 0 % TODO - harden this approach (see assert below)
    end
    
    methods
        
        %
        % Constructor
        %
        function obj = Agent(id, birthdate)
            assert(id ~= 0,'Error: Agent Id = reserved Polis Id');
            obj.id = id;
            obj.birthdate = birthdate;
            obj.wallet = CryptoWallet(obj.id);
        end
        
        %
        % 
        %
    end
end


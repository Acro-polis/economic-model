classdef Agent
%================================================================
% Class Agent
%
% Created by Jess 09.13.18
%================================================================

    properties
        Id
        Birthdate
        Wallet
    end
    
    methods
        
        function obj = Agent(Id, Birthdate)
            obj.Id = Id;
            obj.Birthdate = Birthdate;
            Wallet = Wallet(obj.Id);
        end
        
    end
end


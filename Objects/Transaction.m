classdef Transaction < handle
%================================================================
% Class Transaction
%
% Created by Jess 09.13.18
%================================================================

    properties (SetAccess=private)
        Id
        Type
        Amount
        AgentId
        SourceAgentId
        DestinationAgentId
        DateCreated
    end
    
    methods
        
        %
        % Constructor
        %
        function obj = Transaction(Type, Amount, AgentId, SourceAgentId, DestinationAgentId, DateCreated)
            obj.Id = 1; % TODO make a unique number
            obj.Type = Type;
            obj.Amount = Amount;
            obj.AgentId = AgentId;
            obj.SourceAgentId = SourceAgentId;
            obj.DestinationAgentId = DestinationAgentId;
            obj.DateCreated = DateCreated;
        end
        
    end
end


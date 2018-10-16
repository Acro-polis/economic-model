classdef Transaction < handle
%================================================================
% Class Transaction
%
% Created by Jess 09.13.18
%================================================================

    properties (SetAccess=private)
        id
        type
        amount
        agentId
        sourceAgentId
        destinationAgentId
        dateCreated
    end
        
    methods
        
        %
        % Constructor
        %
        function obj = Transaction(type, amount, agentId, sourceAgentId, destinationAgentId, dateCreated)
            obj.id = 1; % TODO make a unique number
            obj.type = type;
            obj.amount = amount;
            obj.agentId = agentId;
            obj.sourceAgentId = sourceAgentId;
            obj.destinationAgentId = destinationAgentId;
            obj.dateCreated = dateCreated;
        end
        
        function dump(obj)
            fprintf('%d\t %s %+.2f\t %d %d %d\t %s\n', obj.id, obj.type, obj.amount, obj.agentId, obj.sourceAgentId, obj.destinationAgentId, datestr(obj.dateCreated));
        end
        
    end
end


classdef Transaction < matlab.mixin.SetGet
%================================================================
% Class Transaction
%
% Created by Jess 09.13.18
%================================================================

    properties (SetAccess=private)
        id                          % Ledger Id
        type                        % Transaction Type
        amount                      % Transaction Amount
        agentId                     % Transaction Agent Id
        transactionId               % Transaction Id
        sourceAgentId               % Source Agent Id
        destinationAgentId          % Destination Agent Id
        note                        % Note (optional)
        dateCreated                 % Transaction Date + Time
    end
        
    methods
        
        %
        % Constructor
        %
        function obj = Transaction(type, amount, agentId, transactionId, sourceAgentId, destinationAgentId, note, dateCreated)
            obj.id = 1; % TODO make a unique number
            obj.type = type;
            obj.amount = amount;
            obj.agentId = agentId;
            obj.transactionId = transactionId;
            obj.sourceAgentId = sourceAgentId;
            obj.destinationAgentId = destinationAgentId;
            obj.note = note;
            obj.dateCreated = dateCreated;
        end
        
        function value = get.agentId(obj)
            value = obj.agentId;
        end
        
        function dump(obj)
            fprintf('%d\t %d %+.2f\t %d %d %d %d\t %s\t %s\n', obj.id, obj.type, obj.amount, obj.agentId, obj.sourceAgentId, obj.destinationAgentId, obj.transactionId, obj.note, datestr(obj.dateCreated));
        end
        
    end
end


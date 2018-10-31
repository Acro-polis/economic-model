classdef Transaction < matlab.mixin.SetGet
%================================================================
% Class Transaction
%
% Created by Jess 20.10.18
%================================================================

    properties (SetAccess=private)
        id                          % Ledger Id                 - unique id for this wallet
        type                        % Transaction Type          - type of transaction, see TransactionType
        amount                      % Transaction Amount        - amount of crypto currency
        currencyAgentId             % Currency Agent Id         - agent id representing the currency for this transaction
        transactionId               % Transaction Id            - unique transaction id common to every ledger record associated to this transaction, spanning multiple agents
        sourceAgentId               % Source Agent Id           - agent id for source of this crypto currency (an agent or Polis)
        destinationAgentId          % Destination Agent Id      - agent id for the destination of this crypto currency (same as currencyAgentId?)
        note                        % Note                      - Optional note
        dateCreated                 % Transaction Date + Time   - Transcation time (TODO - should probably be the iteration time dt)
    end
        
    methods
        
        %
        % Constructor
        %
        function obj = Transaction(type, amount, currencyAgentId, transactionId, sourceAgentId, destinationAgentId, note, dateCreated)
            obj.id = 1; % TODO make a unique number
            obj.type = type;
            obj.amount = amount;
            obj.currencyAgentId = currencyAgentId;
            obj.transactionId = transactionId;
            obj.sourceAgentId = sourceAgentId;
            obj.destinationAgentId = destinationAgentId;
            obj.note = note;
            obj.dateCreated = dateCreated;
        end
        
        function value = get.currencyAgentId(obj)
            value = obj.currencyAgentId;
        end
        
        function dump(obj)
            fprintf('%d\t %d %+.2f\t %d %d %d %d\t %s\t %s\n', obj.id, obj.type, obj.amount, obj.currencyAgentId, obj.sourceAgentId, obj.destinationAgentId, obj.transactionId, obj.note, datestr(obj.dateCreated));
        end
        
    end
end


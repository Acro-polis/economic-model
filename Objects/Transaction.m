classdef Transaction < matlab.mixin.SetGet
%================================================================
% Class Transaction
%
% Wallets contain Transactions that record sales, purchases, UBI,
% Demurrage, etc.
%
% Created by Jess 20.10.18
%================================================================

    properties (SetAccess=private)
        id                   uint32 % Ledger Id                 - unique id for this wallet
        type                 uint32 % Transaction Type          - type of transaction, see TransactionType
        amount               double % Transaction Amount        - amount of crypto currency
        currencyAgentId      uint32 % Currency Agent Id         - agent id representing the currency for this transaction
        transactionId        uint32 % Transaction Id            - unique transaction id common to every ledger record associated to this transaction, spanning multiple agents
        sourceAgentId        uint32 % Source Agent Id           - agent id for source of this crypto currency (an agent or Polis)
        destinationAgentId   uint32 % Destination Agent Id      - agent id for the destination of this crypto currency (same as currencyAgentId?)
        note                        % Note                      - Optional note
        dateCreated          uint32 % Transaction Date + Time   - For now this equals dt in the simulation time step
    end
        
    methods
        
        %
        % Constructor
        %
        function obj = Transaction(type, amount, currencyAgentId, transactionId, sourceAgentId, destinationAgentId, note, timeStep)
            % 
            obj.id = 1; % TODO make a unique number
            obj.type = type;
            obj.amount = amount;
            obj.currencyAgentId = currencyAgentId;
            obj.transactionId = transactionId;
            obj.sourceAgentId = sourceAgentId;
            obj.destinationAgentId = destinationAgentId;
            obj.note = note;
            obj.dateCreated = timeStep;
        end
        
        function value = get.currencyAgentId(obj)
            value = obj.currencyAgentId;
        end
                
        function dump(obj)
            % Print data for this transaction
            fprintf('%d\t %d\t %d\t %d %+.2f\t %d\t %d\t %d\t  %s\t\n', obj.id, obj.transactionId, obj.dateCreated, obj.type, obj.amount, obj.currencyAgentId, obj.sourceAgentId, obj.destinationAgentId, obj.note);
        end
        
    end
end


classdef Transaction < handle
%================================================================
% Class Transaction
%
% Created by Jess 09.13.18
%================================================================

    properties
        Id
        Type
        Amount
        SourceId
        DestinationId
        DateCreated
    end
    
    methods
        %
        % Constructor
        %
        function obj = Transaction(Id, Type, Amount, SourceId, DestinationId, DateCreated)
            obj.Id = Id;
            obj.Type = Type;
            obj.Amount = Amount;
            obj.SourceId = SourceId;
            obj.DestinationId = DestinationId;
            obj.DateCreated = DateCreated;
        end
        
    end
end


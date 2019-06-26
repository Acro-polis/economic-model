classdef LiquidityFailure < matlab.mixin.SetGet
%================================================================
% Class LiquidityFailure
%
% Records the details of a liquidity failure
%
% Created by Jess 19.06.19
%================================================================

    properties (SetAccess=private)
        id                   uint32 % Liquidity Failure Id      - unique id for this wallet
        sourceAgentId        uint32 % Source Agent Id           - the agent that could not continue the transaction
        destinationAgentId   uint32 % Destination Agent Id      - the agent the source attempted to transact with
        amount               double % Transaction Amount        - transaction amount
        mutualIds                   % Mutual Ids                - the agents mutually shared between the transacting agents
        path                        % Transaction Path          - the entire transaction path
        note                        % Note                      - Optional note
        dateCreated          uint32 % Transaction Date + Time   - For now this equals dt in the simulation time step
    end
        
    methods
        
        %
        % Constructor
        %
        function obj = LiquidityFailure(sourceAgentId, destinationAgentId, amount, mutualIds, path, note, timeStep)
            % 
            obj.id = 1; % TODO make a unique number
            obj.sourceAgentId = sourceAgentId;
            obj.destinationAgentId = destinationAgentId;
            obj.amount = amount;
            obj.mutualIds = mutualIds;
            obj.path = path;
            obj.note = note;
            obj.dateCreated = timeStep;
        end
        
        function value = get.sourceAgentId(obj)
            value = obj.sourceAgentId;
        end

        function value = get.destinationAgentId(obj)
            value = obj.destinationAgentId;
        end
        
        function value = get.amount(obj)
            value = obj.amount;
        end
        
        function value = get.mutualIds(obj)
            value = obj.mutualIds;
        end

        function value = get.path(obj)
            value = obj.path;
        end
        
        function dump(obj)
            % Print data for this record
            m = sprintf("%d\t",obj.mutualIds);
            p = sprintf("%d\t",obj.path);
            fprintf('%d\t %d\t %.2f\t %d\t %s\t mIds = [%s]\t path = [%s]\t\n', obj.sourceAgentId, obj.destinationAgentId, obj.amount, obj.dateCreated, obj.note, m, p);
        end
        
    end
end


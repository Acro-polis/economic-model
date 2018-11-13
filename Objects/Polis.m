classdef Polis < handle
%================================================================
% Class Polis
%
% Created by Jess 10.26.18
%================================================================

    properties (SetAccess = private)
        AM          % The system adjacency matrix
        agents      % Array of all agents
    end

    properties (SetAccess = private, GetAccess = private)
        lastTransactionId
    end
    
    properties (Constant)
        PolisId = 0 
        PercentDemurage = 0.05
    end
    
    methods (Access = public)
        
        function obj = Polis(AM)
            % Zeus assigns the adjacency matrix and instantiates the agents
            obj.AM = AM;
            obj.lastTransactionId = 0;
        end
    
        function createAgents(obj, birthday)
            [rows, ~] = size(obj.AM);
            for row = 1:rows
                obj.agents = [obj.agents ; Agent(row, obj, birthday)];
            end
        end
        
        function depositUBI(obj, amount, timestep)
            % Deposit an amount of UBI to all agents
             [rows, ~] = size(obj.AM);
             for row = 1:rows
                 obj.agents(row).depositUBI(amount, timestep);
             end
        end
        
        function applyDemurrage(obj, timestep)
            % Apply Demurrage to all agents using the default percentage
             [rows, ~] = size(obj.AM);
             for row = 1:rows
                obj.agents(row).applyDemurrage(Polis.PercentDemurage, timestep);
             end
        end
        
        function applyDemurrageWithPercentage(obj, percentage, timestep)
            % Apply Demurrage to all agents using a specified percentage
             [rows, ~] = size(obj.AM);
             for row = 1:rows
                obj.agents(row).applyDemurrage(percentage, timestep);
             end
        end

        function uniqueId = uniqueId(obj)
            % Poor mans unique id, just keep a counter. TODO - advance when
            % the time comes, this will suffice for quite a while.
            obj.lastTransactionId = obj.lastTransactionId + 1;
            uniqueId = obj.lastTransactionId;
        end
        
    end
    
    methods (Static)

    end
end

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

    properties (Constant)
        PolisId = 999 
        PercentDemurage = 0.05
    end
    
    methods (Access = public)
        
        function obj = Polis(AM, birthday)
            % Zeus assigns the adjacency matrix and instantiates the agents
            obj.AM = AM;
            [rows, ~] = size(AM);
            for row = 1:rows
                obj.agents = [obj.agents ; Agent(row, birthday)];
            end
        end
    
        function depositUBI(obj, amount, timestep)
            % Deposit an amount of UBI to all agents
             [rows, ~] = size(obj.AM);
             for row = 1:rows
                 obj.agents(row).wallet.depositUBI(amount, timestep);
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
                obj.agents(row).wallet.applyDemurrage(percentage, timestep);
             end
        end
        
    end
    
    methods (Static)
        function uid = uniqueId()
            %TODO - return a unique number
            uid = 100;
        end
    end
end

classdef Polis < handle
%================================================================
% Class Polis
%
% Welcome to Mount Olympus
%
% Created by Jess 10.26.18
%================================================================

    properties (SetAccess = private)
        AM                  % The system adjacency matrix
        agents              % Array of all agents
        maximumSearchLevels % Maximum search steps allowed for finding valid paths, 6 is a good number
    end

    properties (SetAccess = private, GetAccess = private)
        lastTransactionId
    end
    
    properties (Constant)
        PolisId = 0 
        PercentDemurage = 0.05
    end
    
    properties (Dependent)
        numberOfAgents
    end
    
    methods 
        function numAgents = get.numberOfAgents(obj)
            [numAgents, ~] = size(obj.AM);
        end
    end
    
    methods (Access = public)
        
        function obj = Polis(AM, maximumSearchLevels)
            % Assign the adjacency matrix maximum search levels
            obj.AM = AM;
            obj.maximumSearchLevels = maximumSearchLevels;
            % Reset the sequence
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
        
        function setupSellers(obj, numberOfSellers, initialInventory, totalTimeSteps)
            % Randomly select the agents that will be sellers
            % TODO - Make preferrential selection?
            selectedAgents = randsample(obj.numberOfAgents, numberOfSellers);
            for i = 1:numberOfSellers
                obj.agents(selectedAgents(i,1)).setupAsSeller(initialInventory, totalTimeSteps);
            end
        end
        
        function setupBuyers(obj, numberOfBuyers, totalTimeSteps)
            % Randomly select the agents that will be buyers
            % TODO - Make preferrential selection?
            selectedAgents = randsample(obj.numberOfAgents, numberOfBuyers);
            for i = 1:numberOfBuyers
                obj.agents(selectedAgents(i,1)).setupAsBuyer(totalTimeSteps);
            end
        end
        
        function [buyerseller, buyer, seller, nonparticipant] = parseAgentCommerceRoleTypes(obj)

            buyerseller = 0;
            buyer = 0;
            seller = 0;
            nonparticipant = 0;

            for i = 1:obj.numberOfAgents
                if obj.agents(i).agentCommerceRoleType == Agent.TYPE_BUYER_SELLER
                    buyerseller = buyerseller + 1;
                elseif obj.agents(i).agentCommerceRoleType ==  Agent.TYPE_BUYER_ONLY
                    buyer = buyer + 1;
                elseif obj.agents(i).agentCommerceRoleType == Agent.TYPE_SELLER_ONLY
                    seller = seller + 1;
                else
                    nonparticipant = nonparticipant + 1;
                end    
            end
        end        
        
    end
    
    methods (Static)
    end
    
end

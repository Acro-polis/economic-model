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
    
        function createAgents(obj, birthday, totalTimeSteps)
            [rows, ~] = size(obj.AM);
            for row = 1:rows
                obj.agents = [obj.agents ; Agent(row, obj, birthday, totalTimeSteps)];
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
        
        function setupSellers(obj, numberOfSellers, initialInventory)
            % Randomly select the agents that will be sellers
            % TODO - Make preferrential selection?
            selectedAgents = randsample(obj.numberOfAgents, numberOfSellers);
            for i = 1:numberOfSellers
                obj.agents(selectedAgents(i,1)).setupAsSeller(initialInventory);
            end
        end
        
        function setupBuyers(obj, numberOfBuyers)
            % Randomly select the agents that will be buyers
            % TODO - Make preferrential selection?
            selectedAgents = randsample(obj.numberOfAgents, numberOfBuyers);
            for i = 1:numberOfBuyers
                obj.agents(selectedAgents(i,1)).setupAsBuyer();
            end
        end
        
        function sellers = identifySellers(obj, testAgent)
            % Return a list of all selling agents that are not the
            % testAgent
            sellers = [];
            for i = 1:obj.numberOfAgents
                agent = obj.agents(i);
                if agent.isSeller && agent.id ~= testAgent.id
                    sellers = [sellers ; agent];
                end
            end
        end
        
        %
        % Tabulation Methods
        %
        function [buyerseller, buyer, seller, nonparticipant] = parseAgentCommerceRoleTypes(obj)
            % Count the number of different commerce roles for the current
            % agent poplulation
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
        
        function amount = totalMoneySupplyAtTimestep(obj, timeStep)
            % Sum the total money supply available in all the agents
            % wallets at time = timeStep
            amount = 0;
            for i = 1:obj.numberOfAgents
                amount = amount + obj.agents(i).balanceAllTransactionsAtTimestep(timeStep);
            end
        end

        function amount = totalInventoryAtTimestep(obj, timeStep)
            % Sum the total inventory available from all the agents
            % at time = timeStep
            amount = 0;
            for i = 1:obj.numberOfAgents
                amount = amount + obj.agents(i).availabeInventoryAtTimestep(timeStep);
            end
        end        
        
        function amount = totalPurchasesAtTimestep(obj, timeStep)
            % Sum the total purchases from all the agents
            % at time = timeStep
            amount = 0;
            for i = 1:obj.numberOfAgents
                amount = amount + obj.agents(i).totalPurchasesAtTimestep(timeStep);
            end
        end                

        function amount = totalSalesAtTimestep(obj, timeStep)
            % Sum the total sales from all the agents
            % at time = timeStep
            amount = 0;
            for i = 1:obj.numberOfAgents
                amount = amount + obj.agents(i).totalSalesAtTimestep(timeStep);
            end
        end                        
        
        function amount = totalDemurrageAtTimestep(obj, timeStep)
            % Sum the total demurrage from all the agents
            % at time = timeStep
            amount = 0;
            for i = 1:obj.numberOfAgents
                amount = amount + obj.agents(i).balanceForTransactionTypeAtTimestep(TransactionType.DEMURRAGE, timeStep);
            end
        end                        

        function amount = totalUBIAtTimestep(obj, timeStep)
            % Sum the total UBI from all the agents
            % at time = timeStep
            amount = 0;
            for i = 1:obj.numberOfAgents
                amount = amount + obj.agents(i).balanceForTransactionTypeAtTimestep(TransactionType.UBI, timeStep);
            end
        end                        
        
        function [wallets, ubi, demurrage, purchased, sold, ids, agentTypes] = transactionTimeHistories(obj, totalTimeSteps)
            % Tabulate the wallet, ubi, demurrage time histories for each agent
            wallets = zeros(obj.numberOfAgents, totalTimeSteps);
            ubi = zeros(obj.numberOfAgents, totalTimeSteps);
            demurrage = zeros(obj.numberOfAgents, totalTimeSteps);
            purchased = zeros(obj.numberOfAgents, totalTimeSteps);
            sold = zeros(obj.numberOfAgents, totalTimeSteps);
            ids = zeros(obj.numberOfAgents,1);
            agentTypes = zeros(obj.numberOfAgents,1);
            
            for i = 1:obj.numberOfAgents
                agent = obj.agents(i);
                ids(i,1) = agent.id;
                agentTypes(i,1) = agent.agentCommerceRoleType;
                for j = 1:totalTimeSteps
                    wallets(i,j) = agent.balanceAllTransactionsAtTimestep(j);                                   % Cumulative
                    ubi(i,j) = agent.balanceForTransactionTypeAtTimestep(TransactionType.UBI, j);               % Cumulative
                    demurrage(i,j) = agent.balanceForTransactionTypeAtTimestep(TransactionType.DEMURRAGE, j);   % Cumulative
                    purchased(i,j) = agent.purchasesAtTimestep(j);                                              % Incremental
                    sold(i,j) = agent.salesAtTimestep(j);                                                       % Incremental
                end
            end            
        end

        function count = countBuyers(obj)
            % Count the number of buyer agents
            count = 0;
            for i = 1:obj.numberOfAgents
                if obj.agents(i).isBuyer
                    count = count + 1;
                end
            end
        end

        function count = countSellers(obj)
            % Count the number of seller agents
            count = 0;
            for i = 1:obj.numberOfAgents
                if obj.agents(i).isSeller
                    count = count + 1;
                end
            end
        end

        function [numBS, numB, numS, numNP] = countAgentCommerceTypes(obj, agentTypes)
            % Return the numerical distribution of the agent types
            
            numBS = 0;
            numB = 0;
            numS = 0;
            numNP = 0;
            
            [rows, ~] = size(agentTypes);
            assert(rows == obj.numberOfAgents,"Error due to your incompetence!");
            
            for i = 1:obj.numberOfAgents
                if agentTypes(i) == Agent.TYPE_BUYER_SELLER
                    numBS = numBS + 1;
                elseif agentTypes(i) == Agent.TYPE_BUYER_ONLY
                    numB = numB + 1;
                elseif agentTypes(i) == Agent.TYPE_SELLER_ONLY
                    numS = numS + 1;
                elseif agentTypes(i) == Agent.TYPE_NONPARTICIPANT
                    numNP = numNP + 1;
                end
            end            
        end
        
        function [totalLedgerRecordsByAgent, totalLedgerRecordsByAgentNonTransitive, totalLedgerRecordsByAgentTransitive] = totalLedgerRecordsByAgent(obj, timeStep)
            % Return the total number of ledger records for all agents
            totalLedgerRecordsByAgent = zeros(obj.numberOfAgents,1);
            totalLedgerRecordsByAgentNonTransitive = zeros(obj.numberOfAgents,1);
            totalLedgerRecordsByAgentTransitive = zeros(obj.numberOfAgents,1);
            for i = 1:obj.numberOfAgents
                totalLedgerRecordsByAgent(i,1) = obj.agents(i).totalLedgerRecords;
                totalLedgerRecordsByAgentNonTransitive(i,1) = obj.agents(i).totalLedgerRecordsForTransactionTypeSeries(TransactionType.BUY_SELL_SERIES, timeStep);
                totalLedgerRecordsByAgentTransitive(i,1) = obj.agents(i).totalLedgerRecordsForTransactionTypeSeries(TransactionType.BUY_SELL_TRANSITIVE_SERIES, timeStep);
            end
        end
        
    end
    
    methods (Static)
    end
    
end

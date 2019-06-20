classdef Polis < handle
%================================================================
% Class Polis
%
% Welcome to Mount Olympus
%
% Created by Jess 10.26.18
%================================================================

    properties (SetAccess = public)
        currentTime         % Current Time Step
        liquidityFailures   % Array of all liquidity failures -- TODO further abstract
    end
    
    properties (SetAccess = private)
        AM                  % The system adjacency matrix
        agents              % Array of all agents
        maximumSearchLevels % Maximum search steps allowed for finding valid paths, 6 is a good number
    end

    properties (SetAccess = private, GetAccess = private)
        lastTransactionId
    end
    
    properties (Constant)
        LoggingLevel = 0;   % Current Levels 0, 1, 2
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
        
        function agent = getAgentById(obj, agentId)
            % Given an agent id, return the corresponding agent object
            agent = obj.agents(agentId);
        end
        
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
                
        function [numberOfBuyers, numberOfSellers] = setupBuyersAndSellers(obj, numberOfPassiveAgents, percentSellers, initialInventory)
            % First randomly select the number of passive agents and make
            % all the other agents buyers. Then from the pool of buyers
            % randomly select those that will also be sellers.
            
            % TODO - Make preferrential selection?
            
            % Setup Buyers
            N = obj.numberOfAgents;
            numberOfBuyers = N - numberOfPassiveAgents;
            numberOfSellers = round(percentSellers*numberOfBuyers);
            buyers = zeros(numberOfBuyers);
            
            selectedAgents = randsample(N, numberOfPassiveAgents);
            j = 1;
            for i = 1:N
                if ~ismember(i,selectedAgents)
                    obj.agents(i).setupAsBuyer();
                    buyers(j) = i;
                    j = j + 1;
                end
            end
            
            % Setup Sellers
            selectedAgents = datasample(buyers, numberOfSellers, 'Replace', false);
            for i = 1:numberOfSellers
                obj.agents(selectedAgents(i)).setupAsSeller(initialInventory);
            end
            
        end
                        
        function sellers = identifySellers(obj, testAgent)
            % Return a list of all selling agents that are not the
            % testAgent
            
            % Build list of sellers
            sellers = obj.agents;
            ids = [sellers.isSeller] ~= true;
            sellers(ids) = [];
            
            % Remove testAgent if testAgent is a seller
            if testAgent.isSeller
                id = [sellers.id] == testAgent.id;
                sellers(id) = [];
            end
        end
        
        function selectedAgents = findAgentsByIndexes(obj, agentIndexes)
            % Given a set of agent indexes, return the corresponding agent
            % objects
            selectedAgents = obj.agents(agentIndexes(:));
        end
        
        function sellerIds = identifySellersAvailabeToBuyingAgent(obj, buyingAgentId)
            % Identify all sellers availble to the buying agent (limited by
            % the transaction distance).
            
            buyingAgentsIndirectConnectionsIds = {};
            uncommonConnectionAgentIds = [];
            initialSearchLevel = 0;
            buyingAgent = obj.agents(buyingAgentId);
            buyingAgentDirectConnectionIds = buyingAgent.findMyConnections(obj.AM);
                        
            % Recursively find all indirect connections within the
            % allowed transaction distance
            for i = 1:numel(buyingAgentDirectConnectionIds)
                targetAgentId = buyingAgentDirectConnectionIds(i);
                buyingAgentsIndirectConnectionsIds = [buyingAgentsIndirectConnectionsIds , obj.findAllIndirectConnectionsBetweenTwoAgents(initialSearchLevel, uncommonConnectionAgentIds, buyingAgentId, targetAgentId)]; 
            end

            % Find the unique set of direct and indirect agent ids
            buyerConnectionsIds = unique([cell2mat(buyingAgentsIndirectConnectionsIds) , buyingAgentDirectConnectionIds]);
            
            % Remove the buyingAgentId if present (cannot buy from oneself)
            id = buyerConnectionsIds == buyingAgentId;
            buyerConnectionsIds(id) = [];
            
            % Return the direct and indirect agents that are sellers
            sellers = obj.agents;
            indexes = [sellers.isSeller] ~= true;
            sellers(indexes) = [];
            sellerIds = intersect([sellers.id], buyerConnectionsIds);
            
        end
           
        function uncommonConnectionAgentIds = findAllIndirectConnectionsBetweenTwoAgents(obj, searchLevel, uncommonConnectionAgentIds, thisAgentId, thatAgentId)
            % For two connected agents, thisAgent and thatAgent, find the
            % uncommon connections thatAgent has from thisAgent. Recursivly
            % repeat the process until the search level is reached or we
            % run out of uncommon connections. Remove any duplicates along
            % the way.
            
            logLevel = 2;
            
            if searchLevel > obj.maximumSearchLevels % Must exceed search level to return
              logStatement("\nSearch Maximum Reached for This Agent = %d, That Agent = %d, Search Level = %d\n", [thisAgentId, thatAgentId, searchLevel], logLevel, obj.LoggingLevel);
              return; 
            else
                searchLevel = searchLevel + 1;
            end
            
            % Find uncommon connections and remove any already found
            logStatement("\nProcessing This Agent = %d, That Agent = %d, Search Level = %d\n", [thisAgentId, thatAgentId, searchLevel], logLevel, obj.LoggingLevel);
            newUncommonConnections = findUncommonConnectionsBetweenTwoAgents(obj.AM, thisAgentId, thatAgentId);
            newUncommonConnections = setdiff(newUncommonConnections, uncommonConnectionAgentIds);

            if numel(newUncommonConnections) == 0
                logStatement("\nNone Found for This Agent = %d, That Agent = %d, Search Level = %d\n", [thisAgentId, thatAgentId, searchLevel], logLevel, obj.LoggingLevel);
                return;
            else
                logIntegerArray("Found Uncommon Connections", newUncommonConnections, 2, obj.LoggingLevel);
                
                % Accumulate what we found
                uncommonConnectionAgentIds = [uncommonConnectionAgentIds , newUncommonConnections];
                
                % Recursivley search for more indirect connections
                for i = 1:numel(newUncommonConnections)
                    uncommonConnectionAgentId = newUncommonConnections(i);
                    uncommonConnectionAgentIds = obj.findAllIndirectConnectionsBetweenTwoAgents(searchLevel, uncommonConnectionAgentIds, thatAgentId, uncommonConnectionAgentId);
                end
            end

        end
                
        %
        % Tabulation Methods
        %
        
        function [buyers, sellers] = parseBuyersAndSellers(obj)
            % Identify which agents are buyers and seller (can be both or
            % none)
            N = obj.numberOfAgents;
            buyers = zeros(1,N);
            sellers = zeros(1,N);
            for i = 1:N
                agent = obj.agents(i);
                if agent.isBuyer
                    buyers(1,i) = 1;
                end
                if agent.isSeller
                    sellers(1,i) = 1;
                end
            end
        end
        
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
        
        function numberOfFailures = sumLiquidityFailuresForAgent(obj, agentId)
            % Number of liquidity failures recorded for this agent
        
            function result = isAgent(obj)
                if obj.sourceAgentId == agentId
                    result = true;
                else
                    result = false;
                end
            end
            functionHandle = @isAgent;
    
            matchingObjects = findobj(obj.liquidityFailures, '-function', functionHandle);
            numberOfFailures = numel(matchingObjects);
    
        end
        
    end
    
    methods (Static)
    end
    
end

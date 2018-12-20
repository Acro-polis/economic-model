%===================================================
%
% Commerce model on a network
%
% Author: Jess
% Created: 2018.08.30
%===================================================

version_number = "1.3.0"; % Tagged version in github

inputTypeDouble = 0;
inputTypeString = 1;

% Setup
fprintf("\n===========================================================\n");
fprintf("Modeling Start\n")
fprintf("===========================================================\n");

% Open Input File, read header
fileName = 'InputCommerce.txt';
fileId = fopen(fileName, "r");
for i = 1:3
    fgetl(fileId);
end

% Initializations
T =  parseInputString(fgetl(fileId), inputTypeDouble);                  % Max Time (Input 1)
numSteps = round(T);                                                    % Number of time steps (integer)
assert(numSteps >= 1,'Assert: Number of time steps must be >= 1!');

N =  round(parseInputString(fgetl(fileId), inputTypeDouble));           % Number of Agents (nodes) (Input 2)
assert(N >= 2,'Assert: Number of agemts must be >= 2!');

networkFilename = parseInputString(fgetl(fileId), inputTypeString);     % Network FileName (Input 3)

AM = [];
if networkFilename == ""
    AM = connectedGraph(N);                                                
else
    AM = importNetworkModelFromCSV(N, networkFilename);
end

% Transaction Distance
maxSearchLevels =  round(parseInputString(fgetl(fileId), inputTypeDouble)); % Search Levels (Input 4)
maxSearchLevels = maxSearchLevels - 2;
assert(maxSearchLevels >= 0,"Error: Transaction-Distance < 2");

% Wallet
seedWalletSize = parseInputString(fgetl(fileId), inputTypeDouble); % Wallet Size (Input 5)

% Rate of UBI
amountUBI = parseInputString(fgetl(fileId), inputTypeDouble); % UBI amount (Input 6)
assert(amountUBI > 0,'Assert: UBI must be > 0!');
timeStepUBI = parseInputString(fgetl(fileId), inputTypeDouble); % UBI amount (Input 7)
assert(timeStepUBI >= 1,'Assert: UBI Time Step must be >= 1');

% Percentage of Demurrage
percentDemurrage = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Demurrage (Input 8)
assert(percentDemurrage >= 0 && percentDemurrage <= 1.0,'Assert: Percentage Demurrage Out Of Range!');
timeStepDemurrage = parseInputString(fgetl(fileId), inputTypeDouble); % UBI amount (Input 9)
assert(timeStepDemurrage >= 1,'Assert: Demurrage Time Step must be >= 1');

% Percentage Passive Agents
percentPassiveAgents = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Passive Agents (Input 10)
assert(percentPassiveAgents > 0 && percentPassiveAgents <= 1.0,'Assert: Percentage Buyers Out Of Range!')
numberOfPassiveAgents = round(percentPassiveAgents*N);

% Percentage Seller Agents as a function of the number of Buyers
percentSellers = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Sellers (Input 11)
assert(percentSellers > 0 && percentSellers <= 1.0,'Assert: Percentage Sellers Out Of Range!')

% Cost of goods
price = parseInputString(fgetl(fileId), inputTypeDouble); % Price Goods (Input 12);

% Seller Inventory
inventoryInitialUnits = parseInputString(fgetl(fileId), inputTypeDouble); % Inital Inventory (Input 13)
inventoryInitialValue = inventoryInitialUnits*price;

% Iterations
numberIterations =  round(parseInputString(fgetl(fileId), inputTypeDouble));   % Number Iterations (Input 14)

% Ouput filename
outputSubFolderName = parseInputString(fgetl(fileId), inputTypeString);  % Output folder (Input 15)

fclose(fileId);

% Final Setup
outputFolderPath = "Output";
outputSubfolderPath = sprintf("%s/%s/", outputFolderPath, outputSubFolderName);
[status, msg, msgID] = mkdir(outputSubfolderPath);

salesEfficiencyByIteration = zeros(numberIterations,1);

% Loop over the number of iterations
%parpool('local', 2);
for iteration = 1:numberIterations
        
    polis = Polis(AM, maxSearchLevels); 
    polis.createAgents(1, numSteps);
    
    logStatement("\n\n//////////// Starting Iteration #%d ////////////\n", iteration, 0, polis.LoggingLevel);
    
    % For saving results
    outputPathIteration = sprintf("%s%s/", outputSubfolderPath, sprintf("Iteration_%d",iteration));
    [status, msg, msgID] = mkdir(outputPathIteration);
    
    % Setup Buyers and Sellers
    [numberOfBuyers, numberOfSellers] = polis.setupBuyersAndSellers(numberOfPassiveAgents, percentSellers, inventoryInitialUnits);

    % Parse Roles
    [numBuySellAgents, numBuyAgents, numSellAgents, numPassiveAgents] = polis.parseAgentCommerceRoleTypes();

    % Log Inputs
    reportSimulationInputs(version_number, networkFilename, N, numSteps, maxSearchLevels, amountUBI, timeStepUBI, percentDemurrage, timeStepDemurrage, seedWalletSize, numberOfBuyers, numberOfSellers, price, numBuySellAgents, numBuyAgents, numSellAgents, numPassiveAgents, "");

    % Report Initial Statistics
    sumWallets = polis.totalMoneySupplyAtTimestep(1);
    sumSellerInventoryUnits = polis.totalInventoryAtTimestep(1);
    sumSellerInventoryValue = sumSellerInventoryUnits*price;
    logStatement("\n- Initial Money Supply = %.2f drachma, Inventory Supply = %.2f, Inventory Value = $%.2f\n\n", [sumWallets, sumSellerInventoryUnits, sumSellerInventoryValue], 0, polis.LoggingLevel);

    %--------------------------------------------------------------------------
    % Simulation finish states
    OutOfTime       = 0;
    OutOfInventory  = 1;
    OutOfMoney      = 2;
    SuspendCode     = OutOfTime;
    FailNoPath      = zeros(N, numSteps);
    FailNoLiquidity = zeros(N, numSteps);
    FailNoInventory = zeros(N, numSteps);
    FailNoMoney     = zeros(N, numSteps);

    startTime = tic();

    intervalUBI = 1;
    intervalDemurrage = 1;

    % Start simulation
    for time = 1:numSteps

       logStatement("\n++++++++ Start of time step = %d ++++++++\n", time, 0, polis.LoggingLevel);

       % Apply demurrage
       if intervalDemurrage < timeStepDemurrage
           intervalDemurrage = intervalDemurrage + 1;
       else
           logStatement("\n-- Applying Demurrage at time = %d --\n", time, 1, polis.LoggingLevel);
           polis.applyDemurrageWithPercentage(percentDemurrage, time);
           intervalDemurrage = 1;
       end

       % Deposit UBI
       if intervalUBI < intervalUBI
           intervalUBI = intervalUBI + 1;
       else
            logStatement("\n-- Depositing UBI at time = %d --\n", time, 1, polis.LoggingLevel);
            polis.depositUBI(amountUBI, time);
            intervalUBI = 1;
       end

       % Randomly order buyers before each time step
       numBuyerIndex = 1:N;
       randBuyerIndex = numBuyerIndex(randperm(length(numBuyerIndex)));

       for buyer = 1:numel(randBuyerIndex)

           agentBuyerId = randBuyerIndex(buyer);
           agentBuying = polis.agents(agentBuyerId);

           % Skip non-buying agents
           if agentBuying.isBuyer == false
               logStatement("\n+ B(%d) is not a buyer\n", agentBuyerId, 2, polis.LoggingLevel);
               continue;
           end

           % Skip agents out of money
           if agentBuying.balanceAllTransactionsAtTimestep(time) < price
               FailNoMoney(agentBuyerId, time) = FailNoMoney(agentBuyerId, time) + 1;
               logStatement("\n- B(%d) is a buyer out of money\n", agentBuyerId, 2, polis.LoggingLevel);
               continue;
           end

           % Find sellers that are not the buying agent
           sellingAgents = polis.identifySellers(agentBuying);
           numberOfAvailableSellers = size(sellingAgents,1);

           if  numberOfAvailableSellers > 0

               % Pick a seller randomly
               j = randsample(numberOfAvailableSellers,1);
               agentSelling = sellingAgents(j);

               logStatement("\n++ Proposed Purchase Of Agent %d From Agent %d\n", [agentBuying.id, agentSelling.id], 1, polis.LoggingLevel);
               % Submit the purchase
               numUnits = 1;           
               result = agentBuying.submitPurchase(polis.AM, numUnits, numUnits*price, agentSelling, time);

               if result == TransactionType.TRANSACTION_SUCCEEDED
                   logStatement("\nSale Successful!\n", [], 1, polis.LoggingLevel);
                   agentSelling.recordSale(numUnits, time);
                   agentBuying.recordPurchase(numUnits, time);
               else
                   if result == TransactionType.FAILED_NO_LIQUIDITY
                       FailNoLiquidity(agentBuyerId, time) = FailNoLiquidity(agentBuyerId, time) + 1;
                       logStatement("\nSale Failed, No Liquidity\n", [], 1, polis.LoggingLevel);
                   elseif result == TransactionType.FAILED_NO_PATH_FOUND
                       FailNoPath(agentBuyerId, time) = FailNoPath(agentBuyerId, time) + 1;
                       logStatement("\nSale Failed, No Path Found\n", [], 1, polis.LoggingLevel);
                   elseif result == TransactionType.FAILED_NO_INVENTORY
                       FailNoInventory(agentBuyerId, time) = FailNoInventory(agentBuyerId, time) + 1;
                       logStatement("\nSale Failed, No Inventory\n", [], 1, polis.LoggingLevel);
                   else
                       logStatement("\nUnrecognized result. Check it out!\n", [], 0, polis.LoggingLevel);
                       assert(true,"Should not be here, investigate!");
                   end
               end

           else
               % No sale :-(
               logStatement("\nNo sellers available\n", [], 0, polis.LoggingLevel);
               assert(true,"Should not be here, investigate!");
           end
       end

       if polis.totalInventoryAtTimestep(time) <= 0
           SuspendCode = OutOfInventory;
           break;
       end

    % TODO - Break if out of money any time other than time = 1
    %    if sumWallets <= 0 && time ~= 1
    %        SuspendCode = OutOfMoney;
    %        reportIncrementalStatistics(polis, price, time);
    %        break;
    %    end   

    end

    % Simulation Completion Status
    if SuspendCode == OutOfTime
        logStatement("\n- Simulation Ended Normally At Time Step = %d\n", time, 0, polis.LoggingLevel);
    elseif SuspendCode == OutOfInventory
        logStatement("\n- Simulation Halted: Out Of Inventory At Time = %d\n", time, 0, polis.LoggingLevel);
    elseif SuspendCode == OutOfMoney
        logStatement("\n- Simulation Halted: Out Of Money At Time = %d\n", time, 0, polis.LoggingLevel);
    end

    elapsedTime1 = toc(startTime);
    logStatement('\n===== Simulation Run Time = %.2f Seconds\n', elapsedTime1, 0, polis.LoggingLevel);

    %
    % Tabluate results for ouput
    %
    logStatement("\n=============================\n", [], 0, polis.LoggingLevel);
    logStatement("\nTabulating Results For Output\n", [], 0, polis.LoggingLevel);
    logStatement("\n=============================\n", [], 0, polis.LoggingLevel);
    [Wallet, UBI, Demurrage, Purchased, Sold, ids, agentTypes] = polis.transactionTimeHistories(time);

    elapsedTime2 = toc(startTime);
    logStatement('\n===== Results Generation Required = %.2f Seconds\n', (elapsedTime2 - elapsedTime1), 0, polis.LoggingLevel);

    %
    % ====== Reporting ======
    %

    % Simulation Inputs
    filePath = sprintf("%s%s", outputPathIteration, "results.txt");
    reportSimulationInputs(version_number, networkFilename, N, numSteps, maxSearchLevels, amountUBI, timeStepUBI, percentDemurrage, timeStepDemurrage, seedWalletSize, numberOfBuyers, numberOfSellers, price, numBuySellAgents, numBuyAgents, numSellAgents, numPassiveAgents, filePath);
    % Simulation Statistics
    reportSimulationStatistics(polis, price, time, elapsedTime1, elapsedTime2, filePath);
    % Transaction Failure Analysis
    salesEfficiencyByIteration = reportTransactionFailures(polis, iteration, FailNoMoney, FailNoLiquidity, FailNoPath, FailNoInventory, Purchased, time, filePath, salesEfficiencyByIteration);

    % Output Network
    nodesFilePath = sprintf("%s%s", outputPathIteration, "nodes.csv");
    edgesFilePath = sprintf("%s%s", outputPathIteration, "edges.csv");
    outputNetwork(AM, Purchased, FailNoPath, FailNoLiquidity, FailNoInventory, FailNoMoney, nodesFilePath, edgesFilePath);

    %
    % ======  Plot some results  ======
    %
    logStatement("\n----- Begin Plotting -----\n", [], 0, polis.LoggingLevel);
    close all
    yScale = 1.5;
    colors = Colors();

    % Plot the 4 panal summary plot
    filePath = sprintf("%s%s", outputPathIteration, "Summary.fig");
    plotSummary(yScale, polis, Wallet, UBI, Demurrage, Purchased, Sold, time, filePath);

    % Plot cumulative money supply, UBI and Demurrage
    filePath = sprintf("%s%s", outputPathIteration, "Cum_MS_UBI_Dem.fig");
    plotCumulativeMoneySupplyUBIDemurrageAllAgents(Wallet, UBI, Demurrage, time, colors, filePath);

    % Plot wallets by agent id
    filePath = sprintf("%s%s", outputPathIteration, "Wallets_By_Id.fig");
    plotWalletByAgentId(polis, Wallet, ids, time, filePath);

    % Plot purchased & sold items by agent id
    filePath = sprintf("%s%s", outputPathIteration, "Purchases.fig");
    plotPuchsasedItemsByAgent(polis, Purchased, ids, time, filePath);
    filePath = sprintf("%s%s", outputPathIteration, "Sales.fig");
    plotSoldItemsByAgent(polis, Sold, ids, time, filePath);

    % Plot transaction failures by agent
    filePath = sprintf("%s%s", outputPathIteration, "Transaction_Log_Agent.fig");
    plotTransactionFailuresByAgent(yScale, polis, FailNoMoney, FailNoLiquidity, FailNoPath, FailNoInventory, Purchased, filePath);

    % Plot transaction failures in time
    filePath = sprintf("%s%s", outputPathIteration, "Transaction_Log_Time.fig");
    plotTransactionFailuresInTime(time, FailNoMoney, FailNoLiquidity, FailNoPath, FailNoInventory, filePath);

    % Now sort the data by agentType for the remaining output
    [Wallet, UBI, Demurrage, Purchased, Sold, ids, agentTypes] = sortByAgentType(Wallet, UBI, Demurrage, Purchased, Sold, ids, agentTypes);
    [numBS, numB, numS, numNP] = polis.countAgentCommerceTypes(agentTypes);

    % Plot wallets grouped by agent type
    filePath = sprintf("%s%s", outputPathIteration, "Wallet_Agent_Type.fig");
    plotWalletByAgentType(Wallet, numBS, numB, numS, numNP, time, colors, filePath);

    % Plot cumlative UBI & Demurrage grouped by agent type
    filePath = sprintf("%s%s", outputPathIteration, "Cum_UBI_ETC_BY_Agent_Type.fig");
    plotUBIDemurrageByAgentType(UBI, Demurrage, numBS, numB, numS, numNP, time, colors, filePath);

    % Plot total ledger records by agent
    [totalLedgerRecordsByAgent, totalLedgerRecordsByAgentNonTransitive, totalLedgerRecordsByAgentTransitive] = polis.totalLedgerRecordsByAgent(time);
    filePath = sprintf("%s%s", outputPathIteration, "Ledger.fig");
    plotLedgerRecordTotals(totalLedgerRecordsByAgent, totalLedgerRecordsByAgentNonTransitive, totalLedgerRecordsByAgentTransitive, filePath);
    
    logStatement("\n----- Finsihed Plotting -----\n", [], 0, polis.LoggingLevel);
    logStatement("\n//////////// Ending Iteration #%d ////////////\n", iteration, 0, polis.LoggingLevel);

end % End Of Iterations Loop

resultsFile = sprintf("%s%s", outputSubfolderPath, "summaryResults.txt");
reportGlobalStatistics(resultsFile, salesEfficiencyByIteration);

%
% ======  Helping Functions  ======
%

function reportGlobalStatistics(filePath, results)

    meanR = mean(results);
    stdR = std(results);
    
    o1 = sprintf("\nIterations Complete, Outputing Summary Statistics\n\n");
    o2 = sprintf("<Sales Efficiency> = %.2f\n", meanR*100);
    o3 = sprintf("Standard Deviation = %.2f\n", stdR*100);
    o4 = sprintf("\nSummary Output Complete\n");
    
    fprintf(o1);
    fprintf(o2);
    fprintf(o3);
    fprintf(o4);

    fileId = fopen(filePath, "wt");
    if fileId > 0
        fprintf(fileId, o1);
        fprintf(fileId, o2);
        fprintf(fileId, o3);
        fprintf(fileId, o4);
        fclose(fileId);    
    end
end

function reportSimulationInputs(version_number, networkFilename, N, numSteps, maxSearchLevels, amountUBI, timeStepUBI, percentDemurrage, timeStepDemurrage, seedWalletSize, numberOfBuyers, numberOfSellers, price, numBuySellAgents, numBuyAgents, numSellAgents, numPassiveAgents, filePath)
    o1 = sprintf("\n----- Summarized Simulation Inputs For Code Version %s -----\n", version_number);
    o2 = "";
    if networkFilename == ""
        o2 = sprintf("\n- Using Connected Network\n\n");
    else
        o2 = sprintf("\n- Network Input Filename = %s\n\n", networkFilename);
    end
    o3  = sprintf("- Number Agents = %d, Time Steps (Duration) = %d, Maximum Search Path Level = %d\n\n", N, numSteps, (maxSearchLevels+2));
    o4  = sprintf("- UBI = %.2f drachmas/agent, applied every %.0f time steps\n\n", amountUBI, timeStepUBI);
    o5  = sprintf("- Demurrage = %.2f percent/agent, applied every %.0f time steps\n\n", percentDemurrage*100, timeStepDemurrage);
    o6  = sprintf("- Starting wallet size/agent = %.2f drachma\n\n", seedWalletSize);
    o7  = sprintf("- Price of goods = %.2f drachmas\n\n", price);
    o8  = sprintf("- Num buyers   = %d <= %d agents\n\n", numberOfBuyers, N);
    o9  = sprintf("- Num sellers  = %d <= %d agents\n\n", numberOfSellers, N);
    o10 = sprintf("- Num Buyers&Sellers = %d, Buyers Only = %d, Passive Agents = %d, Sellers Only = %d\n",numBuySellAgents, numBuyAgents, numPassiveAgents, numSellAgents);

    fprintf(o1);
    fprintf(o2);
    fprintf(o3);
    fprintf(o4);
    fprintf(o5);
    fprintf(o6);
    fprintf(o7);
    fprintf(o8);
    fprintf(o9);
    fprintf(o10);

    fileId = fopen(filePath, "w");
    if fileId > 0
        fprintf(fileId, o1);
        fprintf(fileId, o2);
        fprintf(fileId, o3);
        fprintf(fileId, o4);
        fprintf(fileId, o5);
        fprintf(fileId, o6);
        fprintf(fileId, o7);
        fprintf(fileId, o8);
        fprintf(fileId, o9);
        fprintf(fileId, o10);
        fclose(fileId);    
    end
end

function reportSimulationStatistics(polis, price, time, elapsedTime1, elapsedTime2, filePath)

    sumWallets = polis.totalMoneySupplyAtTimestep(time);
    cumDemurrage = polis.totalDemurrageAtTimestep(time);
    cumUBI = polis.totalUBIAtTimestep(time);

    sumSellerInventoryUnits = polis.totalInventoryAtTimestep(time);
    sumSellerInventoryValue = sumSellerInventoryUnits*price;
    sumBought = polis.totalPurchasesAtTimestep(time);
    sumSold = polis.totalSalesAtTimestep(time);

    o1 = sprintf("\n----- Summarized Results, End Of Time Step = %d -----\n\n",time);
    t1 = elapsedTime1/60;
    t2 = (elapsedTime2 - elapsedTime1)/60;
    o2 = sprintf("* Simulation Time = %.2f + Results Generation Time = %.2f = %.2f Minutes\n\n", t1, t2, t1 + t2);
    o3 = sprintf("* Total Money Supply = %.2f drachma, Total Demurrage = %.2f drachma, Total UBI = %.2f drachma (check: Tot. TMS - (UBI + Demurrage) = %.2f)\n\n", sumWallets, cumDemurrage, cumUBI, (sumWallets - (cumUBI + cumDemurrage)));
    o4 = sprintf("* Remaining Inventory Supply = %.2f, Remaining Inventory Value = $%.2f, Total Inventory Exchanged = %2.f (check: Purchased - Sold = %.2f)\n\n",sumSellerInventoryUnits, sumSellerInventoryValue, sumBought, (sumBought - sumSold));
    
    fprintf(o1);
    fprintf(o2);
    fprintf(o3);
    fprintf(o4);
    
    fileId = fopen(filePath, "a");
    if fileId > 0
        fprintf(fileId, o1);
        fprintf(fileId, o2);
        fprintf(fileId, o3);
        fprintf(fileId, o4);
        fclose(fileId);
    end
end

function salesEfficiencyByIteration = reportTransactionFailures(polis, iteration, FailNoMoney, FailNoLiquidity, FailNoPaths, FailNoInventory, Purchased, endTime, filePath, salesEfficiencyByIteration)
    numBuyers = polis.countBuyers;
    sumNoMoney = sum(sum(FailNoMoney(:,1:endTime)));
    sumNoLiquidity = sum(sum(FailNoLiquidity(:,1:endTime)));
    sumNoPaths = sum(sum(FailNoPaths(:,1:endTime)));
    sumNoInventory = sum(sum(FailNoInventory(:,1:endTime)));
    sumPurchased = sum(sum(Purchased(:,1:endTime)));
    o1 = sprintf("* Items Purchased = %.2f, Failed No Money = %.2f, Failed No Liquidity = %.2f, Failed No Paths = %.2f, Failed No Inventory = %.2f\n", sumPurchased, sumNoMoney, sumNoLiquidity, sumNoPaths, sumNoInventory);
    expectedPurchased = numBuyers*endTime;
    checkSum = sumPurchased + sumNoMoney + sumNoLiquidity + sumNoPaths + sumNoInventory;
    o2 = "";
    o3 = "";
    if expectedPurchased == checkSum
        o2 = sprintf("* Expected Purchases = Items Purchased + Sum Of Failures = %2.f\n", expectedPurchased);
        salesEfficiency = (sumPurchased/expectedPurchased);
        o3 = sprintf("* Selling Efficency = %.2f percent\n\n", salesEfficiency*100.0);
        
        % Record the sales efficiency for this iteration
        salesEfficiencyByIteration(iteration) = salesEfficiency;
        
    else
        o2 = sprintf("\n***\n*** Error: Expected Items Purchased %.2f ~= Those Purchased + Failures = %.2f!\n***\n", expectedPurchased, checkSum);
        o3 = sprintf("--\n");
    end

    fprintf(o1);
    fprintf(o2);
    fprintf(o3);
    
    fileId = fopen(filePath, "a");
    if fileId > 0
        fprintf(fileId, o1);
        fprintf(fileId, o2);
        fprintf(fileId, o3);
        fclose(fileId);
    end    
end

function [wallets, ubi, demurrage, purchased, sold, ids, agentTypes] = sortByAgentType(wallets, ubi, demurrage, purchased, sold, ids, agentTypes)
            % Sort these matrices by the agentTypes
            [agentTypes, indices] = sort(agentTypes);
            wallets = wallets(indices,:);
            ubi = ubi(indices,:);
            demurrage = demurrage(indices,:);
            purchased = purchased(indices,:);
            sold = sold(indices,:);
            ids = ids(indices);
end

function outputNetwork(AM, Purchased, FailNoPath, FailNoLiquidity, FailNoInventory, FailNoMoney, nodesFilePath, edgesFilePath)
    % Output the network with some statistics for external processing
    sumPurchased    = sum(Purchased,2);
    sumNoPath       = sum(FailNoPath,2);
    sumNoLiquidity  = sum(FailNoLiquidity,2);
    sumNoInventory  = sum(FailNoInventory,2);
    sumNoMoney      = sum(FailNoMoney,2);
    outputEMNetworkForGephi(AM, sumPurchased, sumNoPath, sumNoLiquidity, sumNoInventory, sumNoMoney, nodesFilePath, edgesFilePath);
end

%
% ====== Plotting Functions ======
%
function plotTransactionFailuresByAgent(yScale, polis, FailNoMoney, FailNoLiquidity, FailNoPath, FailNoInventory, Purchased, filePath)

    sumNoMoney      = sum(FailNoMoney,2);
    sumNoLiquidity  = sum(FailNoLiquidity,2);
    sumNoPath       = sum(FailNoPath,2);
    sumNoInventory  = sum(FailNoInventory,2);
    sumPurchased    = sum(Purchased,2);

    f = figure;
    numAgents = polis.numberOfAgents;
    x = 1:numAgents;
    sp = 6;
    
    ax1 = subplot(sp,1,1);
    maxYHeight = max(sumPurchased)*yScale;
    if (maxYHeight <= 0) 
        maxYHeight = 1; 
    end    
    plot(ax1, x, sumPurchased.','k-d');
    xlim([1 numAgents]);
    ylim([0 maxYHeight]);
    xlabel('Agent');
    ylabel('Number');
    title("Purchases By Agent");
    legend("Purchases");
    
    ax2 = subplot(sp,1,2);
    maxYHeight = max(sumNoPath)*yScale;
    if (maxYHeight <= 0) 
        maxYHeight = 1; 
    end    
    plot(ax2, x, sumNoPath.','b-*');
    xlim([1 numAgents]);
    ylim([0 maxYHeight]);
    xlabel('Agent');
    ylabel('Number');
    title("No Path Failures By Agent");
    legend("Failures");
    
    ax3 = subplot(sp,1,3);
    maxYHeight = max(sumNoLiquidity)*yScale;
    if (maxYHeight <= 0) 
        maxYHeight = 1; 
    end    
    plot(ax3, x, sumNoLiquidity.','r-s');
    xlim([1 numAgents]);
    ylim([0 maxYHeight]);
    xlabel('Agent');
    ylabel('Number');
    title("No Liquidity Failures By Agent");
    legend("Failures");

    ax4 = subplot(sp,1,4);
    maxYHeight = max(sumNoInventory)*yScale;
    if (maxYHeight <= 0) 
        maxYHeight = 1; 
    end    
    plot(ax4, x, sumNoInventory.','c-o');
    xlim([1 numAgents]);
    ylim([0 maxYHeight]);
    xlabel('Agent');
    ylabel('Number');
    title("No Inventory Failures By Agent");
    legend("Failures");

    ax5 = subplot(sp,1,5);
    maxYHeight = max(sumNoMoney)*yScale;
    if (maxYHeight <= 0) 
        maxYHeight = 1; 
    end    
    plot(ax5, x, sumNoMoney.','g-+');
    xlim([1 numAgents]);
    ylim([0 maxYHeight]);
    xlabel('Agent');
    ylabel('Number');
    title("No Money Failures By Agent");
    legend("Failures");
    
    [Buyers, Sellers] = polis.parseBuyersAndSellers();
    ax6 = subplot(sp,1,6);
    plot(ax6, x, Buyers, 'x', x, Sellers, 'o');
    xlim([1 numAgents]);
    ylim([0.9 1.1]);
    xlabel('Agent');
    ylabel('Type');
    title('Buyers & Sellers');
    legend('Buyers','Sellers');
    
    saveas(f, filePath, 'fig');
       
end

function plotTransactionFailuresInTime(time, FailNoMoney, FailNoLiquidity, FailNoPath, FailNoInventory, filePath)
    f = figure;
    x = 1:time;
    hold on;
    p1 = plot(x, sum(FailNoPath(:,x)), '--x');
    p2 = plot(x, sum(FailNoLiquidity(:,x)), '-b');
    p3 = plot(x, sum(FailNoInventory(:,x)), '-r');
    p4 = plot(x, sum(FailNoMoney(:,x)), '-g');
    hold off;
    xlim([1 time]);
    legend([p1, p2, p3, p4],{'Path','Liquidity','Inventory','Money'});
    xlabel('Time');
    ylabel('Number of Failures');
    title('Deal Failures By Type In Time');
    
    saveas(f, filePath, 'fig');
end

function plotSummary(yScale, polis, Wallet, UBI, Demurrage, Purchased, Sold, endTime, filePath)
    %
    % The summary plot has 4 sections
    %
    numAgents = polis.numberOfAgents;

    % Section 1: Final Wallet Size By Agent At time = endTime
    maxYHeight = max(Wallet(:,endTime))*yScale;
    if (maxYHeight <= 0) 
        maxYHeight = 1; 
    end
    
    f = figure;
    ax1 = subplot(4,1,1);
    x = 1:numAgents;
    plot(ax1, x, Wallet(:,endTime),'-o');
    xlim([1 numAgents]);
    ylim([0 maxYHeight]);
    xlabel('Agent');
    ylabel('Drachmas');
    title('Remaining Money');
    legend('Wallet Size');

    % Section 2: Items Bought & Sold Distribution
    yHeights = sort([max(sum(Purchased,2)) max(sum(Sold,2))],'descend');
    maxYHeight = yHeights(1)*yScale;
    if (maxYHeight <= 0) 
        maxYHeight = 1; 
    end

    ax2 = subplot(4,1,2);
    x = 1:numAgents;
    plot(ax2, x, sum(Purchased,2), '--o', x, sum(Sold,2), '-o');
    xlim([1 numAgents]);
    ylim([0 maxYHeight]);
    xlabel('Agent');
    ylabel('Units');
    title('Units Bought & Sold');
    legend('Bought','Sold');

    % Section 3: Distribution Buyers & Sellers
    [Buyers, Sellers] = polis.parseBuyersAndSellers();
    ax3 = subplot(4,1,3);
    x = 1:numAgents;
    plot(ax3, x, Buyers, 'x', x, Sellers, 'o');
    xlim([1 numAgents]);
    ylim([0.9 1.1]);
    xlabel('Agent');
    ylabel('Type');
    title('Buyers & Sellers');
    legend('Buyers','Sellers');

    % Section 4: Money Supply
    totalUBI = UBI(:,endTime);
    totalDemurrage = Demurrage(:,endTime);
    initialWallet = Wallet(:,1);
    net = initialWallet + totalUBI - totalDemurrage;
    yHeights = sort([max(net) max(initialWallet) max(totalUBI) max(totalDemurrage)],'descend');
    maxYHeight = yHeights(1)*yScale;
    if (maxYHeight <= 0) 
        maxYHeight = 1; 
    end
    minyLim = 0;
    if min(net) < 0
        minyLim = min(net)*yScale;
    end

    ax4 = subplot(4,1,4);
    x = 1:numAgents;
    plot(ax4, x, net, 'c-*', x, initialWallet, '--o', x, totalUBI, 'g-x', x, -totalDemurrage, '-ro');
    xlim([1 numAgents]);
    ylim([minyLim maxYHeight]);
    xlabel('Agent');
    ylabel('Drachma');
    title('Money Supply');
    legend('Net', 'Seed','UBI', 'Dumurrage');
    
    saveas(f, filePath, 'fig');
end

function plotWalletByAgentId(polis, Wallet, ids, endTime, filePath)
    %
    % Wallet by Agent
    %
    numberOfAgents = polis.numberOfAgents;
    [rows, ~] = size(Wallet);
    if rows == endTime
        % Sqaure Matrix, invert it so the plot function does what we want
        Wallet = Wallet.';
    end
    f = figure;
    hold on;
    x = 1:endTime;
    p = plot(x, Wallet(:, x),'-x');
    hold off;
    ps = [];
    psnames = {};
    for i = 1:numberOfAgents
        ps = [ps ; p(i)];
        name = sprintf("%d",ids(i));
        psnames = [psnames ; {name}];
    end
    legend(ps, psnames);
    xlim([1 endTime]);
    xlabel('Time');
    ylabel('Drachma');
    title('Wallet By Agent Id');
    
    saveas(f, filePath, 'fig');
end

function plotWalletByAgentType(Wallet, numBS, numB, numS, numNP, endTime, colors, filePath)
    % 
    % Plot Wallet By Agent Type
    %
    
    f = figure;
    x = 1:endTime;
    p1 = plot(x, Wallet(1:numBS, x),'b-diamond');
    %set(p1,'color',blue); %TODO - Matlab bug?
    ps = p1(1);
    psnames = {'Buy-Sell'};
    hold on;
    if numB > 0
        a1 = numBS + 1;
        a2 = numBS + numB;
        p2 = plot(x, Wallet(a1:a2, x),'g-+');
        %p2 = plot(x, Wallet(a1:a2, 1:time),'Color',green,'LineStyle','-','Marker','+','LineWidth',0.5);
        ps = [ps ; p2(1)];
        psnames = [psnames , {'Buy'}];
    end
    if numS > 0
        a1 = numBS + numB + 1;
        a2 = numBS + numB + numS;
        p3 = plot(x, Wallet(a1:a2, x),'Color',colors.violet,'LineStyle','-','Marker','*','LineWidth',0.5); 
        ps = [ps ; p3(1)];
        psnames = [psnames , {'Sell'}];
    end
    if numNP > 0
        a1 = numBS + numB + numS + 1;
        a2 = numBS + numB + numS + numNP;
        p4 = plot(x, Wallet(a1:a2, x),'Color',colors.red,'LineStyle','-','Marker','x','LineWidth',0.5);
        ps = [ps ; p4(1)];
        psnames = [psnames , {'Passive'}];
    end
    %
    % Add the average wallet size
    %
    %plot(x,(sum(Wallet(:, x)) ./ N),'k--+');
    hold off;
    legend(ps,psnames);
    xlim([1 endTime]);
    xlabel('Time');
    ylabel('Drachma');
    title('Wallet by Agent Type');
    
    saveas(f, filePath, 'fig');
end

function plotCumulativeMoneySupplyUBIDemurrageAllAgents(Wallet, UBI, Demurrage, endTime, colors, filePath)
    % 
    % Plot Cumulative Money Supply, Demurrage & UBI
    %
    
    % Sum over all agents
    demurrageAllAgents = sum(-Demurrage);
    UBIAllAgents = sum(UBI);
    walletAllAgents = sum(Wallet);

    f = figure;
    hold on;
    x = 1:endTime;
    p1 = plot(x, walletAllAgents(1, x),'k-diamond');
    p2 = plot(x, demurrageAllAgents(1, x),'b-o');
    p3 = plot(x, UBIAllAgents(1, x),'c-x');
    set(p3,'color',colors.gold);
    hold off;
    xlim([1 endTime]);
    legend([p3, p2, p1],{'UBI','Demurrage','Money Supply'});
    xlabel('Time');
    ylabel('Drachma');
    title('Cumulative UBI, Demurrage & Money Supply');
    
    saveas(f, filePath, 'fig');
end

function plotUBIDemurrageByAgentType(UBI, Demurrage, numBS, numB, numS, numNP, endTime, colors, filePath)
    % 
    % Plot Cumulative UBI & Demurrage
    %
    f = figure;
    x = 1:endTime;
    hold on;
    p1 = plot(x, -Demurrage(1:numBS, x),'b-diamond');
    %set(p1,'color',blue); %TODO - Matlab bug?
    ps = p1(1);
    psnames = {'Dem. Buy-Sell'};
    if numB > 0
        a1 = numBS + 1;
        a2 = numBS + numB;
        p2 = plot(x, -Demurrage(a1:a2, x),'g-+');
        %p2 = plot(x, Demurrage(a1:a2, x),'Color',colors.green,'LineStyle','-','Marker','+','LineWidth',0.5);
        ps = [ps ; p2(1)];
        psnames = [psnames , {'Dem. Buy'}];
    end
    if numS > 0
        a1 = numBS + numB + 1;
        a2 = numBS + numB + numS;
        p3 = plot(x, -Demurrage(a1:a2, x),'Color',colors.violet,'LineStyle','-','Marker','*','LineWidth',0.5); 
        ps = [ps ; p3(1)];
        psnames = [psnames , {'Dem. Sell'}];
    end
    if numNP > 0
        a1 = numBS + numB + numS + 1;
        a2 = numBS + numB + numS + numNP;
        p4 = plot(x, -Demurrage(a1:a2, x),'Color',colors.red,'LineStyle','-','Marker','x','LineWidth',0.5);
        ps = [ps ; p4(1)];
        psnames = [psnames , {'Dem. Passive'}];
    end
    
    [rows, ~] = size(UBI);
    if rows == endTime
        % Sqaure Matrix, invert it so the plot function does what we want
        UBI = UBI.';
    end        
    
    p5 = plot(x, UBI(:, x),'color',colors.gold,'linestyle','-','marker','o','linewidth',0.5);
    ps = [ps ; p5(1)];
    psnames = [psnames , {'UBI'}];
    hold off;
    legend(ps,psnames);
    xlim([1 endTime]);
    xlabel('Time');
    ylabel('Drachma');
    title('Cumulative Demurrage By Agent Type + UBI');
    
    saveas(f, filePath, 'fig');
end

function plotPuchsasedItemsByAgent(polis, Purchased, ids, endTime, filePath)
    %
    % Plot Buying and Selling over time
    %
    numberOfAgents = polis.numberOfAgents;
    
    cumPurchased = cumsum(Purchased,2);

    [rows, ~] = size(cumPurchased);
    if rows == endTime
        % Sqaure Matrix, invert it so the plot function does what we want
        cumPurchased = cumPurchased.';
    end    
    
    f = figure;
    hold on;
    x = 1:endTime;
    p = plot(x, cumPurchased(:, x),'-x');
    hold off;
    ps = [];
    psnames = {};
    for i = 1:numberOfAgents
        ps = [ps ; p(i)];
        name = sprintf("%d",ids(i));
        psnames = [psnames ; {name}];
    end
    legend(ps, psnames);
    xlim([1 endTime]);
    xlabel('Time');
    ylabel('Number of Items');
    title('Cumulative Purchased Items By Agent');
    
    saveas(f, filePath, 'fig');
end

function plotSoldItemsByAgent(polis, Sold, ids, endTime, filePath)
    %
    % Plot Buying and Selling over time
    %
    numberOfAgents = polis.numberOfAgents;
    
    cumSold = cumsum(Sold,2);

    [rows, ~] = size(cumSold);
    if rows == endTime
        % Sqaure Matrix, invert it so the plot function does what we want
        cumSold = cumSold.';
    end    
    
    f = figure;
    hold on;
    x = 1:endTime;
    p = plot(x, cumSold(:, x),'-+');
    hold off;
    ps = [];
    psnames = {};
    for i = 1:numberOfAgents
        ps = [ps ; p(i)];
        name = sprintf("%d",ids(i));
        psnames = [psnames ; {name}];
    end
    legend(ps, psnames);
    xlim([1 endTime]);
    xlabel('Time');
    ylabel('Number of Items');
    title('Cumulative Sold Items By Agent');
    
    saveas(f, filePath, 'fig');
end

function plotLedgerRecordTotals(totalLedgerRecordsByAgent, totalLedgerRecordsByAgentNonTransitive, totalLedgerRecordsByAgentTransitive, filePath)
    f = figure;
    [N, ~] = size(totalLedgerRecordsByAgent);
    x = 1:N;
    hold on;
    p1 = plot(x, totalLedgerRecordsByAgent, '--x');
    p2 = plot(x, totalLedgerRecordsByAgentNonTransitive, '-b');
    p3 = plot(x, totalLedgerRecordsByAgentTransitive, '-r');
    hold off;
    xlim([1 N]);
    legend([p1, p2, p3],{'All','Buy/Sell','Transitive'});
    xlabel('Agent Id');
    ylabel('Number of Records');
    title('Total Number Of Ledger Records By Agent');
    
    saveas(f, filePath, 'fig');
end



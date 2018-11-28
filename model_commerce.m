%===================================================
%
% Commerce model on a network
%
% Author: Jess
% Created: 2018.08.30
%===================================================

version_number = "1.2.0"; % Tagged version in github
	
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
dt = 1;                                                                 % Time Step 
numSteps = round(T / dt);                                               % Number of time steps (integer)
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

% Create the polis
maxSearchLevels =  round(parseInputString(fgetl(fileId), inputTypeDouble)); % Search Levels (Input 4)
assert(maxSearchLevels >= 0,"Error: Max. Search Levels < 0");
polis = Polis(AM, maxSearchLevels); 
polis.createAgents(1, numSteps);

% Unit of currency
drachma = 1;

% Wallet
seedWalletSize = parseInputString(fgetl(fileId), inputTypeDouble); % Wallet Size (Input 5)

% Rate of UBI
amountUBI = parseInputString(fgetl(fileId), inputTypeDouble); % UBI amount (Input 6)
assert(amountUBI > 0,'Assert: UBI must be > 0!');
b = 1.0;
amountUBI = amountUBI*drachma / b*dt; 

% Percentage of Demurrage
percentDemurrage = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Demurrage (Input 7)
assert(percentDemurrage >= 0 && percentDemurrage <= 1.0,'Assert: Percentage Demurrage Out Of Range!');
d = 1;
percentDemurrage = percentDemurrage*drachma / d*dt;

% Buyers
percentBuyers = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Buyers (Input 8)
assert(percentBuyers > 0 && percentBuyers <= 1.0,'Assert: Percentage Buyers Out Of Range!')
numberOfBuyers = round(percentBuyers*N);

% Sellers
percentSellers = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Sellers (Input 9)
assert(percentSellers > 0 && percentSellers <= 1.0,'Assert: Percentage Sellers Out Of Range!')
numberOfSellers = round(percentSellers*N);

% Cost of goods
price = parseInputString(fgetl(fileId), inputTypeDouble); % Price Goods (Input 10);
price = price*drachma;

% Seller Inventory
inventoryInitialUnits = parseInputString(fgetl(fileId), inputTypeDouble); % Inital Inventory (Input 11)
inventoryInitialValue = inventoryInitialUnits*price;

fclose(fileId);

% Randomely select sellers
polis.setupSellers(numberOfSellers, inventoryInitialUnits);

% Randomely select buyers
polis.setupBuyers(numberOfBuyers);

% Roles
[numBuySellAgents, numBuyAgents, numSellAgents, numNonparticipatingAgents] = polis.parseAgentCommerceRoleTypes();

% Log Inputs
reportSimulationInputs(version_number, networkFilename, N, numSteps, maxSearchLevels, amountUBI, percentDemurrage, seedWalletSize, numberOfBuyers, numberOfSellers, price, numBuySellAgents, numBuyAgents, numSellAgents, numNonparticipatingAgents);

% Report Initial Statistics
sumWallets = polis.totalMoneySupplyAtTimestep(1);
sumSellerInventoryUnits = polis.totalInventoryAtTimestep(1);
sumSellerInventoryValue = sumSellerInventoryUnits*price;
fprintf("\n- Initial Money Supply = %.2f drachma, Inventory Supply = %.2f, Inventory Value = $%.2f\n\n", sumWallets, sumSellerInventoryUnits, sumSellerInventoryValue);

%--------------------------------------------------------------------------
% Simulation finish states
OutOfTime       = 0;
OutOfInventory  = 1;
OutOfMoney      = 2;
SuspendCode     = OutOfTime;
FailNoMoney     = zeros(N, numSteps);
FailNoLiquidity = zeros(N, numSteps);
FailNoPath      = zeros(N, numSteps);
FailNoInventory = zeros(N, numSteps);

% Start simulation
for time = 1:numSteps

   fprintf("\n++++++++ Start of time step = %d ++++++++\n", time);

   if time > 1
       % Apply demurrage
       fprintf("\n-- Applying Demurrage --\n");
       polis.applyDemurrageWithPercentage(percentDemurrage, time);
   end
   
   % Deposit UBI
   fprintf("\n-- Depositing UBI --\n");
   polis.depositUBI(amountUBI, time);
   
   % Randomly order buyers before each time step
   numBuyerIndex = 1:N;
   randBuyerIndex = numBuyerIndex(randperm(length(numBuyerIndex)));
   
   for buyer = 1:numel(randBuyerIndex)
       
       agentBuyerId = randBuyerIndex(buyer);
       agentBuying = polis.agents(agentBuyerId);
       
       % Skip non-buying agents
       if agentBuying.isBuyer == false
           fprintf("\n+ B(%d) is not a buyer\n",agentBuyerId);
           continue;
       end
       
       % Skip agents out of money
       if agentBuying.balanceAllTransactionsAtTimestep(time) < price
           FailNoMoney(agentBuyerId, time) = FailNoMoney(agentBuyerId, time) + 1;
           fprintf("\n- B(%d) is a buyer out of money\n",agentBuyerId);
           continue;
       end
       
       % Find sellers that are not the buying agent
       sellingAgents = polis.identifySellers(agentBuying);
       numberOfAvailableSellers = size(sellingAgents,1);
             
       if  numberOfAvailableSellers > 0
           
           % Pick a seller randomly
           j = randsample(numberOfAvailableSellers,1);
           agentSelling = sellingAgents(j);
           
           fprintf("\n++ Proposed Purchase Of Agent %d From Agent %d\n", agentBuying.id, agentSelling.id);
           % Submit the purchase
           numUnits = 1;           
           result = agentBuying.submitPurchase(polis.AM, numUnits, numUnits*price, agentSelling, time);
           
           if result == TransactionType.TRANSACTION_SUCCEEDED
               fprintf("\nSale Successful!\n");
               agentSelling.recordSale(numUnits, time);
               agentBuying.recordPurchase(numUnits, time);
           else
               if result == TransactionType.FAILED_NO_LIQUIDITY
                   FailNoLiquidity(agentBuyerId, time) = FailNoLiquidity(agentBuyerId, time) + 1;
                   fprintf("\nSale Failed, No Liquidity\n");
               elseif result == TransactionType.FAILED_NO_PATH_FOUND
                   FailNoPath(agentBuyerId, time) = FailNoPath(agentBuyerId, time) + 1;
                   fprintf("\nSale Failed, No Path Found\n");
               elseif result == TransactionType.FAILED_NO_INVENTORY
                   FailNoInventory(agentBuyerId, time) = FailNoInventory(agentBuyerId, time) + 1;
                   fprintf("\nSale Failed, No Inventory\n");
               else
                   fprintf("\nUnrecognized result. Check it out!\n");
                   assert(true,"Should not be here, investigate!");
               end
           end
                      
       else
           % No sale :-(
           fprintf("\nNo sellers available\n");
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
    fprintf("\nSimulation Ended Normally At Time = %d\n",time);
elseif SuspendCode == OutOfInventory
    fprintf("\nSimulation Halted: Out Of Inventory At Time = %d\n",time);
elseif SuspendCode == OutOfMoney
    fprintf("\nSimulation Halted: Out Of Money At Time = %d\n",time);
end

%
% Tabluate results for ouput
%
fprintf("\n=============================\n");
fprintf("\nTabulating Results For Output\n");
fprintf("\n=============================\n");
[Wallet, UBI, Demurrage, Purchased, Sold, ids, agentTypes] = polis.transactionTimeHistories(time);

%
% ====== Reporting ======
%

% Simulation Inputs
reportSimulationInputs(version_number, networkFilename, N, numSteps, maxSearchLevels, amountUBI, percentDemurrage, seedWalletSize, numberOfBuyers, numberOfSellers, price, numBuySellAgents, numBuyAgents, numSellAgents, numNonparticipatingAgents);
% Simulation Statistics
reportSimulationStatistics(polis, price, time);
% Transaction Failure Analysis
reportTransactionFailures(polis, FailNoMoney, FailNoLiquidity, FailNoPath, FailNoInventory, Purchased, time);

%
% ======  Plot some results  ======
%
fprintf("\n----- Begin Plotting -----\n");
close all
yScale = 1.5;
colors = Colors();

% Plot the 4 panal summary plot
plotSummary(yScale, polis, Wallet, UBI, Demurrage, Purchased, Sold, time);

% Plot cumulative money supply, UBI and Demurrage
plotCumulativeMoneySupplyUBIDemurrageAllAgents(Wallet, UBI, Demurrage, time, colors);

% Plot wallets by agent id
plotWalletByAgentId(polis, Wallet, ids, time);

% Plot purchased & sold items by agent id
plotPuchsasedItemsByAgent(polis, Purchased, ids, time);
plotSoldItemsByAgent(polis, Sold, ids, time);

% Plot transaction failures by agent
%TODO - make a 4 panel in time with Purchased
sP = Purchased;

% Now sort the data by agentType for the remaining output
[Wallet, UBI, Demurrage, Purchased, Sold, ids, agentTypes] = sortByAgentType(Wallet, UBI, Demurrage, Purchased, Sold, ids, agentTypes);
[numBS, numB, numS, numNP] = polis.countAgentCommerceTypes(agentTypes);

% Plot wallets grouped by agent type
plotWalletByAgentType(Wallet, numBS, numB, numS, numNP, time, colors);

% Plot cumlative UBI & Demurrage grouped by agent type
plotUBIDemurrageByAgentType(UBI, Demurrage, numBS, numB, numS, numNP, time, colors);

% Plot total ledger records by agent
totalLedgerRecordsByAgent = polis.totalLedgerRecordsByAgent;
plotLedgerRecordTotals(totalLedgerRecordsByAgent);

%
% ======  Helping Functions  ======
%
function reportSimulationInputs(version_number, networkFilename, N, numSteps, maxSearchLevels, amountUBI, percentDemurrage, seedWalletSize, numberOfBuyers, numberOfSellers, price, numBuySellAgents, numBuyAgents, numSellAgents, numNonparticipatingAgents)
    fprintf("\n----- Summarized Simulation Inputs For Code Version %s -----\n", version_number);
    if networkFilename == ""
        fprintf("\n- Using Connected Network\n\n");
    else
        fprintf("\n- Network Input Filename = %s\n\n", networkFilename);
    end
    fprintf("- Number Agents = %d, Time Steps (Duration) = %d, Maximum Search Path Level = %d\n\n", N, numSteps, maxSearchLevels);
    fprintf("- UBI = %.2f drachmas/agent/dt, Demurrage = %.2f percent/agent/ dt\n\n", amountUBI, percentDemurrage*100);
    fprintf("- Starting wallet size/agent = %.2f drachma\n\n", seedWalletSize);
    fprintf("- Price of goods = %.2f drachmas\n\n", price);
    fprintf("- Num buyers   = %d <= %d agents\n\n", numberOfBuyers, N);
    fprintf("- Num sellers  = %d <= %d agents\n\n", numberOfSellers, N);
    fprintf("- Num Buyers&Sellers = %d, Buyers Only = %d, Sellers Only = %d, Non-Participants = %d\n",numBuySellAgents, numBuyAgents, numSellAgents, numNonparticipatingAgents);
end

function reportSimulationStatistics(polis, price, time)

       sumWallets = polis.totalMoneySupplyAtTimestep(time);
       cumDemurrage = polis.totalDemurrageAtTimestep(time);
       cumUBI = polis.totalUBIAtTimestep(time);

       sumSellerInventoryUnits = polis.totalInventoryAtTimestep(time);
       sumSellerInventoryValue = sumSellerInventoryUnits*price;
       sumBought = polis.totalPurchasesAtTimestep(time);
       sumSold = polis.totalSalesAtTimestep(time);

       fprintf("\n----- Summarized Results, End Of Time Step = %d -----\n\n",time);
       fprintf("* Total Money Supply = %.2f drachma, Total Demurrage = %.2f drachma, Total UBI = %.2f drachma (check: Tot. TMS - (UBI + Demurrage) = %.2f)\n\n", sumWallets, cumDemurrage, cumUBI, (sumWallets - (cumUBI + cumDemurrage)));
       fprintf("* Remaining Inventory Supply = %.2f, Remaining Inventory Value = $%.2f, Total Inventory Exchanged = %2.f (check: Purchased - Sold = %.2f)\n\n",sumSellerInventoryUnits, sumSellerInventoryValue, sumBought, (sumBought - sumSold));
end

function reportTransactionFailures(polis, FailNoMoney, FailNoLiquidity, FailNoPaths, FailNoInventory, Purchased, endTime)
    numBuyers = polis.countBuyers;
    sumNoMoney = sum(sum(FailNoMoney(:,1:endTime)));
    sumNoLiquidity = sum(sum(FailNoLiquidity(:,1:endTime)));
    sumNoPaths = sum(sum(FailNoPaths(:,1:endTime)));
    sumNoInventory = sum(sum(FailNoInventory(:,1:endTime)));
    sumPurchased = sum(sum(Purchased(:,1:endTime)));
    fprintf("* Items Purchased = %.2f, Failed No Money = %.2f, Failed No Liquidity = %.2f, Failed No Paths = %.2f, Failed No Inventory = %.2f\n", sumPurchased, sumNoMoney, sumNoLiquidity, sumNoPaths, sumNoInventory);
    expectedPurchased = numBuyers*endTime;
    checkSum = sumPurchased + sumNoMoney + sumNoLiquidity + sumNoPaths + sumNoInventory;
    assert(expectedPurchased == checkSum,"Error: Expected Items Purchased %.2f ~= Those Purchased + Failures = %.2f!\n", expectedPurchased, checkSum);
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

%
% ====== Plotting Functions ======
%
function plotSummary(yScale, polis, Wallet, UBI, Demurrage, Purchased, Sold, endTime)
    %
    % The summary plot has 4 sections
    %
    numAgents = polis.numberOfAgents;

    % Section 1: Final Wallet Size By Agent At time = endTime
    maxYHeight = max(Wallet(:,endTime))*yScale;
    if (maxYHeight <= 0) 
        maxYHeight = 1; 
    end

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
    Buyers = zeros(1,numAgents);
    Sellers = zeros(1,numAgents);
    for i = 1:numAgents
        agent = polis.agents(i);
        if agent.isBuyer
            Buyers(1,i) = 1;
        end
        if agent.isSeller
            Sellers(1,i) = 1;
        end
    end
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
end

function plotWalletByAgentId(polis, Wallet, ids, endTime)
    %
    % Wallet by Agent
    %
    numberOfAgents = polis.numberOfAgents;
    
    figure;
    hold on;
    x = 1:endTime;
    p = plot(x, Wallet(:, 1:endTime),'-x');
    hold off;
    ps = [];
    psnames = {};
    for i = 1:numberOfAgents
        ps = [ps ; p(i)];
        name = sprintf("%d",ids(i));
        psnames = [psnames ; {name}];
    end
    legend(ps, psnames);
    xlabel('Time');
    ylabel('Drachma');
    title('Wallet By Agent Id');
end

function plotWalletByAgentType(Wallet, numBS, numB, numS, numNP, endTime, colors)
    % 
    % Plot Wallet By Agent Type
    %
    
    figure;
    x = 1:endTime;
    p1 = plot(x, Wallet(1:numBS, 1:endTime),'b-diamond');
    %set(p1,'color',blue); %TODO - Matlab bug?
    ps = p1(1);
    psnames = {'Buy-Sell'};
    hold on;
    if numB > 0
        a1 = numBS + 1;
        a2 = numBS + numB;
        p2 = plot(x, Wallet(a1:a2, 1:endTime),'g-+');
        %p2 = plot(x, Wallet(a1:a2, 1:time),'Color',green,'LineStyle','-','Marker','+','LineWidth',0.5);
        ps = [ps ; p2(1)];
        psnames = [psnames , {'Buy'}];
    end
    if numS > 0
        a1 = numBS + numB + 1;
        a2 = numBS + numB + numS;
        p3 = plot(x, Wallet(a1:a2,1:endTime),'Color',colors.violet,'LineStyle','-','Marker','*','LineWidth',0.5); 
        ps = [ps ; p3(1)];
        psnames = [psnames , {'Sell'}];
    end
    if numNP > 0
        a1 = numBS + numB + numS + 1;
        a2 = numBS + numB + numS + numNP;
        p4 = plot(x, Wallet(a1:a2, 1:endTime),'Color',colors.red,'LineStyle','-','Marker','x','LineWidth',0.5);
        ps = [ps ; p4(1)];
        psnames = [psnames , {'NP'}];
    end
    %
    % Add the average wallet size
    %
    %plot(x,(sum(Wallet(:,1:endTime)) ./ N),'k--+');
    hold off;
    legend(ps,psnames);
    xlabel('Time');
    ylabel('Drachma');
    title('Wallet by Agent Type');
end

function plotCumulativeMoneySupplyUBIDemurrageAllAgents(Wallet, UBI, Demurrage, endTime, colors)
    % 
    % Plot Cumulative Money Supply, Demurrage & UBI
    %
    
    % Calculate the cumulative Demurrage & UBI as a function of time 
    % (we have incremental values)
    cumDemurrage = cumsum(-Demurrage,2);
    cumUBI = cumsum(UBI,2);

    figure;
    hold on;
    x = 1:endTime;
    p1 = plot(x, sum(Wallet(:,1:endTime)),'k-diamond');
    p2 = plot(x, sum(cumDemurrage(:,1:endTime)),'b-o');
    p3 = plot(x, sum(cumUBI(:,1:endTime)),'c-x');
    set(p3,'color',colors.gold);
    hold off;
    legend([p3, p2, p1],{'UBI','Demurrage','Money Supply'});
    xlabel('Time');
    ylabel('Drachma');
    title('Cumulative UBI, Demurrage & Money Supply');
end

function plotUBIDemurrageByAgentType(UBI, Demurrage, numBS, numB, numS, numNP, endTime, colors)
    % 
    % Plot incremental UBI & Demurrage
    %
    figure;
    x = 1:endTime;
    hold on;
    p1 = plot(x, -Demurrage(1:numBS,1:endTime),'b-diamond');
    %set(p1,'color',blue); %TODO - Matlab bug?
    ps = p1(1);
    psnames = {'Dem. Buy-Sell'};
    if numB > 0
        a1 = numBS + 1;
        a2 = numBS + numB;
        p2 = plot(x, -Demurrage(a1:a2, 1:endTime),'g-+');
        %p2 = plot(x, Demurrage(a1:a2, 1:endTime),'Color',colors.green,'LineStyle','-','Marker','+','LineWidth',0.5);
        ps = [ps ; p2(1)];
        psnames = [psnames , {'Dem. Buy'}];
    end
    if numS > 0
        a1 = numBS + numB + 1;
        a2 = numBS + numB + numS;
        p3 = plot(x, -Demurrage(a1:a2,1:endTime),'Color',colors.violet,'LineStyle','-','Marker','*','LineWidth',0.5); 
        ps = [ps ; p3(1)];
        psnames = [psnames , {'Dem. Sell'}];
    end
    if numNP > 0
        a1 = numBS + numB + numS + 1;
        a2 = numBS + numB + numS + numNP;
        p4 = plot(x, -Demurrage(a1:a2, 1:endTime),'Color',colors.red,'LineStyle','-','Marker','x','LineWidth',0.5);
        ps = [ps ; p4(1)];
        psnames = [psnames , {'Dem. NP'}];
    end
    p5 = plot(x, UBI(:,1:endTime),'color',colors.gold,'linestyle','-','marker','o','linewidth',0.5);
    ps = [ps ; p5(1)];
    psnames = [psnames , {'UBI'}];
    hold off;
    legend(ps,psnames);
    xlabel('Time');
    ylabel('Drachma');
    title('Cumulative Demurrage By Agent Type + UBI');
end

function plotPuchsasedItemsByAgent(polis, Purchased, ids, endTime)
    %
    % Plot Buying and Selling over time
    %
    numberOfAgents = polis.numberOfAgents;
    
    cumPurchased = cumsum(Purchased,2);

    figure;
    hold on;
    x = 1:endTime;
    p = plot(x, cumPurchased(:,1:endTime),'-x');
    hold off;
    ps = [];
    psnames = {};
    for i = 1:numberOfAgents
        ps = [ps ; p(i)];
        name = sprintf("%d",ids(i));
        psnames = [psnames ; {name}];
    end
    legend(ps, psnames);
    xlabel('Time');
    ylabel('Number of Items');
    title('Cumulative Purchased Items By Agent');
end

function plotSoldItemsByAgent(polis, Sold, ids, endTime)
    %
    % Plot Buying and Selling over time
    %
    numberOfAgents = polis.numberOfAgents;
    
    cumSold = cumsum(Sold,2);

    figure;
    hold on;
    x = 1:endTime;
    p = plot(x, cumSold(:,1:endTime),'-+');
    hold off;
    ps = [];
    psnames = {};
    for i = 1:numberOfAgents
        ps = [ps ; p(i)];
        name = sprintf("%d",ids(i));
        psnames = [psnames ; {name}];
    end
    legend(ps, psnames);
    xlabel('Time');
    ylabel('Number of Items');
    title('Cumulative Sold Items By Agent');
end

function plotLedgerRecordTotals(totalLedgerRecordsByAgent)
    figure;
    [N, ~] = size(totalLedgerRecordsByAgent);
    x = 1:N;
    plot(x, totalLedgerRecordsByAgent, '--x');
    xlabel('Agent Id');
    ylabel('Total Records');
    title('Total Number Of Ledger Records By Agent');
end

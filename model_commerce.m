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
fprintf("===========================================================\n\n");
addpath lib

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
    fprintf("\nUsing a connected network\n");
    AM = connectedGraph(N);                                                
else
    fprintf("\nNetwork Filename = %s\n", networkFilename);
    AM = importNetworkModelFromCSV(N, networkFilename);
end

% Create the polis
maxSearchLevels = 6;
polis = Polis(AM, maxSearchLevels); 
polis.createAgents(1, numSteps);

fprintf("\nThis simulation has %d agents and a duration of %d time steps\n\n", N, numSteps);

% Unit of currency
drachma = 1;

% Wallet
seedWalletSize = parseInputString(fgetl(fileId), inputTypeDouble); % Wallet Size (Input 4)
Wallet = newATMatrix(N,numSteps,seedWalletSize);

fprintf("Starting wallet size per agent = %.2f drachma\n", seedWalletSize);

% Rate of UBI
amountUBI = parseInputString(fgetl(fileId), inputTypeDouble); % UBI amount (Input 5)
assert(amountUBI > 0,'Assert: UBI must be > 0!');
b = 1.0;
amountUBI = amountUBI*drachma / b*dt; 
UBI = newATMatrix(N,numSteps,0.0);

% Percentage of Demurrage
percentDemurrage = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Demurrage (Input 6)
assert(percentDemurrage >= 0 && percentDemurrage <= 1.0,'Assert: Percentage Demurrage Out Of Range!');
d = 1;
percentDemurrage = percentDemurrage*drachma / d*dt;
Demurrage = newATMatrix(N,numSteps,0.0);

fprintf("UBI = %.2f drachmas / agent / dt, Demurrage = %.2f percent / agent / dt\n", amountUBI, percentDemurrage*100);

% Buyers 1 = Buyer, 0 = No Buyer
Buyers = zeros(N,1);
unitsBought = newATMatrix(N,numSteps,0.0);
percentBuyers = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Buyers (Input 7)
assert(percentBuyers > 0 && percentBuyers <= 1.0,'Assert: Percentage Buyers Out Of Range!')
numberOfBuyers = round(percentBuyers*N);

fprintf("Num buyers   = %d <= %d agents\n", numberOfBuyers, N);

% Sellers 1 = Seller, 0 = No Seller
Sellers = zeros(N,1);
unitsSold = newATMatrix(N,numSteps,0.0);
percentSellers = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Sellers (Input 8)
assert(percentSellers > 0 && percentSellers <= 1.0,'Assert: Percentage Sellers Out Of Range!')
numberOfSellers = round(percentSellers*N);

fprintf("Num sellers  = %d <= %d agents\n", numberOfSellers, N);

% Cost of goods
price = parseInputString(fgetl(fileId), inputTypeDouble); % Price Goods (Input 9);
price = price*drachma;

fprintf("Price of goods = %.2f drachmas\n", price);

% Seller Inventory
inventoryInitialUnits = parseInputString(fgetl(fileId), inputTypeDouble); % Inital Inventory (Input 10)
inventoryInitialValue = inventoryInitialUnits*price;
sellerInventoryUnits = newATMatrix(N,numSteps,0.0);

fprintf("Initial inventory = %.2f units / selling agent and value = %.2f\n", inventoryInitialUnits, inventoryInitialValue);

fclose(fileId);

% Randomely select sellers
polis.setupSellers(numberOfSellers, inventoryInitialUnits);

% Randomely select buyers
polis.setupBuyers(numberOfBuyers);

% Report roles
[numBuySellAgents, numBuyAgents, numSellAgents, numNonparticipatingAgents] = polis.parseAgentCommerceRoleTypes();
fprintf("\nNum Buyers+Sellers = %d\n",numBuySellAgents);
fprintf("Num Buyers Only    = %d\n",numBuyAgents);
fprintf("Num Sellers Only   = %d\n",numSellAgents);
fprintf("Non-Participants   = %d\n",numNonparticipatingAgents);

% Report Initial Statistics
sumWallets = polis.totalMoneySupplyAtTimestep(1);
sumSellerInventoryUnits = polis.totalInventoryAtTimestep(1);
sumSellerInventoryValue = sumSellerInventoryUnits*price;
fprintf("\nInitial Money Supply = %.2f drachma, Inventory Supply = %.2f, Inventory Value = $%.2f\n\n", sumWallets, sumSellerInventoryUnits, sumSellerInventoryValue);

%--------------------------------------------------------------------------
% Simulation finish states
OutOfTime = 0;
OutOfInventory = 1;
OutOfMoney = 2;
SuspendCode = OutOfTime;

% Start simulation
for time = 1:numSteps
   
   fprintf("\n----- Start of time step = %d, money supply = %.2f -----\n\n", time, polis.totalMoneySupplyAtTimestep(time));

   if time > 1
       % Apply demurrage
       polis.applyDemurrageWithPercentage(percentDemurrage, time);
   end
   
   % Deposit UBI
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
           
           fprintf("\nProposed purchase of agent %d from agent %d\n", agentBuying.id, agentSelling.id);
           % Submit the purchase
           numUnits = 1;           
           result = agentBuying.submitPurchase(polis.AM, numUnits*price, agentSelling, time);
           
           if result == TransactionType.TRANSACTION_SUCCEEDED
               fprintf("\nSale Successful!\n");
               agentSelling.recordSale(numUnits, time);
               agentBuying.recordPurchase(numUnits, time);
           else
               if result == TransactionType.FAILED_NO_LIQUIDITY
                   fprintf("\nSale Failed, no liquidity\n");
               elseif result == TransactionType.FAILED_NO_PATH_FOUND
                   fprintf("\nSale Failed, no path found\n");
               else
                   fprintf("\nUnrecognized result. Check it out!\n");
               end
           end
                      
       else
           % No sale :-(
           fprintf("\nNo sellers available\n");
       end
   end
   
   % Report Incremental Statistics
   
   sumWallets = polis.totalMoneySupplyAtTimestep(time);
   cumDemurrage = polis.totalDemurrageAtTimestep(time);
   cumUBI = polis.totalUBIAtTimestep(time);
   
   sumSellerInventoryUnits = polis.totalInventoryAtTimestep(time);
   sumSellerInventoryValue = sumSellerInventoryUnits*price;
   sumBought = polis.totalPurchasesAtTimestep(time);
   sumSold = polis.totalSalesAtTimestep(time);
   
   fprintf("\n----- End of time step   = %d -----\n\n",time);
   fprintf("* Total Money Supply = %.2f drachma, Total Demurrage = %.2f drachma, Total UBI = %.2f drachma (check: Tot. TMS - (UBI + Demurrage) = %.2f)\n", sumWallets, cumDemurrage, cumUBI, (sumWallets - (cumUBI + cumDemurrage)));
   fprintf("* Remaining Inventory Supply = %.2f, Remaining Inventory Value = $%.2f, Total Inventory Exchanged = %2.f (check: Purchased - Sold = %.2f)\n\n",sumSellerInventoryUnits, sumSellerInventoryValue, sumBought, (sumBought - sumSold));

   if sumSellerInventoryUnits <= 0
       SuspendCode = OutOfInventory;
       break;
   end
   
   % Break if out of money any time other than time = 1
   if sumWallets <= 0 && time ~= 1
       SuspendCode = OutOfMoney;
       break;
   end   
   
end

% Completion status
if SuspendCode == OutOfTime
    fprintf("\nSimulation ended normally at time = %d\n",time);
elseif SuspendCode == OutOfInventory
    fprintf("\nSimulation Halted: Out of inventory at time = %d\n",time);
elseif SuspendCode == OutOfMoney
    fprintf("\nSimulation Halted: Out of money at time = %d\n",time);
end
        
% Plot some results
close all
yScale = 1.5;

% 1. Final Wallet Size
maxYHeight = max(Wallet(:,time))*yScale;
if (maxYHeight <= 0) 
    maxYHeight = 1; 
end

ax1 = subplot(4,1,1);
x = 1:N;
plot(ax1, x, Wallet(:,time),'-o');
xlim([1 N]);
ylim([0 maxYHeight]);
xlabel('Agent');
ylabel('Drachmas');
title('Remaining Money');
legend('Wallet Size');

stop;

% 2. Bought / Sold Distribution
yHeights = sort([max(sum(unitsBought,2)) max(sum(unitsSold,2)) max(sellerInventoryUnits(:,time))],'descend');
maxYHeight = yHeights(1)*yScale;
if (maxYHeight <= 0) 
    maxYHeight = 1; 
end

ax2 = subplot(4,1,2);
x = 1:N;
plot(ax2, x, sum(unitsBought,2), '--o', x, sum(unitsSold,2), '-o', x, sellerInventoryUnits(:,time), 'c--*');
xlim([1 N]);
ylim([0 maxYHeight]);
xlabel('Agent');
ylabel('Units');
title('Units Bought & Sold');
legend('Bought','Sold','Ending Inventory');

% 3. Buyers & Sellers Plot
ax3 = subplot(4,1,3);
x = 1:N;
plot(ax3, x, Buyers, 'x', x, Sellers, 'o');
xlim([1 N]);
ylim([0.9 1.1]);
xlabel('Agent');
ylabel('Type');
title('Buyers & Sellers');
legend('Buyers','Sellers');

% 4. Money Supply
totalUBI = UBI(:,time);
totalDemurrage = Demurrage(:,time);
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
x = 1:N;
plot(ax4, x, net, 'c-*', x, initialWallet, '--o', x, totalUBI, 'g-x', x, totalDemurrage, '-ro');
xlim([1 N]);
ylim([minyLim maxYHeight]);
xlabel('Agent');
ylabel('Drachma');
title('Money Supply');
legend('Net', 'Seed','UBI', 'Dumurrage');

% Split data by B+S, B, S and NP

buysellW = [];
buyW = [];
sellW = [];
npW = [];

buysellD = [];
buyD = [];
sellD = [];
npD = [];

for agentId = 1:N
    if Buyers(agentId) == 1 && Sellers(agentId) == 1
        buysellW = [buysellW; Wallet(agentId,1:time)];
        buysellD = [buysellD; Demurrage(agentId,1:time)];
    elseif Buyers(agentId) == 1 && Sellers(agentId) == 0
        buyW = [buyW; Wallet(agentId,1:time)];
        buyD = [buyD; Demurrage(agentId,1:time)];
    elseif Sellers(agentId) == 1 && Buyers(agentId) == 0
        sellW = [sellW; Wallet(agentId,1:time)];
        sellD = [sellD; Demurrage(agentId,1:time)];
    else
        npW = [npW; Wallet(agentId,1:time)];
        npD = [npD; Demurrage(agentId,1:time)];
    end
end

% Custom colors
gold   = [255.0/255.0, 171.0/255.0,  23.0/255.0];
orange = [232.0/255.0,  85.0/255.0,  12.0/255.0];
red    = [255.0/255.0,   0.0/255.0,   0.0/255.0];
violet = [215.0/255.0,  12.0/255.0, 232.0/255.0];
blue   = [ 86.0/255.0,  13.0/255.0, 255.0/255,0];
green  = [  4.0/255.0, 255.0/255.0,   0.0/255,0];

% Plot Wallet
figure;
x = 1:time;
p1 = plot(x, buysellW(:,1:time),'b-diamond');
%set(p1,'color',blue); %TODO - Matlab bug?
ps = p1(1);
psnames = {'Buy-Sell'};
hold on;
if ~isempty(sellW)
    p2 = plot(x, sellW(:,1:time),'Color',violet,'LineStyle','-','Marker','*','LineWidth',0.5); 
    ps = [ps ; p2(1)];
    psnames = [psnames , {'Sell'}];
end
if ~isempty(buyW)
    p3 = plot(x, buyW(:,1:time),'Color',green,'LineStyle','--','Marker','+','LineWidth',0.5);
    ps = [ps ; p3(1)];
    psnames = [psnames , {'Buy'}];
end
if ~isempty(npW)
    p4 = plot(x, npW(:,1:time),'Color',red,'LineStyle','-','Marker','x','LineWidth',0.5);
    ps = [ps ; p4(1)];
    psnames = [psnames , {'NP'}];
end
%plot(x,(sum(Wallet(:,1:time)) ./ N),'k--+');
hold off;
legend(ps,psnames);
xlabel('Time');
ylabel('Drachma');
title('Agent Wallets');

% Plot incremental UBI & Demurrage
figure;
x = 1:time;
hold on;
p1 = plot(x, buysellD(:,1:time),'b-diamond');
%set(p1,'color',blue); %TODO - Matlab bug?
ps = p1(1);
psnames = {'D Buy-Sell'};
if ~isempty(sellD)
    p2 = plot(x, sellD(:,1:time),'color',violet,'linestyle','-','marker','*','linewidth',0.5);
    ps = [ps ; p2(1)];
    psnames = [psnames , {'D Sell'}];
end
if ~isempty(buyD)
    p3 = plot(x, buyD(:,1:time),'color',green,'linestyle','-','marker','+','linewidth',0.5);
    ps = [ps ; p3(1)];
    psnames = [psnames , {'D Buy'}];
end
if ~isempty(npD)
    p4 = plot(x, npD(:,1:time),'color',red,'linestyle','-','marker','x','linewidth',0.5);
    ps = [ps ; p4(1)];
    psnames = [psnames , {'D NP'}];
end
p5 = plot(x, UBI(:,1:time),'color',gold,'linestyle','-','marker','o','linewidth',0.5);
ps = [ps ; p5(1)];
psnames = [psnames , {'UBI'}];
hold off;
legend(ps,psnames);
xlabel('Time');
ylabel('Drachma');
title('Incremental Demurrage By Agent & Type + UBI');

% Cumulative Money Suppy, Demurrage & UBI

% Calculate the cumulative Demurrage & UBI as a function of time (we have been
% storing incremental values)
cumDemurrage = cumsum(Demurrage,2);
cumUBI = cumsum(UBI,2);

figure;
hold on;
x = 1:time;
p1 = plot(x, sum(Wallet(:,1:time)),'k-diamond');
p2 = plot(x, sum(cumDemurrage(:,1:time)),'b-o');
p3 = plot(x, sum(cumUBI(:,1:time)),'c-x');
set(p3,'color',gold);
hold off;
legend([p1, p2, p3],{'Money Supply','Demurrage','UBI'});
xlabel('Time');
ylabel('Drachma');
title('Cumulative Money Supply, Demurrage & UBI');

% Plot Inventory, Buying and Selling over time
cumBought = cumsum(unitsBought,2);
cumSold = cumsum(unitsSold,2);

figure;
hold on;
x = 1:time;
p1 = plot(x, sellerInventoryUnits(:,1:time),'b-o');
p2 = plot(x, cumSold(:,1:time),'r-+');
p3 = plot(x, cumBought(:,1:time),'g-x');
hold off;
legend([p1(1), p2(1), p3(1)],{'Inventory','Cum. Sold','Cum. Bought'});
xlabel('Time');
ylabel('Inventory');
title('Inventory by Agent');



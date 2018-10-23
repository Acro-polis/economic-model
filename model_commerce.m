%===================================================
%
% Commerce model on a network
%
% Author: Jess
% Created: 2018.08.30
%===================================================

version_number = "1.0.2"; % Tracking state in time
	
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
T =  parseInputString(fgetl(fileId));   % Max Time (Input 1)
dt = 1;                                 % Time Step 
numSteps = round(T / dt);               % Number of time steps (integer)
assert(numSteps >= 1,'Assert: Number of time steps must be >= 1!');

N =  round(parseInputString(fgetl(fileId)));    % Number of Agents (nodes) (Input 2)
AM = connectedGraph(N);                         % The WOT network

fprintf("Simulation has %d agents and will run for %d time steps\n\n", N, numSteps);

% Unit of currency
drachma = 1;

% Wallet
seedWalletSize = parseInputString(fgetl(fileId)); % Wallet Size (Input 3)
Wallet = newATMatrix(N,T,seedWalletSize);
initialWallet = Wallet(:,1); % time = 0

fprintf("Starting wallet size per agent = %.2f drachma\n", seedWalletSize);

% Rate of UBI
a = parseInputString(fgetl(fileId)); % UBI Rate (Input 4)
b = 1.0;
incrementalUBI = a*drachma / b*dt; 
UBI = newATMatrix(N,T,0.0);

% Percentage of Demurrage
percentDemurrage = parseInputString(fgetl(fileId)); % Percentage Demurrage (Input 5)
assert(percentDemurrage >= 0 && percentDemurrage <= 1.0,'Assert: Percentage Demurrage Out Of Range!');
d = 1;
percentDemurrage = percentDemurrage*drachma / d*dt;
Demurrage = newATMatrix(N,T,0.0);

fprintf("UBI = %.2f drachmas / agent / dt, Demurrage = %.2f percent / agent / dt\n", incrementalUBI, percentDemurrage*100);

% Buyers 1 = Buyer, 0 = No Buyer
B = zeros(N,1);
unitsBought = zeros(N,1);
percentBuyers = parseInputString(fgetl(fileId)); % Percentage Buyers (Input 6)
assert(percentBuyers > 0 && percentBuyers <= 1.0,'Assert: Percentage Buyers Out Of Range!')
numberOfBuyers = round(percentBuyers*N);

fprintf("Num buyers   = %d <= %d agents\n", numberOfBuyers, N);

% Sellers 1 = Seller, 0 = No Seller
S = zeros(N,1);
unitsSold = zeros(N,1);
percentSellers = parseInputString(fgetl(fileId)); % Percentage Sellers (Input 7)
assert(percentSellers > 0 && percentSellers <= 1.0,'Assert: Percentage Sellers Out Of Range!')
numberOfSellers = round(percentSellers*N);

fprintf("Num sellers  = %d <= %d agents\n", numberOfSellers, N);

% Cost of goods
p = parseInputString(fgetl(fileId)); % Price Goods (Input 8);
price = p*drachma;

fprintf("Price of goods = %.2f drachmas\n", price);

% Seller Inventory
inventoryInitialUnits = parseInputString(fgetl(fileId)); % Inital Inventory (Input 9)
inventoryInitialValue = inventoryInitialUnits*price;
sellerInventoryUnits = zeros(N,1);

fprintf("Inital inventory = %.2f units / selling agent\n", inventoryInitialUnits);

fclose(fileId);

% Randomely select sellers
% TODO - Make preferrential selection?
selectedNodes = randsample(N,numberOfSellers);
if (numberOfSellers == N) 
    S = ones(N,1);
    sellerInventoryUnits(:,1) = inventoryInitialUnits;
else   
    for i = 1:numberOfSellers
        sellerInventoryUnits(selectedNodes(i,1)) = inventoryInitialUnits;
        S(selectedNodes(i,1)) = 1;
    end
end

% Randomely select buyers
% TODO - Make preferrential selection?
if (numberOfBuyers == N) 
    B = ones(N,1);
else
    selectedNodes = randsample(N,numberOfBuyers);
    for i = 1:numberOfBuyers
        B(selectedNodes(i,1)) = 1;
    end
end

% Report Initial Statistics
sumWallets = sum(Wallet(:,1));
sumSellerInventoryUnits = sum(sellerInventoryUnits(:,1));
sumSellerInventoryValue = sum(sellerInventoryUnits(:,1))*price;
fprintf("\nInitial Money Supply = %.2f drachma, Inventory Supply = %.2f, Inventory Value = %.2f\n\n", sumWallets, sumSellerInventoryUnits, sumSellerInventoryValue);

%--------------------------------------------------------------------------
% Simulation finish states
OutOfTime = 0;
OutOfInventory = 1;
OutOfMoney = 2;
SuspendCode = OutOfTime;

% Start simulation
for time = 1:numSteps
   
   if time == 1
       fprintf("----- Start of time step = %d, money supply = %.2f -----\n\n", time, sum(Wallet(:,time)));
   elseif time > 1 
       
       fprintf("----- Start of time step = %d, money supply = %.2f -----\n\n", time, sum(Wallet(:,time - 1)));
       
       % Prepare For Next Step
       Wallet(:,time) = Wallet(:,time - 1);
       
       % Subtract the demurrage from each wallet and accumulate total demurrange 
       incrementalDemurrage = Wallet(:,time) * percentDemurrage;
       Wallet(:,time) = Wallet(:,time) - incrementalDemurrage;
       Demurrage(:,time) = Demurrage(:,time) + incrementalDemurrage;

       % Wallet cannot be reduced below zero due to demurrage
       Wallet(Wallet < 0) = 0;
       
       % Add UBI to each wallet and accumulate total UBI
       Wallet(:,time) = Wallet(:,time) + incrementalUBI;
       UBI(:,time) = UBI(:,time) + incrementalUBI;
       
   end
   
   % Randomly order buyers before each time step
   numBuyerIndex = 1:N;
   randBuyerIndex = numBuyerIndex(randperm(length(numBuyerIndex)));
   
   for buyer = 1:numel(randBuyerIndex)
       
       % Skip non-buying agents
       if B(buyer,1) ~= 1
           fprintf("+ B(%d) is not a buyer\n",buyer);
           continue;
       end
       
       % Skip agents out of money
       if Wallet(buyer,time) < price
           fprintf("- B(%d) is a buyer out of money\n",buyer);
           continue;
       end
       
       % Find connections
       connections = find(AM(buyer,:) ~= 0);
       
       % Find connections that are sellers (prohibits buying from yourself)
       availableSellers = [];
       for connection = 1:size(connections,2)
           i = connections(1,connection);
           if S(i) == 1
               % Collect the sellers that have inventory
               if sellerInventoryUnits(i) > 0
                   availableSellers = [availableSellers ; i];
               end
           end
       end
       
       % If sellers available, pick one randomly
       numberOfAvailableSellers = size(availableSellers,1);
       
       %fprintf("For Buyer %d, # Sellers = %d\n", buyer, numberOfAvailableSellers);
       
       if  numberOfAvailableSellers > 0
           
           % Sale!
           j = randsample(numberOfAvailableSellers,1);
           sellerIndex = availableSellers(j);
           numUnits = 1;
           
           %fprintf("Buyer %d exchanging with Seller %d\n", buyer, sellerIndex);
           
           % Seller
           
           % Decrement Inventory
           sellerInventoryUnits(sellerIndex) = sellerInventoryUnits(sellerIndex) - numUnits;
           unitsSold(sellerIndex) = unitsSold(sellerIndex) + numUnits;
           
           % Increment Wallet
           Wallet(sellerIndex,time) = Wallet(sellerIndex,time) + numUnits*price;
           
           % Buyer
           
           % Increment Amount Bought
           unitsBought(buyer,1) = unitsBought(buyer,1) + numUnits;
           
           % Decrement Wallet
           Wallet(buyer,time) = Wallet(buyer,time) - numUnits*price;
           
       else
           % No sale :-(
           fprintf("No sellers available\n");
       end
   end
   
   % Report Incremental Statistics
   
   sumWallets = sum(Wallet(:,time));
   sumDemurrage = sum(sum(Demurrage(:,1:time)));
   cumUBI = sum(sum(UBI(:,1:time)));
   sumSellerInventoryUnits = sum(sellerInventoryUnits(:,1));
   sumSellerInventoryValue = sumSellerInventoryUnits*price;
   sumBought = sum(unitsBought(:,1));
   sumSold = sum(unitsSold(:,1));
   fprintf("\n----- End of time step   = %d -----\n\n",time);
   fprintf("* Total Money Supply = %.2f drachma, Total Demurrage = %.2f drachma, Total UBI = %.2f drachma (check: Tot. UBI-Demurrage = TMS = %.2f)\n", sumWallets, sumDemurrage, cumUBI, (cumUBI - sumDemurrage));
   fprintf("* Remaining Inventory Supply = %.2f, Remaining Inventory Value = %.2f, Total Inventory Exchanged %2.f (check: Purchased - Sold = %.2f)\n\n",sumSellerInventoryUnits, sumSellerInventoryValue, sumBought, (sumBought - sumSold));

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
    fprintf("Simulation ended normally at time = %d\n",time);
elseif SuspendCode == OutOfInventory
    fprintf("Simulation Halted: Out of inventory at time = %d\n",time);
elseif SuspendCode == OutOfMoney
    fprintf("Simulation Halted: Out of money at time = %d\n",time);
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

% 2. Bought / Sold Distribution
yHeights = sort([max(unitsBought(1:end,1)) max(unitsSold(1:end,1)) max(sellerInventoryUnits)],'descend');
maxYHeight = yHeights(1)*yScale;
if (maxYHeight <= 0) 
    maxYHeight = 1; 
end

ax2 = subplot(4,1,2);
x = 1:N;
plot(ax2, x, unitsBought, '--o', x, unitsSold, '-o', x, sellerInventoryUnits, 'c--*');
xlim([1 N]);
ylim([0 maxYHeight]);
xlabel('Agent');
ylabel('Units');
title('Units Bought & Sold');
legend('Bought','Sold','Ending Inventory');

% 3. Buyers & Sellers Plot
ax3 = subplot(4,1,3);
x = 1:N;
plot(ax3, x, B, 'x', x, S, 'o');
xlim([1 N]);
ylim([0.9 1.1]);
xlabel('Agent');
ylabel('Type');
title('Buyers & Sellers');
legend('Buyers','Sellers');

% 4. Money Supply
totalUBI = UBI(:,time);
totalDemurrage = Demurrage(:,time);
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

for a = 1:N
    if B(a) == 1 && S(a) == 1
        buysellW = [buysellW; Wallet(a,1:time)];
        buysellD = [buysellD; Demurrage(a,1:time)];
    elseif B(a) == 1 && S(a) == 0
        buyW = [buyW; Wallet(a,1:time)];
        buyD = [buyD; Demurrage(a,1:time)];
    elseif S(a) == 1 && B(a) == 0
        sellW = [sellW; Wallet(a,1:time)];
        sellD = [sellD; Demurrage(a,1:time)];
    else
        npW = [npW; Wallet(a,1:time)];
        npD = [npD; Demurrage(a,1:time)];
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

% 

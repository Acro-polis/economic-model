%===================================================
%
% Commerce model on a network
%
% Author: Jess
% Created: 2018.08.30
%===================================================

version_number = 1.1; % Tracking state in time
	
% Setup
fprintf("\n===========================================================\n");
fprintf("Modeling Start\n")
fprintf("===========================================================\n\n");
addpath lib

% Initializations
T =  150;                   % Max Time 
dt = 1;                     % Time Step 
numSteps = round(T / dt);   % Number of time steps (integer)

N =  20;                    % Number of Agents (nodes)
AM = connectedGraph(N);     % The WOT network

fprintf("Network consists of %d agents.\n", N);

% Unit of currency
drachma = 1;

% Wallet
seedWalletSize = 100;
Wallet = newATMatrix(N,T,seedWalletSize);
initialWallet = Wallet(:,1); % time = 0

% Rate of UBI
a = 1.0;
b = 1.0;
incrementalUBI = a*drachma / b*dt; 
UBI = newATMatrix(N,T,0.0);

% Percentage of Demurrage
percentDemurrage = 0.05;
assert(percentDemurrage >= 0 && percentDemurrage <= 1.0,'Assert: Percentage Demurrage Out Of Range!');
d = 1;
percentDemurrage = percentDemurrage*drachma / d*dt;
Demurrage = newATMatrix(N,T,0.0);

fprintf("UBI = %.2f drachmas / dt, Demurrage = %.2f percent / dt\n", incrementalUBI, percentDemurrage*100);

% Cost of goods
p = 1;
price = p*drachma;

fprintf("Price of goods = %.2f drachmas\n", price);

% Sellers 1 = Seller, 0 = No Seller
S = zeros(N,1);
unitsSold = zeros(N,1);
percentSellers = 0.5;
assert(percentSellers > 0 && percentSellers <= 1.0,'Assert: Percentage Sellers Out Of Range!')
numberOfSellers = round(percentSellers*N);

fprintf("Num Sellers = %d <= %d agents\n", numberOfSellers, N);

% Seller Inventory
inventoryInitialUnits = 200;
inventoryInitialValue = inventoryInitialUnits*price;
sellerInventoryUnits = zeros(N,1);

% Buyers 1 = Buyer, = No Buyer
B = zeros(N,1);
unitsBought = zeros(N,1);
percentBuyers = 0.8;
assert(percentBuyers > 0 && percentBuyers <= 1.0,'Assert: Percentage Buyers Out Of Range!')
numberOfBuyers = round(percentBuyers*N);

fprintf("Num Buyers  = %d <= %d agents\n", numberOfBuyers, N);

% Randomely select sellers
% TODO - Make preferrential selection
selectedNodes = randsample(N,numberOfSellers);
if (numberOfSellers == N) 
    S = ones(N,1);
else   
    for i = 1:numberOfSellers
        sellerInventoryUnits(selectedNodes(i,1)) = inventoryInitialUnits;
        S(selectedNodes(i,1)) = 1;
    end
end

% Select buyers
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
fprintf("Money Supply = %.2f drachma, Inventory Supply = %.2f, Inventory Value = %.2f\n\n", sumWallets, sumSellerInventoryUnits, sumSellerInventoryValue);

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
       
       % Subtract Demurrage
       incrementalDemurrage = percentDemurrage * Wallet(:,time - 1);
       Demurrage(:,time) = Demurrage(:,time - 1) + incrementalDemurrage;
       Wallet(:,time) = Wallet(:,time - 1) - incrementalDemurrage;

       % Wallet cannot be reduced below zero due to demurrage
       Wallet(Wallet < 0) = 0;
       
       % Add UBI
       Wallet(:,time) = Wallet(:,time) + incrementalUBI;
       UBI(:,time) = UBI(:,time - 1) + incrementalUBI;
       
   end
   
   % Randomly order buyers before each time step
   numBuyerIndex = 1:numberOfBuyers;
   randBuyerIndex = numBuyerIndex(randperm(length(numBuyerIndex)));
   
   for buyer = 1:numel(randBuyerIndex)
       
       % Skip non-buying agents
       if B(buyer,1) ~= 1
           continue;
       end
       
       % Skip agents out of money
       if Wallet(buyer,time) <= price
           fprintf("- B(%d) is out of money\n",buyer);
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
       end
   end
   
   % Report Incremental Statistics
   
   sumWallets = sum(Wallet(:,time));
   sumSellerInventoryUnits = sum(sellerInventoryUnits(:,1));
   sumSellerInventoryValue = sumSellerInventoryUnits*price;
   sumBought = sum(unitsBought(:,1));
   sumSold = sum(unitsSold(:,1));
   fprintf("\n----- End of time step   = %d -----\n\n",time);
   fprintf("* Money Supply = %.2f drachma, Inventory Supply = %.2f, Inventory Value = %.2f\n", sumWallets, sumSellerInventoryUnits, sumSellerInventoryValue);
   fprintf("* Total units purchased = %.2f, total units sold = %.2f\n\n", sumBought, sumSold);

   if sumSellerInventoryUnits <= 0
       SuspendCode = OutOfInventory;
       break;
   end
   
   if sumWallets <= 0
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
    maxmaxYHeight = 1; 
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

figure;
x = 1:time;
plot(x, Wallet(:,1:time),'-o');
xlabel('Time');
ylabel('Drachma');
title('Wallet');

figure;
x = 1:time;
plot(x, UBI(:,1:time),'-o', x, Demurrage(:,1:time),'-x');
xlabel('Time');
ylabel('Drachma');
title('UBI & Demurrage');
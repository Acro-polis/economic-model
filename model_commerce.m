%===================================================
%
% Commerce model on a network
%
% Author: Jess
% Created: 2018.08.30
%===================================================
version_number = 1.0;
	
% Setup
fprintf("Start Modeling\n\n")
addpath lib

% Initializations
T =  100;                   % Max Time 
dt = 1;                     % Time Step 
numSteps = round(T / dt);   % Number of time steps (integer)

N =  20;                    % Number of Agents (nodes)
AM = connectedGraph(N);     % The WOT network

fprintf("Network consists of %d agents.\n", N);

% Unit of currency
drachma = 1;

% Wallet
initialWallet = 100;
Wallet = ones(N,1).*initialWallet;
initialWallet = ones(N,1).*initialWallet;

% Rate of UBI
a = 1;
b = 1;
UBI = a*drachma / b*dt; 
totalUBI = zeros(N,1);

% Rate of Demurrage
c = 1;
d = 1;
Demurrage = c*drachma / d*dt;
totalDemurrage = zeros(N,1);

fprintf("UBI = %.2f drachmas/dt, Demurrage = %.2f drachmas/dt\n", UBI, Demurrage);

% Cost of goods
p = 1;
price = p*drachma;

fprintf("Price of goods = %.2f drachmas\n", price);

% Sellers 1 = Seller, 0 = No Seller
S = zeros(N,1);
unitsSold = zeros(N,1);
percentSellers = 0.5;
numberOfSellers = round(percentSellers*N);

fprintf("Num Sellers = %d <= %d agents\n", numberOfSellers, N);

% Seller Inventory
inventoryInitialUnits = 100;
inventoryInitialValue = inventoryInitialUnits*price;
sellerInventoryUnits = zeros(N,1);

% Buyers 1 = Buyer, = No Buyer
B = zeros(N,1);
unitsBought = zeros(N,1);
percentBuyers = 1.0;
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

% Simulation finish states
OutOfTime = 0;
OutOfInventory = 1;
OutOfMoney = 2;

% Report Initial Statistics
sumWallets = sum(Wallet(:,1));
sumSellerInventoryUnits = sum(sellerInventoryUnits(:,1));
sumSellerInventoryValue = sum(sellerInventoryUnits(:,1))*price;
fprintf("Money Supply = %.2f drachma, Inventory Supply = %.2f, Inventory Value = %.2f\n\n", sumWallets, sumSellerInventoryUnits, sumSellerInventoryValue);

%--------------------------------------------------------------------------
SuspendCode = OutOfTime;

% Start simulation
for time = 1:numSteps
    
   if mod(time,T/10) == 1
       fprintf('Time Step = %u\n',time);
   end
   
   if time > 1 
       
       % Add UBI
       Wallet(1:N,1) = Wallet(1:N,1) + UBI;
       totalUBI(1:N,1) = totalUBI(1:N,1) + UBI;
       
       % Subtract Demurrage; ensure non-negative values
       Wallet(1:N,1) = Wallet(1:N,1) - Demurrage;
       Wallet(Wallet < 0) = 0;
       totalDemurrage(1:N,1) = totalDemurrage(1:N,1) + Demurrage;
       
   end
   
   fprintf("At start of time = %d, money supply = %.2f\n\n",time, sum(Wallet(:,1)));
   
   for buyer = 1:numberOfBuyers
       
       % TODO random order buyers
       
       % Skip non-buying agents
       if B(buyer,1) ~= 1
           continue;
       end
       
       % Skip agents out of money
       if Wallet(buyer,1) <= price
           fprintf("B(%d) is out of money\n",buyer);
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
           Wallet(sellerIndex,1) = Wallet(sellerIndex,1) + numUnits*price;
           
           % Buyer
           
           % Increment Amount Bought
           unitsBought(buyer,1) = unitsBought(buyer,1) + numUnits;
           
           % Decrement Wallet
           Wallet(buyer,1) = Wallet(buyer,1) - numUnits*price;
           
       else
           % No sale :-(
       end
   end
   
   % Report Incremental Statistics
   
   sumWallets = sum(Wallet(:,1));
   sumSellerInventoryUnits = sum(sellerInventoryUnits(:,1));
   sumSellerInventoryValue = sumSellerInventoryUnits*price;
   sumBought = sum(unitsBought(:,1));
   sumSold = sum(unitsSold(:,1));
   fprintf("\nMoney Supply = %.2f drachma, Inventory Supply = %.2f, Inventory Value = %.2f\n", sumWallets, sumSellerInventoryUnits, sumSellerInventoryValue);
   fprintf("Total units purchased = %.2f, total units sold = %.2f\n\n", sumBought, sumSold);

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
yScale = 1.5;

% Final Wallet Size
ax1 = subplot(4,1,1);
plot(ax1, 1:N, Wallet,'-o');
xlim([1 N]);
maxyLim = max(Wallet(1:end,1))*yScale;
if (maxyLim <= 0) 
    maxyLim = 1; 
end
ylim([0 maxyLim]);
xlabel('Agent');
ylabel('Drachmas');
title('Remaining Money');
legend('Wallet Size');

% Bought / Sold Distribution
maxB = max(unitsBought(1:end,1));
maxS = max(unitsSold(1:end,1));
maxyLim = maxS;
if (maxS < maxB) 
    maxyLim = maxB; 
end

ax2 = subplot(4,1,2);
x = 1:N;
plot(ax2, x, unitsBought, '--o', x, unitsSold, '-o');
xlim([1 N]);

maxyLim = maxyLim*yScale;
if (maxyLim <= 0) 
    maxyLim = 1; 
end
ylim([0 maxyLim]);

xlabel('Agent');
ylabel('Units');
title('Units Bought & Sold');
legend('Bought','Sold');

% Buyers & Sellers Plot
ax3 = subplot(4,1,3);
x = 1:N;
plot(ax3, x, B, 'x', x, S, 'o');
xlim([1 N]);
ylim([0.9 1.1]);
xlabel('Agent');
ylabel('Type');
title('Buyers & Sellers');
legend('Buyers','Sellers');

% Money Supply
net = initialWallet + totalUBI - totalDemurrage;
maxW = max(initialWallet(1:end,1));
maxUBI = max(totalUBI(1:end,1));
maxD = max(totalDemurrage(1:end,1));
maxN = max(net(1:end,1));
maxylim = maxW;
if maxyLim < maxUBI
    maxyLim = maxUBI;
end
if maxyLim < maxD
    maxyLim = maxD;
end
if maxyLim < maxN
    maxyLim = maxN;
end

ax4 = subplot(4,1,4);
x = 1:N;
plot(ax4, x, net, 'c-*', x, initialWallet, '--o', x, totalUBI, 'g-x', x, totalDemurrage, '-ro');
xlim([1 N]);
ylim([0 maxyLim*yScale]);
xlabel('Agent');
ylabel('Drachma');
title('Money Supply');
legend('Net', 'Seed','UBI', 'Dumurrage');

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
T =  60;                     % Max Time 
dt = 1;                     % Time Step 
numSteps = round(T / dt);   % Number of time steps (integer)

N =  20;                    % Number of Agents (nodes)
AM = connectedGraph(N);     % The WOT network

fprintf("Network consists of %d agents.\n", N);

% Unit of currency
drachma = 1;

% Rate of UBI
a = 1;
b = 1;
UBI = a*drachma / b*dt; 

% Rate of Demurrage
c = 1;
d = 1;
Demurrage = c*drachma / d*dt;

fprintf("UBI = %.2f drachmas/dt, Demurrage = %.2f drachmas/dt\n", UBI, Demurrage);

% Wallet
initialWallet = UBI*100;
Wallet(1:N) = initialWallet;

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
% TODO - Make preferrential
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

% Start simulation
for time = 1:numSteps
    
   if mod(time,T/10) == 1
       fprintf('Time Step = %u\n',time);
   end
    
   for buyer = 1:numberOfBuyers
       
       % TODO add UBI
       % TODO subtract Demurrage
       % TODO random order buyers
       
       % Agent is buyer & has money?
       if B(buyer,1) ~= 1 || Wallet(buyer,1) <= price
           fprintf("B(%d) is not a buyer or out of money\n",B(buyer,1));
           continue;
       end
       
       % Find connections
       connections = find(AM(buyer,:) ~= 0);
       
       % Find connections that are sellers
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
       fprintf("For Buyer %d, # Sellers = %d\n", buyer, numberOfAvailableSellers);
       
       if  numberOfAvailableSellers > 0
           
           % Sale!
           j = randsample(numberOfAvailableSellers,1);
           sellerIndex = availableSellers(j);
           numUnits = 1;
           fprintf("Buyer %d exchanging with Seller %d\n", buyer, sellerIndex);
           
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
       fprintf("Stopping simulation: Out of inventory at time = %d\n",time);
       break;
   end   
   
end

% Plot some results

% Final Wallet Size
ax1 = subplot(2,1,1);
plot(ax1, 1:N, Wallet(1:end,1),'-o');
xlim([1 N]);
ylim([0 initialWallet*1.75]);
xlabel('Agent');
ylabel('Drachmas');
title('Wallet Size');

% Bought / Sold Distribution
ax2 = subplot(2,1,2);
x = 1:N;
plot(ax2, x, unitsBought(1:end,1), '--o', x, unitsSold(1:end,1), '-o');
xlim([1 N]);
ylim([0 inventoryInitialUnits*1.25]);
xlabel('Agent');
ylabel('Units');
title('Units Bought & Sold');
legend('Bought','Sold');





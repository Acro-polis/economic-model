%=====================================================
%
% Create an input file for the commerce model
%
% Author: Jess
% Created: 2018.10.16
%=====================================================
addpath lib

fn = 'InputCommerce.txt';
fileId = fopen(fn, "w");

fprintf(fileId,'\nCommerce Model Input Parameters\n\n');

fprintf(fileId,'1)  Number of Time Steps (dt): %.0f\n',52.0);
fprintf(fileId,'2)  Number of Agents: %.0f\n',100);
fprintf(fileId,'3)  Network Pathname (blank for connected):%s\n',"");
fprintf(fileId,'4)  Transaction-Distance (max. steps, >= 2): %.0f\n',3.0);
fprintf(fileId,'5)  Initial Wallet Size (drachma / agent): %.2f\n',0.00);
fprintf(fileId,'6)  UBI Amount (drachma / ubi interval): %.2f\n',360.00);
fprintf(fileId,'7)  UBI Interval: %.0f\n',1.0);
fprintf(fileId,'8)  Percent Demurrage: %.2f\n',0.05);
fprintf(fileId,'9)  Demurrage Interval: %.0f\n',4.0);
fprintf(fileId,'10) Percentage of Passive Agents: %.2f\n',0.05);
fprintf(fileId,'11) Percentage of Selling Agents: %.2f\n',0.15);
fprintf(fileId,'12) Price of Goods (drachma / unit): %.2f\n',300.00);
fprintf(fileId,'13) Initial Inventory (# units / agent): %.2f\n',300.00);
fprintf(fileId,'14) Number of Iterations: %.0f\n',1);
fprintf(fileId,'15) Output folder name:%s\n',"Economic_Model");

fprintf(fileId,'\n');
fprintf(fileId,'\nNote for 3): Specify the uniquely named subfolder in the\n');
fprintf(fileId,'economic-model/Network Models folder where the corresponding edges.csv\n');
fprintf(fileId,'file resides\n');
fprintf(fileId,'\n');
fprintf(fileId,'Model 1: %s\n',"Hybrid SN=1 EN=100 T=99 alpha=0.00 ver=H_1.2.0");
fprintf(fileId,'Model 2: %s\n',"Hybrid SN=2 EN=100 T=49 alpha=0.00 ver=H_1.2.0");
fprintf(fileId,'Model 3: %s\n',"Hybrid SN=5 EN=100 T=19 alpha=0.00 ver=H_1.2.0");
fprintf(fileId,'Model 4: %s\n',"Hybrid SN=10 EN=100 T=9 alpha=0.00 ver=H_1.2.0");
fprintf(fileId,'Test Model 1: %s\n',"Wallet Test Plan 10 Agents");

fclose(fileId);

[numSteps,                ...
N,                        ...
networkPathname,          ...
AM,                       ...
maxSearchLevels,          ...
seedWalletSize,           ...
amountUBI,                ...
timeStepUBI,              ...
percentDemurrage,         ...
timeStepDemurrage,        ...
numberOfPassiveAgents,    ...
percentSellers,           ...
price,                    ...
inventoryInitialUnits,    ...
numberIterations,         ...
outputSubFolderName] = readInputCommerceFile(fn);

fprintf("\nInput File Generated Without Errors\n");


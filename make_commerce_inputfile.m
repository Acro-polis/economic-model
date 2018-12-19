%=====================================================
%
% Create an input file for the commerce model
%
% Author: Jess
% Created: 2018.10.16
%=====================================================
addpath lib

fileName = 'InputCommerce.txt';
fileId = fopen(fileName, "w");

fprintf(fileId,'\nCommerce Model Input Parameters\n\n');

fprintf(fileId,'1)  Number of Time Steps (dt): %.0f\n',52.0);
fprintf(fileId,'2)  Number of Agents: %.0f\n',100);
fprintf(fileId,'3)  Network Filename: %s\n',"use blank for connected network");
fprintf(fileId,'4)  Transaction-Distance (max. steps, >= 2): %.0f\n',2.0);
fprintf(fileId,'5)  Initial Wallet Size (drachma / agent): %.2f\n',0.00);
fprintf(fileId,'6)  UBI Amount (drachma / ubi interval): %.2f\n',360.00);
fprintf(fileId,'7)  UBI Interval: %.0f\n',1.0);
fprintf(fileId,'8)  Percent Demurrage: %.2f\n',0.05);
fprintf(fileId,'9)  Demurrage Interval: %.0f\n',4.0);
fprintf(fileId,'10) Percentage of Passive Agents: %.2f\n',0.05);
fprintf(fileId,'11) Percentage of Selling Agents: %.2f\n',0.90);
fprintf(fileId,'12) Price of Goods (drachma / unit): %.2f\n',325.00);
fprintf(fileId,'13) Initial Inventory (# units / agent): %.2f\n',300.00);
fprintf(fileId,'14) Number of Iterations: %.0f\n',1);
fprintf(fileId,'15) Output folder name: %s\n',"Economic_Model");

fprintf(fileId,'\n');
fprintf(fileId,'Model 1: %s\n',"Edges Hybrid SN=1 FN=101 T=50 a=0.00 V1.1.0.csv");
fprintf(fileId,'Model 2: %s\n',"Edges Hybrid SN=2 FN=100 T=49 a=0.00 V1.1.0.csv");
fprintf(fileId,'Model 3: %s\n',"Edges Hybrid SN=5 FN=100 T=19 a=0.00 V1.1.0.csv");

fclose(fileId);

fileId = fopen(fileName, "r");

% Testing

%
% Header
% 
for i = 1:3
    fgetl(fileId);
end

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,1);
fprintf('%s\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,1);
fprintf('%s\n',inputValue);

% -----
fgetl(fileId);

line = fgetl(fileId);
inputValue = parseInputString(line,1);
fprintf('%s\n',inputValue);
line = fgetl(fileId);
inputValue = parseInputString(line,1);
fprintf('%s\n',inputValue);
line = fgetl(fileId);
inputValue = parseInputString(line,1);
fprintf('%s\n',inputValue);

fclose(fileId);
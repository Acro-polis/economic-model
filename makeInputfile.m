%=====================================================
%
%
% Author: Jess
% Created: 2018.10.16
%=====================================================
addpath lib

fileName = 'InputCommerce.txt';
fileId = fopen(fileName, "w");

fprintf(fileId,'Commerce Model Input Parameters\n');

fprintf(fileId,'Number of Time Steps: %.0f\n',150.0);
fprintf(fileId,'Number of Agents: %d\n',20);
fprintf(fileId,'Initial Wallet Size (drachma): %.1f\n',100.0);
fprintf(fileId,'UBI Rate (drachma / dt): %.1f\n',1.0);
fprintf(fileId,'Percent Demurrage: %.2f\n',0.05);
fprintf(fileId,'Price of Goods (drachma): %.1f\n',1.0);
fprintf(fileId,'Percentage of Agents Selling: %.2f\n',0.50);
fprintf(fileId,'Initual Inventory (# units): %.1f\n',200.0);
fprintf(fileId,'Percentage of Agents Buying: %.2f\n',0.80);

fclose(fileId);

fildId = fopen(fileName, "r");

line = fgetl(fildId); % Header

line = fgetl(fildId);
inputValue = parseInputString(line);
fprintf('%.2f\n',inputValue);

line = fgetl(fildId);
inputValue = parseInputString(line);
fprintf('%.2f\n',inputValue);

line = fgetl(fildId);
inputValue = parseInputString(line);
fprintf('%.2f\n',inputValue);

line = fgetl(fildId);
inputValue = parseInputString(line);
fprintf('%.2f\n',inputValue);

line = fgetl(fildId);
inputValue = parseInputString(line);
fprintf('%.2f\n',inputValue);

line = fgetl(fildId);
inputValue = parseInputString(line);
fprintf('%.2f\n',inputValue);

line = fgetl(fildId);
inputValue = parseInputString(line);
fprintf('%.2f\n',inputValue);

line = fgetl(fildId);
inputValue = parseInputString(line);
fprintf('%.2f\n',inputValue);

line = fgetl(fildId);
inputValue = parseInputString(line);
fprintf('%.2f\n',inputValue);

fclose(fildId);
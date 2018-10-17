%=====================================================
%
%
% Author: Jess
% Created: 2018.10.16
%=====================================================
addpath lib

fileName = 'InputCommerce.txt';
fileId = fopen(fileName, "w");

fprintf(fileId,'\nCommerce Model Input Parameters\n\n');

fprintf(fileId,'1) Number of Time Steps (dt): %.0f\n',150.0);
fprintf(fileId,'2) Number of Agents: %d\n',20);
fprintf(fileId,'3) Initial Wallet Size (drachma): %.1f\n',100.0);
fprintf(fileId,'4) UBI Rate (drachma / dt): %.1f\n',1.0);
fprintf(fileId,'5) Percent Demurrage (/dt): %.2f\n',0.05);
fprintf(fileId,'6) Price of Goods (drachma): %.1f\n',1.0);
fprintf(fileId,'7) Percentage of Agents Selling: %.2f\n',0.50);
fprintf(fileId,'8) Initual Inventory (# units): %.1f\n',200.0);
fprintf(fileId,'9) Percentage of Agents Buying: %.2f\n',0.80);

fclose(fileId);

fildId = fopen(fileName, "r");

%
% Header
% 
for i = 1:3
    fgetl(fildId);
end

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
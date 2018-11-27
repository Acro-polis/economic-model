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

fprintf(fileId,'1)  Number of Time Steps (dt): %.0f\n',300.0);
fprintf(fileId,'2)  Number of Agents: %d\n',25.0);
fprintf(fileId,'3)  Network Filename: %s\n',"use blank for connected network");
fprintf(fileId,'4)  Number of search steps (find path): %d\n',0);
fprintf(fileId,'5)  Initial Wallet Size (drachma / agent): %.1f\n',0.0);
fprintf(fileId,'6)  UBI Rate (drachma / dt): %.1f\n',100.0);
fprintf(fileId,'7)  Percent Demurrage (/dt): %.2f\n',0.05);
fprintf(fileId,'8)  Percentage of Agents Buying: %.2f\n',0.75);
fprintf(fileId,'9)  Percentage of Agents Selling: %.2f\n',0.75);
fprintf(fileId,'10)  Price of Goods (drachma / unit): %.1f\n',75.0);
fprintf(fileId,'11) Initial Inventory (# units / agent): %.1f\n',300.0);

fclose(fileId);

fileId = fopen(fileName, "r");

% Testing

%
% Header
% 
for i = 1:3
    fgetl(fileId);
end

% line 1
line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

% line 2
line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

% line 3
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

fclose(fileId);
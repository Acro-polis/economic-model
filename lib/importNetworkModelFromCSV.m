function AM = importNetworkModelFromCSV(numberAgents, fileName)
%========================================
%
%
% Author: Jess
% Created: 2018.11.11
%========================================

% Read the csv file skipping the header
%M = csvread(fileName, A1, 0, [2 0 3 1]);
T = readtable(fileName);
T2 = T{1:4,0:1};
T2

end


function AM = importNetworkModelFromCSV(N, fileName)
%========================================
%
% Read a csv file containing network edges
% produced by the Random Hybrid Model.
%
% Author: Jess
% Created: 2018.11.11
%========================================


% Create the adjacency matrix with no connections
AM = zeros(N,N);

% Read the csv file that contains the network connections into a table
T = readtable(fileName,'Delimiter',',','Format','%d%d%s%s'); % Random Generator Output

% Build AM from the connections provided
[connections, ~] = size(T);
for i = 1:connections
    source = T.Source(i);
    target = T.Target(i);
    %fprintf("Source = %d, Target = %d\n", source, target);
    AM(source, target) = 1;
    AM(target, source) = 1;
end


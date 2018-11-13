function AM = importNetworkModelFromCSV(N, fileName)
%========================================
%
% Read a csv file containing network edges
% produced by Gephi. Note Gephi uses arrays
% that start with an index of zero while Matlab 
% uses arrays that start with an index of one. 
%
% Author: Jess
% Created: 2018.11.11
%========================================


% Create the adjacency matrix with no connections
AM = zeros(N,N);

% Read the csv file that contains the network connections into a table
T = readtable(fileName,'Delimiter',',','Format','%d%d%s%d%s%s%d');

% Build AM from the connections provided
[connections, ~] = size(T);
for i = 1:connections
    source = T.Source(i) + 1;
    target = T.Target(i) + 1;
    %fprintf("Source = %d, Target = %d\n", source, target);
    AM(source, target) = 1;
    AM(target, source) = 1;
end


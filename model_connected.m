%==============================================
% 
% Create a complete network for N nodes and
% and output the results in files suitable
% for import into the visualization tool Gephi
%
%==============================================

% Setup	
fprintf("Start Modeling\n")
addpath lib

N = 125;	% Number of Nodes
Am = connectedGraph(N);
outputModel(Am);
plotFrequecyDistribution(Am, 0);

% Tear Down
%rmpath lib
fprintf("Modeling Complete\n");



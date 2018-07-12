%
%
%
fprintf("Start Modeling\n")
addpath lib
%===============================

% Setup Model
N = 25;	% Number of Nodes

% Initialize Adjacency Matrix
Am = connectedGraph(N);

% Output the final model
outputModel(Am);

%===============================
rmpath lib
fprintf("Modeling Complete\n");



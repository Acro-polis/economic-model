%===================================================
%
% Hybrid Random Growth Network Model
%
% Author: Jess
% Created: 2018.07.19
%===================================================
	
% Setup
fprintf("Start Modeling\n")
addpath lib

% Initializations

T = 1000;               % Max Time 
dt = 1;                 % Time Step 
numT = round(T / dt);   % Number of time steps (integer)

N = 25;                   % Number of initial nodes
TN = N;                   % Number of current nodes
Am = connectedGraph(N);   % Initial Adjacency Matrix - Connected graph
OriginTimes = ones(N,1);  % The origin time for these nodes (t=1)

alpha = 0.50;             % Proportion of random connections vs preferred connections [0,1]

% NewNodesPercent = 0.1;    % Percentage of new nodes added each time dt; dt > 1
% numNewNodes = round(N * NewNodesPercent);

% Loop over time
for time = 1:numT

    % Number of new nodes per time
    numNewNodes = 1;
    
    % Distribuiton of N new connections per new node
    newRandomConnections = round(alpha * N);
    newPreferredConnections = N - newRandomConnections;

    % Process each new node
    for newNode = 1:numNewNodes
        
        % Add new node
        [newAm, OriginTimes] = addNewNodes(Am, OriginTimes, time, 1);
        TN = size(newAm,1);
        
        % Add random connections to the other nodes
        for newRandomConnection = 1:newRandomConnections
            index = round(unifrnd(1,TN - 1)); % Note can reassign (duplicate), TODO for later, if necessary
            newAm(index, TN) = 1;
            newAm(TN, index) = 1;
            %fprintf('t = %d, random index = %d\n', time, index);
        end;
        
        % Add preferred connections to the other nodes
        for newPreferredConnection = 1:newPreferredConnections
            index = identifyPreferredNode(Am); % Note can reassign (duplicate), TODO for later, if necessary
            newAm(index, TN) = 1;
            newAm(TN, index) = 1;
            %fprintf('t = %d, preferred index = %d\n', time, index);
        end;
        
        Am = newAm;
                
    end;    

    %fprintf('For t = %d, avgDeg = %f\n',time, averageDegree(Am));

end;

outputModel(Am);

plotFrequecyDistribution(Am, 1);

% Tear down
%rmpath lib
fprintf("Modeling Complete\n");
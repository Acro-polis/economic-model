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

T = 99;                 % Max Time 
dt = 1;                 % Time Step 
numT = round(T / dt);   % Number of time steps (integer)

N = 1;                   % Number of initial nodes
TN = N;                   % Number of current nodes
Am = connectedGraph(N);   % Initial Adjacency Matrix - Connected graph
OriginTimes = ones(N,1);  % The origin time for these nodes (t=1)
numNewNodesPerDt = 1;     % Number of new nodes per time

alpha = 0.99;             % Proportion of random connections vs preferred connections [0,1]
                          % 1 = All random (need slightly less than < 1.0
                          %     for Mean-field plot, so use 0.99.
                          % 0 = All preferred 

numNewRandomConnections = round(alpha * N);
numNewPreferredConnections = N - numNewRandomConnections;
fprintf('\n');
fprintf('Random Connections = %.2f, Preferred = %.2f\n',numNewRandomConnections, numNewPreferredConnections);
fprintf('\n');

modeUndirected = 1;
expectedNodes = N + T*numNewNodesPerDt;
expectedConnections = numberOfConnections(Am, modeUndirected) + T*N*numNewNodesPerDt;

% Loop over time
for time = 2:(numT+1)

    % Process each new node
    for newNode = 1:numNewNodesPerDt
        
        % Add new node
        [newAm, OriginTimes] = addNewNodes(Am, OriginTimes, time, 1);
        TN = size(newAm,1);
        
        % Add random connections to the other nodes
        randomAttachments = [];
        if numNewRandomConnections >  0 
            randomAttachments = findRandomNodes(TN-1, numNewRandomConnections);
            newAm(randomAttachments, TN) = 1;
            newAm(TN, randomAttachments) = 1;
            %fprintf('Found %d random attachments\n',size(attachments,2));
        end;
        
        % Add preferred connections to the other nodes
        if numNewPreferredConnections > 0
            preferredAttachments = findPreferredNodes(Am, TN-1, numNewPreferredConnections, randomAttachments);
            newAm(preferredAttachments, TN) = 1;
            newAm(TN, preferredAttachments) = 1;
            %fprintf('Found %d preferred attachments\n',size(attachments,2));
        end;
        
        Am = newAm; %TODO - not computationally efficient
                
    end;    

    %fprintf('For t = %d, avgDeg = %f\n',time, averageDegree(Am));

end;

outputModel(Am);

generatedNodes = size(Am,1);
generatedConnections = numberOfConnections(Am,modeUndirected);

fprintf('\n');
fprintf('Expected %d nodes, generated %d nodes\n',expectedNodes,generatedNodes);
fprintf('Expected %d connections, generated %d connections\n',expectedConnections,generatedConnections);
fprintf('\n');

plottingStyle = 1;
plotFrequecyDistributionHybrid(Am, N, T, alpha, plottingStyle);

%G = graph(Am);
%p = plot(G,'Layout','force');

% Tear down
%rmpath lib
fprintf("Modeling Complete\n");
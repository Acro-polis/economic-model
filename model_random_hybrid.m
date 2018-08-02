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

% Parameters

N =   5;                  % Number of initial nodes
T = 995;                  % Max Time 
alpha = 0.99;             % Proportion of random connections vs preferred connections [0,1]
                          % 1 = All random (need slightly less than < 1.0
                          %     for Mean-field plot, so use 0.99.
                          % 0 = All preferred 
numNewNodesPerDt = 1;     % Number of new nodes per time

% Initializations
dt = 1;                   % Time Step 
numT = round(T / dt);     % Number of time steps (integer)
Am = connectedGraph(N);   % Initial Adjacency Matrix - Connected graph
OriginTimes = ones(N,1);  % The origin time for these nodes (t=1)


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
    fprintf('Time step = %u\n',time);

    % Store dimension of each node for time - 1
    D = sum(Am);
    nodesD = size(D,2);

    % Process each new node
    for newNode = 1:numNewNodesPerDt

        % Add new node
        [Am, OriginTimes] = addNewNodes(Am, 1, OriginTimes, time);
        TN = size(Am,1);
        
        % Add random connections to the other nodes
        randomAttachments = [];
        if numNewRandomConnections >  0 
            randomAttachments = findRandomNodes(nodesD, numNewRandomConnections);
            Am(randomAttachments, TN) = 1;
            Am(TN, randomAttachments) = 1;
            %fprintf('Found %d random attachments\n',size(attachments,2));
        end
        
        % Add preferred connections to the other nodes
        if numNewPreferredConnections > 0
            preferredAttachments = findPreferredNodes(D, nodesD, numNewPreferredConnections, randomAttachments);
            Am(preferredAttachments, TN) = 1;
            Am(TN, preferredAttachments) = 1;
            %fprintf('Found %d preferred attachments\n',size(attachments,2));
        end
        
    end    

    %fprintf('For t = %d, avgDeg = %f\n',time, averageDegree(Am));

end

generatedNodes = size(Am,1);
generatedConnections = numberOfConnections(Am,modeUndirected);

fprintf('\n');
fprintf('Expected %d nodes, generated %d nodes\n',expectedNodes,generatedNodes);
fprintf('Expected %d connections, generated %d connections\n',expectedConnections,generatedConnections);
fprintf('\n');

plottingStyle = 1;
plotFrequecyDistributionHybrid(Am, N, T, alpha, plottingStyle);

outputModel(Am);
fprintf('\n');

%G = graph(Am);
%p = plot(G,'Layout','force');

% Tear down
%rmpath lib
fprintf("Modeling Complete\n");
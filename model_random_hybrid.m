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

T = 975;                % Max Time 
dt = 1;                 % Time Step 
numT = round(T / dt);   % Number of time steps (integer)

N = 25;                    % Number of initial nodes
TN = N;                   % Number of current nodes
Am = connectedGraph(N);   % Initial Adjacency Matrix - Connected graph
OriginTimes = ones(N,1);  % The origin time for these nodes (t=1)

alpha = 0.50;             % Proportion of random connections vs preferred connections [0,1]
                          % 1 = all random, 0 = all preferred (need < 1.0
                          % for Mean-field plot, so use 0.99.

modeUndirected = 1;
expectedConnections = numberOfConnections(Am, modeUndirected) + T*N;

% Distribuiton of N new connections per new node
newRandomConnections = round(alpha * N);
newPreferredConnections = N - newRandomConnections;
fprintf('Random Connections = %.2f, Preferred = %.2f\n',newRandomConnections, newPreferredConnections);

% Loop over time
for time = 1:numT

    % Number of new nodes per time
    numNewNodes = 1;

    % Process each new node
    for newNode = 1:numNewNodes
        
        % Add new node
        [newAm, OriginTimes] = addNewNodes(Am, OriginTimes, time, 1);
        TN = size(newAm,1);
        
        % Add random connections to the other nodes
        if newRandomConnections >  0 
            randomAttachments = findRandomNodes(TN - 1, newRandomConnections);
            newAm(randomAttachments, TN) = 1;
            newAm(TN, randomAttachments) = 1;
            %fprintf('Found %d random attachments\n',size(attachments,2));
        end;
        
        % Add preferred connections to the other nodes
        if newPreferredConnections > 0
            preferredAttachments = identifyPreferredNodes(Am, TN - 1, newPreferredConnections, randomAttachments);
            newAm(preferredAttachments, TN) = 1;
            newAm(TN, preferredAttachments) = 1;
            %fprintf('Found %d preferred attachments\n',size(attachments,2));
        end;
        
        Am = newAm;
                
    end;    

    %fprintf('For t = %d, avgDeg = %f\n',time, averageDegree(Am));

end;

outputModel(Am);

generatedConnections = numberOfConnections(Am,modeUndirected);

fprintf('\n');
fprintf('Expected %d connections, generated %d connections\n',expectedConnections,generatedConnections);
fprintf('\n');

plottingStyle = 1;
plotFrequecyDistributionHybrid(Am, N, alpha, plottingStyle);

% Tear down
%rmpath lib
fprintf("Modeling Complete\n");
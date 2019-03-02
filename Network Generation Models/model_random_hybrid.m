%===================================================
%
% Hybrid Random Growth Network Model
%
% Author: Jess
% Created: 2018.07.19
%===================================================
version_number = "1.1.0";
	
inputTypeDouble = 0;
inputTypeString = 1;

% Setup
fprintf("\n===========================================================\n");
fprintf("Starting Network Generation\n")
fprintf("===========================================================\n");

% Open Input File, read header
fileName = 'InputNetworkGeneration.txt';
fileId = fopen(fileName, "r");
for i = 1:3
    fgetl(fileId);
end
addpath lib

% Parameters

N =  parseInputString(fgetl(fileId), inputTypeDouble);                  % Number of initial nodes
T =  parseInputString(fgetl(fileId), inputTypeDouble);                  % Number of generation steps
numNewNodesPerDt = parseInputString(fgetl(fileId), inputTypeDouble);    % Number of new nodes per genration step

alpha =  parseInputString(fgetl(fileId), inputTypeDouble);  % Proportion of random connections vs preferred connections [0,1]
                                                            % 1 = All random (need slightly less than < 1.0
                                                            %     for Mean-field plot, so use 0.99.
                                                            % 0 = All preferred 
if alpha == 1.0
    alpha = 0.99;
end
assert(alpha >= 0 && alpha <= 0.99,"Error: Alpha out of bounds");

% Initializations
dt = 1;                   % Time Step 
numT = round(T / dt);     % Number of time steps (integer)
Cm = connectedGraph(N);   % Initial Adjacency Matrix - Connected graph
OriginTimes = ones(N,1);  % The origin time for these nodes (t=1)

numNewRandomConnections = round(alpha * N);
numNewPreferredConnections = N - numNewRandomConnections;

modeUndirected = 1;
expectedNodes = N + T*numNewNodesPerDt;
expectedConnections = numberOfConnections(Cm, modeUndirected) + T*N*numNewNodesPerDt;

% Preallocate size of Am for performance reasons, add Cm to Am to get
% started
Am = zeros(expectedNodes,expectedNodes);
TN = size(Cm,1);
Am(1:TN , 1:TN) = Cm;

startTime = tic();

% Loop over time
for time = 1:numT
    
   if mod(time,100) == 1
       fprintf('\nTime Step = %u\n',time);
   end

    % Store dimensions of nodes at time t and number of nodes TN
    D = sum(Am(1:TN,1:TN)); % This line of code slows it all up!
    nodesD = TN;

    % Process each new node and connect them to the nodes in set nodesD
    % (meaning if more than one node is added per time = t all the new 
    % nodes are attached to the original set we started with at time = t)
    
    for newNode = 1:numNewNodesPerDt

        % Add new node
        TN = TN + 1;
        
        % Add random connections to the other nodes
        randomAttachments = [];
        if numNewRandomConnections >  0 
            randomAttachments = findRandomeNodes(nodesD, numNewRandomConnections);
            Am(randomAttachments, TN) = 1;
            Am(TN, randomAttachments) = 1;
            %fprintf('Found %d random attachments\n',size(attachments,2));
        end
        
        % Add preferred connections to the other nodes, minus the
        % randomAttachments if there are any
        if numNewPreferredConnections > 0
            preferredAttachments = findPreferredNodesHybrid(D, nodesD, numNewPreferredConnections, randomAttachments);
            Am(preferredAttachments, TN) = 1;
            Am(TN, preferredAttachments) = 1;
            %fprintf('Found %d preferred attachments\n',size(attachments,2));
        end
        
    end    

    %fprintf('For t = %d, avgDeg = %f\n',time, averageDegree(Am));

end

elapsedTime = toc(startTime);

generatedNodes = size(Am,1);
generatedConnections = numberOfConnections(Am, modeUndirected);

fprintf('\n');
fprintf('Elapsed time = %.2f seconds\n',elapsedTime);
fprintf('\n');
fprintf('Random Connections = %.2f, Preferred = %.2f\n',numNewRandomConnections, numNewPreferredConnections);
fprintf('\n');
fprintf('Expected %d nodes, generated %d nodes\n',expectedNodes,generatedNodes);
fprintf('Expected %d connections, generated %d connections\n',expectedConnections,generatedConnections);
fprintf('\n');
%fprintf('Average Degree = %.2f\n',averageDegree(Am));

plottingStyle = 1;
plotFrequecyDistributionHybrid(Am, N, T, alpha, plottingStyle);

outputNetworkModelForGephi("Hybrid", Am, N, T, alpha, version_number);
fprintf('\n');

%G = graph(Am);
%p = plot(G,'Layout','force');

% Tear down
%rmpath lib
fprintf("Modeling Complete\n");
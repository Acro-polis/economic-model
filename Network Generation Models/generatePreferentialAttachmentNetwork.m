%===================================================
%
% Grow a network using ...
%
% 1) Preferrential Attachment for 
%   a) New Nodes
%   b) Selected existing nodes
%
% Author: Jess
% Created: 2019.03.02
%===================================================
version_number = "PF_1.0.0";
	
inputTypeDouble = 0;
inputTypeString = 1;

% Setup
fprintf("\n===========================================================\n");
fprintf("Starting Network Generation\n")
fprintf("===========================================================\n");

% Open Input File, read header
fileName = 'inputFile_PA.txt';
fileId = fopen(fileName, "r");
for i = 1:3
    fgetl(fileId);
end
addpath lib

% Parameters

N =  parseInputString(fgetl(fileId), inputTypeDouble);                              % Number of initial nodes
T =  parseInputString(fgetl(fileId), inputTypeDouble);                              % Number of generation steps
newNodesPerDt = parseInputString(fgetl(fileId), inputTypeDouble);                   % Number of new nodes per genration step
numAttachmentsPerNewNode = parseInputString(fgetl(fileId), inputTypeDouble);        % Number of attachments to make for each new node
percentageExistingNodesPerDt = parseInputString(fgetl(fileId), inputTypeDouble);    % Percentage of existing nodes to treat per genration step
newAttachmentsPerDt = parseInputString(fgetl(fileId), inputTypeDouble);             % Number of new connections per node per genration step

assert(percentageExistingNodesPerDt >= 0 && percentageExistingNodesPerDt <= 1.0,"Error: percentageExistingNodesPerDt out of bounds");

% Initializations
dt = 1;                                 % Time Step 
numTimeSteps = round(T / dt);           % Number of time steps (integer)
AM = connectedGraph(N);                 % The initial netowrk is a connected graph with N agents
modeUndirected = 1;                     % Connections: 1 for Undirected, 0 for Directed

startTime = tic();
numNodes = N;

nodeOriginTimes = ones(N,1);           % The origin time for these nodes (t=0)

% Loop over time
for timeStep = 2:numTimeSteps
    
    if mod(timeStep,100) == 1
        fprintf('\nTime Step = %u\n',timeStep);
    end

    % Add new attachments from existing nodes
    numNodesToAddNewAttachments = round(numNodes*percentageExistingNodesPerDt);
    if numNodesToAddNewAttachments > 0
        listOfNodes = datasample(1:numNodes, numNodesToAddNewAttachments, 'Replace', false);
        for i = 1:numNodesToAddNewAttachments
            AM = addAttachmentsToNodeWithPreferentialAttachment(AM, listOfNodes(i), newAttachmentsPerDt);
        end
    end
    
    % Add new nodes and attachments
    for newNode = 1:newNodesPerDt
        AM = addNewNodeWithPreferentialAttachments(AM, numAttachmentsPerNewNode);
        [numNodes, ~] = size(AM);
        nodeOriginTimes(numNodes) = timeStep;
    end

end

elapsedTime = toc(startTime);

fprintf('\nElapsed time = %.2f seconds\n',elapsedTime);

fprintf('\nPlotting degree distribution\n');
fprintf('\n');
plottingStyle = 1;
plotFrequecyDistributionHybrid(AM, N, numTimeSteps, 0, plottingStyle);

outputTimeSeriesNetworkModelForGephi("PA", AM, nodeOriginTimes, N, numTimeSteps, version_number)
fprintf('\n');

fprintf("Generation Complete\n");

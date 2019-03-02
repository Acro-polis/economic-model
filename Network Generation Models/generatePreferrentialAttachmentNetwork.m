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
newConnectionsPerDt = parseInputString(fgetl(fileId), inputTypeDouble);             % Number of new connections per node per genration step

assert(percentageExistingNodesPerDt >= 0 && percentageExistingNodesPerDt <= 1.0,"Error: percentageExistingNodesPerDt out of bounds");

% Initializations
dt = 1;                                 % Time Step 
numTimeSteps = round(T / dt);           % Number of time steps (integer)
OriginTimes = ones(N,1);               % The origin time for these nodes (t=0)
AM = connectedGraph(N);                 % The initial netowrk is a connected graph with N agents
modeUndirected = 1;                     % Connections: 1 for Undirected, 0 for Directed

startTime = tic();
numAgents = N;

% Loop over time
for time = 2:numTimeSteps
    
    if mod(time,100) == 1
        fprintf('\nTime Step = %u\n',time);
    end

    %TODO treat existing nodes

    for newNode = 1:newNodesPerDt
        AM = addNewNodeWithPreferredAttachments(AM, numAttachmentsPerNewNode);
        numAgents = numAgents + 1;
        OriginTimes(numAgents) = time;
    end

end

elapsedTime = toc(startTime);

fprintf('\n');
fprintf('Elapsed time = %.2f seconds\n',elapsedTime);
fprintf('\n');

%TODO plot degree distribution

outputTimeSeriesNetworkModelForGephi("PA", AM, OriginTimes, N, numTimeSteps, version_number)
fprintf('\n');

fprintf("Generation Complete\n");

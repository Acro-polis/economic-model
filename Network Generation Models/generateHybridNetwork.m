%==========================================================================
%
% Hybrid Random Growth Network Model
%
% Version H_1.2.0 - Adding output files that record the input parameters 
% and the output parameters in a subfolder. Also we will start saving to 
% disk the associated degree distribution plot. 
%
% Author: Jess
% Created: 2018.07.19
%==========================================================================
program_name = "Hybrid Random Growth Network Model";
version_number = "H_1.2.0";
	
inputTypeDouble = 0;
inputTypeString = 1;

fprintf("\n===========================================================\n");
fprintf("Starting Random Network Generation\n")
fprintf("===========================================================\n");

%
% Open Input File, read header
%
fileName = 'inputFile_Hybrid.txt';
fileId = fopen(fileName, "r");
for i = 1:3
    fgetl(fileId);
end

%
% Input Parameters
%
N =  parseInputString(fgetl(fileId), inputTypeDouble);                  % Number of initial nodes
T =  parseInputString(fgetl(fileId), inputTypeDouble);                  % Number of generation steps
numNewNodesPerDt = parseInputString(fgetl(fileId), inputTypeDouble);    % Number of new nodes per genration step
alpha =  parseInputString(fgetl(fileId), inputTypeDouble);  % Proportion of random connections vs preferred connections [0,1]
                                                            % 1 = All random (need slightly less than < 1.0
                                                            %     for Mean-field plot, so use 0.99).
                                                            % 0 = All preferred 
if alpha == 1.0
    alpha = 0.99;
end
assert(alpha >= 0 && alpha <= 0.99,"Error: Alpha out of bounds");

%
% Initializations
%
dt = 1;                   % Time Step 
numT = round(T / dt);     % Number of time steps (integer)
Cm = connectedGraph(N);   % Initial Adjacency Matrix - Connected graph
OriginTimes = ones(N,1);  % The origin time for these nodes (t=1)

numNewRandomConnections = round(alpha * N);
numNewPreferredConnections = N - numNewRandomConnections;

modeUndirected = 1;
expectedNodes = N + T*numNewNodesPerDt;
expectedConnections = numberOfConnections(Cm, modeUndirected) + T*N*numNewNodesPerDt;

%
% Output Directory
%
outputSubFolderName = sprintf('Hybrid: SN=%d EN=%d T=%d alpha=%.2f ver=%s', N, expectedNodes, numT, alpha, version_number);
outputFolderPath = "Output";
outputSubfolderPath = sprintf("%s/%s/", outputFolderPath, outputSubFolderName);
[status, msg, msgID] = mkdir(outputSubfolderPath);

%
% Save input parameters and relevant derived data
%
inputFilePathAndName = sprintf("%s%s", outputSubfolderPath, "inputParameters.txt");
recordInputParameters(program_name,                 ...
                      version_number,               ... 
                      N,                            ...
                      numNewNodesPerDt,             ...
                      expectedNodes,                  ...
                      numT,                         ... 
                      alpha,                        ...
                      numNewRandomConnections,      ...
                      numNewPreferredConnections,   ...
                      expectedConnections,          ...
                      outputSubFolderName,          ...
                      inputFilePathAndName);

%
% For performance reasons, preallocate size of Am, add Cm to Am to start
%
Am = zeros(expectedNodes,expectedNodes);
TN = size(Cm,1);
Am(1:TN , 1:TN) = Cm;

startTime = tic();

for time = 1:numT
    
   if mod(time,100) == 1
       fprintf('\nTime Step = %u\n',time);
   end
   
   %
   % Store dimensions of nodes at time t and number of nodes TN
   %
   D = sum(Am(1:TN,1:TN)); % This line of code slows it all up!
   nodesD = TN;

   %
   % Process each new node and connect them to the nodes in set nodesD
   % (meaning if more than one node is added per time = t all the new 
   % nodes are attached to the original set we started with at time = t)
   %
   for newNode = 1:numNewNodesPerDt
       % 
       % Add new node
       %
       TN = TN + 1;
        
       %
       % Add random connections to the other nodes
       %
       randomAttachments = [];
       if numNewRandomConnections >  0 
           randomAttachments = findRandomNodes(nodesD, numNewRandomConnections);
           Am(randomAttachments, TN) = 1;
           Am(TN, randomAttachments) = 1;
%           fprintf('Found %d random attachments\n',size(randomAttachments,2));
       end
       
       %
       % Add preferred connections to the other nodes, minus the
       % randomAttachments if there are any
       %
       if numNewPreferredConnections > 0
           preferredAttachments = findPreferredNodesHybrid(D, nodesD, numNewPreferredConnections, randomAttachments);
           Am(preferredAttachments, TN) = 1;
           Am(TN, preferredAttachments) = 1;
 %          fprintf('Found %d preferred attachments\n',size(preferredAttachments,2));
        end
        
   end    

   fprintf('For t = %d, avgDeg = %f\n',time, averageDegree(Am));

end

elapsedTime = toc(startTime);
fprintf('\nElapsed time = %.2f seconds\n',elapsedTime);

generatedNodes = size(Am,1);
generatedConnections = numberOfConnections(Am, modeUndirected);

fprintf('\nRandom Connections = %.2f, Preferred = %.2f\n',numNewRandomConnections, numNewPreferredConnections);
assert(generatedNodes == expectedNodes,'generatedNodes != expectedNodes');
assert(generatedConnections == expectedConnections,'generatedConnections != expectedConnections');
fprintf('\nAverage Degree = %.2f\n',averageDegree(Am));

outputNodes = 1; % 1 = Yes, 0 = No
outputHybridNetworkModelForGephi(Am, outputNodes, outputSubfolderPath);

plottingStyle = 1; % 1 = LogLog, 0 = LinLin
plotFrequecyDistributionHybrid(Am, N, T, alpha, plottingStyle, outputSubfolderPath);

fprintf("\nNetwork Generation Complete\n");

%
% Helper Functions
%

function recordInputParameters(program_name,        ...
                      version_number,               ... 
                      N,                            ...
                      numNewNodesPerDt,             ...
                      expectedNodes,                ...
                      numT,                         ... 
                      alpha,                        ...
                      numNewRandomConnections,      ...
                      numNewPreferredConnections,   ...
                      expectedConnections,          ...
                      outputSubFolderName,          ...
                      inputFilePathAndName)

    o0 = sprintf("\n\n Summary of network generation input parameters\n\n");
    o1 = sprintf("\n Program:        %s,\n Version:        %s,\n Ouput Location: %s \n", program_name, version_number, outputSubFolderName);
    o2 = sprintf("\n Start with %d nodes, add %d nodes / time step for %d time steps\n", N, numNewNodesPerDt, numT);
    o3 = sprintf("\n Creating a total of %d nodes and %d connections\n", expectedNodes, expectedConnections);
    o4 = sprintf("\n For alpha = %.2f, per time step, %d connections are random and %d are preferrential attachment\n", alpha, numNewRandomConnections, numNewPreferredConnections);

    fileId = fopen(inputFilePathAndName, "wt");
    if fileId > 0
        fprintf(fileId, o0);
        fprintf(fileId, o1);
        fprintf(fileId, o2);
        fprintf(fileId, o3);
        fprintf(fileId, o4);
        fclose(fileId);
    end
    
end


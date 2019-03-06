function [N,                        ...
          T,          ...
          newNodesPerDt,                       ...
          numAttachmentsPerNewNode,          ...
          percentageExistingNodesPerDt,           ...
          newAttachmentsPerDt,                ...
          timeStepUBI] = readNetworkInputFile(networkInputFilename)      

% Read the input parameters for the economic commerce model from the given file

    inputTypeDouble = 0;
    inputTypeString = 1;

    % Open Input File, set the inputFileName as an environment variable (or we'll crash out)
    fileId = fopen(networkInputFilename, "r");
    assert(fileId ~= -1, "\nError: Cannot open model commerce input file = %s, check environment variable!\n", networkInputFilename);

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

    fclose(fileId);

end



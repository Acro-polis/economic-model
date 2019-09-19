function [numSteps,                 ...
          N,                        ...
          networkPathname,          ...
          AM,                       ...
          maxSearchLevels,          ...
          seedWalletSize,           ...
          amountUBI,                ...
          timeStepUBI,              ...
          percentDemurrage,         ...
          timeStepDemurrage,        ...
          numberOfPassiveAgents,    ...
          percentPassiveAgents,     ...
          percentSellers,           ...
          price,                    ...
          inventoryInitialUnits,    ...
          numberIterations,         ...
          outputSubFolderName] = readInputCommerceFile(inputFilename)
      
% Read the input parameters for the economic commerce model from the given file

    inputTypeDouble = 0;
    inputTypeString = 1;

    % Open Input File, set the inputFileName as an environment variable (or we'll crash out)
    fileId = fopen(inputFilename, "r");
    assert(fileId ~= -1, "\nError: Cannot open model commerce input file = %s, check environment variable!\n", inputFilename);

        % Read header
        for i = 1:3
            fgetl(fileId);
        end

        % Initializations
        T =  parseInputString(fgetl(fileId), inputTypeDouble);                  % Max Time (Input 1)
        numSteps = round(T);                                                    % Number of time steps (integer)
        assert(numSteps >= 1,'Assert: Number of time steps must be >= 1!');

        N =  round(parseInputString(fgetl(fileId), inputTypeDouble));           % Number of Agents (nodes) (Input 2)
        assert(N >= 2,'Assert: Number of agents must be >= 2!');

        networkPathname = parseInputString(fgetl(fileId), inputTypeString);     % Network FileName (Input 3)

        AM = [];
        if networkPathname == ""
            AM = connectedGraph(N);                                                
        else
            % TODO - this is a bit brittle ... fix it
            cd('Network Models');
            cd(networkPathname);
            AM = importNetworkModelFromCSV(N, 'edges.csv');
            cd('../..');
        end

        % Transaction Distance
        % Max Search Level = 0 internally means we will always search for 
        % your neighbors and neighbors neighbors. But we ask for 2 on 
        % input as this makes more sense to a user - 2 legs searched.
        % (i.e. if search level > max search level return (not >=))
        maxSearchLevels =  round(parseInputString(fgetl(fileId), inputTypeDouble)); % Search Levels (Input 4)
        maxSearchLevels = maxSearchLevels - 2;
        assert(maxSearchLevels >= 0,"Error: Transaction-Distance < 2");

        % Wallet
        seedWalletSize = parseInputString(fgetl(fileId), inputTypeDouble); % Wallet Size (Input 5)

        % Rate of UBI
        amountUBI = parseInputString(fgetl(fileId), inputTypeDouble); % UBI amount (Input 6)
        assert(amountUBI > 0,'Assert: UBI must be > 0!');
        timeStepUBI = parseInputString(fgetl(fileId), inputTypeDouble); % UBI amount (Input 7)
        assert(timeStepUBI >= 1,'Assert: UBI Time Step must be >= 1');

        % Percentage of Demurrage
        percentDemurrage = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Demurrage (Input 8)
        assert(percentDemurrage >= 0 && percentDemurrage <= 1.0,'Assert: Percentage Demurrage Out Of Range!');
        timeStepDemurrage = parseInputString(fgetl(fileId), inputTypeDouble); % UBI amount (Input 9)
        assert(timeStepDemurrage >= 1,'Assert: Demurrage Time Step must be >= 1');

        % Percentage Passive Agents
        percentPassiveAgents = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Passive Agents (Input 10)
        assert(percentPassiveAgents > 0 && percentPassiveAgents <= 1.0,'Assert: Percentage Buyers Out Of Range!')
        numberOfPassiveAgents = round(percentPassiveAgents*N);

        % Percentage Seller Agents as a function of the number of Buyers
        percentSellers = parseInputString(fgetl(fileId), inputTypeDouble); % Percentage Sellers (Input 11)
        assert(percentSellers > 0 && percentSellers <= 1.0,'Assert: Percentage Sellers Out Of Range!')

        % Cost of goods
        price = parseInputString(fgetl(fileId), inputTypeDouble); % Price Goods (Input 12);

        % Seller Inventory
        inventoryInitialUnits = parseInputString(fgetl(fileId), inputTypeDouble); % Inital Inventory (Input 13)

        % Iterations
        numberIterations =  round(parseInputString(fgetl(fileId), inputTypeDouble));   % Number Iterations (Input 14)

        % Ouput filename
        outputSubFolderName = parseInputString(fgetl(fileId), inputTypeString);  % Output folder (Input 15)

    fclose(fileId);

end


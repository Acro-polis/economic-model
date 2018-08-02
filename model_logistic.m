%===================================================
%
% Logistic model for network growth
%
% Author: Jess
% Created: 2018.07.11
%===================================================
	
% Setup
fprintf("Start Modeling\n")
addpath lib

% Initializations

T = 180;        % Max Time (say a year)
dt = 1;         % Time Step (say a month)
numT = T / dt;  % Number of time steps

N = 25;                   % Number of initial nodes
Am = zeros(N,N);          % Initial Adjacency Matrix - No connections
OriginTimes = ones(N,1);  % The origin time for these nodes (t=1)

NewNodesPercent = 0.02;   % Percentage of new nodes added each time dt; dt > 1

startNodes = N;

% Dynamically Build Model

% Algorithm
%
% For each time step 
% 1. Add new nodes to the system (t > 1)
% 2. Visit each node and determine how many new connections 
%    they can have at that time, as govenred by the the logistic function. 
%    If they can have one or more new connections, add each one by randomly 
%    selecting any other node from the rest (ignoring self connections 
%    (the diagonals) and occasional random reassignments).
%

% Loop over time
for t = 1:numT
    
    % Add new nodes
    if (t >= 2)
        numNewNodes = round(N * NewNodesPercent);
        [Am, OriginTimes] = addNewNodes(Am, numNewNodes, OriginTimes, t);
        N = size(Am,1);
        fprintf('For T = %d, New Nodes = %d & N = %d\n',t, numNewNodes, N);
    end;
    
    % Loop over nodes
    for i = 1:N
      
      % Calculate new connections to add for node i taking into
      % consideration the time node i entered the network
      adjustedTime = t - OriginTimes(i) - 1;
      if (adjustedTime < 0)
          adjustedTime = 0;
      end;
      %fprintf('t = %d, i = %d, at = %d\n',t, i, adjustedTime);
      numNewConnections = round(logisticFunction(25, 1.0, 0.75, 4.0, adjustedTime)) - sum(Am(i,:));
      
      % Make the new connections
      if (numNewConnections > 0)
        %if (i == 1)
          %fprintf('For t = %d, numNewConnections = %d\n', t, numNewConnections);
        %end;
        for nc = 1:numNewConnections
          index = round(unifrnd(1,N));  % uniform distribution between 1 and N
          if (i ~= index)               % skip diagonal elements
            Am(i,index) = 1;            % this might happen more than once, ignore for now
            Am(index,i) = 1;            % Make undirected relationship
            %fprintf('t=%d, i=%d, index=%d\n',t,i,index);
          end;
        end;
      end;
    end;
end;

outputModel(Am);

plottingStyle = 1;
plotFrequecyDistributionLogistic(Am, startNodes, T, NewNodesPercent, plottingStyle);

% Tear down
%rmpath lib
fprintf("Modeling Complete\n");
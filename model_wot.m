%===================================================
%
% Initial growth model for web of trust
%
% Author: Jess
% Created: 2018.07.11
%===================================================
	
% Setup
fprintf("Start Modeling\n")
addpath lib

% Initializations

T = 12;         % Max Time (say a year)
dt = 1;         % Time Step (say a month)
numT = T / dt;  % Number of time steps

N = 100;         % Number of nodes
Am = zeros(N,N); % Initial Adjacency Matrix - No connections

% Dynamically Build Model

% Algorithm
%
% For each time step visit each node and determine how many new connections 
% they can have at that time, as govenred by the the logistic function. 
% If they can have one or more new connections, add each one by randomly 
% selecting any other node from the rest (ignoring self connections 
% (the diagonals) and occasional random reassignments).
%

for t = 1:numT
    for i = 1:N
      numNewConnections = round(logisticFunction(t-1)) - sum(Am(i,:));
      if (numNewConnections > 0)
        if (i == 1)
          fprintf('For t = %d, numNewConnections = %d\n', t, numNewConnections);
        end;
        for nc = 1:numNewConnections
          index = round(unifrnd(1,N));
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

% Tear down
rmpath lib
fprintf("Modeling Complete\n");
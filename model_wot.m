%===================================================
%
% Growth model for web of trust
%
% Author: Jess
% Created: 2018.07.11
%===================================================
	
% Setup
fprintf("Start Modeling\n")
addpath lib

T = 12; 			  % Max Time (say a year)
dt = 1;         % Time Step (say a month)
numT = T / dt;  % Number of time steps

N = 100;				  % Number of nodes
Am = zeros(N,N);	% Initial Adjacency Matrix

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
        for j = 1:N
            if (i ~= j) % skip diagonal elements
              numNewConnections = round(logisticFunction(t-1)) - sum(Am(i,:));
              if (numNewConnections > 0)
              fprintf('numNewConnections = %d\n',numNewConnections);
                for nc = 1:numNewConnections
				          index = round(unifrnd(1,N));
                  if (i ~= index)               % skip diagonal elements
                    Am(i,index) = 1;            % this might happen more than once, ignore for now
   					        %Am(index,j) = 1;           % uncomment for undirecte releationship
					          %fprintf('t=%d, i=%d, index=%d\n',t,i,index);
                  end;
                end;
              end;
            end;
        end;
    end;
end;

outputModel(Am);

% Tear down
rmpath lib
fprintf("Modeling Complete\n");



%===================================================
%
% Work in progress ... 
%===================================================:
%===================================================
	
% Setup
fprintf("Start Modeling\n")
addpath lib

N = 50;				% Number of nodes
T = 1; 				% Number of times steps 
Am = zeros(N,N);	% Initial Adjacency Matrix

% Dynamically Build Model

for t = 1:T
        for j = 1:N
		for k = 1:N
			if (j == k) 
				continue;
			else
				index = round(unifrnd(1,N));
				if (j != index) 
					Am(j,index) = 1;
					%Am(index,j) = 1;
					%fprintf("t=%u, j=%u, index=%u\n",t,j,index);
				endif;
			endif;
		endfor;
        endfor;
endfor;

outputModel(Am);

% Tear down
rmpath lib
fprintf("Modeling Complete\n");



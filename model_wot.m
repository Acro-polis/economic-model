%
%
%
fprintf("Start Modeling\n")
addpath lib
%===============================

% Setup Model
N = 25;	% Number of nodes
T = 1; % Number of times steps 

% Initialize Adjacency Matrix
Am = zeros(N,N);

% Build Model

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

% Output the final model
outputModel(Am);

%===============================
rmpath lib
fprintf("Modeling Complete\n");



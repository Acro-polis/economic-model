function [Am] = connectedGraph(N)
%
% Return a completely connected graph of dimension N
%

Am = ones(N,N);

for i = 1:N
	Am(i,i) = 0;
endfor;

end

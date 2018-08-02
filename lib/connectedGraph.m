function [Am] = connectedGraph(N)
%=====================================================
%
% Return a completely connected graph of dimension N
%
% Author: Jess
% Created: 2018.07.8
%=====================================================

Am = ones(N,N);

for i = 1:N
	Am(i,i) = 0;
end

end

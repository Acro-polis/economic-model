function AM = connectedGraph(N)
%=====================================================
%
% Return a connected, undirected graph of dimension N
%
% Author: Jess
% Created: 2018.07.8
%=====================================================

AM = ones(N,N);
AM(1:N+1:end) = 0;

end

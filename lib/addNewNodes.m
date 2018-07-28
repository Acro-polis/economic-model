function [Am_out, OriginTimes_out] = addNewNodes(Am, OriginTimes, T, numNewNodes)
%=====================================================
%
% Am            = Existing Adjacency Matrix (NxN)
% OriginTimes   = Origin Times for existing nodes (Nx1)
% T             = Current time step (integer)
% numNewNodes   = Number of new nodes to add to the network
%
%
% Author: Jess
% Created: 2018.07.16
%=====================================================

N = size(Am,1);
Am_out = Am;

% Add new nodes to the adjacency matrix
for i = 1:numNewNodes    
    newColumn = zeros(N , 1);
    Am_out = [Am_out newColumn];
    N = N + 1;
    newRow = zeros(1, N);
    Am_out = [Am_out; newRow];
end;

% Add new origin times T
newTimes = ones(numNewNodes,1).*T;
OriginTimes_out = [OriginTimes; newTimes];

end


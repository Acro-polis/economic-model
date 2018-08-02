function [Am, OriginTimes] = addNewNodes(Am, numNewNodes, OriginTimes, T)
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

% Add new row and column
Am(:, end + numNewNodes) = 0;
Am(end + numNewNodes, :) = 0;

% Add new origin times T
newTimes = ones(numNewNodes, 1) .* T;
OriginTimes = [OriginTimes; newTimes];

end


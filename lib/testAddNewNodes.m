%=====================================================
%
% Test function addNewNodes
%
% Author: Jess
% Created: 2018.07.16
%=====================================================

N = 4;
T = 2;
newNodes = 4;
Am = ones(N, N);
Ot = ones(N,1);
[Am, Ot] = addNewNodes(Am, Ot, T, newNodes);
fprintf('Adjacency Matrix\n');
fprintf([repmat(' %d ', 1, N+newNodes) '\n'], Am');
fprintf('Origin Times\n');
fprintf([repmat(' %d ', 1, N+newNodes) '\n'], Ot');

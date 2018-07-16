%=====================================================
%
% Test function addNewNodes
%
% Author: Jess
% Created: 2018.07.16
%=====================================================
N = 4;
newNodes = 4;
Am = ones(N, N);
Am = addNewNodes(Am,newNodes);
fprintf([repmat(' %d ', 1, N+newNodes) '\n'], Am');

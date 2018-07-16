function [Am_out] = addNewNodes(Am_in,numNewNodes)
%=====================================================
%
% Add a new, unconnected node(s) to the input 
% Adjacency Matrix Am_in
%
% Author: Jess
% Created: 2018.07.16
%=====================================================

N = size(Am_in,1);
Am_out = Am_in;

for i = 1:numNewNodes    
    newColumn = zeros(N , 1);
    Am_out = [Am_out newColumn];
    N = N + 1;
    newRow = zeros(1, N);
    Am_out = [Am_out; newRow];
end;

end


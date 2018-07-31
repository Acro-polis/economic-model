function [numberOfConnections] = numberOfConnections(Am,mode)
%===================================================
%
% Return the number of connections for the 
% given adjacency matrix Am. Set mode = 1 for
% for an undirected count and mode <> 1 for directed.
%
% Author: Jess
% Created: 2018.07.30
%===================================================

D = 2;
if (mode ~= 1) 
    D = 1 
end;
    
numberOfConnections = sum(sum(Am)) / D;

end


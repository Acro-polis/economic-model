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

numberOfConnections = sum(sum(Am));

if (mode ~= 1) 
    numberOfConnections = numberOfConnections / 2.0;
end
    

end


function [newATMatrix] = newAgentTimeMatrix(agents, time, seed)
%==========================================================================
%
% newAgentTimeMatrix
% 
%
% Author: Jess
% Created: 2018.09.07
%==========================================================================

newATMatrix = zeros(agents, time);
newATMatrix(:,1) = seed;
    
end


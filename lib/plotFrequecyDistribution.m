function [fDist] = plotFrequecyDistribution(Am, plotStyle)
%===================================================
%
% Plot the frequency distribution for the matrix Am
%
% plotStyle = 1 for loglog, anything else for linear
% Am is the adjacency matrix
%
% Author: Jess
% Created: 2018.07.19
%===================================================

fDist = degreeFrequencyDistribution(Am);

if (plotStyle == 1)
    loglog(fDist(:,1),fDist(:,2));
else
    plot(fDist(:,1),fDist(:,2));
end;

end


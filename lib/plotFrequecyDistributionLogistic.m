function [fDist] = plotFrequecyDistributionLogistic(AM, N, T, NewNodesPercent, plotStyle)
%===================================================
%
% Plot the frequency distribution for the matrix Am
%
% plotStyle       = 1 for loglog, anything else for linear
% AM              = final adjacency matrix
% N               = initial nodes
% T               = time steps
% newNodesPercent = % new nodes added per time step
%
% Author: Jess
% Created: 2018.07.19
%===================================================

fDist = degreeFrequencyDistribution(AM);

if (plotStyle == 1)
    loglog(fDist(:,1),fDist(:,2));
    xlabel('Log Degree');
    ylabel('Log Frequency');
else
    plot(fDist(:,1),fDist(:,2));
    xlabel('Degree');
    ylabel('Frequency');
end

text = sprintf('Frequency Distribution - Logistic: SN = %u, EN = %u, T = %u, New Nodes = %.1f Percent', N, size(AM,1), T, NewNodesPercent*100);
title(text);
legend('Simulated');

end


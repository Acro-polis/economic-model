function [fDist] = plotFrequecyDistributionLogistic(Am, N, T, NewNodesPercent, plotStyle)
%===================================================
%
% Plot the frequency distribution for the matrix Am
%
% plotStyle       = 1 for loglog, anything else for linear
% Am              = final adjacency matrix
% N               = iniital nodes
% T               = time steps
% newNodesPercent = % new nodes added per time step
%
% Author: Jess
% Created: 2018.07.19
%===================================================

fDist = degreeFrequencyDistribution(Am);

if (plotStyle == 1)
    loglog(fDist(:,1),fDist(:,2));
    xlabel('Log Degree');
    ylabel('Log Frequency');
else
    plot(fDist(:,1),fDist(:,2));
    xlabel('Degree');
    ylabel('Frequency');
end;

text = sprintf('Frequency Distribution - Logistic: SN = %u, FN = %u, T = %u, New Nodes = %.1f Percent', N, size(Am,1), T, NewNodesPercent*100);
title(text);
legend('Simulated');

end


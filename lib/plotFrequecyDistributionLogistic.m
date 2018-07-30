function [fDist] = plotFrequecyDistributionLogistic(Am, plotStyle, T, N, NewNodesPercent)
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
    xlabel('Log Degree');
    ylabel('Log Frequency');
else
    plot(fDist(:,1),fDist(:,2));
    xlabel('Degree');
    ylabel('Frequency');
end;

text = sprintf('Frequency Distribution - Logistic Model: T = %d, N = %d, New Nodes = %.1f Percent', T, N, NewNodesPercent*100);
title(text);
legend('Simulated');

end


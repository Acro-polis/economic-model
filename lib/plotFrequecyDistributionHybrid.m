function [fDistSim, fDistMF] = plotFrequecyDistributionHybrid(AM, N, T, alpha, plotStyle)
%===================================================
%
% Plot the frequency distribution for the matrix Am
% and the corresponding mean-field approximation
%
% plotStyle = 1 for loglog, anything else for linear
% Am        = final adjacency matrix
% N         = iniital nodes
% T         = time steps
% alpha     = proportion of random vs preferred
%
% Author: Jess
% Created: 2018.07.19
%===================================================

fDistSim = degreeFrequencyDistribution(AM);
fDistMF = degreeFrequencyDistributionRandomHybrid(N, alpha, max(fDistSim(N:end,1)));

if (plotStyle == 1)
    figureHandle = loglog(fDistSim(N:end,1),fDistSim(N:end,2),fDistSim(N:end,1),fDistMF);
    xlabel('Log Degree');
    ylabel('Log Frequency');
else
    figureHandle = plot(fDistSim(N:end,1),fDistSim(N:end,2),fDistSim(N:end,1),fDistMF)
    xlabel('Degree');
    ylabel('Frequency');
end

text = sprintf('Frequency Distribution - Hybrd: SN = %u, EN = %u, T = %u, a = %.2f', N, size(AM,1), T, alpha);
title(text);
legend('Simulated','Mean-field');

end



function [fDistSim, fDistMF] = plotFrequecyDistributionHybrid(Am, N, T, alpha, plotStyle)
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

fDistSim = degreeFrequencyDistribution(Am);
fDistMF = degreeFrequencyDistributionRandomHybrid(N, alpha, max(fDistSim(N:end,1)));

if (plotStyle == 1)
    loglog(fDistSim(N:end,1),fDistSim(N:end,2),fDistSim(N:end,1),fDistMF);
    xlabel('Log Degree');
    ylabel('Log Frequency');
else
    plot(fDistSim(N:end,1),fDistSim(N:end,2),fDistSim(N:end,1),fDistMF)
    xlabel('Degree');
    ylabel('Frequency');
end

text = sprintf('Frequency Distribution - Hybrd: SN = %u, FN = %u, T = %u, a = %.2f', N, size(Am,1), T, alpha);
title(text);
legend('Simulated','Mean-field');

end



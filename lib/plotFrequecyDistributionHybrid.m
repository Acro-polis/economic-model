function [fDistSim, fDistMF] = plotFrequecyDistributionHybrid(AM, N, T, alpha, plotStyle, outputSubfolderPath)
%===================================================
%
% Plot the frequency distribution for the matrix Am along with the 
% corresponding mean-field approximation
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

outputFilePathAndName = sprintf("%s%s", outputSubfolderPath, "degree distribution.fig");
f = figure;

if (plotStyle == 1)
    loglog(fDistSim(N:end,1),fDistSim(N:end,2),fDistSim(N:end,1),fDistMF);
    xlabel('Log Degree');
    ylabel('Log Frequency');
else
    plot(fDistSim(N:end,1),fDistSim(N:end,2),fDistSim(N:end,1),fDistMF);
    xlabel('Degree');
    ylabel('Frequency');
end

text = sprintf('Frequency Distribution: SN = %u, EN = %u, T = %u, a = %.2f', N, size(AM,1), T, alpha);
title(text);
legend('Simulated','Mean-field');

saveas(f, outputFilePathAndName, 'fig');

end



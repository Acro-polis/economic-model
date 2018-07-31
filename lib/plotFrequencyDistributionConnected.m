function [fDist] = plotFrequencyDistributionConnected(Am, plotStyle)
%===================================================
%
% Plot the frequency distribution for the matrix Am
%
% plotStyle       = 1 for loglog, anything else for linear
% Am              = final adjacency matrix
%
% Author: Jess
% Created: 2018.07.31
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

text = sprintf('Frequency Distribution - Connected: N = %u,',size(Am,1));
title(text);
legend('Simulated');

end


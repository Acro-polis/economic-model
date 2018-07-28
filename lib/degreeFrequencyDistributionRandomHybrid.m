function [fd] = degreeFrequencyDistributionRandomHybrid(N,alpha,maxD)
%===================================================
%
% For the vector D, return fd the degree frequency distribution
% of the mean-field equivallent of the hybrid-random model
%
% The mean-field equivallent cumulative degree frequency 
% distribution of the hybrid-random model is:
%
% let A = (2 * alpha * N) / (1 - alpha) &
%     C = 2 / (1 - alpha)
%
% F(d) = 1 - ((N + A) / (d + A))^C
% 
% and the corresponding frequency distribution is
%
% f(d) = (C * (N + A) * ((N + A) / (d + A))^(C-1))/ (d + A)^2
%
% Where N     = Number of initial nodes / degress of the model
%       alpha = Proportion of random connections vs preferred connections [0,1]
%       maxD  = max dimendion d for which to calculate f(d)
%
% Author: Jess
% Created: 2018.07.27
%===================================================

D = N:maxD;
fd = size(D);

A = (2 * alpha * N) / (1 - alpha);
C = 2 / (1 - alpha);

fd = (C * (N + A) * ((N + A) ./ (D + A)).^(C - 1)) ./ (D + A).^2;

end


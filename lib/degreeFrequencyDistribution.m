function [fDist] = degreeFrequencyDistribtion(Am)
%===================================================
%
% Return the normalized frequency distribution for 
% degree in a table using the tabulate function
%
% Author: Jess
% Created: 2018.07.19
%===================================================

D = sum(Am);
fDist = tabulate(D);
n = sum(fDist(:,2));
fDist(:,2) = fDist(:,2) ./ n;

end
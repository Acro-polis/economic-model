function [index] = identifyPreferredNode(Am)
%===================================================
%
% Randomly identify a node with probabilities proportional
% to their degrees. This is the preferential attachment
% model.
%
% TODO - Add more explaination
%
% Author: Jess
% Created: 2018.07.19
%===================================================

D = sum(Am);
d = sum(D);
P = cumsum(D ./ d);
r = unifrnd(0,1);
index = find([-1 P] < r, 1, 'last');

end


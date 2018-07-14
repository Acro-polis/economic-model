%========================================
%
% For a given x return f(x) for the 
% logistic function as defined below
%
% Author: Jess
% Created: 2018.07.13
%========================================
function [fx] = logisticFunction (x)

% With these paramenters f(0) = 6 and f(11) = 19

  a = 25;
  b = 1;
  c = 0.75;
  d = 4;
  
  fx = (a / (1 + b*exp(-c*x))) - a / d;
  
end
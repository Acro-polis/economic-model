%==============================%% Test logisticFunction%% Author: Jess% Created: 2018.07.13%==============================  s = -10;  for i = 1:20    x = s + (i-1);    fx = logisticFunction(x);    fprintf('f(%d) = %f\n',x,fx);  end;
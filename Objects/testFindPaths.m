%=====================================================
%
% Test Find Paths
%
%
% Author: Jess
% Created: 2018.11.5
%=====================================================

birthday = 1;
agent1 = Agent(1,birthday);

AM = connectedGraph(5);

% A1 knows only A2
AM(1,3) = 0;
AM(3,1) = 0;
AM(1,4) = 0;
AM(4,1) = 0;
AM(1,5) = 0;
AM(5,1) = 0;

% A2 knows A1 & A3
AM(2,4) = 0;
AM(4,2) = 0;
AM(2,5) = 0;
AM(5,2) = 0;

% A3 knows A2, A4 & A5
% Done

% A4 knows A3 & A4
% Done

% A5 knows A3 & A4
% Done

% expecting 
% 1 2 3 5
% 1 2 3 4 5

output = agent1.findAllPaths(AM);

output = output{:};
[row, col] = size(output);
fprintf("\nOutput is a (%d,%d) cell matrix\n",row,col);
for i = 1:row
    fprintf("\nrow = %d\n",i);
    column = cell2mat(output(i,1));
    [~, col] = size(column);
    for j = 1:col
        fprintf("col=%d ",column(1,j));
    end
    fprintf("\n");
end

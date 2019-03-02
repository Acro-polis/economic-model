%=====================================================
%
%
% Author: Jess
% Created: 2018.10.16
%=====================================================
addpath lib

fileName = 'inputFile_Hybrid.txt';
fileId = fopen(fullfile([pwd '/Network Generation Models'],fileName),"w");

fprintf(fileId,'\nRandom Network Generation Input Parameters\n\n');

fprintf(fileId,'1)  Number Of Inital Nodes: %d\n',5);
fprintf(fileId,'2)  Number Of Generation Steps: %d\n',25);
fprintf(fileId,'3)  Number Of New Nodes Per Step: %d\n',5);
fprintf(fileId,'4)  Alpha (0 = Preferred, 1 = Random): %.1f\n',0.5);

fclose(fileId);

% Testing

fileId = fopen(fileName, "r");

%
% Header
% 
for i = 1:3
    fgetl(fileId);
end

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,1);
fprintf('%s\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

fclose(fileId);
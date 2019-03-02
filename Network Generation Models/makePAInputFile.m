%=====================================================
%
% Create an input file for use by the 
% generatePreferrentialAttachmentNetwork algorithm
%
% Author: Jess
% Created: 2019.03.02
%=====================================================
addpath lib

fileName = 'inputFile_PA.txt';
fileId = fopen(fullfile([pwd '/Network Generation Models'],fileName),"w");

fprintf(fileId,'\nPreferrential Attachment Network Generation Input Parameters\n\n');

fprintf(fileId,'1)  # Of Inital Nodes: %d\n',5);
fprintf(fileId,'2)  # Of Generation Steps: %d\n',25);
fprintf(fileId,'3)  # Of New Nodes Per Step: %d\n',5);
fprintf(fileId,'4)  # Of New Node Attachments: %d\n',3);
fprintf(fileId,'5)  Percentage Of Existing Nodes To Add Attachments Per Step: %.2f\n',0.10);
fprintf(fileId,'6)  # Of Existing Node Attachments Per Step: %d\n',2);

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
fprintf('%d\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%d\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%d\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%d\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%.2f\n',inputValue);

line = fgetl(fileId);
inputValue = parseInputString(line,0);
fprintf('%d\n',inputValue);

fclose(fileId);
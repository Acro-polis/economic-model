%===================================================
%
% Batch Run Commerce Model
%
% Author: Jess
% Created: 2018.12.21
%===================================================

clear;

numberRuns = 2;

fileNames = ["" ; ""];
fileNames(1) = "inputCommerce_1.txt";
fileNames(2) = "inputCommerce_2.txt";

%TODO - implement parfor
for i = 1:numberRuns
    inputFileName = fileNames(i);
    model_commerce;
end


% job = batch('run_commerce','Pool',1);
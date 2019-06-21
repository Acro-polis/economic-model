%===================================================
%
% Batch Run Commerce Model
%
% Author: Jess
% Created: 2018.12.21
%===================================================

clear;

numberRuns = 3;

fileNames = ["" ; "" ; ""];
fileNames(1) = "InputCommerce_1.txt";
fileNames(2) = "InputCommerce_2.txt";
fileNames(3) = "InputCommerce_3.txt";

%TODO - implement parfor
for i = 1:numberRuns
    inputFilename = fileNames(i);
    model_commerce_v1_4;
end


% job = batch('run_commerce','Pool',1);
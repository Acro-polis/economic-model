%===================================================
%
% Batch Run Commerce Model
%
% Author: Jess
% Created: 2018.12.21
%===================================================

clear;

numberRuns = 1;

fileNames = ["" ; "" ; ""; ""];
fileNames(1) = "InputCommerce_1.txt";
fileNames(2) = "InputCommerce_2.txt";
fileNames(3) = "InputCommerce_3.txt";
fileNames(4) = "InputCommerce_4.txt";

%TODO - implement parfor
for i = 1:numberRuns
    inputFilename = fileNames(i);
    model_commerce_v1_4;
end

% addpath(genpath('/Users/jess/git/economic-model')) % Add path and
% subfolders
% job = batch('run_commerce','Pool',1);
function [inputValue] = parseInputString(inputString)
%================================================================
% Function parseInputString
%
% Returns a single double value for a parameter read after the delimeter
%
% Created by Jess 16.10.18
%================================================================    

delimeter = ':';
delimeterPosition = strfind(inputString, delimeter);
assert(~isempty(delimeterPosition),'Error: Delimeter %s not found in string \"%s\"!', delimeter, inputString);
inputValue = str2double(cell2mat(extractBetween(inputString,delimeterPosition+1,strlength(inputString))));

end


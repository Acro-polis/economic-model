function [inputValue] = parseInputString(inputString, inputType)
%================================================================
% Function parseInputString
%
% Returns a value for a parameter read after the delimeter
% if inputType = 0, return a double
% if inputType <> 0, return a string
%
% Created by Jess 16.10.18
%================================================================    
    delimeter = ':';
    delimeterPosition = strfind(inputString, delimeter);
    assert(~isempty(delimeterPosition),'Error: Delimeter %s not found in string \"%s\"!', delimeter, inputString);
    if inputType == 0
        inputValue = str2double(cell2mat(extractBetween(inputString,delimeterPosition+1,strlength(inputString))));
    else
        inputValue = cell2mat(extractBetween(inputString,delimeterPosition+1,strlength(inputString)));
    end
end


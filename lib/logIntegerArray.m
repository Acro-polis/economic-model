function logIntegerArray(text, theArray, logLevel, LoggingLevel)
%========================================
%
% Log an array on one line of text
%
% Author: Jess
% Created: 2018.11.07
%========================================

    if logLevel <= LoggingLevel
        fprintf("\n%s = [",text);
        fprintf("% d ",theArray);
        fprintf("]\n");
    end

end


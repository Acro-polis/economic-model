function logStatement(format, variables, logLevel, LoggingLevel)
%=====================================================
%
% If the logLevel is less than the loggingLevel print the statement. 
%
% Author: Jess
% Created: 2018.12.7
%=====================================================
    if logLevel <= LoggingLevel
        fprintf(format,variables);
    end
end


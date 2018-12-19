function logStatement(format, variables, logLevel, LoggingLevel)
% If the logLevel is less than the loggingLevel print the statement. 
    if logLevel <= LoggingLevel
        fprintf(format,variables);
    end
end


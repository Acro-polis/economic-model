classdef Polis < handle
%================================================================
% Class Polis
%
% Created by Jess 10.26.18
%================================================================

    properties (Constant)
        PolisId = 999 
        PercentDemurage = 0.05
    end
    
    methods (Static)
        function uid = uniqueId()
            %TODO - return a unique number
            uid = 100;
        end
    end
end



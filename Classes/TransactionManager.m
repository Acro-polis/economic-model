classdef TransactionManager < handle
    %TRANSACTIONMANAGER Facilitates a transaction between two agents
    %   TBD
    
    properties (SetAccess = private)
        polis   Polis
    end
    
    methods (Access = public)
        
        function obj = TransactionManager(polis)
            %TRANSACTIONMANAGER Construct an instance of this class
            %   TBD
            obj.polis = polis;
        end
        
    end
end


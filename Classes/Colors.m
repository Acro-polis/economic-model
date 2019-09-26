classdef Colors
    % Some Custom colors for plotting
 
    properties
        gold
        orange
        red
        violet
        blue
        green
    end
    
    methods
        function obj = Colors()
            obj.gold   = [255.0/255.0, 171.0/255.0,  23.0/255.0];
            obj.orange = [232.0/255.0,  85.0/255.0,  12.0/255.0];
            obj.red    = [255.0/255.0,   0.0/255.0,   0.0/255.0];
            obj.violet = [215.0/255.0,  12.0/255.0, 232.0/255.0];
            obj.blue   = [ 86.0/255.0,  13.0/255.0, 255.0/255,0];
            obj.green  = [  4.0/255.0, 255.0/255.0,   0.0/255,0];            
        end        
    end
    
end


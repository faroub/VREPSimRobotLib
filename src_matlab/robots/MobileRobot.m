classdef MobileRobot < handle
    %   MobileRobot: base class for mobile robots
    %
    %   A MobileRobot object holds all information related to 
    %   a mobile robot kinematics and dynamics parameters
    
    properties (Access = public)


        
        
    end
    
    properties (Access = protected)
       
       
       pos % state pose vector : pos = [x y theta]
       
       dpos % delta state pose vector :  dpos = [dx dy dtheta]
        
    end
    
    properties (Access = private)


        
    end
    
    methods  (Access = public)
        
        function obj = MobileRobot()
            

            if nargin == 0
                
                obj.pos = [0 0 0];
                obj.dpos = [0 0 0];
   
            elseif nargin == 1
                
                obj.dpos = [0 0 0];
                
            end
            
%             obj.pos = pos;
%             obj.dpos = dpos;
            
        end

    end
    methods (Access = protected)
        
    end
    methods (Access = private)
        
    end
    
end


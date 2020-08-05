classdef MobileRobot < handle
    %   MobileRobot: base class for mobile robots
    %
    %   A MobileRobot object holds all information related to 
    %   a mobile robot kinematics and dynamics parameters
    
    properties (Access = public)


        
        
    end
    
    properties (Access = protected)
       
       
       x = 0; % x position in global frame [m]
       y = 0; % x position in global frame [m]
       theta = 0;  % heading direction in global frame [rad]       
        
    end
    
    properties (Access = private)


        
    end
    
    methods  (Access = public)
        
        function obj = MobileRobot(robotPose)
            

            if nargin == 0
                
                obj.x = 0;
                obj.y = 0;
                obj.theta = 0;
                
   
            else
                
                obj.x = robotPose(1);
                obj.y = robotPose(2);
                obj.theta = robotPose(3);
                
            end
            
 
            
        end
        
        function out=updatePose(obj,dx,dy,dtheta)
            
            obj.x = obj.x + dx;
            obj.y = obj.y + dy;
            obj.theta = obj.theta + dtheta;   
            out = [obj.x obj.y obj.theta]
        
        end
        

    end
    methods (Access = protected)
        
    end
    methods (Access = private)
        
    end
    
end


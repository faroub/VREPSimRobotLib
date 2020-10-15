classdef DifferentialDrive  < handle
    %   DifferentialMobileRobot: abstract base class for differential robots
    %
    %   A DifferentialMobileRobot object holds all information related to 
    %   a differential mobile robot kinematics and dynamics parameters
    
    properties (Constant)
        
        rad2deg = 180/pi; % conversion radian to degrees
        deg2rad = pi/180; % conversion degrees to radian 

      
    
    end
           
    methods  (Abstract)
     
        move(obj,v,omega) % move robot
        
    end
    
    methods (Access = protected)
                       
        function out = computeForwardKinematics(obj,robotOrient,robotVelocityEgo)

            out = rotz(robotOrient*obj.rad2deg)*robotVelocityEgo;
        
        end
        
        
        function out = computeInverseKinematics(obj,robotOrient,robotVelocityAllo)
            
            out = rotz(robotOrient*obj.rad2deg)\robotVelocityAllo;
        
        end
        
       
        function out = updateRobotState(~,robotState,robotVelocityAllo,stepTime)
            
            out(1) = robotState(1) + robotVelocityAllo(1)*stepTime;
            out(2) = robotState(2) + robotVelocityAllo(2)*stepTime;
            out(3) = robotState(3) + robotVelocityAllo(3)*stepTime;
                   
        end
                                 
    end
    
end


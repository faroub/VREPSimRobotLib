classdef DifferentialDrive  < MobileRobot
    %   DifferentialMobileRobot: abstract base class for differential robots
    %
    %   A DifferentialMobileRobot object holds all information related to 
    %   a differential mobile robot kinematics and dynamics parameters
    
    properties (Constant)
        
        rad2deg = 180/pi; % conversion radian to degrees
        deg2rad = pi/180; % conversion degrees to radian 

      
    
    end
    
   
    properties (Access = protected)
  

        
    end
    
    properties (Access = private)


        robotState % robot state     
        robotVelocityEgo % robot velocity in egocentric frame 
        robotVelocityAllo % robot velocity in allocentric frame 
        stepTime % step time [s]
       
        

        
    end
    

    methods  (Access = public)
     

    end
    
    methods (Access = protected)
        
        function setRobotVelocityEgo(obj,robotVelocityEgo)
            
            obj.robotVelocityEgo = robotVelocityEgo;
        
        end
        
        function out=getRobotVelocityEgo(obj)
            
            out=obj.robotVelocityEgo;
        
        end
        function setRobotVelocityAllo(obj,robotVelocityAllo)
            
            obj.robotVelocityAllo = robotVelocityAllo;
        
        end
        
        function out=getRobotVelocityAllo(obj)
            
            out=obj.robotVelocityAllo;
        
        end
       
        function computeForwardKinematics(obj)
            
            obj.robotVelocityAllo = rotz(obj.robotState(3)*obj.rad2deg)*obj.robotVelocityEgo;
        
        end
        
        function computeInverseKinematics(obj)
            
            obj.robotVelocityEgo = rotz(obj.robotState(3)*obj.rad2deg)\obj.robotVelocityAllo;
        
        end
        
        function updateRobotState(obj)
            
            obj.robotState(1) = obj.robotState(1) + obj.robotVelocityAllo(1)*obj.stepTime;
            obj.robotState(2) = obj.robotState(2) + obj.robotVelocityAllo(2)*obj.stepTime;
            obj.robotState(3) = obj.robotState(3) + obj.robotVelocityAllo(3)*obj.stepTime;
                   
        end
        
        function out=getRobotState(obj)
            
            out = obj.robotState;
                   
        end
        
        function setRobotState(obj,robotState)
            
            obj.robotState = robotState;
                   
        end
        
        function setStepTime(obj,stepTime)
            
            obj.stepTime = stepTime;
                   
        end
        
        
    end
    methods (Access = private)
    end
    
end


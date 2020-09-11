classdef DifferentialMobileRobot  < MobileRobot
    %   DifferentialMobileRobot: abstract base class for differential robots
    %
    %   A DifferentialMobileRobot object holds all information related to 
    %   a differential mobile robot kinematics and dynamics parameters
    

    
   
    properties (Access = protected)
  

        
    end
    
    properties (Access = private)


        robotState = [0;0;0] % robot state     
        stepTime = -1;% step time [s]
        

        
    end
    

    methods  (Access = public)

        function obj = DifferentialMobileRobot(stepTime,robotState)
            
            obj.stepTime = stepTime;
            obj.robotState = robotState;

        end
        



    end
    
    methods (Access = protected)
        
       
        function out=computeForwardKinematics(obj,robotVelocityEgo)
            
            out=rotz(obj.robotState(3))*robotVelocityEgo;
        
        end
        
        function out=computeInverseKinematics(obj,robotVelocityAllo)
            
            out=rotz(obj.robotState(3))\robotVelocityAllo;
        
        end
        
        function out=updateState(obj)
            
            obj.robotState(1) = obj.robotState(1) + *obj.stepTime;
            obj.robotState(2) = obj.robotState(2) + *obj.stepTime;
            obj.robotState(3) = obj.robotState(3) + *obj.stepTime;
            
            out = obj.robotState;
        
        end
        
        
    end
    methods (Access = private)
    end
    
end


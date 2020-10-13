classdef (Abstract) MobileRobot < handle
    %   MobileRobot: abstract base class for mobile robots
    %
    %   A MobileRobot object holds all information related to 
    %   a mobile robot kinematics and dynamics parameters
    
    
    properties (Access = private)      
        
        robotVelocityEgo
        robotVelocityAllo
        robotState 
        
        
    end
    methods  (Access = public)
        
        move(obj,v,omega) % move robot
    
    end
  
    methods  (Access = protected)
        
        frdKin(obj,robotVelocityEgo) % compute forward kinematics
        invKin(obj,robotVelocityAllo) % compute inverse kinematics
    
    end
    
end


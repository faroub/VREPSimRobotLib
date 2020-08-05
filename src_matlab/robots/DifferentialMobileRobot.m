classdef DifferentialMobileRobot  < MobileRobot
    %   DifferentialMobileRobot: base class for differential robots
    %
    %   A DifferentialMobileRobot object holds all information related to 
    %   a differential mobile robot kinematics and dynamics parameters
    
    properties (Access = public)
        

        

        
        
    end
    
    properties (Access = protected)
  
        ds = 0; % overall linear displacement increment [m]
        dtheta = 0; % heading direction increment [rad]
        dx = 0; % delta x position 
        dy = 0; % delta y position
        
    end
    
    properties (Access = private)


        
    end
    
    methods  (Access = public)
        function obj = DifferentialMobileRobot(robotPose)
            
            obj@MobileRobot(robotPose);

            if nargin == 0

   
            else
                
                

                
            end

        end
        
        function out=computeOdometry(obj,ds_l,ds_r)
                    
            obj.ds = (ds_l + ds_r)/2;
            obj.dtheta = (ds_r - ds_l)/obj.l;
            obj.dx = obj.ds * cos(obj.theta+(obj.dtheta/2));
            obj.dy = obj.ds * sin(obj.theta+(obj.dtheta/2));                       
            out = updatePose(obj,obj.dx,obj.dy,obj.dtheta);
            

        end


    end
    
    methods (Access = protected)
    end
    methods (Access = private)
    end
    
end


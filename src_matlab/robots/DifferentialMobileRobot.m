classdef DifferentialMobileRobot  < MobileRobot
    %   DifferentialMobileRobot: base class for differential robots
    %
    %   A DifferentialMobileRobot object holds all information related to 
    %   a differential mobile robot kinematics and dynamics parameters
    
    properties (Access = public)
        

        

        
        
    end
    
    properties (Access = protected)
  
        v_l % left wheel velocity
        v_r % right wheel velocity        
        r_l % radius of left wheel
        r_r % radius of right wheel
        l % distance of each wheel from the center between the two drive wheels
        
    end
    
    properties (Access = private)


        
    end
    
    methods  (Access = public)
        function obj = DifferentialMobileRobot()
            

            if nargin == 0
                
   
            else
                
            end
            obj@MobileRobot();

        end

    end
    methods (Access = protected)
    end
    methods (Access = private)
    end
    
end


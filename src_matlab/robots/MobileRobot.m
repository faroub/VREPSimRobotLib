classdef MobileRobot
    %   MobileRobot: base class for mobile robots
    %
    %   A MobileRobot object holds all information related to 
    %   a mobile robot kinematics and dynamics parameters
    
    properties (Access = public)


        
        
    end
    
    properties (Access = protected)
  
       m_positionX
       m_positionY
       m_orientation
        
    end
    
    properties (Access = private)


        
    end
    
    methods  (Access = public)
        function obj = DifferentialMobileRobot()
            

            if nargin == 0
                
   
            else
                
            end

        end

    end
    methods (Access = protected)
    end
    methods (Access = private)
    end
    
end


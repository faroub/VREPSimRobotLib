classdef DifferentialMobileRobot  < MobileRobot
    %   DifferentialMobileRobot: base class for differential robots
    %
    %   A DifferentialMobileRobot object holds all information related to 
    %   a differential mobile robot kinematics and dynamics parameters
    
    properties (Access = public)
        

        

        
        
    end
    
    properties (Access = protected)
  
        m_leftWheelRadius
        m_rightWheelRadius
        m_wheelDistance
        
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


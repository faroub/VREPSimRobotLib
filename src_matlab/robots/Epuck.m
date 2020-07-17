classdef Epuck
    %   Epuck: is an Epuck simulation object
    %   This class handles the interface to the V-REP simulator and 
    %   low-level object handle operations for the Epuck mobile robot
    %
    %   A Epuck object holds all information related to 
    %   the robot kinematics and dynamics parameters
    
    properties (SetAccess = public)


        
        
    end
    
    properties (SetAccess = protected)
  
        
        
    end
    
    properties (SetAccess = private)
        
        
    end
    
    methods
        function obj = Epuck(vrep)
            

            if nargin == 0
                
   
            else
                
            end
            % using the prototype file (remoteApiProto.m)
            obj.vrep=remApi('remoteApi'); 
        end
        function openConnection()
        end
        
        function closeConnection()
            
            obj.vrep.simxFinish(-1); 
            
        end
    end
    
end


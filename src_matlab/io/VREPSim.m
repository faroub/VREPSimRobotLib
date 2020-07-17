classdef VREPSim
    %   VREPSim: is a communications object with the V-REP simulator 
    %   This class handles the interface to the simulator and 
    %   low-level object handle operations
    %
    %   A VREP object holds all information related to 
    %   the state of a connection to an instance of the 
    %   V-REP simulator running on this or a networked computer. 
    %   It also allows the creation of references to other objects/models 
    %   in V-REP which can be manipulated in MATLAB
    
    properties (SetAccess = public)

        
        
    end
    
    properties (SetAccess = protected)
  
        
        
    end
    
    properties (SetAccess = private)
        vrep
        address_ip
        port_number
        connect_wait
        reconnect
        time_out
        data_cycle
        
        
    end
    
    methods
        function obj = VREPSim(varargin)
            

            if nargin == 0
                
                obj.address_ip = '127.0.0.1';
                obj.port_number = 19999;
                obj.connect_wait = true;
                obj.reconnect = true;
                obj.time_out = 5000;
                obj.data_cycle = 5;

            else
                
            end
            % using the prototype file (remoteApiProto.m)
            obj.vrep = remApi('remoteApi'); 
        end
        function out = openConnection(obj)
            % starts a communication thread with the server (i.e. V-REP)  on port 19999
            out = obj.vrep.simxStart(obj.address_ip,obj.port_number,obj.connect_wait,obj.reconnect,obj.time_out,obj.data_cycle);
        end
        
        function closeConnection(obj)
            
            obj.vrep.simxFinish(-1); 
            
        end
    end
    
end


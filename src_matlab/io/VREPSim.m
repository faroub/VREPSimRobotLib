classdef VREPSim  < handle
    %   VREPSim: is a communications object with the V-REP simulator 
    %   This class handles the interface to the simulator and 
    %   low-level object handle operations
    %
    %   A VREP object holds all information related to 
    %   the state of a connection to an instance of the 
    %   V-REP simulator running on this or a networked computer. 
    %   It also allows the creation of references to other objects/models 
    %   in V-REP which can be manipulated in MATLAB
    
    properties (Access = public)

        m_clientID = -1;
        m_vrep = -1;
        
    end
    
    properties (Access = protected)
  
        
        
    end
    
    properties (Access = private)
        
        
        m_addressIP 
        m_portNumber 
        m_connectWait 
        m_reconnect 
        m_timeOut 
        m_dataCycle 
        
    end

    
    methods  (Access = public)
        
        function obj = VREPSim(varargin)
            
            if nargin == 0
                
                obj.m_addressIP = '127.0.0.1';
                obj.m_portNumber = 19991;
                obj.m_connectWait = true;
                obj.m_reconnect = true;
                obj.m_timeOut = 5000;
                obj.m_dataCycle = 5;

            else
                % parse inputs
            end
            % using the prototype file (remoteApiProto.m)
            obj.m_vrep = remApi('remoteApi'); 
            
        end
        
        function out = openConnection(obj)

            
            obj.m_clientID = obj.m_vrep.simxStart(obj.m_addressIP,obj.m_portNumber,obj.m_connectWait,obj.m_reconnect,obj.m_timeOut,obj.m_dataCycle);           
            out = obj.m_clientID;
            disp('Open communication thread');
            
        end
        
        function closeConnection(obj)
            
            obj.m_vrep.simxFinish(obj.m_clientID); 
            disp('Close communication thread');            
            
        end
        
        function enableSynchronousMode(obj,enable)

            if nargin == 1
                 enable = 1;
            end
            
            if (enable)
                
                obj.m_vrep.simxSynchronous(obj.m_clientID,true);
                disp('Enable synchronous operation mode');
                
            else
                
                obj.m_vrep.simxSynchronous(obj.m_clientID,false);
                disp('Disable synchronous operation mode');

                
            end
            
        end
        
        function startSimulation(obj,operationMode)
             
            if nargin == 1
                 operationMode = 'oneshot';
             end
             
            obj.m_vrep.simxStartSimulation(obj.m_clientID,validateOperationMode(obj,operationMode));
            disp('Start V-REP simulation');
            
        end
        
        function stopSimulation(obj,operationMode)
             
            if nargin == 1
                 operationMode = 'blocking';
             end
             
            obj.m_vrep.simxStopSimulation(obj.m_clientID,validateOperationMode(obj,operationMode));
            disp('Stop V-REP simulation');
            
        end
        
        function pauseSimulation(obj,operationMode)
             
            if nargin == 1
                 operationMode = 'oneshot';
            end
             
            obj.m_vrep.simxPauseSimulation(obj.m_clientID,validateOperationMode(obj,operationMode));
            disp('Pause V-REP simulation');
            
        end
        
        function out = getConnectionID(obj)
           
            out = obj.m_vrep.simxGetConnectionId(obj.m_clientID);
            
        end
      
        function getPinTime(obj)
           
            obj.m_vrep.simxGetPingTime(obj.m_clientID);            
            
        end
        
        function SendSynchronousTrigger(obj)
           
            obj.m_vrep.simxSynchronousTrigger(obj.m_clientID);            
            
        end
       
        function out = validateOperationMode(obj,operationMode)
           
           if (ismember(operationMode,{'oneshot', 'blocking', 'streaming', 'oneshot_split', 'streaming_split', 'discontinue', 'buffer', 'remove'})) 
               
                switch operationMode
                    case 'oneshot'
                        out =  obj.m_vrep.simx_opmode_oneshot;
                    case 'blocking'
                        out =  obj.m_vrep.simx_opmode_blocking;
                    case 'streaming'
                        out =  obj.m_vrep.simx_opmode_streaming;
                    case 'oneshot_split'
                        out =  obj.m_vrep.simx_opmode_oneshot_split;       
                    case 'streaming_split'
                        out =  obj.m_vrep.simx_opmode_streaming_split;        
                    case 'discontinue'
                        out =  obj.m_vrep.simx_opmode_discontinue;  
                    case 'buffer'
                        out =  obj.m_vrep.simx_opmode_buffer;  
                    case 'remove'
                        out =  obj.m_vrep.simx_opmode_remove;                                   
                end
           else
               error ('Argument operationMode must be a member of this set : oneshot, blocking, streaming, oneshot_split, streaming_split, discontinue, buffer, remove')
           end
        end
        
        function delete(obj)
                % make sure that the last command sent out had time to arrive
                getPinTime(obj);
                % stop vrep simulation from Matlab script
                stopSimulation(obj);
                % close all opened connections
                closeConnection(obj);
                disp('VREPSim object deleted');

        end
            
    end
     
    methods (Access = protected)
        
    end
    
    methods (Access = private)
          

    end
end


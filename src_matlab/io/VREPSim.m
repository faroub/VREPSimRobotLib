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
        m_syncMode = -1
        
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
        
        function obj = VREPSim(simParams)
            
            if nargin == 0
                
                disp ('argument <1:simParams> must be provided. Default used: simParams = {''127.0.0.1'', 19997,true,true,5000,5}')
                obj.m_addressIP = '127.0.0.1';
                obj.m_portNumber = 19997;
                obj.m_connectWait = true;
                obj.m_reconnect = true;
                obj.m_timeOut = 5000;
                obj.m_dataCycle = 5;

            else
                obj.m_addressIP = simParams{1};
                obj.m_portNumber = simParams{2};
                obj.m_connectWait = simParams{3};
                obj.m_reconnect = simParams{4};
                obj.m_timeOut = simParams{5};
                obj.m_dataCycle = simParams{6};
            end
            % using the prototype file (remoteApiProto.m)
            obj.m_vrep = remApi('remoteApi'); 
            
        end
        
        function out = openConnection(obj)
            
            if (obj.m_clientID~=-1)
                closeConnection(obj);
            end
            
            obj.m_clientID = obj.m_vrep.simxStart(obj.m_addressIP,obj.m_portNumber,obj.m_connectWait,obj.m_reconnect,obj.m_timeOut,obj.m_dataCycle);           
            out = obj.m_clientID;
            disp('open communication thread');
            
        end
        
        function closeConnection(obj)
            
            obj.m_vrep.simxFinish(obj.m_clientID); 
            disp('close communication thread');            
            
        end
        
        function pauseCommunication(obj,enable)
            if (enable)                
                
                obj.m_vrep.simxPauseCommunication(obj.m_clientID,1);
                
            else
                
                obj.m_vrep.simxPauseCommunication(obj.m_clientID,0);
                
            end
            
        end
        
        function enableSynchronousMode(obj,enable)

            if nargin == 1
                 enable = 1;
            end
            
            if (enable)
                
                obj.m_vrep.simxSynchronous(obj.m_clientID,true);
                disp('enable synchronous operation mode');
                
            else
                
                obj.m_vrep.simxSynchronous(obj.m_clientID,false);
                disp('disable synchronous operation mode');

                
            end
            
        end
        
        function startSimulation(obj,enableSync, operationMode)
             
            
            switch nargin
                case 1
                    enableSync = 1;
                    operationMode = 'oneshot';

                case 2
                    operationMode = 'oneshot';
            end

            
            % enable synchronous mode
            enableSynchronousMode(obj,enableSync);
            if (enableSync)
                obj.m_syncMode = 1;
            else
                obj.m_syncMode = 0;
            end
            
            % start simulation
            obj.m_vrep.simxStartSimulation(obj.m_clientID,validateOperationMode(obj,operationMode));
            disp('start V-REP simulation');
            
        end
        
        function stopSimulation(obj,operationMode)
             
            if nargin == 1
                 operationMode = 'blocking';
             end
             
            obj.m_vrep.simxStopSimulation(obj.m_clientID,validateOperationMode(obj,operationMode));
            disp('stop V-REP simulation');
            
        end
        
        function pauseSimulation(obj,operationMode)
             
            if nargin == 1
                 operationMode = 'oneshot';
            end
             
            obj.m_vrep.simxPauseSimulation(obj.m_clientID,validateOperationMode(obj,operationMode));
            disp('pause V-REP simulation');
            
        end
        
        function out = getConnectionID(obj)
           
            out = obj.m_vrep.simxGetConnectionId(obj.m_clientID);
            
        end
      
        function getPingTime(obj)
           
            obj.m_vrep.simxGetPingTime(obj.m_clientID);            
            
        end
        
        function sendSynchronousTrigger(obj)
           
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
               error ('argument <1:operationMode> must be a member of this set : oneshot, blocking, streaming, oneshot_split, streaming_split, discontinue, buffer, remove')
           end
        end
        
        function delete(obj)
            % make sure that the last command sent out had time to arrive
            getPingTime(obj);    
            % stop vrep simulation
            stopSimulation(obj);   
            % close opened connections
            closeConnection(obj);
            % explicitely call the destructor!
            obj.m_vrep.delete();
            disp('VREPSim object deleted');

        end
            
    end
     
    methods (Access = protected)
        
    end
    
    methods (Access = private)
          

    end
end


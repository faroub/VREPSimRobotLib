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

        clientID = -1;
        vrepObj = -1;
        syncMode = -1;
        error_code
        
    end
    
    properties (Access = protected)
  
        
        
    end
    
    properties (Access = private)
        
     
        addressIP
        portNumber
        connectWait
        reconnect
        timeOut
        dataCycle
        
    end

    
    methods  (Access = public)
        
        function obj = VREPSim(simParams)
            
            if nargin == 0
                
                disp ('argument <1:simParams> must be provided. Default used: simParams = {''127.0.0.1'', 19997,true,true,5000,5}')
                obj.addressIP = '127.0.0.1';
                obj.portNumber = 19997;
                obj.connectWait = true;
                obj.reconnect = true;
                obj.timeOut = 5000;
                obj.dataCycle = 5;

            else
                obj.addressIP = simParams{1};
                obj.portNumber = simParams{2};
                obj.connectWait = simParams{3};
                obj.reconnect = simParams{4};
                obj.timeOut = simParams{5};
                obj.dataCycle = simParams{6};
            end
            % using the prototype file (remoteApiProto.m)
            obj.vrepObj = remApi('remoteApi'); 
            
        end
        
        function out = openConnection(obj)
            
            % close previous connection if exist
            closeConnection(obj);            
            obj.clientID = obj.vrepObj.simxStart(obj.addressIP,obj.portNumber,obj.connectWait,obj.reconnect,obj.timeOut,obj.dataCycle);           
            out = obj.clientID;
            disp('open communication thread');
            
        end
        function closeAllConnections(obj)
            
            obj.vrepObj.simxFinish(-1); 
            disp('close all communication threads');       
        
        end
        
        function closeConnection(obj)
        
            if (obj.clientID~=-1)
                
                obj.vrepObj.simxFinish(obj.clientID); 
                disp('close communication thread');            
                
            else
                
                disp('no communication thread to close'); 
                
            end
            
        end
        
        function pauseCommunication(obj,enable)
            
            if (enable)                
                
                obj.error_code{1,1} = obj.vrepObj.simxPauseCommunication(obj.clientID,1);
                obj.error_code{1,2}='pauseCommunication';
                
            else
                
                obj.error_code{1,1} = obj.vrepObj.simxPauseCommunication(obj.clientID,0);
                obj.error_code{1,2}='pauseCommunication';
                
            end
            
        end
        
        function enableSynchronousMode(obj,enable)

            if nargin == 1
                 enable = 1;
            end
            
            if (enable)
                
                obj.error_code{2,1} = obj.vrepObj.simxSynchronous(obj.clientID,true);
                obj.error_code{2,2} = 'enableSynchronousMode'; 
                disp('enable synchronous operation mode');
                
            else
                
                obj.error_code{2,1} = obj.vrepObj.simxSynchronous(obj.clientID,false);
                obj.error_code{2,2} = 'enableSynchronousMode'; 
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
           
            obj.syncMode = enableSync;
            
            % enable synchronous mode
            enableSynchronousMode(obj,enableSync);
            
            % start simulation
            obj.error_code{3,1} = obj.vrepObj.simxStartSimulation(obj.clientID,validateOperationMode(obj,operationMode));
            obj.error_code{3,2} = 'startSimulation';
            disp('start V-REP simulation');
            
        end
        
        function stopSimulation(obj,operationMode)
             
            if nargin == 1
                 operationMode = 'blocking';
             end
             
            obj.error_code{4,1} = obj.vrepObj.simxStopSimulation(obj.clientID,validateOperationMode(obj,operationMode));
            obj.error_code{4,2} = 'stopSimulation';
            disp('stop V-REP simulation');
            
        end
        
        function pauseSimulation(obj,operationMode)
             
            if nargin == 1
                 operationMode = 'oneshot';
            end
             
            obj.error_code{5,1} = obj.vrepObj.simxPauseSimulation(obj.clientID,validateOperationMode(obj,operationMode));
            obj.error_code{5,2} = 'pauseSimulation';
            disp('pause V-REP simulation');
            
        end
        
        function out = getConnectionID(obj)
           
            out = obj.vrepObj.simxGetConnectionId(obj.clientID);
            
        end
      
        function out = getPingTime(obj)
           
             [obj.error_code{6,1},out] = obj.vrepObj.simxGetPingTime(obj.clientID);
              obj.error_code{6,2} = 'getPingTime';
            
        end
        
        function sendSynchronousTrigger(obj)
           
            obj.error_code{7,1} = obj.vrepObj.simxSynchronousTrigger(obj.clientID);
            obj.error_code{7,2} = 'sendSynchronousTrigger';
            
        end
       
        function out = validateOperationMode(obj,operationMode)
           
           if (ismember(operationMode,{'oneshot', 'blocking', 'streaming', 'oneshot_split', 'streaming_split', 'discontinue', 'buffer', 'remove'})) 
               
                switch operationMode
                    case 'oneshot'
                        out =  obj.vrepObj.simx_opmode_oneshot;
                    case 'blocking'
                        out =  obj.vrepObj.simx_opmode_blocking;
                    case 'streaming'
                        out =  obj.vrepObj.simx_opmode_streaming;
                    case 'oneshot_split'
                        out =  obj.vrepObj.simx_opmode_oneshot_split;       
                    case 'streaming_split'
                        out =  obj.vrepObj.simx_opmode_streaming_split;        
                    case 'discontinue'
                        out =  obj.vrepObj.simx_opmode_discontinue;  
                    case 'buffer'
                        out =  obj.vrepObj.simx_opmode_buffer;  
                    case 'remove'
                        out =  obj.vrepObj.simx_opmode_remove;                                   
                end
           else
               error ('argument <1:operationMode> must be a member of this set : { oneshot, blocking, streaming, oneshot_split, streaming_split, discontinue, buffer, remove }')
           end
        end
        
        
        function out = getJointPosition(obj,objectHandle, operationMode)
            
            switch nargin
                case 1
                    error ('argument <1:objectHandle> is required ') 
                case 2
                    operationMode = 'buffer';
            end
            
            [obj.error_code{8,1},out] = obj.vrepObj.simxGetJointPosition(obj.clientID,objectHandle, validateOperationMode(obj,operationMode));
            obj.error_code{8,2} = 'getJointPosition';
            while (obj.error_code{8,1}~= obj.vrepObj.simx_return_ok)  
                
                [obj.error_code{8,1},out] = obj.vrepObj.simxGetJointPosition(obj.clientID,objectHandle, validateOperationMode(obj,operationMode));

            end
            
        end
        
        function setJointPosition(obj,objectHandle, position, operationMode)
            
            switch nargin
                case 1
                    error ('argument <1:objectHandle> is required ') 
                case 2
                    operationMode = 'oneshot';
            end
            
            obj.error_code{9,1} = obj.vrepObj.simxSetJointPosition(obj.clientID,objectHandle, position, validateOperationMode(obj,operationMode));
            obj.error_code{9,2} = 'setJointPosition';
            
            
        end
        
        function out = setJointTargetPosition(obj,objectHandle, targetPosition, operationMode)
            
            switch nargin
                case 1
                    error ('argument <1:objectHandle> is required ') 
                case 2
                    operationMode = 'oneshot';
            end
            
            obj.error_code{10,1} = obj.vrepObj.simxSetJointTargetPosition(obj.clientID,objectHandle, targetPosition, validateOperationMode(obj,operationMode));
            obj.error_code{10,2} = 'setJointTargetPosition';
            
        end
        
        function setJointTargetVelocity(obj,speed, objectHandle, operationMode)
            
            switch nargin
                case 1
                    
                    error ('arguments <1:speed> and <2:objectHandle> is required ') 
                    
                case 2
                    
                    error ('argument <2:objectHandle> is required ') 

                case 3
                    operationMode = 'oneshot';
            end
        
             obj.error_code{11,1} = obj.vrepObj.simxSetJointTargetVelocity(obj.clientID,objectHandle,speed,validateOperationMode(obj,operationMode));			
             obj.error_code{11,2} = 'setJointTargetVelocity';
            
        end
        
        function out = getObjectHandle(obj,objectName,operationMode)
            
            switch nargin
                case 1
                    error ('argument <1:objectName> is required ') 
                case 2
                    operationMode = 'blocking';
            end
            
            [obj.error_code{12,1} ,out]= obj.vrepObj.simxGetObjectHandle(obj.clientID,objectName,validateOperationMode(obj,operationMode));
            obj.error_code{12,2} = 'setJointTargetVelocity';
            
            while (obj.error_code{12,1}~= obj.vrepObj.simx_return_ok)  
                
                [obj.error_code{12,1},out]= obj.vrepObj.simxGetObjectHandle(obj.clientID,objectName,validateOperationMode(obj,operationMode));

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
            obj.vrepObj.delete();
            disp('VREPSim object deleted');

        end
            
    end
    
    
     
    methods (Access = protected)
        
    end
    
    methods (Access = private)
          

    end
end


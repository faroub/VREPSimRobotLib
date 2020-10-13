classdef VREPSimRobot  < handle
    %   VREPSimRobot: is a communications object with the V-REP simulator 
    %   This class handles the interface to the simulated robot and 
    %   low-level object handle operations
    %
    %   A VREP object holds all information related to 
    %   the state of a connection to an instance of the 
    %   V-REP simulator running on this or a networked computer. 
    %   It also allows the creation of references to other objects/models 
    %   in V-REP which can be manipulated in MATLAB
    
    properties (Access = public)


        
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
        clientID
        vrepObj
        error_code
        
        
    end

    
    methods  (Access = public)
        
        function obj = VREPSimRobot(simParams)
            
            % todo: include the posibility to pass a VREPSimScene object as
            % argument
            % TODO: check if connection already established before
            % attempting it
            % Fixme: Is the area of hemisphere as below?
            switch nargin
                case 0                 
                    error ('argument <1:simParams> must be provided')
                case 1
                
                    obj.addressIP = simParams{1};
                    obj.portNumber = simParams{2};
                    obj.connectWait = simParams{3};
                    obj.reconnect = simParams{4};
                    obj.timeOut = simParams{5};
                    obj.dataCycle = simParams{6};

            end
            
            % using the prototype file (remoteApiProto.m)
            obj.vrepObj = remApi('remoteApi'); 
            

            % open connection 
%             if (Connected(obj))
%                                 
%                 msg = ['VREPSimRobot: already connected to remote API server [',obj.addressIP,num2str( obj.portNumber),']'];
%                 disp(msg)   
% 
%             else
                
                if (openConnection(obj)==-1)
                    error ('VREPSimRobot: connection to remote API server [IP: %s, Port: %d] was not possible', obj.addressIP,obj.portNumber)              
                else
                    msg = ['VREPSimRobot: connection to remote API server [',obj.addressIP,num2str( obj.portNumber),'] established'];
                    disp(msg)   
                end
            
        %end
            
        end
        
        function out = openConnection(obj)
            
        
            obj.clientID = obj.vrepObj.simxStart(obj.addressIP,obj.portNumber,obj.connectWait,obj.reconnect,obj.timeOut,obj.dataCycle);           
            out = obj.clientID;
            
        end
        function closeAllConnections(obj)
            
            obj.vrepObj.simxFinish(-1);    
        
        end
        
        function closeConnection(obj)
        
            if (obj.clientID ~= -1)
                
                obj.vrepObj.simxFinish(obj.clientID); 
                    
            end
            
        end
        function out= Connected(obj)
             if (obj.clientID ~= -1)
                out = 1;
             else
                 out = 0;
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
        
        

        

        
        

      
        function out = getPingTime(obj)
           
             [obj.error_code{6,1},out] = obj.vrepObj.simxGetPingTime(obj.clientID);
              obj.error_code{6,2} = 'getPingTime';
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
            
            switch operationMode                
                case 'buffer'
                     [obj.error_code{8,1},out] = obj.vrepObj.simxGetJointPosition(obj.clientID,objectHandle, validateOperationMode(obj,operationMode));
                     while (obj.error_code{8,1}~=obj.vrepObj.simx_return_ok)                     
                        [obj.error_code{8,1},out] = obj.vrepObj.simxGetJointPosition(obj.clientID,objectHandle, validateOperationMode(obj,operationMode));
                     end                    
                case 'streaming'                    
                     [obj.error_code{8,1},out] = obj.vrepObj.simxGetJointPosition(obj.clientID,objectHandle, validateOperationMode(obj,operationMode));                    
                     while (obj.error_code{8,1}~=obj.vrepObj.simx_return_ok)                     
                        [obj.error_code{8,1},out] = obj.vrepObj.simxGetJointPosition(obj.clientID,objectHandle, validateOperationMode(obj,operationMode));
                     end    
            
            end            

            obj.error_code{8,2} = 'getJointPosition';
           
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
        
        function setJointTargetPosition(obj,objectHandle, targetPosition, operationMode)
            
            switch nargin
                case 1
                    error ('argument <1:objectHandle> is required ') 
                case 2
                    operationMode = 'oneshot';
            end
            
            obj.error_code{10,1} = obj.vrepObj.simxSetJointTargetPosition(obj.clientID,objectHandle, targetPosition, validateOperationMode(obj,operationMode));
            obj.error_code{10,2} = 'setJointTargetPosition';

            
        end
        
        function setJointTargetVelocity(obj,objectHandle,speed,operationMode)
            
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
            obj.error_code{12,2} = 'getObjectHandle';
            
        end
        

        
        function out = getObjectPosition(obj,objectHandle,parentHandle,operationMode)
            
            switch nargin
                case 1
                    error ('argument <1:objectHandle> and <2:parentHandle> is required ') 
                case 2
                     error ('argument <2:parentHandle> is required ') 
                 case 3
                    operationMode = 'buffer';
            end
            
            switch operationMode                
                case 'buffer'
                     [obj.error_code{14,1},out] = obj.vrepObj.simxGetObjectPosition(obj.clientID,objectHandle, parentHandle, validateOperationMode(obj,operationMode));
                     while (obj.error_code{14,1}~=obj.vrepObj.simx_return_ok)                     
                        [obj.error_code{14,1},out] = obj.vrepObj.simxGetObjectPosition(obj.clientID,objectHandle, parentHandle, validateOperationMode(obj,operationMode));
                     end                    
                case 'streaming'                    
                     [obj.error_code{14,1},out] = obj.vrepObj.simxGetObjectPosition(obj.clientID,objectHandle, parentHandle, validateOperationMode(obj,operationMode));                    
                     while (obj.error_code{14,1}~=obj.vrepObj.simx_return_ok)                     
                        [obj.error_code{14,1},out] = obj.vrepObj.simxGetObjectPosition(obj.clientID,objectHandle, parentHandle, validateOperationMode(obj,operationMode));
                     end    
            
            end                         
            obj.error_code{14,2} = 'getObjectPosition';            
            
        end
        
        function setObjectPosition(obj,objectHandle,parentHandle,position,operationMode)
            
            switch nargin
                case 1
                    error ('argument <1:objectHandle> and <2:parentHandle> is required ') 
                case 2
                    error ('argument <2:parentHandle> is required ') 
                case 3
                    position = [0 0 0];
                    operationMode = 'oneshot';
            end
            
            
            [obj.error_code{15,1}]= obj.vrepObj.simxSetObjectPosition(obj.clientID,objectHandle,parentHandle,position,validateOperationMode(obj,operationMode));
            obj.error_code{15,2} = 'setObjectPosition';


        end
        
        function setObjectOrientation(obj,objectHandle,parentHandle,eulerAngles,operationMode)
            switch nargin
                case 1
                    error ('argument <1:objectHandle> and <2:parentHandle> is required ') 
                case 2
                    error ('argument <2:parentHandle> is required ') 
                case 3
                    eulerAngles = [0 0 0];
                    operationMode = 'oneshot';
            end
            
            
            [obj.error_code{16,1}]= obj.vrepObj.simxSetObjectPosition(obj.clientID,objectHandle,parentHandle,eulerAngles,validateOperationMode(obj,operationMode));
            obj.error_code{16,2} = 'setObjectOrientation';
        
        end

        function out = getObjectOrientation(obj,objectHandle,parentHandle,operationMode)
            
            switch nargin
                case 1
                    error ('argument <1:objectHandle> and <2:parentHandle> is required ') 
                case 2
                     error ('argument <2:parentHandle> is required ') 
                 case 3
                    operationMode = 'buffer';
            end
            
            switch operationMode                
                case 'buffer'
                     [obj.error_code{17,1},out] = obj.vrepObj.simxGetObjectOrientation(obj.clientID,objectHandle, parentHandle, validateOperationMode(obj,operationMode));
                     while (obj.error_code{17,1}~=obj.vrepObj.simx_return_ok)                     
                        [obj.error_code{17,1},out] = obj.vrepObj.simxGetObjectOrientation(obj.clientID,objectHandle, parentHandle, validateOperationMode(obj,operationMode));
                     end                    
                case 'streaming'                    
                     [obj.error_code{17,1},out] = obj.vrepObj.simxGetObjectOrientation(obj.clientID,objectHandle, parentHandle, validateOperationMode(obj,operationMode));                    
                     while (obj.error_code{17,1}~=obj.vrepObj.simx_return_ok)                     
                        [obj.error_code{17,1},out] = obj.vrepObj.simxGetObjectOrientation(obj.clientID,objectHandle, parentHandle, validateOperationMode(obj,operationMode));
                     end    
            
            end                         
            obj.error_code{17,2} = 'getObjectOrientation';            
            
        end
        
        
        function out=getSimulationTimeStep(obj,operationMode)
            
            if nargin == 1
                operationMode = 'blocking';
            end
            
            
            [obj.error_code{18,1},out]= obj.vrepObj.simxGetFloatingParameter(obj.clientID,obj.vrepObj.sim_floatparam_simulation_time_step,validateOperationMode(obj,operationMode));
            obj.error_code{18,2} = 'getSimulationTimeStep';


        end
        
        function delete(obj)
            % make sure that the last command sent out had time to arrive
            getPingTime(obj);    
            % close opened connection
            closeConnection(obj);
            % explicitely call the destructor!
            obj.vrepObj.delete();
            disp('VREPSimRobot object deleted');

        end
            
    end
    
    
     
    methods (Access = protected)
        
    end
    
    methods (Access = private)
          

    end
end


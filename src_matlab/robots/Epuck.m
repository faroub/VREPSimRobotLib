classdef Epuck < DifferentialMobileRobot
    %   Epuck: is an Epuck simulation object
    %   This class handles the interface to the V-REP simulator and 
    %   low-level object handle operations for the Epuck mobile robot
    %
    %   A Epuck object holds all information related to 
    %   the robot kinematics and dynamics parameters
    
    properties (Access = public)


        
        
    end
    
    properties (Access = protected)
  
        
        
    end
    
    properties (Access = private)

        m_vrepSim = -1;
        m_vrep = -1;
        m_clientID = -1;
        m_leftJointHandle = -1;
        m_rightJointHandle = -1;
        
    end
    
    methods  (Access = public)
        function obj = Epuck(vrep, robotName, operationMode)            

            if nargin == 0

                error ('Epuck object needs a VREPSim object to communicate with the V-REP simulator ')              
   
            else
                obj.m_vrepSim = vrep;
                obj.m_vrep = obj.m_vrepSim.m_vrep;
                obj.m_clientID = obj.m_vrepSim.m_clientID;
            end
            
            % Epuck Kinematics parameters
            m_leftWheelRadius = 0.021; % m 
            m_rightWheelRadius = 0.021; % m 
            m_wheelDistance = 0.053; % m
            
            % get joint handles
            obj.m_leftJointHandle = getJointHandle(obj, 'ePuck_leftJoint', 'blocking')
            obj.m_rightJointHandle = getJointHandle(obj, 'ePuck_rightJoint', 'blocking')
            
            
        end
        
        
        function out = getJointHandle(obj, objectName,operationMode)
            switch nargin
                case 1
                    error ('Argument objectName is required ') 
                case 2
                    operationMode = 'blocking';
            end
            
            [err_code,out]= obj.m_vrep.simxGetObjectHandle(obj.m_clientID,objectName,validateOperationMode(obj.m_vrepSim,operationMode));
            
            while (err_code~= obj.m_vrep.simx_return_ok)  
                
                [err_code,out]= obj.m_vrep.simxGetObjectHandle(obj.m_clientID,objectName,validateOperationMode(obj.m_vrepSim,operationMode));

            end 
        end
        
        
        function out = getJointPosition(obj, objectHandle, operationMode)
            switch nargin
                case 1
                    error ('Argument objectHandle is required ') 
                case 2
                    operationMode = 'buffer';
            end
            
            [err_code,out] = obj.m_vrep.simxGetJointPosition(obj.m_clientID,objectHandle, validateOperationMode(obj.m_vrepSim,operationMode));
            
            while (err_code~= obj.m_vrep.simx_return_ok)  
                
                [err_code,out] = obj.m_vrep.simxGetJointPosition(obj.m_clientID,objectHandle, validateOperationMode(obj.m_vrepSim,operationMode));

            end
            
        end
        

        function move(obj, speed, operationMode)
            switch nargin
                case 1
                    speed = 0;
                    operationMode = 'oneshot';
                case 2
                    operationMode = 'oneshot';
            end
            obj.m_vrep.simxPauseCommunication(obj.m_clientID,1);
            setJointSpeed(obj, speed, obj.m_leftJointHandle, operationMode);
            setJointSpeed(obj, speed, obj.m_rightJointHandle, operationMode);
            obj.m_vrep.simxPauseCommunication(obj.m_clientID,0);
        end


    end
    
    methods  (Access = protected)
        
    end
    
    methods  (Access = private)
        
        function setJointSpeed(obj, speed, objectHandle, operationMode)
            
            switch nargin
                case 1
                    
                    error ('Argument objectHandle is required ') 
                    
                case 2
                    
                    error ('Argument objectHandle is required ') 

                case 3
                    operationMode = 'oneshot';
            end
        
            obj.m_vrep.simxSetJointTargetVelocity(obj.m_clientID,objectHandle,speed,validateOperationMode(obj.m_vrepSim,operationMode));			
            
        end

    end
    
end


classdef ePuck < DifferentialDrive
    %   Epuck: is an Epuck simulation object
    %   This class handles the interface to the V-REP simulator and 
    %   low-level object handle operations for the Epuck mobile robot
    %
    %   A Epuck object holds all information related to 
    %   the robot kinematics and dynamics parameters
    
    properties (Constant)
        
        wheelRadius = 0.021; % wheel radius [m]        
        wheelsDistance = 0.053; % distance between wheels [m]
      
    
    end
    
    
    properties (Access = private)
        
        % ------ simulation parameters
        stepTime % step time [s]
        vrepObj % V_REP simulation object 
        
        % ------ VREP parameters
        robotHandle % robot handle
        jointHandle % joints handles
        cameraHandle % camera handle
        lightSensorHandle % light sensor handle
        ledLightHandle % led light handle
        speakerHandle % speaker handle
        proximitySensorHandle % proximity sensors handles
        
        % -------internal variables
        jointPositionNew % current joint position [rad]       
        jointPositionOld % previous joint position [rad]        
        deltaDistanceNew % current delta distance [m]        
        deltaDistanceOld % previous delta distance [m]
        robotState % robot state  [x;y;phi] 
                                                      
    end
    
    methods  (Access = public)
        function obj = ePuck(vrepObj, epuckParams,robotState)            
                     
            switch nargin
                case 0
                    error ('argument <1:vrepSimObj> is required to communicate with the V-REP simulator ')              
                case 1
                    error ('argument <2:epuckParams> is required')
                case 2
                    % get V_REP simulation object
                    obj.vrepSimObj = vrepObj;
                    % get robot handle
                    obj.robotHandle = getObjectHandle(obj.vrepObj,epuckParams.ePuck.name.Text,'blocking');
                    % get robot position
                    robotPos = getObjectPosition(obj.vrepObj,obj.robotHandle,-1, 'streaming');
                    % get robot orientation
                    robotOrient = getObjectOrientation(obj.vrepObj,obj.robotHandle,-1,'streaming');                    
                   % get robot state
                   obj.robotState = [robotPos(1);robotPos(2);robotOrient(3)];
 
                    
                case 3
                    % get V_REP simulation object
                    obj.vrepObj = vrepObj;
            end
                                       
           % get robot handle
           obj.robotHandle = getObjectHandle(obj.vrepObj,epuckParams.ePuck.name.Text,'blocking');
           
            % get robot position
            getObjectPosition(obj.vrepObj,obj.robotHandle,-1, 'streaming');
            
            % get robot orientation
            getObjectOrientation(obj.vrepObj,obj.robotHandle,-1,'streaming');   
           
            % get joints handles
            obj.jointHandle(1) = getObjectHandle(obj.vrepObj,epuckParams.ePuck.leftJoint.Text,'blocking');
            obj.jointHandle(2) = getObjectHandle(obj.vrepObj,epuckParams.ePuck.rightJoint.Text,'blocking');
            
            % get camera handle 
            cameraHandle = getObjectHandle(obj.vrepObj,epuckParams.ePuck.camera.Text,'blocking');
            
            % get light sensor handle 
            lightSensorHandle = getObjectHandle(obj.vrepObj,epuckParams.ePuck.lightSensor.Text,'blocking');            
            
            % get led light handle 
            ledLightHandle = getObjectHandle(obj.vrepObj,epuckParams.ePuck.ledLight.Text,'blocking');
            
            % get speaker handle 
            speakerHandle = getObjectHandle(obj.vrepObj,epuckParams.ePuck.speaker.Text,'blocking');
                                    
            % get proximity sensors handles
            for i = 1:length(epuckParams.ePuck.proxSensor)
                proximitySensorHandle(i) = getObjectHandle(obj.vrepObj,epuckParams.ePuck.proxSensor{i}.Text,'blocking');
            end
                                   
            % set initial joints position
            setJointPosition(obj.vrepObj,obj.jointHandle(1), 0, 'blocking');
            setJointPosition(obj.vrepObj,obj.jointHandle(2), 0, 'blocking');
            
            % set initial joint velocity
            setJointTargetVelocity(obj.vrepObj,obj.jointHandle(1),0,'blocking');
            setJointTargetVelocity(obj.vrepObj,obj.jointHandle(2),0,'blocking');            
                                    
            % get initial joints positions
            obj.jointPositionOld(1) = getJointPosition(obj.vrepObj,obj.jointHandle(1), 'streaming');       
            obj.jointPositionOld(2)  = getJointPosition(obj.vrepObj,obj.jointHandle(2), 'streaming');
            
            % get initial delta distance
            obj.deltaDistanceOld(1) = getJointPosition(obj.vrepObj,obj.jointHandle(1),'streaming')*obj.wheelRadius;
            obj.deltaDistanceOld(2) = getJointPosition(obj.vrepObj,obj.jointHandle(2),'streaming')*obj.wheelRadius;      
            
            % set robot state
            obj.robotState = robotState;

            % get step time
            obj.stepTime =  getSimulationTimeStep(obj.vrepObj,'blocking');

           
                  
        end
          
        function out=move(obj,v,omega)
            
            switch nargin
                case 1
                    v = 0;
                    omega = 0;
                case 2
                    omega = 0;                    
            end
            
            
            % ----------- set speed robot speed
            
                        % compute wheels speed
            wheelsSpeed = [(2*v-omega*obj.wheelsDistance)/(2*obj.wheelRadius);(2*v+omega*obj.wheelsDistance)/(2*obj.wheelRadius)];  % [rad/s]
                                                                                    
            % set wheels speed
            setSpeed(obj,wheelsSpeed);
                        
            
            % ----------- get feedback
            
            % get wheels speed
            wheelsSpeed=getSpeed(obj);
              
            % set robot velocity in ego frame
            robotVelocityEgo = [(obj.wheelRadius*wheelsSpeed(1)+obj.wheelRadius*wheelsSpeed(2))/2;0;(obj.wheelRadius*wheelsSpeed(2)-obj.wheelRadius*wheelsSpeed(1))/obj.wheelsDistance];

            % compute forward kinematics
            robotVelocityAllo = computeForwardKinematics(obj,obj.robotState(3),robotVelocityEgo);

            % update robot state
            obj.robotState = updateRobotState(obj,obj.robotState,robotVelocityAllo,obj.stepTime);                                                          

            out = obj.robotState;

            
        end
        
       function  setSpeed(obj,wheelsSpeed)
            
            if nargin == 1                
                wheelsSpeed = [0;0];                                        
            end
                        
            % set desired velocity
            pauseCommunication(obj.vrepObj,1);
            setJointTargetVelocity(obj.vrepObj,obj.jointHandle(1),wheelsSpeed(1),'oneshot');
            setJointTargetVelocity(obj.vrepObj,obj.jointHandle(2),wheelsSpeed(2),'oneshot');
            pauseCommunication(obj.vrepObj,0);            
            
       end
       
       function  out=getSpeed(obj)
         
            obj.jointPositionNew(1) = getJointPosition(obj.vrepObj,obj.jointHandle(1),'buffer');
            obj.jointPositionNew(2) = getJointPosition(obj.vrepObj,obj.jointHandle(2),'buffer');
            out = [(obj.jointPositionNew(1) - obj.jointPositionOld(1)) / obj.stepTime;(obj.jointPositionNew(2) - obj.jointPositionOld(2)) / obj.stepTime];            
            obj.jointPositionOld(1) = obj.jointPositionNew(1);
            obj.jointPositionOld(2) = obj.jointPositionNew(2);
        
       end
       

         
        function out=getSimRobotState(obj)
            
            % get robot position
            robotPos = getObjectPosition(obj.vrepObj,obj.robotHandle,-1, 'buffer');
            % get robot orientation
            robotOrient = getObjectOrientation(obj.vrepObj,obj.robotHandle,-1,'buffer');                    
            % set robot state
            out = [robotPos(1);robotPos(2);robotOrient(3)];
            
        end
        
        function delete(obj)
             
             getObjectPosition(obj.vrepObj,obj.robotHandle,-1, 'discontinue');
             getPingTime(obj.vrepObj);  
             getObjectOrientation(obj.vrepObj,obj.robotHandle,-1,'discontinue');           
             getPingTime(obj.vrepObj);              
             getJointPosition(obj.vrepObj,obj.jointHandle(1), 'discontinue');
             getPingTime(obj.vrepObj);  
             getJointPosition(obj.vrepObj,obj.jointHandle(2), 'discontinue');            
             getPingTime(obj.vrepObj);  
             disp('ePuck object deleted')
                                
       end
       
    end
    
end


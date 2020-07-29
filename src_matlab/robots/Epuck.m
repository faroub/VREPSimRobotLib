classdef Epuck < DifferentialMobileRobot
    %   Epuck: is an Epuck simulation object
    %   This class handles the interface to the V-REP simulator and 
    %   low-level object handle operations for the Epuck mobile robot
    %
    %   A Epuck object holds all information related to 
    %   the robot kinematics and dynamics parameters
    
    properties (Constant)
        
        % Epuck Kinematics parameters
        %rl = 0.021; % radius of left wheel [m]
        %rr = 0.021; % radius of right wheel [m]
        %l = 0.053; % distance of each wheel from the center between the two drive wheels [m]
    
    
    end
    properties (Access = public)


        
        
    end
    
    properties (Access = protected)
  
        
        
    end
    
    properties (Access = private)
        
        vrepSimObj = -1; % V_REP simulation object               
        jh_l = -1; % left joint handle
        jh_r = -1; % right joint handle               
        denc = [0 0]; % left and right wheels encoder increments [m]
        
    end
    
    methods  (Access = public)
        function obj = Epuck(vrepSimObj, epuckParams)            
            
            switch nargin
                case 0
                    error ('argument <1:vrepSimObj> is required to communicate with the V-REP simulator ')              
                case 1
                    error ('argument <2:epuckParams> is required')              
            end
            
            obj@DifferentialMobileRobot();
            
            % get V_REP simulation object
            obj.vrepSimObj = vrepSimObj;
                                  
            % get joint handles
            obj.jh_l = getObjectHandle(obj.vrepSimObj,epuckParams{1}, 'blocking');
            obj.jh_r = getObjectHandle(obj.vrepSimObj,epuckParams{2}, 'blocking');
            

        end
        
   

        function move(obj,operationModes)
            
            switch nargin
                case 1
                    operationModes(1) = 'oneshot';
                    operationModes(2) = 'oneshot';
                case 2
                    operationModes(1) = 'oneshot';
                    operationModes(2) = 'oneshot';
            end
            
            % get joints positions feedback
            obj.denc(1) = getJointPosition(obj,obj.jh_l, operationModes(1)*obj.r_l;
            obj.denc(2) = getJointPosition(obj,obj.jh_r, operationModes(1)*obj.r_r;
            
            
            % compute the control law
            
            
            % set desired velocity
            pauseCommunication(obj.vrepSimObj,1);
            setJointTargetVelocity(obj.vrepSimObj,vl, obj.jh_l, operationModes(2));
            setJointTargetVelocity(obj.vrepSimObj,vr, obj.jh_r, operationModes(2));
            pauseCommunication(obj.vrepSimObj,0);
            
            if (obj.vrepSimObj.syncMode)
                
               sendSynchronousTrigger(obj.vrepSimObj);
               getPingTime(obj.vrepSimObj);                
               
            end
            
        end
        


    end
    
    methods  (Access = protected)
        
    end
    
    methods  (Access = private)
        
        function getFeedBack(obj,operationModes)
        % get all possible sensor data available (encoder, proximity sensors, camera, ...)
            
        end
        
        function setFeedBack(obj,operationModes)
        % get all possible sensor data available (encoder, proximity sensors, camera, ...)
            
        end


    end
    
end


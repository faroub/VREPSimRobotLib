classdef Epuck < DifferentialMobileRobot
    %   Epuck: is an Epuck simulation object
    %   This class handles the interface to the V-REP simulator and 
    %   low-level object handle operations for the Epuck mobile robot
    %
    %   A Epuck object holds all information related to 
    %   the robot kinematics and dynamics parameters
    
    properties (Constant)
        
        r_l = 0.021; % left wheel radius [m]
        r_r = 0.021; % right wheel radius [m]
        l = 0.053; % distance between wheels [m]
      
    
    end
    properties (Access = public)


        
        
    end
    
    properties (Access = protected)
  
        
        
    end
    
    properties (Access = private)
        
        vrepSimObj = -1; % V_REP simulation object     
        rh = -1; % robot handle
        jh_l = -1; % left joint handle
        jh_r = -1; % right joint handle               
        ds_l = 0; % left wheel displacement increment [m]
        ds_r = 0; % right wheel displacement increment [m]



        
    end
    
    methods  (Access = public)
        function obj = Epuck(vrepSimObj, epuckParams,robotPose)            
            
            obj@DifferentialMobileRobot(robotPose);
            
            switch nargin
                case 0
                    error ('argument <1:vrepSimObj> is required to communicate with the V-REP simulator ')              
                case 1
                    error ('argument <2:epuckParams> is required')
            end
            
           

            
            % get V_REP simulation object
            obj.vrepSimObj = vrepSimObj;
            
            % get robot handle
            obj.rh = getObjectHandle(obj.vrepSimObj,epuckParams{1}, 'blocking');
            
            % get joint handles
            obj.jh_l = getObjectHandle(obj.vrepSimObj,epuckParams{2}, 'blocking');
            obj.jh_r = getObjectHandle(obj.vrepSimObj,epuckParams{3}, 'blocking');
            
            % get initial robot position
            
            % get initial joints positions
            obj.ds_l = getJointPosition(obj.vrepSimObj,obj.jh_l, 'streaming')*obj.r_l;
            obj.ds_r = getJointPosition(obj.vrepSimObj,obj.jh_r, 'streaming')*obj.r_r;

            
            

        end
        
   

        function out=move(obj,v,operationModes)
            
            switch nargin
                case 1
                    v=[0 0];
                    operationModes{1} = 'oneshot';
                    operationModes{2} = 'buffer';
                case 2
                    operationModes{1} = 'oneshot';
                    operationModes{2} = 'buffer';
            end
                                         
            % set desired velocity
            pauseCommunication(obj.vrepSimObj,1);
            setJointTargetVelocity(obj.vrepSimObj,v(1), obj.jh_l, operationModes{1});
            setJointTargetVelocity(obj.vrepSimObj,v(2), obj.jh_r, operationModes{1});
            pauseCommunication(obj.vrepSimObj,0);
            
            if (obj.vrepSimObj.syncMode)
                
               sendSynchronousTrigger(obj.vrepSimObj);
               getPingTime(obj.vrepSimObj);                
               
            end
            
            % get joints positions
            obj.ds_l = (getJointPosition(obj.vrepSimObj,obj.jh_l, operationModes{2})*obj.r_l) - obj.ds_l;
            obj.ds_r = (getJointPosition(obj.vrepSimObj,obj.jh_r, operationModes{2})*obj.r_r) - obj.ds_r;
                      
            % compute odometry
            out=computeOdometry(obj,obj.ds_l,obj.ds_r);
            
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


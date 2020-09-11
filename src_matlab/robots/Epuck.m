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
        jp_n_l = 0; % left current encoder tick [m]
        jp_n_r = 0; % right current encoder tick [m]
        jp_o_l = 0; % left previous encoder tick [m]
        jp_o_r = 0; % right previous encoder tick [m]
        robotState = [0;0;0]; % robot position [x y theta]
        robotVelocityEgo = [0;0;0]; % robot velocity in egocentric frame 
        robotVelocityAllo = [0;0;0]; % robot velocity in allocentric frame 
        out % temporary variable
        stepTime = -1;% step time [s]
        
       
        
       
    end
    
    methods  (Access = public)
        function obj = Epuck(vrepSimObj, epuckParams,robotState)            
            
            obj@DifferentialMobileRobot(vrepSimObj.stepTime,robotState);
            
            switch nargin
                case 0
                    error ('argument <1:vrepSimObj> is required to communicate with the V-REP simulator ')              
                case 1
                    error ('argument <2:epuckParams> is required')
                case 2
                    % get V_REP simulation object
                    obj.vrepSimObj = vrepSimObj;
                    % get robot handle
                    obj.rh = getObjectHandle(obj.vrepSimObj,epuckParams{1},'blocking');
                    % get robot position
                    obj.out = getObjectPosition(obj.vrepSimObj,obj.rh,-1, 'streaming');
                    obj.robotState(1:2) = obj.out(1:2);
                    % get robot orientation
                    obj.out = getObjectOrientation(obj.vrepSimObj,obj.rh,-1,'streaming');
                    obj.robotState(3)=obj.out(3); 
                    % get step time
                    obj.stepTime =  obj.vrepSimObj.stepTime;
                case 3
                    % get V_REP simulation object
                    obj.vrepSimObj = vrepSimObj;
                    % get robot state
                    obj.robotState = robotState; 
                    % get step time
                    obj.stepTime =  obj.vrepSimObj.stepTime;
            end
                                                 

            
           
            % get joint handles
            obj.jh_l = getObjectHandle(obj.vrepSimObj,epuckParams{2},'blocking');
            obj.jh_r = getObjectHandle(obj.vrepSimObj,epuckParams{3},'blocking');
                       
            % set initial joints position
            setJointPosition(obj.vrepSimObj,obj.jh_l, 0, 'blocking');
            setJointPosition(obj.vrepSimObj,obj.jh_r, 0, 'blocking');
            
            % set initial joint velocity
            setJointTargetVelocity(obj.vrepSimObj,obj.jh_l,0,'blocking');
            setJointTargetVelocity(obj.vrepSimObj,obj.jh_r,0,'blocking');            
            
                        
            % get initial joints positions
            obj.jp_o_l = getJointPosition(obj.vrepSimObj,obj.jh_l, 'streaming');       
            obj.jp_o_r  = getJointPosition(obj.vrepSimObj,obj.jh_r, 'streaming');
                   
        end
        
   

        function out=move(obj,v,omega)
            
            switch nargin
                case 1
                    v = 0;
                    omega = 0;
                case 2
                    omega = 0;                    
            end
            
            % compute wheels speeds
            v_l = (2*v-omega*obj.l)/(2*obj.r_l) % [rad/s)
            v_r = (2*v+omega*obj.l)/(2*obj.r_r) % [rad/s]
            
            % set robot speed
            setSpeed(obj,v_l,v_r)
            
            getspeedout = getSpeed(obj)
            
            % get travelled distance
            %getDistance(obj);
                                  
%             % get left/right speed
%             [obj.v_l, obj.v_r]=getSpeed(obj);
%             
%             
%             obj.robotVelocityEgo = [(obj.r_l*obj.v_l +  obj.r_r*obj.v_r)/2;0;(obj.r_r*obj.v_r - obj.r_l*obj.v_l)/obj.l];
%                                                                    
%             obj.robotVelocityAllo=computeForwardKinematics(obj,obj.robotVelocityEgo);
%                        
%             obj.robotState = obj.robotState + obj.robotVelocityAllo * obj.vrepSimObj.stepTime;
%             
             out = obj.robotState;
            
        end
        
       function delete(obj)
             disp('delete ePuck')
             if obj.rh ~= -1
                getObjectPosition(obj.vrepSimObj,obj.rh, 'discontinue');            
                getPingTime(obj.vrepSimObj);
                getObjectOrientation(obj.vrepSimObj,obj.rh, 'discontinue');            
                getPingTime(obj.vrepSimObj);  
             end
             getJointPosition(obj.vrepSimObj,obj.jh_l, 'discontinue');
             getPingTime(obj.vrepSimObj);  
             getJointPosition(obj.vrepSimObj,obj.jh_r, 'discontinue');            
             getPingTime(obj.vrepSimObj);  
                                
       end
       
       
    end
    
   
    methods  (Access = private)
        
        function  setSpeed(obj,v_l,v_r)
            
            switch nargin
                case 1
                    v_l = 0;
                    v_r = 0;
                case 2
                    omega = 0;                    
            end
                        
            % set desired velocity
            pauseCommunication(obj.vrepSimObj,1);
            setJointTargetVelocity(obj.vrepSimObj,obj.jh_l,v_l,'oneshot');
            setJointTargetVelocity(obj.vrepSimObj,obj.jh_r,v_r,'oneshot');
            pauseCommunication(obj.vrepSimObj,0);
            
            
        end
        
         function  [out]=getSpeed(obj)
         
            obj.jp_n_l = getJointPosition(obj.vrepSimObj,obj.jh_l,'buffer');
            obj.jp_n_r = getJointPosition(obj.vrepSimObj,obj.jh_r,'buffer');
            out(1) = (obj.jp_n_l - obj.jp_o_l) / obj.stepTime;
            out(2) = (obj.jp_n_r - obj.jp_o_r) / obj.stepTime;
            obj.jp_o_l = obj.jp_n_l;
            obj.jp_o_r = obj.jp_n_r;

        
         end
        
%         function out=getDistance(obj)
%             
%             obj.ds_n_l = getJointPosition(obj.vrepSimObj,obj.jh_l,'buffer')*obj.r_l;
%             obj.ds_n_r = getJointPosition(obj.vrepSimObj,obj.jh_r,'buffer')*obj.r_r;            
%             out(1) = obj.ds_n_l - obj.ds_o_l;
%             out(2) = obj.ds_n_r - obj.ds_o_r; 
%             obj.ds_o_l = obj.ds_n_l;
%             obj.ds_o_r = obj.ds_n_r;            
% 
%             
%         end


    end
    
end


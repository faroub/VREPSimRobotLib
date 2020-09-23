classdef ePuck < DifferentialMobileRobot
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
        jp_n_l = 0; % left current joint position [rad]
        jp_n_r = 0; % right current joint position [rad]
        jp_o_l = 0; % left previous joint position [rad]
        jp_o_r = 0; % right previous joint position [rad]
        ds_n_l % left current delta distance [m]
        ds_n_r % right current delta distance [m]
        ds_o_l % left previous delta distance [m]
        ds_o_r % right previous delta distance [m]
        stepTime = -1;% step time [s]
        
        
       
        
       
    end
    
    methods  (Access = public)
        function obj = ePuck(vrepSimObj, epuckParams,robotState)            
                     
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
                    out_pos = getObjectPosition(obj.vrepSimObj,obj.rh,-1, 'streaming');
                    % get robot orientation
                    out_orient = getObjectOrientation(obj.vrepSimObj,obj.rh,-1,'streaming');                    
                   % get robot state
                   robotState = [double(out_pos(1));double(out_pos(2));double(out_orient(3))];
 
                    
                case 3
                    % get V_REP simulation object
                    obj.vrepSimObj = vrepSimObj;
            end
                                       
           % get robot handle
           obj.rh = getObjectHandle(obj.vrepSimObj,epuckParams{1},'blocking');
           
            % get robot position
            getObjectPosition(obj.vrepSimObj,obj.rh,-1, 'streaming');
            
            % get robot orientation
            getObjectOrientation(obj.vrepSimObj,obj.rh,-1,'streaming');   
           
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
            
            % get initial delta distance
            obj.ds_o_l = getJointPosition(obj.vrepSimObj,obj.jh_l,'streaming')*obj.r_l;
            obj.ds_o_r = getJointPosition(obj.vrepSimObj,obj.jh_r,'streaming')*obj.r_r;      
            
            % set robot state
            setRobotState(obj,robotState);
            % get step time
            obj.stepTime =  getSimulationTimeStep(obj.vrepSimObj,'blocking');
            % set step time
            setStepTime(obj,obj.stepTime);
           
                  
        end
        
   

        function out=move(obj,v,omega)
            
            switch nargin
                case 1
                    v = 0;
                    omega = 0;
                case 2
                    omega = 0;                    
            end
            
            % get robot speed
            v_w=getSpeed(obj);
              
            % set robot velocity in ego frame
            robotVelocityEgo = [(obj.r_l*v_w(1)+obj.r_r*v_w(2))/2;0;(obj.r_r*v_w(2)-obj.r_l*v_w(1))/obj.l];
            setRobotVelocityEgo(obj,robotVelocityEgo) 
             
            % compute forward kinematics
            computeForwardKinematics(obj);
            
            % update robot state
            updateRobotState(obj);
                                                            
            % compute wheels speeds
            v_w = [(2*v-omega*obj.l)/(2*obj.r_l);(2*v+omega*obj.l)/(2*obj.r_r)];  % [rad/s]
                                                                                    
            % set robot speed
            setSpeed(obj,v_w);
            
            out = getRobotState(obj);
            
        end
        
       function  setSpeed(obj,v_w)
            
            if nargin == 1                
                v_w = [0;0];                                        
            end
                        
            % set desired velocity
            pauseCommunication(obj.vrepSimObj,1);
            setJointTargetVelocity(obj.vrepSimObj,obj.jh_l,v_w(1),'oneshot');
            setJointTargetVelocity(obj.vrepSimObj,obj.jh_r,v_w(2),'oneshot');
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
       

         
        function out=getSimRobotState(obj)
            
            % get robot position
            out_pos = getObjectPosition(obj.vrepSimObj,obj.rh,-1, 'buffer');
            % get robot orientation
            out_orient = getObjectOrientation(obj.vrepSimObj,obj.rh,-1,'buffer');                    
            % set robot state
            out = [double(out_pos(1));double(out_pos(2));double(out_orient(3))];
            
        end
        
        function delete(obj)
             disp('Delete ePuck')
             getObjectPosition(obj.vrepSimObj,obj.rh,-1, 'discontinue');
             getPingTime(obj.vrepSimObj);  
             getObjectOrientation(obj.vrepSimObj,obj.rh,-1,'discontinue');           
             getPingTime(obj.vrepSimObj);              
             getJointPosition(obj.vrepSimObj,obj.jh_l, 'discontinue');
             getPingTime(obj.vrepSimObj);  
             getJointPosition(obj.vrepSimObj,obj.jh_r, 'discontinue');            
             getPingTime(obj.vrepSimObj);  
                                
       end
       
    end
    
   
    methods  (Access = private)
        

        

        



    end
    
end


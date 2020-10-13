function controlRobot()


% --- Initialization phase ---- %

% simulation step time
stepTime = 0.02;

% is simulation synchronous
syncMode = true;

% robot state
robotState=zeros(3, 1);

% controller
ObjPID=pidController(2,0,0,stepTime);


% simulation scene API server parameters
sceneSimParams = {'127.0.0.1', 19997,true,true,5000,5};

% instantiate VREP simulation scene object
ObjSceneSim = VREPSimScene(sceneSimParams,stepTime,syncMode);

% load simulation scene
loadScene(ObjSceneSim,'/home/faroub/Documents/development-projects/projects-matlab/vrep-projects/robotic-framework/src_vrep/differential_robot_behavior_based_controller.ttt',0, 'blocking');

% ePuck API server parameters
ePuckSimParams = {'127.0.0.1', 19992,true,true,5000,5};
%ePuckSimParams = {'127.0.0.1', 19997,true,true,5000,5};

% time pause
pause(2);

% instantiate VREP simulation robot object
ObjePuckSim = VREPSimRobot(ePuckSimParams);

% ePuck parameters
ePuckParams = {'ePuck', 'ePuck_leftJoint', 'ePuck_rightJoint'};
        
% instantiate ePuck object
ObjePuck = ePuck(ObjePuckSim, ePuckParams,robotState);


% get target handle
targetHandle=getObjectHandle(ObjSceneSim,'target','blocking');

% get target position
targetPos=getObjectPosition(ObjSceneSim,targetHandle,-1,'streaming');

% start simulation
startSimulation(ObjSceneSim,'blocking');

    

% --- simulation loop ---- %

while (getConnectionID(ObjSceneSim)~=-1) 


    % get target position
    targetPos=getObjectPosition(ObjSceneSim,targetHandle,-1,'buffer');


    % desired heading
    phi_des = atan2(targetPos(2)-robotState(2),targetPos(1)-robotState(1));

    % compute error 
    error = phi_des - robotState(3);

    % ensure error in range [-pi, pi]        
    error = atan2(sin(error),cos(error));

    % controller 
    omega = compute(ObjPID,error);

    % moves robot and gets control inputes and outputs current pose of the robot
    robotState = move(ObjePuck,0.2,omega);


    % executed only when synchronous  mode enables
    execSimStep(ObjSceneSim);
        
end
    
    % discontinue streaming
    getObjectPosition(ObjSceneSim,targetHandle,-1, 'discontinue');
    
    disp('program ended');
    
 


end
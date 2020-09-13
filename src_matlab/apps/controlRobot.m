function controlRobot()


% --- Initialization phase ---- %

% simulation step time
stepTime = 0.02;

% is simulation synchronous
syncMode = true;

% robot state
robotState=zeros(3, 1);


% instantiate VREP simulation scene object
sceneSimParams = {'127.0.0.1', 19997,true,true,5000,5};
ObjSceneSim = VREPSimScene(sceneSimParams,stepTime,syncMode);

% load simulation scene
loadScene(ObjSceneSim,'/home/faroub/Documents/development-projects/projects-matlab/vrep-projects/robotic-framework/src_vrep/test_scene.ttt',0);



% robot parameters
epuck1Params = {'ePuck', 'ePuck_leftJoint', 'ePuck_rightJoint'};

epuck2Params = {'ePuck0','ePuck_leftJoint0', 'ePuck_rightJoint0'};


% instantiate VREPSim object
epuck1SimParams = {'127.0.0.1', 19992,true,true,5000,5};

epuck2SimParams = {'127.0.0.2', 19993,true,true,5000,5};


ObjEpuck1Sim = VREPSimRobot(epuck1SimParams);
ObjEpuck2Sim = VREPSimRobot(epuck2SimParams);


if (openConnection(ObjSceneSim)~=-1)
        
    disp('connected to remote API server');  
    
    % set simulation parameters : step time and synchronous mode                
    setSimulationParameters(ObjSceneSim);
    
    

    % instantiate Epuck object
    ObjEpuck1 = Epuck(ObjEpuck1Sim, epuck1Params,robotState);
    ObjEpuck2 = Epuck(ObjEpuck2Sim, epuck2Params);
    
    % start simulation
    startSimulation(ObjSceneSim,'blocking');

    

    % while we are connected:
    while (getConnectionID(ObjSceneSim)~=-1) 

        % Trajectory/Path planner
        

        % controller that gets current pose and generates control inputs
        % controller 
        
        % moves robot and gets control inputes and outputs current pose of the robot
        robotState = move(ObjEpuck1,0.1,0)
        robotState = move(ObjEpuck2,0.1,0)
        
        rssim=getSimRobotState(ObjEpuck1);
        %robotPose = move(ObjEpuck2, [5 5]);

        % executed only when synchronous  mode enables
        executeNextSimulationStep(ObjSceneSim);
    end
    
    disp('program ended');
    

    
else
    
    disp('failed connecting to remote API server');
    
end

end
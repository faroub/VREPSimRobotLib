function controlRobot()


% --- Initialization phase ---- %

% simulation step time
stepTime = 0.02;

% is simulation synchronous
syncMode = true;

% robot state
robotState=zeros(3, 1);

% default api server parameters
sceneSimParams = {'127.0.0.1', 19997,true,true,5000,5};

% instantiate VREP simulation scene object using the default api server
ObjSceneSim = VREPSimScene(sceneSimParams,stepTime,syncMode);

% load simulation scene
loadScene(ObjSceneSim,'/home/faroub/Documents/development-projects/projects-matlab/vrep-projects/robotic-framework/src_vrep/differential_robot_behavior_based_controller.ttt',0);

% ePuck parameters
ePuck1Params = {'ePuck', 'ePuck_leftJoint', 'ePuck_rightJoint'};

% ePuck simulation parameters
ePuck1SimParams = {'127.0.0.1', 19992,true,true,5000,5};

% instantiate VREPSim object
ObjePuck1Sim = VREPSimRobot(ePuck1SimParams);

if (openConnection(ObjSceneSim)~=-1)
        
    disp('connected to remote API server');  
    
    % set simulation parameters : step time and synchronous mode                
    setSimulationParameters(ObjSceneSim);
       
    % instantiate Epuck object
    ObjePuck1 = ePuck(ObjePuck1Sim, ePuck1Params,robotState);

    
    % start simulation
    startSimulation(ObjSceneSim,'blocking');

    

    % while we are connected:
    while (getConnectionID(ObjSceneSim)~=-1) 

        % Trajectory/Path planner
        

        % controller that gets current pose and generates control inputs
        % controller 
        
        % moves robot and gets control inputes and outputs current pose of the robot
        robotState = move(ObjePuck1,0.1,0);


        % executed only when synchronous  mode enables
        execSimStep(ObjSceneSim);
        
    end
    
    disp('program ended');
    

    
else
    
    disp('failed connecting to remote API server');
    
end

end
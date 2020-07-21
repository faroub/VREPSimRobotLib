function controlRobot()


% Initialization phase

% load simulation scene
loadScene('/home/faroub/Documents/development-projects/projects-matlab/vrep-projects/robotic-framework/src_vrep/test_scene.ttt',0);

% instantiate VREPSim object
ObjVREP = VREPSim;

% instantiate Epuck object
ObjEpuck = Epuck(ObjVREP);

if (openConnection(ObjVREP)~=-1)
        
    disp('Connected to remote API server');  
   
    % start simulation
     startSimulation(ObjVREP,'blocking');
    
    % while we are connected:
    while (getConnectionID(ObjVREP)~=-1) 


        move(ObjEpuck, 5);


    end
    
else
    
    disp('Failed connecting to remote API server');
    
end

end
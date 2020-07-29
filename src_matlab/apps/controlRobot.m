function controlRobot()

% load simulation scene
loadScene('/home/faroub/Documents/development-projects/projects-matlab/vrep-projects/robotic-framework/src_vrep/test_scene.ttt',0);

% Initialization phase

% robot parameters
epuckParams1 = {'ePuck_leftJoint', 'ePuck_rightJoint'};

epuckParams2 = {'ePuck_leftJoint#0', 'ePuck_rightJoint#0'};


% instantiate VREPSim object
simParams1 = {'127.0.0.1', 19991,true,true,5000,5};

simParams2 = {'127.0.0.2', 19990,true,true,5000,5};


ObjVREP1 = VREPSim(simParams1);
%ObjVREP2 = VREPSim(simParams2);


%if ((openConnection(ObjVREP1)~=-1) && (openConnection(ObjVREP2)~=-1))

if (openConnection(ObjVREP1)~=-1)
        
    disp('connected to remote API server');  
   
    % instantiate Epuck object
    ObjEpuck1 = Epuck(ObjVREP1, epuckParams1);
    %ObjEpuck2 = Epuck(ObjVREP1, epuckParams2);
    
    % start simulation
    startSimulation(ObjVREP1,'blocking');
    %startSimulation(ObjVREP2,'blocking');
    
    % while we are connected:
    %while ((getConnectionID(ObjVREP1)~=-1)&&(getConnectionID(ObjVREP2)~=-1)) 
    while (getConnectionID(ObjVREP1)~=-1) 
       
        move(ObjEpuck1, [1 3]);
        %move(ObjEpuck2, 8);


    end
    
    disp('program ended');
    

    
else
    
    disp('failed connecting to remote API server');
    
end

end
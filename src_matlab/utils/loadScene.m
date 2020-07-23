function loadScene(scenePathAndName,location)
    disp('load simulation scene');
    % using the prototype file (remoteApiProto.m)
    vrep=remApi('remoteApi'); 
    % just in case, close all opened connections
    %vrep.simxFinish(-1); 
    % starts a communication thread with the DEFAULT server (i.e. V-REP)
    % on Port=19997 and IP=127.0.0.1  (make sure the V_REP simulator is started)
    clientID=vrep.simxStart('127.0.0.1',19997,true,true,5000,5);
    % load simulation scene
    vrep.simxLoadScene(clientID, scenePathAndName,location,vrep.simx_opmode_blocking);    
    % close all opened connections
    vrep.simxFinish(-1); 

end
function loadScene(vrepSimObj, scenePathAndName,location)
    disp('load simulation scene');
    % just in case, close all opened connections
    vrepSimObj.vrepObj.simxFinish(-1); 
    % starts a communication thread with the DEFAULT server (i.e. V-REP)
    % on Port=19997 and IP=127.0.0.1  (make sure the V_REP simulator is started)
    clientID=vrepSimObj.vrepObj.simxStart('127.0.0.1',19997,true,true,5000,5);
    % load simulation scene
    vrepSimObj.vrepObj.simxLoadScene(clientID, scenePathAndName,location,vrepSimObj.vrepObj.simx_opmode_blocking);    
    % close all opened connections
    vrepSimObj.vrepObj.simxFinish(-1); 

end
params ["_player", "_target"];

_camPos = [((getPos _player select 0) + (getPos _target select 0)) / 2, ((getPos _player select 1) + (getPos _target select 1)) / 2, ((getPos _player select 2) + (getPos _target select 2)) / 2 + 20];

_cam1 = "camera" camCreate (ASLToAGL eyePos _player);
_cam1 cameraEffect ["Internal","back"];

showCinemaBorder true;
_cam1 camPrepareTarget _player;
_cam1 camPreparePos _camPos;
_cam1 camPrepareFOV 0.700;
_cam1 camCommitPrepared 0;
WaitUntil {camCommitted _cam1};

sleep 3;

showCinemaBorder true;
_cam1 camPrepareTarget _target;
_cam1 camPreparePos _camPos;
_cam1 camPrepareFOV 0.500;
_cam1 camCommitPrepared 3;
WaitUntil {camCommitted _cam1};

sleep 4;

showCinemaBorder true;
_cam1 camPrepareTarget _player;
_cam1 camPreparePos _camPos;
_cam1 camPrepareFOV 0.300;
_cam1 camCommitPrepared 2;
WaitUntil {camCommitted _cam1};

sleep 3;

showCinemaBorder false;
_cam1 camPrepareTarget _target;
_cam1 camPreparePos (getPos _player);
_cam1 camPrepareFOV 0.700;
_cam1 camCommitPrepared 2;
WaitUntil {camCommitted _cam1};

sleep 1;

_cam1 cameraEffect ["Terminate","back"];
camDestroy _cam1;
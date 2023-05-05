[] spawn {
[1,["Wait for game to start", "PLAIN DOWN", 0.7]] remoteExec ["cutText",-2];
[1,["Your game starts in 10 seconds", "PLAIN DOWN", 0.7]] remoteExec ["cutText"];
sleep 10;
execVM "AISpawn.sqf";
};
BRSEWeather = "MPWeather" call BIS_fnc_getParamValue;
BRSEAICount = "MPNumberOfAI" call BIS_fnc_getParamValue;
BRSETime = "MPTime" call BIS_fnc_getParamValue;
BRSEAISkill = "MPAISkill" call BIS_fnc_getParamValue;
isFatigueEnabled = "MPEnableFatigue" call BIS_fnc_getParamValue;
addGPS =  "MPAddGPS" call BIS_fnc_getParamValue;
enableDangerZones = "MPEnableDangerZones" call BIS_fnc_getParamValue;
ExtendedTimeMode = "MPExtendedTime" call BIS_fnc_getParamValue;
EnableCustomHudMode = "MPEnableCustomHUD" call BIS_fnc_getParamValue;
PublicVariable "EnableCustomHudMode";
DayNightCycle = "MPEnableDayNightCycle" call BIS_fnc_getParamValue;

MySpawnAI = {
_myplane = _this;
_myPlanePos = getPos _this;
//_myplanePos = planeSpawnPositionArray select randompos;
//_myplanePos = _myplanePos getPos [20 * sqrt random 1, random 360];
_pdir = 0;
//_centerposition = [worldSize / 2, worldsize / 2, 0];
//_y2 = _centerposition select 1;
//_y1 = _myplanePos select 1;
//_x2 = _centerposition select 2;
//_x1 = _myplanePos select 2;
//_pdir = round(((_y2/_y1) atan2 (_x2/_x1)) * (180 / 3.1416))+90;


//_myplane setObjectTextureGlobal [0,'\A3\air_f_beta\heli_transport_02\data\heli_transport_02_1_indp_co.paa'];
//https://darkchozo.github.io/vehicleskins/vehicleskins.html
//_myplane setVariable ["BIS_enableRandomization", false];

_ntextures = getObjectTextures _myPlane;
switch(_myplane) do {
    case dropPlane1: {{_myPlane setObjectTexture [_forEachIndex,"#(rgb,8,8,3)color(1,1,0,1)"]} forEach _ntextures};
    case dropPlane2: {{_myPlane setObjectTexture [_forEachIndex,"#(rgb,8,8,3)color(0.4,0.15,0.03,1)"]} forEach _ntextures}; 
    case dropPlane3: {{_myPlane setObjectTexture [_forEachIndex,"#(rgb,8,8,3)color(0.35,0.12,0.20,1)"]} forEach _ntextures}; 
    case dropPlane4: {{_myPlane setObjectTexture [_forEachIndex,"#(rgb,8,8,3)color(0.18,0.08,0.02,1)"]} forEach _ntextures}; 
};

switch(randompos) do{
	case 0: {_pdir = 180};
	case 1: {_pdir = 180};
	case 2: {_pdir = 180};
	case 3: {_pdir = 180};
	case 4: {_pdir = 180};
	case 5: {_pdir = 225};
	case 6: {_pdir = 270};
	case 7: {_pdir = 270};
	case 8: {_pdir = 270};
	case 9: {_pdir = 315};
	case 10: {_pdir = 315};
	case 11: {_pdir = 360};
	case 12: {_pdir = 360};
	case 13: {_pdir = 360};
	case 14: {_pdir = 360};
	case 15: {_pdir = 360};
};
//_myplanePos set [2,1000];
_planePosZ = _myplanePos select 2;
_planePosY = _myplanePos select 1;
if (_myplane == dropPlane2) then {
//_myplanePos set [2,_planePosZ + 200]; _myplanePos set [1,_planePosY - 50];
};
//_myplane setDir _pdir;
_myplane setVehiclePosition [_myplanePos, [], 0, "FLY"];
_hasCargo= _myplane emptyPositions "CARGO" > 2;
while {False} do   
{
_red = creategroup civilian;
[_myplane] join _red;
_skill = 0;; 
switch(BRSEAISkill) do{
case 0: {_skill = 1};
case 1: {_skill = (floor (random [7,9,11]))/10};
case 2: {_skill = (floor (random [4,6,8]))/10};
case 3: {_skill = (floor (random [0,3,5]))/10};
case 4: {_skill = (floor (random (11)))/10};
};
_heroChooser = count MainHeroesArray;
_heroPlayAg = floor random (_heroChooser);
_heroPlayAg = MainHeroesArray select _heroPlayAg;
_unit = _red createUnit [_heroPlayAg, position _myplane, [], 0, "CARGO"]; 
[_myplane] join grpNull;
[_unit] join grpNull;
removeAllWeapons _unit;
removeAllItems _unit;
_unit removeWeapon "throw";
_redblue = creategroup east; //changed it here;
[_unit] join _redblue;
_unit setSkill _skill;
_unit setskill ["aimingAccuracy",_skill];
_unit setskill ["aimingSpeed",_skill];
_unit setskill ["spotTime",_skill];
_unit setskill ["aimingShake",_skill];
_unit setskill ["courage",1];
_grp = group _unit;
_unit addRating -9999;
//_unit addEventHandler ["killed", "MyPlayersCount = MyPlayersCount -1; plalive = MyPlayersCount; publicVariable 'MyPlayersCount'; chatMsg = format ['%1 was killed by %2. Players alive: %3', (name (_this select 0)), (name (_this select 1)), MyPlayersCount]; [(_this select 0),chatMsg] remoteExec ['globalChat'];  remoteExec ['updateUI'];"];
_unit addEventHandler ["killed", "MyPlayersCount = MyPlayersCount -1; plalive = MyPlayersCount; publicVariable 'MyPlayersCount'; if (isPlayer (_this select 1)) then {remoteExec ['addKillCounter',(_this select 1)]}; chatMsg = format ['%1 was killed by %2. Players alive: %3', (name (_this select 0)), (name (_this select 1)), MyPlayersCount]; [(_this select 0),chatMsg] remoteExec ['globalChat'];  remoteExec ['updateUI']; call test_logger;"];
_grp setBehaviour "CARELESS";
_hasCargo= _myplane emptyPositions "CARGO" > ExpectedPlayerCount;
greenLight = creategroup resistance;
[_myplane] join greenLight;
};
_randomRoute = 0;
genNumb = randompos;
runNumb = 0;

lastPointPos = _myPlanePos;
//lastPointPos = planeSpawnPositionArray select lastpointId;
//_lastPointPosRadius = planeSpawnRadiusArray select lastpointId;
//_mylastPlanePos = lastPointPos getPos [_lastPointPosRadius * sqrt random 1, random 360];
//if (_myplane == dropPlane2) then {
//_planePosZ = _mylastPlanePos select 2;
//_planePosY = _mylastPlanePos select 1;
//_mylastPlanePos set [2,_planePosZ + 200]; _myplanePos set [1,_planePosY - 100];
//};

_drop_terrain = ["BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","HOUSE","LIGHTHOUSE","POWER LINES","POWERSOLAR","POWERWAVE","POWERWIND","QUAY","RUIN","TOURISM","TRANSMITTER","VIEW-TOWER","WATERTOWER","FOREST BORDER","FOREST SQUARE","FOREST TRIANGLE","BUSH","ROAD","RAILWAY","ROCK","ROCKS","STACK","SMALL TREE","TRACK","TREE","WALL","TRAIL","MAIN ROAD","FOREST BORDER","FOREST SQUARE","FOREST TRIANGLE","FOREST","FENCE","SHIPWRECK","TRACK"];
//_loot_terrain = ["HOUSE","BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","LIGHTHOUSE","POWERSOLAR","POWERWAVE","QUAY","RUIN","TOURISM","TRANSMITTER","VIEW-TOWER","WATERTOWER","FOREST BORDER","FOREST SQUARE","FOREST TRIANGLE"];
//_vehicle_terrain = ["BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","LIGHTHOUSE","POWERSOLAR","POWERWAVE","QUAY","RUIN","TOURISM","TRANSMITTER","VIEW-TOWER","WATERTOWER"];
//_na_terrain = ["BUSH","ROAD","RAILWAY","ROCK","ROCKS","STACK","SMALL TREE","TRACK","TREE","WALL","TRAIL","MAIN ROAD","FOREST BORDER","FOREST SQUARE","FOREST TRIANGLE","FOREST","FENCE","SHIPWRECK","TRACK","HIDE", "POWER LINES","TRANSMITTER","STACK","TRAIL"];
private _buildTerrainObjects = nearestTerrainObjects
[
    [worldSize / 2, worldSize / 2],
    _drop_terrain,
    worldSize,
    false
];

_randp = floor random(count _buildTerrainObjects);
_mylastPlanePos = getPosWorld (_buildTerrainObjects select _randp);
[_myplane,_mylastPlanePos] call createWapoint;
_markerName = str _myplane + " end 1";
createMarker [_markerName, _mylastPlanePos];
_markerName setMarkerType "hd_end";
switch(_myplane) do{
	case dropPlane1: {_markerName setMarkerColor "ColorYellow"};
	case dropPlane2: {_markerName setMarkerColor "ColorOrange"};
	case dropPlane3: {_markerName setMarkerColor "ColorPink"};
    case dropPlane4: {_markerName setMarkerColor "ColorBrown"};
};
_markerName setMarkerAlpha 1; 
_markerName setMarkerText _markerName;

_randp = floor random(count _buildTerrainObjects);
_mylastPlanePos = getPosWorld (_buildTerrainObjects select _randp);
[_myplane,_mylastPlanePos] call createWapoint;

_markerName = str _myplane + " end 2";
createMarker [_markerName, _mylastPlanePos];
_markerName setMarkerType "hd_end";
switch(_myplane) do{
	case dropPlane1: {_markerName setMarkerColor "ColorYellow"};
	case dropPlane2: {_markerName setMarkerColor "ColorOrange"};
	case dropPlane3: {_markerName setMarkerColor "ColorPink"};
    case dropPlane4: {_markerName setMarkerColor "ColorBrown"};
};
_markerName setMarkerAlpha 1;
_markerName setMarkerText _markerName;
};

getLastPointId = {
lastpointId =0;
switch(randompos) do{
	case 0: {lastpointId = 1};
	case 1: {lastpointId = 2};
	case 2: {lastpointId = 3};
	case 3: {lastpointId = 4};
	case 4: {lastpointId = 5};
	case 5: {lastpointId = 6};
	case 6: {lastpointId = 7};
	case 7: {lastpointId = 8};
	case 8: {lastpointId = 9};
	case 9: {lastpointId = 10};
	case 10: {lastpointId = 11};
	case 11: {lastpointId = 12};
	case 12: {lastpointId = 13};
	case 13: {lastpointId = 14};
	case 14: {lastpointId = 15};
	case 15: {lastpointId = 16};
};
};


EndTrGenerator = {
//_p1 = planeSpawnPositionArray select randompos;
//_p2 = planeSpawnPositionArray select lastpointId;
_building_terrain=["BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","HOUSE","LIGHTHOUSE","POWERSOLAR","POWERWAVE","POWERWIND","RUIN","TRANSMITTER","VIEW-TOWER","WATERTOWER"];
private _buildTerrainObjects = nearestTerrainObjects
[
    [worldSize / 2, worldSize / 2],
    _building_terrain,
    worldSize,
    false
];

_randp1 = floor random(count _buildTerrainObjects);
_randp2 = floor random(count _buildTerrainObjects);
_p1 = getPosWorld (_buildTerrainObjects select _randp1);
_p2 = getPosWorld (_buildTerrainObjects select _randp2);

_p1xmin = (selectMin [(_p1 select 0), (_p2 select 0)]);
_p1ymin = (selectMin [(_p1 select 1), (_p2 select 1)]);
_p1xmax = (selectMax [(_p1 select 0), (_p2 select 0)]);
_p1ymax = (selectMax [(_p1 select 1), (_p2 select 1)]);

_p1xdif = (_p1xmax - _p1xmin)/2;
_p1ydif = (_p1ymax - _p1ymin)/2;
_plxmid = _p1xdif + _p1xmin;
_plymid = _p1ydif + _p1ymin;
_randomx = floor random [_p1xmin,_plxmid,_p1xmax];
_randomy = floor random [_p1ymin,_plymid,_p1ymax];

LastPosition = [_randomx,_randomy, 1000]; 
EndTr setPos LastPosition;
IsSpawnLoaded = true;
0 = [] spawn { 
//call removeCarTriggers;
//call removeLootTriggers;
};
if (EnableCustomHudMode>0) then {
[["BRSEMissionInfoUI", "PLAIN"]] remoteExec ["cutRsc"];
remoteExec ["updateUI"];
};
if (DayNightCycle>0) then {call EnableDayNightCicle;};
};

PlaneXOffset = 0;

createWapoint = {
_plane = _this select 0;
_pos = _this select 1;
_planegr = group _plane;
_wp = _planegr addWaypoint[_pos,0];
_wp setWaypointCompletionRadius 30;
_planegr setBehaviour "CARELESS";
};


planeSpawnPositionArray = [[3000,25000,800], [8000,25000,800], [13000,25000,800], [18000,25000,800], [23000,25000,800], [26000,25000,800], [26000,20000,800], [26000,15000,800], [26000,10000,800], [26000,5000,800],[3000,5000,800], [8000,5000,800], [13000,5000,800], [18000,5000,800], [23000,5000,800], [26000,5000,800]];
planeSpawnRadiusArray = [100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100];

//player addRating -9999;
//player addBackPack 'B_parachute';

EventHandlerAdder ={
//player addEventHandler ["killed", "(_this select 0) globalChat format ['%1 was killed by %2. Players alive: %3', (name (_this select 0)), (name (_this select 1)), MyPlayersCount];"];
//player addEventHandler ["Dammaged", "call updateUI"];
//player addEventHandler ["HandleHeal", "0 = _this spawn {params ['_injured','_healer'];_damage = damage _injured; if (_injured == _healer) then {waitUntil {damage _injured != _damage}; call updateUI;};}"];
};

if (addGPS > 0) then {  
{  
 if (isPlayer _x) then  
 {  
   _x addItem "ItemGPS";  
   _x assignItem "ItemGPS";  
 };  
} forEach playableUnits; 
};  

if (isFatigueEnabled < 1) then {  
{  
 if (isPlayer _x) then  
 {  
	[_x,false] remoteExec ["enableFatigue"];
 };  
} forEach playableUnits;  

};  


 
switch (BRSEAICount) do {
    case 0: {call getLastPointId; 0 = [] spawn {dropPlane1 call MySpawnAI; dropPlane2 call MySpawnAI; dropPlane3 call MySpawnAI; dropPlane4 call MySpawnAI; MyPlayersCount = (sideEnemy countSide allUnits) + (count units MyTeamSquad); publicVariable "MyPlayersCount"; sleep 1; call EventHandlerAdder; sleep 0.1; call EndTrGenerator; };};
    case 1: {call getLastPointId; ExpectedPlayerCount = 50; 0 = [] spawn {dropPlane1 call MySpawnAI; sleep 10; dropPlane2 call MySpawnAI; sleep 10; dropPlane3 call MySpawnAI; MyPlayersCount = (sideEnemy countSide allUnits) + (count units MyTeamSquad); publicVariable "MyPlayersCount";; sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
    case 2: {call getLastPointId; ExpectedPlayerCount = 30; 0 = [] spawn {dropPlane1 call MySpawnAI; sleep 10; dropPlane2 call MySpawnAI; sleep 10; dropPlane3 call MySpawnAI; MyPlayersCount = (sideEnemy countSide allUnits) + (count units MyTeamSquad); publicVariable "MyPlayersCount";; sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
    case 3: {call getLastPointId; ExpectedPlayerCount = 10; 0 = [] spawn {dropPlane1 call MySpawnAI; sleep 10; dropPlane2 call MySpawnAI; sleep 10; dropPlane3 call MySpawnAI; MyPlayersCount = (sideEnemy countSide allUnits) + (count units MyTeamSquad); publicVariable "MyPlayersCount";; sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
	default { hint "ERROR - WRONG BRSEAICount !" };
};

switch (BRSEWeather) do {
    case 0: {};
    case 1: {_randFog = random [0.4,0.5,1]; 99999 setFog _randFog; forceWeatherChange;};
	case 2: {10  setOvercast 0.9; forceWeatherChange;};
	case 3: {10  setOvercast 1; 10  setRain 1; forceWeatherChange;};
	case 4: {_rainRandom = random (1); _rainbowRandom = random (1); _fogRandom = random (1); _overcastRandom = random (1); 10 setOverCast _overcastRandom; 10 setRain _rainRandom; if ( _overcastRandom > 0.7 && _rainRandom < 0.2) then {10 setFog _fogRandom}; 10 setRainbow _rainbowRandom; forceWeatherChange;};
    case 5: {IsWeatherVariable = true;};
	default { hint "ERROR - WRONG BRSEAICount !" };
};

switch (BRSETime) do {
    case 0: {};
    case 1: {skipTime 12;};
	case 2: {skipTime 16;};
	case 3: {skipTime 2;};
	case 4: {_rTimeTS= floor random(25); skipTime _rTimeTS;};
	case 5: {IsTimeVariable = true;};
    default { hint "ERROR - WRONG BRSEAICount !" };
};

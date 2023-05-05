dropCount = 0;
randompos = floor random(15);
MyPlayersCount = 0;
PublicVariable "MyPlayersCount";
PlaneXOffset = 0;
randomFloorpl1 = 68;
randomFloorpl2 = 95;
PlaneZOffset = 100;
firstTimerRun = true;
myplayers =0;
LastPosition = position EndTr;//[0,0,0];
IsSpawnLoaded = false;
YouAreGettingDamage = parseText "<t color='#F7C69B' size='1.5'>You are getting damage! <br/> Move inside the safe zone</t>"; 
BRSEWeather = 0;
probaray = [50,50,50,20,0];
combatBehav = "COMBAT";
MainHeroesArray = ["C_man_1","C_man_polo_1_F_afro","C_man_polo_1_F_euro","C_man_polo_1_F_asia","C_man_1","C_man_polo_3_F_afro","C_man_polo_4_F_euro","C_man_polo_4_F_asia","C_man_polo_6_F","C_man_polo_6_F_afro","C_man_polo_6_F_euro","C_man_polo_6_F_asia","C_scientist_F","C_man_hunter_1_F","C_journalist_F","C_Orestes","C_Driver_2_F","C_Marshal_F","C_man_sport_1_F_euro","C_man_sport_1_F_afro","C_man_sport_1_F_asia","C_man_sport_2_F_euro","C_man_sport_2_F_afro","C_man_sport_2_F_asia","C_man_sport_3_F_euro","C_man_sport_3_F_afro","C_man_sport_3_F_asia","O_G_Survivor_F","B_Survivor_F","I_G_Survivor_F"];
BRSETime =0;
isFatigueEnabled = 1;
EnableCustomHudMode = 1;
DayNightCycle = 0;
ExpectedPlayerCount = 2;
flag_pressed = false;
plalive =15000;
addGPS = 0;
LSgr =1;
KillsCounter =0;
IsWeatherVariable = false;
IsTimeVariable = false;
PossibleSquadArray = playableUnits;
EnableSquad = "MPEnableSquad" call BIS_fnc_getParamValue;
SquadAISize = "MPAddSquadAI" call BIS_fnc_getParamValue;
MyTeamSquad = creategroup west;
RoundTime = "MPRoundTime" call BIS_fnc_getParamValue;
//RoundArea = "MPRoundArea" call BIS_fnc_getParamValue;
RoundArea = worldSize / 3;
LootProbability = "MPLootProbability" call BIS_fnc_getParamValue;
VehicleMarkers = "MPVehicleMarkers" call BIS_fnc_getParamValue;
LootMarkers = "MPLootMarkers" call BIS_fnc_getParamValue;

switch(randompos) do{
	case 0: {LSgr =1};
	case 1: {LSgr =3}; 
	case 2: {LSgr =1};
	case 3: {LSgr =1};
	case 4: {LSgr =1};
	case 5: {LSgr =2};
	case 6: {LSgr =2};
	case 7: {LSgr =2};
	case 8: {LSgr =2};
	case 9: {LSgr =2};
	case 10: {LSgr =2};
	case 11: {LSgr =2};
	case 12: {LSgr =2};
	case 13: {LSgr =1};
	case 14: {LSgr =1};
};

SquadProcessor = {
if (EnableSquad > 0) then {
//diag_log format ["PossibleSquadArray: %1;",PossibleSquadArray]; 
//diag_log format ["playableUnits: %1;",playableUnits];
AIHelperArray = [];
{	
//isplx = isPlayer _x;
//diag_log format ["isplx: %1;",isplx];
if (isPlayer _x) then {
//[[_x], MyTeamSquad] remoteExec ["join"];
[_x] join MyTeamSquad;
[_x, 20000] remoteExec ["addRating"];
//_x addRating 20000;
_x addItem "ItemRadio";
_x assignItem "ItemRadio";
//PossibleSquadArray deleteAt (PossibleSquadArray find _x);		
}
else {
AIHelperArray pushBack _x;
};
}forEach PossibleSquadArray;
diag_log format ["SquadAISizeBefore: %1;", SquadAISize];
diag_log format ["possqar: %1;",PossibleSquadArray];	
if(SquadAISize > 0) then {
{
if (SquadAISize == 0) exitWith {};
diag_log format ["_x: %1;",_x];
[_x] join MyTeamSquad;
_x addRating 10000;
_x addItem "ItemRadio";
_x assignItem "ItemRadio";
_x addBackpackGlobal "B_parachute";
SquadAISize = SquadAISize - 1;
diag_log format ["SquadAISizeInCycle: %1;", SquadAISize];
}forEach AIHelperArray;	
};
};
};

call SquadProcessor;

ChangeWeatherOrTime = {
	if (DayNightCycle < 1) then {
		if (IsWeatherVariable) then {
			_rainRandom = random (1);
			_rainbowRandom = random (1);
			_fogRandom = random (1);
			_overcastRandom = random (1);
			10 setOverCast _overcastRandom;
			10 setRain _rainRandom;
			if ( _overcastRandom > 0.7 && _rainRandom < 0.2) then {10 setFog _fogRandom}; 
			10 setRainbow _rainbowRandom;
			forceWeatherChange;	
		};
		if (IsTimeVariable) then {
			_rTimeTS= floor random(25);
			skipTime _rTimeTS;
		};
	};
};

EnableDayNightCicle = {
480000 setOverCast 0;
480000 setRain 0;
480000 setFog 0;
forceWeatherChange;
	0 = [] spawn {
		while {true} do 
		{
			sleep 0.2;
			skipTime 0.00375;
		};
	};
};

addKillCounter  = {
KillsCounter= KillsCounter +1;
call updateUI;
};


updateUI = {
if (EnableCustomHudMode>0) then {
disableSerialization;

_display = uiNamespace getVariable "hudScrDisplay";
_textPlayersAlive = _display displayCtrl 1905;
_textPlayersAlive ctrlSetText format["%1",MyPlayersCount];
//[_textPlayersAlive,"format['%1',MyPlayersCount]" ] remoteExec["ctrlSetText"];

_textKillsCounter = _display displayCtrl 1908;
_textKillsCounter ctrlSetText format["%1",KillsCounter];

_textHP = _display displayCtrl 1902;
_playerDmg = (damage player)*100;
_playerDmg = floor (100 - _playerDmg);
_textHP ctrlSetText format["HP: %1/100",_playerDmg];	

_textRound = _display displayCtrl 1911;
_textRound ctrlSetText format["%1",roundCounter];

//_textRoundTime = _display displayCtrl 1913;
//_roundTimeStr = missionNameSpace getVariable ["roundTimeStr",0];
//_textRoundTime ctrlSetText format ["%1", _roundTimeStr];
//_currentTime = triggerTimeoutCurrent (TriggersArray select roundCounter);
//_currentTimeMMSS = [floor(_currentTime)+1, "HH:MM"] call BIS_fnc_secondsToString;
//_textRoundTime ctrlSetText format ["%1", _currentTimeMMSS];
//_remainingTime = floor(triggerTimeoutCurrent (TriggersArray select roundCounter))+1; 
//_remainingTimeMMSS = [floor(_remainingTime)+1, "HH:MM"] call BIS_fnc_secondsToString;
//_textRoundTime ctrlSetText format ["%1", _remainingTimeMMSS];

_textBlack = _display displayCtrl 1900;
_WidthAr = ctrlPosition _textBlack;
_Width = _WidthAr select 2;

_textHPRed = _display displayCtrl 1901;
_textHPRedpos = ctrlPosition _textHPRed;
_textHPRedposX= _textHPRedpos select 0;
_textHPRedposY= _textHPRedpos select 1;
_textHPRedWidth = _textHPRedpos select 2;
_textHPRedHeight = _textHPRedpos select 3;
_textHPRedWidth = (_Width/100) * _playerDmg;
_textHPRed ctrlSetPosition [_textHPRedposX,_textHPRedposY,_textHPRedWidth,_textHPRedHeight];
_textHPRed ctrlCommit 0;
};
};

test_logger = {
diagcall = (count allUnits);
diagPlay = (count allPlayersmy);
diag_log format ["PlayersAliveActual(countAllunits): %1; PlayersAlive(plalive): %2; AllPlayersMy(count): %3;", diagcall, plalive, diagPlay];
diag_log format ["AllUnits: %1;", AllUnits];
diag_log format ["AllPlayersMy: %1;", allPlayersmy];
diag_log format ["MyPlayersCount: %1;", MyPlayersCount];	
};




removeCarTriggers = {
TrigCount = 1;
while {TrigCount < 367} do {
TrigCount = TrigCount +1;
ConstStrToDelete = "MyCarSpawnTrigger_" + (str TrigCount);
_obj = missionNamespace getVariable [ConstStrToDelete, objNull];
deleteVehicle _obj;
};
};

removeLootTriggers = {
TrigCount = 1;
while {TrigCount < 367} do {
TrigCount = TrigCount +1;
ConstStrToDelete = "MyLootSpawnTrigger_" + (str TrigCount);
_obj = missionNamespace getVariable [ConstStrToDelete, objNull];
deleteVehicle _obj;
};
};

myfuncLS = compile preprocessFileLineNumbers "lootspawn.sqf";
myfuncCS = compile preprocessFileLineNumbers "carspawn.sqf";


LootSpawnRandomizer = {
_LStrigger = _this select 0;
_nObjectsArray = _LStrigger nearObjects 20;
{   
    if (isPlayer _x == False && ((typeOf _x == "BOX_NATO_AmmoOrd_F") == False) && _forEachIndex < 3) then { 
        _amishouldSpawn = floor random (LootProbability); 
        if(_amishouldSpawn == 0) then {
            _checkType = typeOf _x;  
            _resultPump = _checkType find "_pump";  
            _resultKiosk = _checkType find "Land_Kiosk";  
            _resultTransformer = _checkType find "Land_spp_Transformer";   
            _resultPier = _checkType find "Land_Pier"; 
            _lootPlaces = _x buildingPos -1; 
            if (count _lootPlaces > 0) then {   
                {0 = [_x] call myfuncLS;}foreach _lootPlaces;   
            };
        };  
    };
}foreach _nObjectsArray;
deletevehicle _LStrigger;
};

//if ((_resultPump != 0) && (_resultKiosk != 0)&&(_resultTransformer != 0) && (_resultPier != 0)) then {  
//}foreach (_LStrigger nearObjects ["house", 300]);
//};  
//

createLootTriggers = {
_loot_terrain = ["HOUSE","BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","LIGHTHOUSE","RUIN","TOURISM","VIEW-TOWER","WATERTOWER","POWERWIND"];
//_vehicle_terrain = ["BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","LIGHTHOUSE","RUIN","TOURISM","VIEW-TOWER","WATERTOWER"];
//_na_terrain = ["BUSH","ROAD","RAILWAY","ROCK","ROCKS","STACK","SMALL TREE","TRACK","TREE","WALL","TRAIL","MAIN ROAD","FOREST BORDER","FOREST SQUARE","FOREST TRIANGLE","FOREST","FENCE","SHIPWRECK","TRACK","HIDE", "POWER LINES","TRANSMITTER","STACK","TRAIL","POWERSOLAR","TRANSMITTER","POWERWAVE","TRANSMITTER"];
private _buildTerrainObjects = nearestTerrainObjects
[
    [worldSize / 2, worldSize / 2],
    _loot_terrain,
    worldSize,
    false
];
{   
        _markerName = "Marker_MyLootSpawnTrigger_"+str _forEachIndex;
        if (LootMarkers==1) then {
            createMarker [_markerName, getPos _x];
            _markerName setMarkerType "mil_box";
            _markerName setMarkerColor "ColorBlack";
            _markerName setMarkerAlpha 1; 
        };
        _lootTriggerName = "MyLootSpawnTrigger_"+str _forEachIndex;
        _lootTrigger = createTrigger ["EmptyDetector", getPosWorld _x, false];
        _lootTrigger setTriggerArea [10, 10, getDir _x, false];
        _lootTrigger setTriggerActivation ["ANYPLAYER", "PRESENT", false]; //_lootTrigger setTriggerActivation ["NONE", "NONE", false];
        _lootTrigger setTriggerStatements
        [
            "this", //this //LSgr > 0
            "0=[thisTrigger] call LootSpawnRandomizer;",
            ""
        ];
        missionNamespace setVariable [_lootTriggerName, _lootTrigger];
} forEach _buildTerrainObjects;
};



createCarTriggers = {
//_loot_terrain = ["HOUSE","BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","LIGHTHOUSE","RUIN","TOURISM","VIEW-TOWER","WATERTOWER","POWERWIND"];
_vehicle_terrain = ["BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","LIGHTHOUSE","RUIN","TOURISM","VIEW-TOWER","WATERTOWER"];
//_na_terrain = ["BUSH","ROAD","RAILWAY","ROCK","ROCKS","STACK","SMALL TREE","TRACK","TREE","WALL","TRAIL","MAIN ROAD","FOREST BORDER","FOREST SQUARE","FOREST TRIANGLE","FOREST","FENCE","SHIPWRECK","TRACK","HIDE", "POWER LINES","TRANSMITTER","STACK","TRAIL","POWERSOLAR","TRANSMITTER","POWERWAVE","TRANSMITTER"];
private _roadTerrainObjects = nearestTerrainObjects
[
    [worldSize / 2, worldSize / 2],
    _vehicle_terrain,
    worldSize,
    false
];
{   
    _markerName = "Marker_MyCarSpawnTrigger_"+str _forEachIndex;
    if (VehicleMarkers == 1) then {
        createMarker [_markerName, getPos _x];
        _markerName setMarkerType "respawn_unknown";
        _markerName setMarkerColor "ColorBlue";
        _markerName setMarkerAlpha 1; 
    };
    _carTriggerName = "MyCarSpawnTrigger_"+str _forEachIndex;
    _carTrigger = createTrigger ["EmptyDetector", getPosWorld _x, false];
	_carTrigger setTriggerArea [50, 50, getDir _x, false];
    _carTrigger setTriggerActivation ["ANYPLAYER", "PRESENT", false]; //_carTrigger setTriggerActivation ["NONE", "NONE", false];
	_carTrigger setTriggerStatements
	[
        "this", //"(LSgr == 1) || (LSgr == 3)",
        "0=[thisTrigger] call myfuncCS;",
        ""
	];
    missionNamespace setVariable [_carTriggerName, _carTrigger];
} forEach _roadTerrainObjects;
};

call createLootTriggers;
call createCarTriggers;

mortarAmmoAr = ["32Rnd_155mm_Mo_shells","6Rnd_155mm_Mo_smoke","6Rnd_155mm_Mo_mine"];
mortarsCrew = [mortar1C,mortar1D,mortar1G,mortar2C,mortar2D,mortar2G,mortar3C,mortar3D,mortar3G,mortar4C,mortar4D,mortar4G,mortar5C,mortar5D,mortar5G,mortar6C,mortar6D,mortar6G,mortar7C,mortar7D,mortar7G];

safeArr = [lootPlane,lootPlanePilot_1];

AreasArray = [RoundArea,RoundArea*(-log (1-0.9)),RoundArea*(-log (1-0.8)),RoundArea*(-log (1-0.7)),RoundArea*(-log (1-0.6)),RoundArea*(-log (1-0.5)),RoundArea*(-log (1-0.4)),RoundArea*(-log (1-0.3)),RoundArea*(-log (1-0.2)),RoundArea*(-log (1-0.1)),100];
TimeArray = [RoundTime,RoundTime*0.9,RoundTime*0.8,RoundTime*0.7,RoundTime*0.6,RoundTime*0.5,RoundTime*0.5,RoundTime*0.5,RoundTime*0.5,RoundTime*0.5,RoundTime*0.5];
ExtendedTimeArray = [RoundTime,120+RoundTime*0.9,120+RoundTime*0.8,120+RoundTime*0.7,120+RoundTime*0.6,120+RoundTime*0.5,120+RoundTime*0.5,120+RoundTime*0.5,120+RoundTime*0.5,120+RoundTime*0.5,120+RoundTime*0.5];
missionNameSpace setVariable ["TimeArray", TimeArray];

TriggersArray = [round_tigger_1,round_tigger_2,round_tigger_3,round_tigger_4,round_tigger_5,round_tigger_6,round_tigger_7,round_tigger_8,round_tigger_9,round_tigger_10,round_tigger_11];
Trigger2Helpers = [round_tigger_2_helper_1,round_tigger_2_helper_2];
TriggersGameplayArray = [gameplay_trig_1, gameplay_trig_3, gameplay_trig_4];

InitTimeStart = 10;
InitTimeTOC = 60;
InitTimeToAdd = InitTimeStart+InitTimeTOC;
StartTimeToAdd = InitTimeToAdd;
ExtendedTimeMode = 0;
LootBots = objNull;


TimeInTriggers = {
	counterArrays = 0;
	{
		if (ExtendedTimeMode == 1) then {
            StartTimeToAdd = StartTimeToAdd + (ExtendedTimeArray select counterArrays); 
        } else  {
            StartTimeToAdd = StartTimeToAdd + (TimeArray select counterArrays); 
        };
		if(counterArrays ==0) then {
        //gameplay_trig_1 setTriggerTimeout [((gameplay_trig_1 triggerTimeout) select 0) + InitTimeToAdd,((gameplay_trig_1 triggerTimeout) select 1) + InitTimeToAdd,((gameplay_trig_1 triggerTimeout) select 2) + InitTimeToAdd,false];
		 round_tigger_2_helper_1 setTriggerTimeout [StartTimeToAdd-0.5,StartTimeToAdd-0.5,StartTimeToAdd-0.5,false];
		 round_tigger_2_helper_2 setTriggerTimeout [StartTimeToAdd-0.5,StartTimeToAdd-0.5,StartTimeToAdd-0.5,false];
		};
		_x setTriggerTimeout [StartTimeToAdd,StartTimeToAdd,StartTimeToAdd,false];
		counterArrays = counterArrays +1;
	}forEach TriggersArray;
    
};
call TimeInTriggers;


TimeInTriggersGameplay = {
	counterArrays = 0;
	{
		StartTimeToAdd = StartTimeToAdd + (TimeArray select counterArrays); 
		_x setTriggerTimeout [StartTimeToAdd,StartTimeToAdd,StartTimeToAdd,false];
		counterArrays = counterArrays +1;
	}forEach TriggersGameplayArray;
};


sleepArtTime =60;
mymortarrs = [mortar1,mortar2,mortar3,mortar4,mortar5,mortar6,mortar7];
randAmmo =0;
enableDangerZones =0;
PIL = mymortarrs + mortarsCrew + safeArr;

DropCargoInGame = {
DropPointPos = _this select 0;	
DropPointPos set [2,150];

0 = createMarker ["DropLootMarker", DropPointPos]; 
"DropLootMarker" setMarkerSize [250, 250]; 
"DropLootMarker" setMarkerShape "ELLIPSE"; 
"DropLootMarker" setMarkerColor "ColorYellow";

_infohint = format ["CARGO DROP INCOMING!"];
[1,[_infohint, "PLAIN DOWN", 0.6]] remoteExec ["cutText"];


PlanePos = [[[DropPointPos, 2500]],["water"]] call BIS_fnc_randomPos; 
PlanePosZ = PlanePos select 2; 
PlanePos set [2, 300]; 

//dropCargoPos = DropPointPos;
//PlanePosZ = dropCargoPos select 2;
//dropCargoPos set [2,PlanePosZ + 150]; 

LeavePos = [[[DropPointPos, 2500]],["water"]] call BIS_fnc_randomPos;
LeavePosZ = LeavePos select 2;
LeavePos set [2, 300]; 
   
lootPlane setPos PlanePos;
_grp = group lootPlane; 
while {(count (waypoints _grp)) > 0} do{ deleteWaypoint ((waypoints _grp) select 0);};

_wp = _grp addWaypoint [DropPointPos, 0];  
_grp setBehaviour "CARELESS";           
_wp setWaypointType "MOVE"; 
_wp setWaypointStatements["true","0 = [] execVM 'planeDrop.sqf';"]; 
 
_wp = _grp addWaypoint [LeavePos,0]; 
_wp setWaypointType "MOVE"; 
_wp setWaypointStatements["true","lootPlane setPos [0,0,150]; _grp = group lootPlane; _wp = _grp addWaypoint [[0,0,150],0]; _wp setWaypointType 'LOITER'; "];
};


ArttilleryStrike = {
randAmmo = floor (random 3); 
randAmmoName = mortarAmmoAr select randAmmo;
{
sleep 0.1;
0 = [_x] spawn {
_x = _this select 0;
_artStrikePos = DangerZonePos getPos [150 * sqrt random 1, random 360]; 

_x commandArtilleryFire [_artStrikePos, randAmmoName, 4];  
etaTime = mortar1 getArtilleryETA [_artStrikePos, randAmmoName];
switch (randAmmo) do {
case 0: {sleepArtTime = 6 + etaTime};
case 1: {sleepArtTime = 16 + etaTime};
case 2: {sleepArtTime = 14 + etaTime};
};
sleep sleepArtTime;
_x removeMagazineTurret [randAmmoName, [0]];
_x addMagazineTurret [randAmmoName, [0]]; 
};
} forEach mymortarrs; 
};


roundCounter = 1;
Traveler = {
_hum = _this select 0;
_rad = _this select 1;
_grp = group _hum;
_lastPosHuman = [[[position _hum, _rad]],["water"]] call BIS_fnc_randomPos;        
_wp = _grp addWaypoint [_lastPosHuman, 0];             
_wp setWaypointType "MOVE";
};

lootKiller={
_myhuman = _this select 0; 
_mycargo = nearestObjects [position _myhuman, ["BOX_NATO_AmmoOrd_F"], 5];  
if (count _mycargo != 0) then {
_mycargo = _mycargo select 0;
clearweaponcargo _mycargo;
clearmagazinecargo _mycargo;
clearItemCargo _mycargo;
clearBackpackCargo _mycargo;
deleteVehicle _mycargo;
}
else {};};


lootDeleterWp = {
_hum = _this select 0;
_place = _this select 1;
_grp = group _hum;
_wp = _grp addWaypoint [_place,0];
_wp setWaypointType "MOVE";
_wp SetWaypointStatements ["true","[this] call lootkiller"];
};

waypointAdder = {
_hum = _this select 0;
_place = _this select 1;
_grp = group _hum;
_wp = _grp addWaypoint [_place,0];
_wp setWaypointType "MOVE";
};

BuildingCamper = {
_hum = _this select 0;
_rad = _this select 1;
_humnobj = nearestBuilding _hum; 
_distToBuild = _humnobj distance2d _hum;
if(_distToBuild < _rad) then {
[_hum,_humnobj] call waypointAdder;
}
};

lootTaker = {
_hum = _this select 0;
_rad = _this select 1;
_humobj = _hum nearObjects ["BOX_NATO_AmmoOrd_F", _rad];
if(_rad > 150) then {_rad = 150};
{
[_hum,_x] call lootDeleterWp;
}foreach _humobj; 
};

PatroolCamper = {
_hum = _this select 0;
_rad = _this select 1;
if (_rad > 100) then {_rad = 100};
_bigRad = 25;
_smallRad = 10;
if (roundCounter > 7) then { _bigRad =5;_smallRad = 2; _rad = 0};
_grp = group _hum;
_phum = getPos _hum;
_phum = [[[_phum, _rad]],["water"]] call BIS_fnc_randomPos;
_phum2 = [[[_phum, _smallRad]],["water"]] call BIS_fnc_randomPos;
_phum3 = [[[_phum2, _bigRad]],["water"]] call BIS_fnc_randomPos;
_wp1 = _grp addWaypoint [_phum,0];
_wp1 setWaypointType "MOVE";
_wp2 = _grp addWaypoint [_phum2,0];
_wp2 setWaypointType "MOVE";
_wp3 = _grp addWaypoint [_phum3,0];
_wp3 setWaypointType "CYCLE";
};

timeKillerAdapter = {
_hum = _this select 0;
_SmallCircleS = AreasArray select roundCounter;
_xHumanPos = getPosWorld _hum; 
_dist = _xHumanPos distance2D LastPosition;
_possibleTKdist = _SmallCircleS - _dist;
[_hum,_possibleTKdist] call timeKiller;
};

lastPointRunner = {
_hum = _this select 0;
_rad = _this select 1;
if(roundCounter > 7) then {
_rad = 1;
};
_grp = group _hum;
_grp setBehaviour 'AWARE';     
_wp = _grp addWaypoint [LastPosition, _rad];            
_wp setWaypointType "MOVE";
_wp setWaypointCombatMode "RED";
};

CamperKiller = {
_hum = _this select 0;
_rad = _this select 1;
if(_rad>100) then {_rad = 100};
_humnobj = _hum nearObjects ["house", _rad];
{  
_checkType = typeOf _x; 
_resultPump = _checkType find "_pump"; 
_resultKiosk = _checkType find "Land_Kiosk"; 
_resultTransformer = _checkType find "Land_spp_Transformer";  
_lootPlaces = _x buildingPos -1; 
if (count _lootPlaces > 0) then {  
if ((_resultPump != 0) && (_resultKiosk != 0)&&(_resultTransformer != 0)) then { 
_rp = floor random (2);
 if (_rp < 1) then {
 {[_hum,_x] call waypointAdder;}foreach _lootPlaces;};
};
}
else {
[_hum,_x] call waypointAdder;};
}foreach _humnobj; 
};

runner = {
_hum = _this select 0;
_smallCircleSize = _this select 1;
_grp = group _hum;
_grp setBehaviour 'AWARE';
_lastPosHuman = [[[LastPosition, _smallCircleSize]],["water"]] call BIS_fnc_randomPos;        
_wp = _grp addWaypoint [_lastPosHuman, 0];            
_wp setWaypointType "MOVE";
_dstc = _lastPosHuman distance2D LastPosition;
_dstc = _smallCircleSize - _dstc;
_wp setWaypointStatements["true","[this] call timeKillerAdapter"];
};

timeKiller = {
_hum = _this select 0;
_range = _this select 1;
_profchooser = floor random[0,3,5];
if (roundCounter >7) then { _profchooser =4};
switch(_profchooser) do{
case 1: {[_hum,_range] call lootTaker};
case 2: {[_hum,_range] call CamperKiller};
case 3: {[_hum,_range] call BuildingCamper};
case 4: {[_hum,_range] call PatroolCamper};
case 5: {[_hum,_range] call Traveler};
default {[_hum,_range] call Traveler};
};
};

DangerZoneGenerator = {
0 = [] spawn {
	
sleep 8;
_infohint = format ["DANGER ZONE WILL BE ACTIVATED IN 30 SEC."];
[1,[_infohint, "PLAIN DOWN", 0.6]] remoteExec ["cutText"];

0 = createMarker ["DangerMarker", DangerZonePos]; 
"DangerMarker" setMarkerSize [150, 150]; 
"DangerMarker" setMarkerShape "ELLIPSE"; 
"DangerMarker" setMarkerColor "ColorRed";

call ArttilleryStrike;

sleep 30;

_infohint = format ["DANGER ZONE HAS BEEN ACTIVATED. STAY SAFE."];
[1,[_infohint, "PLAIN DOWN", 0.6]] remoteExec ["cutText"];

sleep sleepArtTime; 

if (randAmmo <2) then {
_infohint = format ["DANGER ZONE DEACTIVATED"];
[1,[_infohint, "PLAIN DOWN", 0.6]] remoteExec ["cutText"];
}
else {
_infohint = format ["DANGER ZONE DEACTIVATED. WATCH OUT FOR MINES."];
[1,[_infohint, "PLAIN DOWN", 0.6]] remoteExec ["cutText"];
};
deleteMarker "DangerMarker";
};	
};

notifyGenerator = {
_TotalSec = _this select 0; 
0 = [_TotalSec] spawn { 
_TotalSec = _this select 0; 
PutTimerSleep =0; 
_TotalSec = _TotalSec - 5;
sleep 5;
while {_TotalSec > 0} do { 
_infohint = "none"; 
_exptimeSec = _TotalSec; 
if(_TotalSec >= 60) then {	
_exptimeMin = floor (_TotalSec / 60); 
_actSec = _TotalSec % 60; 
_checkDif = _TotalSec - 60; 
if(_checkDif < 10) then {if (_checkDif > 0) then {sleep _checkDif; _actSec = _actSec - _checkDif;}; _TotalSec = _TotalSec - _checkDif; PutTimerSleep = 10; _TotalSec = _TotalSec-10;} 
else { if (_actSec != 0) then {_TotalSec = _TotalSec - _actSec; PutTimerSleep = _actSec;} else { 
_TotalSec = _TotalSec-60; PutTimerSleep=60;}; 
}; 
_infohint = format ["THE SAFE ZONE WILL BE RESTRICTED IN %1 MIN %2 SEC",_exptimeMin, _actSec]; 
} 
else { 
if (_TotalSec > 9) then { 
_sleeptime = _TotalSec%10; 
if (_sleeptime > 0 ) then {sleep _sleeptime;}; 
_SecToShow = _TotalSec - _sleeptime; 
_infohint = format ["ALL PLAYERS OUTSIDE THE ZONE WILL RECEIVE DAMAGE IN %1 SEC",_SecToShow]; 
_TotalSec = _TotalSec - 10; 
PutTimerSleep = 10; 
};}; 
if (_infohint isEqualTo "none") then {} else {[1,[_infohint, "PLAIN DOWN", 0.7]] remoteExec ["cutText"];}; 
if (PutTimerSleep >0) then {sleep PutTimerSleep}; 
};
if (roundCounter < 10) then {
_infohint = format ["THE SAFE ZONE HAS BEEN RESTRICTED"]; [1,[_infohint, "PLAIN DOWN", 0.7]] remoteExec ["cutText"]; 
}
else {
_infohint = format ["THE SAFE ZONE IS STABLE NOW. KILL THEM ALL"]; [1,[_infohint, "PLAIN DOWN", 0.7]] remoteExec ["cutText"];
};
};
}; 
 
graphicsCreator = {
_bigCircleSize = _this select 1;
_smallCircleSize = _this select 0;
"EndTrMarker" setMarkerSize [_smallCircleSize, _smallCircleSize]; 
"EndTrMarker" setMarkerPos LastPosition;

"EndTrMarker2" setMarkerSize [_bigCircleSize, _bigCircleSize]; 
"EndTrMarker2" setMarkerPos position EndTr;

myemitter setPos (position EndTr);  
myemitter1 setPos (position EndTr);  
myemitter2 setPos (position EndTr);  
myemitter3 setPos (position EndTr);  
myemitter4 setPos (position EndTr); 
myemitter5 setPos (position EndTr); 
myemitter6 setPos (position EndTr); 
  
myemitter setParticleCircle [_bigCircleSize,[0,0,5]];  
myemitter1 setParticleCircle [_bigCircleSize,[0,0,5]];  
myemitter2 setParticleCircle [_bigCircleSize,[0,0,5]];  
myemitter3 setParticleCircle [_bigCircleSize,[0,0,5]]; 
myemitter4 setParticleCircle [_bigCircleSize,[0,0,5]];  
myemitter5 setParticleCircle [_bigCircleSize,[0,0,5]]; 
myemitter6 setParticleCircle [_bigCircleSize,[0,0,5]];
};

graphicsCreatorEnd = {
_bigCircleSize = _this select 1;
_smallCircleSize = _this select 0;

"EndTrMarker" setMarkerSize [_bigCircleSize, _bigCircleSize]; 
"EndTrMarker" setMarkerPos position EndTr;

deleteMarkerLocal "EndTrMarker2";

myemitter setPos (position EndTr);  
myemitter1 setPos (position EndTr);  
myemitter2 setPos (position EndTr);  
myemitter3 setPos (position EndTr);  
myemitter4 setPos (position EndTr); 
myemitter5 setPos (position EndTr); 
myemitter6 setPos (position EndTr); 
myemitter setParticleCircle [_bigCircleSize,[0,0,5]];  
myemitter1 setParticleCircle [_bigCircleSize,[0,0,5]];  
myemitter2 setParticleCircle [_bigCircleSize,[0,0,5]];  
myemitter3 setParticleCircle [_bigCircleSize,[0,0,5]]; 
myemitter4 setParticleCircle [_bigCircleSize,[0,0,5]];  
myemitter5 setParticleCircle [_bigCircleSize,[0,0,5]]; 
myemitter6 setParticleCircle [_bigCircleSize,[0,0,5]];
};

triggerLogicCreator = {
0 = [] spawn {

_BigCircleS = AreasArray select (roundCounter-1);
_SmallCircleS = AreasArray select roundCounter;
_LasPosPossibleRad = _BigCircleS - _SmallCircleS;
EndTr setPos LastPosition;
_timeNote = 0;

DangerZoneRad = _BigCircleS - 150;
DangerZonePos = [[[LastPosition, DangerZoneRad]],["water"]] call BIS_fnc_randomPos; 

DropCargoZoneRad = _BigCircleS - 250;
DropCargoZonePos = [[[LastPosition, DropCargoZoneRad]],["water"]] call BIS_fnc_randomPos; 

call ChangeWeatherOrTime;
EndTr setTriggerArea [_BigCircleS,_BigCircleS,0,false];
LastPosition = [[[position EndTr, _LasPosPossibleRad]],["ban_marker","ban_marker_1","ban_marker_2","ban_marker_3","ban_marker_4","ban_marker_5","ban_marker_6","ban_marker_7","ban_marker_8","ban_marker_9","ban_marker_10","ban_marker_11"]] call BIS_fnc_randomPos;
if (roundCounter < 10) then {
[_SmallCircleS, _BigCircleS] call graphicsCreator;
}
else {
[_SmallCircleS, _BigCircleS] call graphicsCreatorEnd;	
};
//_SmallCircleS = _SmallCircleS * 0.8; 
SmallCircleSGlobal = _SmallCircleS;
if (ExtendedTimeMode == 0) then 
{_timeNote = TimeArray select (roundCounter);}
else {_timeNote = ExtendedTimeArray select (roundCounter);};

if (roundCounter < 4 && enableDangerZones > 0) then {
call DangerZoneGenerator;	
};

if (roundCounter < 4) then {
0 = [] spawn {
sleep 12;
[DropCargoZonePos] call DropCargoInGame;	
};
};

if (roundCounter < 10) then {
[_timeNote] call notifyGenerator;
};
{
sleep 0.1;
_xHumanPos = getPosWorld _x; 
_dist = _xHumanPos distance2D LastPosition;
if ((!isPlayer _x) && ((side _x) == sideEnemy)) then {
_grp = group _x;
_possibleTKdist=0;                
while {(count (waypoints _grp)) > 0} do{ deleteWaypoint ((waypoints _grp) select 0);};  
unassignVehicle _x;
moveOut _x; 
[_x] allowGetIn false;
_grp setBehaviour "AWARE";
	if (_dist < _SmallCircleS) then 
	{
		if (roundCounter > 5) then {
			[_x,_SmallCircleS] call lastPointRunner;
		}
		else 
		{
			_possibleTKdist = _SmallCircleS - _dist;
			[_x,_possibleTKdist] call timeKiller;
		}
	 }
	else 
	{
	 _carWP = floor(random 4);
	 _carFindRad = _BigCircleS - _dist;
	 if(_carFindRad < 0) then {_carFindRad = 150};
	 if(_carFindRad > 250) then {_carFindRad =250};
	 _cargAr = nearestObjects [position _x,["car"],_carFindRad];
	 _myCar = _cargAr select 0;  	
	 _grp = group _x;
		if ((_carWP > 0) && (count _cargAr > 0)&&(roundCounter < 4)) then {_wp = _grp addWaypoint [position _myCar, 0]; _grp setBehaviour 'CARELESS'; _wp setWaypointType "GETIN NEAREST"; _wp setWaypointStatements ["true", "_grpt = group this; _carGroupPos = [[[LastPosition, SmallCircleSGlobal]],['water']] call BIS_fnc_randomPos;_a1 = _grpt addWaypoint [_carGroupPos, 0];_a1 setWaypointType 'GETOUT';_a1 setWaypointStatements['true','unassignVehicle this; moveOut this; _gr = group this; _gr setBehaviour combatBehav;'];"];}
		else {if (roundCounter < 6) then {[_x,_SmallCircleS] call runner;} else {[_x,_SmallCircleS] call lastPointRunner;};}; 
	};
};
} forEach allUnits;
if (roundCounter <4) then {
0 = [] spawn {
sleep 10; 
{
if ((!isPlayer _x) && ((side _x) == sideEnemy)) then {	
_distToCenter = _x distance2D LastPosition;
 if (_distToCenter > SmallCircleSGlobal) then { [_x,SmallCircleSGlobal] call runner; _grp = group _x;};
};}forEach allUnits;
deleteMarker "DropLootMarker";
};};
if (roundCounter-1 > 0) then {
_remainingTime = floor(TimeArray select (roundCounter)); 
[_remainingTime] execVM "timer.sqf"; 
};
roundCounter = roundCounter +1; 

	};
};


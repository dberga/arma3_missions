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
DayNightCycle = 0; //"MPEnableDayNightCycle" call BIS_fnc_getParamValue;

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
////_unit addEventHandler ["killed", "MyPlayersCount = MyPlayersCount -1; plalive = MyPlayersCount; publicVariable 'MyPlayersCount'; chatMsg = format ['%1 was killed by %2. Survivors: %3', (name (_this select 0)), (name (_this select 1)), MyPlayersCount]; [(_this select 0),chatMsg] remoteExec ['globalChat'];  remoteExec ['updateUI'];"];
//_unit addEventHandler ["killed", "MyPlayersCount = MyPlayersCount -1; plalive = MyPlayersCount; publicVariable 'MyPlayersCount'; if (isPlayer (_this select 1)) then {remoteExec ['addKillCounter',(_this select 1)]}; chatMsg = format ['%1 was killed by %2. Survivors: %3', (name (_this select 0)), (name (_this select 1)), MyPlayersCount]; [(_this select 0),chatMsg] remoteExec ['globalChat'];  remoteExec ['updateUI']; call test_logger;"];

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


_building_terrain=["BUILDING","BUNKER","BUSH","BUSSTOP","CHAPEL","CHURCH","CROSS","FENCE","FOREST BORDER","FOREST SQUARE","FOREST TRIANGLE","FOREST","FORTRESS","FOUNTAIN","FUELSTATION","HIDE","HOSPITAL","HOUSE","LIGHTHOUSE","MAIN ROAD","POWER LINES","POWERSOLAR","POWERWAVE","POWERWIND","QUAY","RAILWAY","ROAD","RUIN","SHIPWRECK","SMALL TREE","STACK","TOURISM","TRACK","TRAIL","TRANSMITTER","TREE","VIEW-TOWER","WALL","WATERTOWER"];
private _buildTerrainObjects = nearestTerrainObjects
[
    [worldSize / 2, worldSize / 2],
    _building_terrain,
    worldSize,
    false
];

_randp = floor random(count _buildTerrainObjects);
_mylastPlanePos = getPosWorld (_buildTerrainObjects select _randp);
[_myplane,_mylastPlanePos] call createWapoint;
_randp = floor random(count _buildTerrainObjects);
_mylastPlanePos = getPosWorld (_buildTerrainObjects select _randp);
[_myplane,_mylastPlanePos] call createWapoint;
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
IsSpawnLoaded = true;
0 = [] spawn { 
//call removeCarTriggers;
call removeLootTriggers;
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
//player addEventHandler ["killed", "(_this select 0) globalChat format ['%1 was killed by %2. Survivors: %3', (name (_this select 0)), (name (_this select 1)), MyPlayersCount];"];
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

drawPlaneRouteInWorld = {
    params ["_plane", "_color"];
    
    private _group = group _plane;
    private _waypoints = waypoints _group;
    private _planeName = vehicleVarName _plane;
    if (_planeName == "") then { _planeName = format ["Plane%1", round(random 1000)]; };
    
    // Get world boundaries
    private _worldSize = worldSize; // Usually 15360 for Altis, 20480 for Tanoa, etc.
    private _worldCenter = [_worldSize/2, _worldSize/2, 0];
    private _worldMin = 0;
    private _worldMax = _worldSize;
    
    // Get all positions within world bounds
    private _allPositionsFiltered = [];
    
    // Function to check if position is within world bounds
    private _fnc_isInWorldBounds = {
        params ["_pos2D", ["_buffer", 0]];
        private _x = _pos2D select 0;
        private _y = _pos2D select 1;
        
        // Check if within world boundaries (with optional buffer)
        (_x >= _buffer && _x <= _worldMax - _buffer && 
         _y >= _buffer && _y <= _worldMax - _buffer)
    };
    
    // Add starting position if within world
    private _startPos = getPos _plane;
    private _startPos2D = [_startPos select 0, _startPos select 1];
    
    if ([_startPos2D, 100] call _fnc_isInWorldBounds) then {
        _allPositionsFiltered pushBack _startPos2D;
        //systemChat format ["%1: Start position within world bounds", _planeName];
    } else {
        //systemChat format ["%1: Start position OUTSIDE world bounds! [%2, %3]", 
        //    _planeName, _startPos2D select 0, _startPos2D select 1];
    };
    
    // Process all waypoint positions
    for "_i" from 0 to (count _waypoints - 1) do {
        private _wpPos = waypointPosition (_waypoints select _i);
        private _wpPos2D = [_wpPos select 0, _wpPos select 1];
        
        // Check if within world bounds (with 100m buffer from edge)
        if ([_wpPos2D, 100] call _fnc_isInWorldBounds) then {
            _allPositionsFiltered pushBack _wpPos2D;
        } else {
            //systemChat format ["%1: Waypoint %2 OUTSIDE world bounds [%3, %4]", 
            //    _planeName, _i + 1, _wpPos2D select 0, _wpPos2D select 1];
        };
    };
    
    // Create a single polyline marker connecting all valid points
    if (count _allPositionsFiltered > 1) then {
        private _markerName = format ["%1_route_inworld", _planeName];
        private _marker = createMarker [_markerName, _allPositionsFiltered select 0];
        _marker setMarkerShape "POLYLINE";
        
        // Convert to flat array format required by setMarkerPolyline
        private _flatPositions = [];
        {
            _flatPositions pushBack (_x select 0); // x
            _flatPositions pushBack (_x select 1); // y
        } forEach _allPositionsFiltered;
        
        _marker setMarkerPolyline _flatPositions;
        _marker setMarkerColor _color;
        _marker setMarkerAlpha 0.7;
        _marker setMarkerBrush "Solid";
        _marker setMarkerSize [1.5, 0]; // Width of the line
        
        //systemChat format ["World route drawn for %1: %2 valid points", 
        //    _planeName, count _allPositionsFiltered];
    } else {
        if (count _allPositionsFiltered == 1) then {
            //systemChat format ["%1: Only 1 valid point in world, can't draw line", _planeName];
        } else {
            //systemChat format ["%1: No points within world bounds", _planeName];
        };
    };
    
    // Add waypoint markers at each valid point
    private _wpIndex = 0;
    {
        private _markerName = format ["%1_wp_%2", _planeName, _wpIndex];
        private _marker = createMarker [_markerName, _x];
        _marker setMarkerType "hd_pickup";
        _marker setMarkerColor _color;
        _marker setMarkerText format ["%1 WP%2", _planeName, _wpIndex + 1];
        _marker setMarkerSize [0.5, 0.5];
        _wpIndex = _wpIndex + 1;
    } forEach _allPositionsFiltered;
};
drawSimpleRoute = {
    params ["_plane", "_color"];
    
    private _group = group _plane;
    private _waypoints = waypoints _group;
    private _planeName = vehicleVarName _plane;
    if (_planeName == "") then { _planeName = format ["Plane%1", round(random 1000)]; };
    
    // Just create waypoint markers (no lines)
    for "_i" from 0 to (count _waypoints - 1) do {
        private _wpPos = waypointPosition (_waypoints select _i);
        private _wpPos2D = [_wpPos select 0, _wpPos select 1];
        
        private _markerName = format ["%1_wp_%2", _planeName, _i];
        private _marker = createMarker [_markerName, _wpPos2D];
        _marker setMarkerType "hd_pickup";
        _marker setMarkerColor _color;
        _marker setMarkerText format ["%1 WP%2", _planeName, _i + 1];
        _marker setMarkerSize [0.5, 0.5];
    };
    
    //systemChat format ["Waypoints marked for %1", _planeName];
};

if (isServer) then {
//switch (BRSEAICount) do {
//    case 0: {call getLastPointId; 0 = [] spawn {dropPlane1 call MySpawnAI; sleep 10; dropPlane2 call MySpawnAI; sleep 10; dropPlane3 call MySpawnAI; dropPlane4 call MySpawnAI; MyPlayersCount = (sideEnemy countSide allUnits) + (count units MyTeamSquad); publicVariable "MyPlayersCount";; sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
//    case 1: {call getLastPointId; ExpectedPlayerCount = 50; 0 = [] spawn {dropPlane1 call MySpawnAI; sleep 10; dropPlane2 call MySpawnAI; sleep 10; dropPlane3 call MySpawnAI; MyPlayersCount = (sideEnemy countSide allUnits) + (count units MyTeamSquad); publicVariable "MyPlayersCount";; sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
//    case 2: {call getLastPointId; ExpectedPlayerCount = 30; 0 = [] spawn {dropPlane1 call MySpawnAI; sleep 10; dropPlane2 call MySpawnAI; sleep 10; dropPlane3 call MySpawnAI; MyPlayersCount = (sideEnemy countSide allUnits) + (count units MyTeamSquad); publicVariable "MyPlayersCount";; sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
//    case 3: {call getLastPointId; ExpectedPlayerCount = 10; 0 = [] spawn {dropPlane1 call MySpawnAI; sleep 10; dropPlane2 call MySpawnAI; sleep 10; dropPlane3 call MySpawnAI; MyPlayersCount = (sideEnemy countSide allUnits) + (count units MyTeamSquad); publicVariable "MyPlayersCount";; sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
//	default { hint "ERROR - WRONG BRSEAICount !" };
//};



switch (BRSEAICount) do {
    case 0: {call getLastPointId; 0 = [] spawn {
        dropPlane1 call MySpawnAI; sleep 0.5; 
        [dropPlane1, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane2 call MySpawnAI; sleep 0.5; 
        [dropPlane2, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane3 call MySpawnAI; sleep 0.5; 
        [dropPlane3, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane4 call MySpawnAI; sleep 0.5; 
        [dropPlane4, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        
        _survivorCount = 0;
        _civilianEnemyCount = 0;
        
        {
            _varName = vehicleVarName _x;
            if (_varName != "") then {
                _hasSurvivor = (_varName find "Survivor") != -1;
                if (_hasSurvivor) then {
                    _survivorCount = _survivorCount + 1;
                    _playerType = if (isPlayer _x) then {"(Player)"} else {"(AI)"};
                    //systemChat format ["Found Survivor: %1 Name: %2 %3", _varName, name _x, _playerType];
                };
                
                _hasCivilian = (_varName find "Civilian") != -1;
                if (_hasCivilian) then {
                    _civilianEnemyCount = _civilianEnemyCount + 1;
                };
            };
        } forEach allUnits;
        
        //systemChat format ["Total Survivor units found: %1", _survivorCount];
        //systemChat format ["Total Civilian Enemy units found: %1", _civilianEnemyCount];
        
        MyPlayersCount = MyPlayersCount+_survivorCount; 
        CivilianEnemyCount = CivilianEnemyCount+_civilianEnemyCount;
        publicVariable "MyPlayersCount"; 
        publicVariable "CivilianEnemyCount";
        sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
    
    case 1: {call getLastPointId; ExpectedPlayerCount = 50; 0 = [] spawn {
        dropPlane1 call MySpawnAI; sleep 0.5; 
        [dropPlane1, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane2 call MySpawnAI; sleep 0.5; 
        [dropPlane2, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane3 call MySpawnAI; sleep 0.5; 
        [dropPlane3, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane4 call MySpawnAI; sleep 0.5; 
        [dropPlane4, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        
        _survivorCount = 0;
        _civilianEnemyCount = 0;
        
        {
            _varName = vehicleVarName _x;
            if (_varName != "") then {
                _hasSurvivor = (_varName find "Survivor") != -1;
                if (_hasSurvivor) then {
                    _survivorCount = _survivorCount + 1;
                    _playerType = if (isPlayer _x) then {"(Player)"} else {"(AI)"};
                    //systemChat format ["Found Survivor: %1 Name: %2 %3", _varName, name _x, _playerType];
                };
                
                _hasCivilian = (_varName find "Civilian") != -1;
                if (_hasCivilian) then {
                    _civilianEnemyCount = _civilianEnemyCount + 1;
                };
            };
        } forEach allUnits;
        
        //systemChat format ["Total Survivor units found: %1", _survivorCount];
        //systemChat format ["Total Civilian Enemy units found: %1", _civilianEnemyCount];
        
        MyPlayersCount = MyPlayersCount+_survivorCount; 
        CivilianEnemyCount = CivilianEnemyCount+_civilianEnemyCount;
        publicVariable "MyPlayersCount"; 
        publicVariable "CivilianEnemyCount";
        sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
    
    case 2: {call getLastPointId; ExpectedPlayerCount = 30; 0 = [] spawn {
        dropPlane1 call MySpawnAI; sleep 0.5; 
        [dropPlane1, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane2 call MySpawnAI; sleep 0.5; 
        [dropPlane2, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane3 call MySpawnAI; sleep 0.5; 
        [dropPlane3, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane4 call MySpawnAI; sleep 0.5; 
        [dropPlane4, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        
        _survivorCount = 0;
        _civilianEnemyCount = 0;
        
        {
            _varName = vehicleVarName _x;
            if (_varName != "") then {
                _hasSurvivor = (_varName find "Survivor") != -1;
                if (_hasSurvivor) then {
                    _survivorCount = _survivorCount + 1;
                    _playerType = if (isPlayer _x) then {"(Player)"} else {"(AI)"};
                    //systemChat format ["Found Survivor: %1 Name: %2 %3", _varName, name _x, _playerType];
                };
                
                _hasCivilian = (_varName find "Civilian") != -1;
                if (_hasCivilian) then {
                    _civilianEnemyCount = _civilianEnemyCount + 1;
                };
            };
        } forEach allUnits;
        
        //systemChat format ["Total Survivor units found: %1", _survivorCount];
        //systemChat format ["Total Civilian Enemy units found: %1", _civilianEnemyCount];
        
        MyPlayersCount = MyPlayersCount+_survivorCount; 
        CivilianEnemyCount = CivilianEnemyCount+_civilianEnemyCount;
        publicVariable "MyPlayersCount"; 
        publicVariable "CivilianEnemyCount";
        sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
    
    case 3: {call getLastPointId; ExpectedPlayerCount = 10; 0 = [] spawn {
        dropPlane1 call MySpawnAI; sleep 0.5; 
        [dropPlane1, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane2 call MySpawnAI; sleep 0.5; 
        [dropPlane2, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane3 call MySpawnAI; sleep 0.5; 
        [dropPlane3, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        sleep 10; 
        dropPlane4 call MySpawnAI; sleep 0.5; 
        [dropPlane4, "#(0, 1, 1, 1)"] call drawSimpleRoute;
        
        _survivorCount = 0;
        _civilianEnemyCount = 0;
        
        {
            _varName = vehicleVarName _x;
            if (_varName != "") then {
                _hasSurvivor = (_varName find "Survivor") != -1;
                if (_hasSurvivor) then {
                    _survivorCount = _survivorCount + 1;
                    _playerType = if (isPlayer _x) then {"(Player)"} else {"(AI)"};
                    //systemChat format ["Found Survivor: %1 Name: %2 %3", _varName, name _x, _playerType];
                };
                
                _hasCivilian = (_varName find "Civilian") != -1;
                if (_hasCivilian) then {
                    _civilianEnemyCount = _civilianEnemyCount + 1;
                };
            };
        } forEach allUnits;
        
        //systemChat format ["Total Survivor units found: %1", _survivorCount];
        //systemChat format ["Total Civilian Enemy units found: %1", _civilianEnemyCount];
        
        MyPlayersCount = MyPlayersCount+_survivorCount; 
        CivilianEnemyCount = CivilianEnemyCount+_civilianEnemyCount;
        publicVariable "MyPlayersCount"; 
        publicVariable "CivilianEnemyCount";
        sleep 1; call EventHandlerAdder; if (ExtendedTimeMode == 1) then {call ExtendTimeInTriggers;}; sleep 0.1; call EndTrGenerator;};};
    
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
};

params["_survivor"];
_survivor addRating 0;     
     
_survivor addEventHandler ["Fired", {     
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];     
    if (_unit getVariable ["shootingDisabled", false]) then {     
        deleteVehicle _projectile;     
        if (isPlayer _unit) then {     
            systemChat "Shooting is disabled in this area!";     
        };     
    };     
}];     
     
_survivor addEventHandler ["killed", {     
    params ["_unit", "_killer", "_instigator"]; 
    if (side _unit == civilian) then {
            CivilianEnemyCount = CivilianEnemyCount - 1;
            publicVariable "CivilianEnemyCount";     
    } else {
        MyPlayersCount = MyPlayersCount - 1;
        plalive = MyPlayersCount;
        publicVariable "MyPlayersCount"; 
    };
    
    if (isPlayer _killer) then {     
        remoteExec ["addKillCounter", _killer];     
    };     
    private _sideName = switch (side _unit) do {
        case west: { "USEC" };
        case east: { "BEAR" };
        case independent: { "SCAV" };
        case resistance: { "SCAV" };
        default{ "Civilians" };
    };
    private _sideKiller = switch (side _killer) do {
        case west: { "USEC" };
        case east: { "BEAR" };
        case independent: { "SCAV" };
        case resistance: { "SCAV" };
        default{ "Civilians" };
    };
    chatMsg = format ["%1 (%2) was killed by %3 (%4)", (name _unit),_sideName, (name _killer), _sideKiller];   
    //[_unit, chatMsg] remoteExec ["globalChat"];    
    systemChat chatMsg;
      
    if (local _unit && isPlayer _unit) then {     
        private _playerUID = getPlayerUID _unit;  
          
        _unit setVariable ["cashMoney", 0, true];    
        _unit setVariable ["playerTimeout", false, true];  
        _unit setVariable ["supportTimer", 480, true];  
          
        missionProfileNamespace setVariable [_playerUID + "_cashMoney", 0];  
        missionProfileNamespace setVariable [_playerUID + "_playerTimeout", false];  
        missionProfileNamespace setVariable [_playerUID + "_supportTimer", 480];  
        saveMissionProfileNamespace;  
          
        systemChat format["Mission Timeout has Reset. Currency lost."];     
        _unit synchronizeObjectsRemove [west_support];  
    };   
    remoteExec ["updateUI"];    
}];  
  
_survivor addEventHandler ["Respawn", {  
    params ["_newUnit", "_oldUnit"];  
    [_newUnit] spawn {  
        params ["_player"];  
        sleep 5;  
        [_player] remoteExec ["fnc_spawnSavedUnits", 2];  
    };  
}];  
     
if (isPlayer _survivor) then {     
    _survivor addEventHandler ["Dammaged", "remoteExec ['updateUI'];"];     
    _survivor addEventHandler ["HandleHeal", "     
        0 = _this spawn {     
            params ['_injured','_healer'];     
            _damage = damage _injured;      
            if (_injured == _healer) then {     
                waitUntil {damage _injured != _damage};      
                remoteExec ['updateUI'];     
            };     
        };     
    "];     
};     
     
_survivor setVariable ["playerTimeout", false];     
_survivor setVariable ["supportTimer", 480];     
     
[_survivor] spawn {     
    params ["_unit"];     
    while {alive _unit} do {     
        waitUntil {_unit getVariable ["playerTimeout", false] || !alive _unit};     
          
        if (!alive _unit) exitWith {};  
          
        _timeLeft = _unit getVariable ["supportTimer", 480];     
        while {_timeLeft > 0 && (_unit getVariable ["playerTimeout", false]) && alive _unit} do {     
            sleep 1;     
            _timeLeft = _timeLeft - 1;     
            if (_timeLeft % 60 == 0) then {     
                _minutesLeft = _timeLeft / 60;     
                systemChat format["Extraction available in %1 minutes", _minutesLeft];     
            };     
        };     
          
        if (_unit getVariable ["playerTimeout", false] && alive _unit) then {     
            _unit synchronizeObjectsAdd [west_support];     
            systemChat "Support units are now available!";     
            playMusic "LeadTrack02_F";     
        };     
        _unit setVariable ["playerTimeout", false];     
        sleep 1;     
    };     
};  
    
if (!isPlayer _survivor) then {    
    private _ai = _survivor;    
        
    _locations = nearestLocations [[worldSize/2, worldSize/2], ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"], worldSize];    
        
    if (count _locations > 0) then {    
        _randomLocation = selectRandom _locations;    
        _locationPos = locationPosition _randomLocation;    
        _buildings = nearestObjects [_locationPos, ["BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","HOUSE","LIGHTHOUSE","POWERSOLAR","POWERWAVE","POWERWIND","RUIN","TRANSMITTER","VIEW-TOWER","WATERTOWER"], 200];    
            
        if (count _buildings > 0) then {    
            _randomBuilding = selectRandom _buildings;    
            _buildingPos = getPos _randomBuilding;    
            _ai setPos _buildingPos;    
        } else {    
            _ai setPos _locationPos;    
        };    
    };    
        
    [_survivor] spawn {    
        params ["_ai"];    
        myfuncWT = compile preprocessFileLineNumbers "WeaponTake.sqf";    
            
        while {alive _ai} do {    
            sleep 120;    
                
            if ((side _ai) == east && !(_ai getVariable ["shootingDisabled", false])) then {    
                _pkr = currentWeapon _ai;    
                _pkrC = count (toArray _pkr);    
                    
                if (((_pkrC < 1) or (_pkr == "throw")) && (isTouchingGround _ai)) then {    
                    _grp = group _ai;    
                    _cargoAr = nearestObjects [getPosWorld _ai, ["BOX_NATO_AmmoOrd_F"], 150];    
                    _ccar = count _cargoAr;    
                    _range = 150;    
                        
                    while {_ccar < 1 && _range < 1000} do {    
                        _range = _range + 100;    
                        _cargoAr = nearestObjects [getPosWorld _ai, ["BOX_NATO_AmmoOrd_F"], _range];    
                        sleep 0.2;    
                        _ccar = count _cargoAr;    
                    };    
                        
                    if (_ccar > 0) then {    
                        _carpoint = floor random (_ccar);    
                        _cargo = _cargoAr select _carpoint;    
                            
                        if ((count (waypoints _grp)) <= 2 && !isPlayer _ai) then {    
                            while {(count (waypoints _grp)) > 1} do {    
                                deleteWaypoint ((waypoints _grp) select 1);    
                            };    
                                
                            _wp = _grp addWaypoint [getPosWorld _cargo, 3];    
                            _wp setWaypointType "MOVE";    
                            _wp setWaypointStatements ["true", "[_survivor] call myfuncWT; _grp = group _survivor; _grp setBehaviour 'COMBAT';"];    
                        };    
                    };    
                };    
            };    
        };    
    };    
        
    _survivor addEventHandler ["Killed", {    
        params ["_unit"];    
        [_unit] spawn {    
            params ["_unit"];    
            sleep 30;    
            _group = createGroup east;    
            _newUnit = _group createUnit [typeOf _unit, [0,0,0], [], 0, "NONE"];    
                
            _locations = nearestLocations [[worldSize/2, worldSize/2], ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"], worldSize];    
            if (count _locations > 0) then {    
                _randomLocation = selectRandom _locations;    
                _locationPos = locationPosition _randomLocation;    
                _buildings = nearestObjects [_locationPos, ["BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","HOUSE","LIGHTHOUSE","POWERSOLAR","POWERWAVE","POWERWIND","RUIN","TRANSMITTER","VIEW-TOWER","WATERTOWER"], 200];    
                    
                if (count _buildings > 0) then {    
                    _randomBuilding = selectRandom _buildings;    
                    _buildingPos = getPos _randomBuilding;    
                    _newUnit setPos _buildingPos;    
                } else {    
                    _newUnit setPos _locationPos;    
                };    
            };    
                
            deleteVehicle _unit;    
        };    
    }];    
        
    _survivor setVariable ["shootingDisabled", false, true];    
        
    [_survivor] spawn {    
        params ["_ai"];    
        while {alive _ai} do {    
            if (_ai getVariable ["shootingDisabled", false]) then {    
                _ai setUnitCombatMode "BLUE";    
                _ai setBehaviour "CARELESS";    
                _ai disableAI "AUTOTARGET";    
                _ai disableAI "TARGET";    
                _ai setUnitPos "DOWN";    
                _ai forceWeaponFire ["", ""];    
            } else {    
                _ai setUnitCombatMode "RED";    
                _ai setBehaviour "COMBAT";    
                _ai enableAI "AUTOTARGET";    
                _ai enableAI "TARGET";    
                _ai setUnitPos "AUTO";    
            };    
            sleep 30;    
        };    
    };    
        
    [_survivor] spawn {    
        params ["_ai"];    
            
        private _fnc_roamLocation = {    
            params ["_unit"];    
            private _locations = nearestLocations [getPos _unit, ["NameVillage", "NameCity", "NameCityCapital"], 2000];    
            if (count _locations > 0) then {    
                private _targetLocation = selectRandom _locations;    
                private _pos = locationPosition _targetLocation;    
                private _buildings = nearestObjects [_pos, ["BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","CROSS","FORTRESS","FOUNTAIN","FUELSTATION","HOSPITAL","HOUSE","LIGHTHOUSE","POWERSOLAR","POWERWAVE","POWERWIND","RUIN","TRANSMITTER","VIEW-TOWER","WATERTOWER"], 150];    
                    
                if (count _buildings > 0) then {    
                    private _building = selectRandom _buildings;    
                    private _buildingPos = getPos _building;    
                    _unit doMove _buildingPos;    
                    _unit setBehaviour "AWARE";    
                } else {    
                    _unit doMove _pos;    
                };    
            };    
        };    
            
        private _fnc_lootAmmoboxes = {    
            params ["_unit"];    
            private _crates = (getPos _unit) nearObjects ["BOX_NATO_AmmoOrd_F", 100];    
            if (count _crates > 0) then {    
                private _crate = selectRandom _crates;    
                _unit doMove (getPos _crate);    
                _unit setBehaviour "AWARE";    
            };    
        };    
            
        private _fnc_findAndUseVehicle = {    
            params ["_unit"];    
            private _vehicles = (getPos _unit) nearEntities [["Car", "Motorcycle", "Tank"], 150];    
            if (count _vehicles > 0) then {    
                private _vehicle = selectRandom _vehicles;    
                if (count crew _vehicle == 0 && fuel _vehicle > 0) then {    
                    _unit doMove (getPos _vehicle);    
                        
                    [_unit, _vehicle] spawn {    
                        params ["_unit", "_vehicle"];    
                        waitUntil {unitReady _unit || !alive _unit || (_unit distance _vehicle < 10)};    
                            
                        if (alive _unit && (_unit distance _vehicle < 10)) then {    
                            _unit assignAsDriver _vehicle;    
                            _unit moveInDriver _vehicle;    
                                
                            sleep 5;    
                                
                            if (vehicle _unit == _vehicle) then {    
                                private _destination = (getPos _unit) getPos [500 + random 1000, random 360];    
                                private _group = group _unit;    
                                _group addWaypoint [_destination, 0];    
                                    
                                sleep 60 + random 120;    
                                    
                                if (alive _unit && vehicle _unit == _vehicle) then {    
                                    doGetOut _unit;    
                                    unassignVehicle _unit;    
                                };    
                            };    
                        };    
                    };    
                };    
            };    
        };    
            
        private _fnc_huntEnemies = {    
            params ["_unit"];    
            private _enemies = allUnits select {     
                alive _x &&     
                side _x != side _unit &&     
                _x distance _unit < 500 &&    
                !isPlayer _x    
            };    
                
            if (count _enemies > 0) then {    
                private _target = selectRandom _enemies;    
                _unit doMove (getPos _target);    
                _unit setBehaviour "COMBAT";    
                _unit setCombatMode "RED";    
            };    
        };    
            
        private _lastActionTime = 0;    
            
        while {alive _ai} do {    
            if !(_ai getVariable ["shootingDisabled", false]) then {    
                if (time - _lastActionTime > 30) then {    
                    _action = selectRandom [1, 2, 3, 4];    
                        
                    switch (_action) do {    
                        case 1: {     
                            [_ai] call _fnc_roamLocation;    
                        };    
                        case 2: {     
                            [_ai] call _fnc_lootAmmoboxes;    
                        };    
                        case 3: {     
                            [_ai] call _fnc_findAndUseVehicle;    
                        };    
                        case 4: {     
                            [_ai] call _fnc_huntEnemies;    
                        };    
                    };    
                    _lastActionTime = time;    
                };    
            };    
            sleep 60;    
        };    
    };    
};
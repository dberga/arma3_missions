params["_civilian"];
_civilian addRating -9999;  
_civilian setskill ["courage",1];
(group _civilian) setBehaviour "CARELESS";

_civilian addEventHandler ["killed", { 
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
    remoteExec ["updateUI"]; 
}]; 


private _planes = [dropPlane1, dropPlane2, dropPlane3, dropPlane4];

// Filter planes that have available cargo seats
private _availablePlanes = _planes select {
    !isNull _x && 
    {alive _x} && 
    {_x emptyPositions "cargo" > 0}
};

// Check if there are any planes with available seats
if (count _availablePlanes == 0) exitWith {
    // Handle no available planes (e.g., hint, log, or alternative action)
    hint "No planes with available seats!";
    // Return nil or take other action
    nil
};

// Select a random plane from those with available seats
private _plane = _availablePlanes call BIS_fnc_selectRandom;

// Assign and move the civilian into the plane
_civilian assignAsCargo _plane;       
_civilian moveInCargo _plane;     
_civilian addBackPack 'B_parachute';  
isFatigueEnabled = "MPEnableFatigue" call BIS_fnc_getParamValue;      
addGPS =  "MPAddGPS" call BIS_fnc_getParamValue;     

  
      
if (isPlayer _civilian) then{        
_civilian addEventHandler ["Dammaged", "remoteExec ['updateUI'];"];        
_civilian addEventHandler ["HandleHeal", "0 = _this spawn {params ['_injured','_healer'];_damage = damage _injured; if (_injured == _healer) then {waitUntil {damage _injured != _damage}; remoteExec ['updateUI'];};}"];        
_civilian addBackPack 'B_parachute';        
};

   
if (!isPlayer _civilian) then {  
	// ADDED: Ejection after random time between 120-300 seconds
	[_civilian, _plane] spawn {
		params ["_civilian", "_plane"];
		
		
		// Then wait until the plane is over land (not water)
		waitUntil {
			sleep (floor (30 + random 30));
			!alive _civilian || 
			vehicle _civilian != _plane || 
			!alive _plane ||
			!surfaceIsWater getPos _plane
		};
		
		if (alive _civilian && 
			vehicle _civilian == _plane && 
			alive _plane &&
			!surfaceIsWater getPos _plane) then {
			
			// Ensure parachute is equipped
			if (!("B_parachute" in (backpack _civilian))) then {
				_civilian addBackPack 'B_parachute';
			};
			
			// Move civilian out of the plane
			_civilian action ["Eject", _plane];
			
			sleep 1;
			_civilian action ["OpenParachute", _civilian];
		};
	};
    private _ai = _civilian; 
        
    [_civilian] spawn {    
        params ["_ai"];    
        myfuncWT = compile preprocessFileLineNumbers "WeaponTake.sqf";    
            
        while {alive _ai} do { 
            if (!(_ai getVariable ["shootingDisabled", false])) then {    //(side _ai) == east && 
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
			  
            sleep 120;    
        };    
    };    
};
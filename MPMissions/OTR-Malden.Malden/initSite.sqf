// initSite.sqf - Initialize logic entity as a site with simple capture detection
params ["_site"];

// Only run on server
if (!isServer) exitWith {};

private _locations = [];          //"Mount","Hill","ViewPoint","RockArea","BorderCrossing","VegetationBroadleaf","VegetationFir","VegetationPalm","VegetationVineyard"
private _allLocations = nearestLocations [[worldSize/2,worldSize/2,0], ["Name","NameCityCapital","NameCity","NameVillage","NameLocal","ViewPoint"], worldSize/2];         
 
{         
    private _locationName = text _x;         
    private _locationPos = locationPosition _x;         
             
    if (_locationName != "") then {         
        _locations pushBack [_locationName, _locationPos, type _x];         
    };         
} forEach _allLocations;       
       
private _location = _locations call BIS_fnc_selectRandom;      
while {(_location select 1) distance (getPos respawn_west) < 300} do {       
    _location = _locations call BIS_fnc_selectRandom;       
};        
private _locationName = _location select 0;
_site setVariable ["_locationName",_locationName];

private _pos = [_location select 1, 5, 50, 3, 0, 0.2, 0] call BIS_fnc_findSafePos;     
_site setPos _pos;        
    
[_site] spawn {        
    params ["_site"];       
           
    private _side = "";      
    private _flag = "";      
    private _isciv = false;
    private _siteName = "";      
    private _side_eval = side _site;
    switch (_side_eval) do {      
        case sideLogic: {      
            private _timeout = time + 5;      
            waitUntil {      
                _side = _site getVariable ["side", ""];      
                _side != "" || time > _timeout      
            };      
            _side = toLower (_site getVariable ["side", ""]);      
            switch (_side) do {      
                case "blufor": {      
                    _side = "USEC";       
                    _flag = "flag_USA";       
                };      
                case "opfor": {      
                    _side = "BEAR";       
                    _flag = "flag_Russia";       
                };      
                case "independent": {      
                    _side = "SCAV";       
                    _flag = "flag_AAF";       
                };      
                default {       
                    _side = _site getVariable ["faction", "UNKN"];       
                    _flag = "flag_UN";
                    _isciv = true;
                };      
            };      
        };      
        case west: {      
            _side = "USEC";       
            _flag = "flag_USA";       
        };      
        case east: {      
            _side = "BEAR";       
            _flag = "flag_Russia";       
        };      
        case independent: {      
            _side = "SCAV";       
            _flag = "flag_AAF";       
        };      
        default {       
            _side = _site getVariable ["faction", "UNKN"];      
            _flag = "flag_UN";      
            _isciv = true;
        };      
    };      
    private _description = _site getVariable ["description", ""];      
    if (_description  == "") then {      
        _siteName = format ["%1 %2",       
                _side,       
                _site getVariable ["sitetype", ""]      
            ];      
    } else {      
        _siteName = _description;      
    };      
    waitUntil {isClass (missionConfigFile >> "CfgMarkers")};      
    
    private _markerName = format ["war_site_%1", random 10000];      
    private _marker = createMarker [_markerName, getPos _site];      
    _marker setMarkerType _flag;       
    _marker setMarkerText "";      
    _marker setMarkerSize [0.8, 0.8];      
    
    // Store initial side and marker for capture detection
    _site setVariable ["currentSide", _side_eval, true];
    _site setVariable ["siteMarker", _markerName, true];
        
	private _siteflag = switch (_side_eval) do {
	 case west: {"Flag_FD_Blue_F" createVehicle (getPos _site);};
	 case east: {"Flag_FD_Red_F" createVehicle (getPos _site);};
	 case independent: {"Flag_FD_Green_F" createVehicle (getPos _site);};
	 case resistance: {"Flag_FD_Green_F" createVehicle (getPos _site);};
	 case civilian: {"Flag_UNO_F" createVehicle (getPos _site);};
	 default {"Flag_FD_Purple_F" createVehicle (getPos _site);};
	};
		
    if (_isciv == true) then {
        [_site] execVM "createSafeZone.sqf";   
    } else {
		
        private _garrison = _site getVariable ["garrison", []];    
        {    
            {   _x setPos ([_site, 5, 50, 3, 0, 20, 0] call BIS_fnc_findSafePos);    
                //[_location select 1, 5, 50, 3, 0, 20, 0] call BIS_fnc_findSafePos
                //_x setPos (_site getPos [random 5, random 360]);    
            } forEach units _x;    
              
            [_x, getPos _site] spawn {  
                params ["_group", "_center"];  
                sleep 1;  
                while {(count (waypoints _group)) > 0} do {  
                    deleteWaypoint ((waypoints _group) select 0);  
                };  
                //[_group, _center, 200] call BIS_fnc_TaskPatrol;
                [_group, _center] call BIS_fnc_TaskDefend;
                /*
                for "_i" from 0 to 3 do {  
                    private _wp = _group addWaypoint [_center getPos [50, _i * 90], 0];  
                    _wp setWaypointType "MOVE";  
                    _wp setWaypointBehaviour "SAFE";  
                    _wp setWaypointSpeed "LIMITED";  
                    _wp setWaypointCompletionRadius 10;  
                };  
                private _wp = _group addWaypoint [_center getPos [50, 0], 0];  
                _wp setWaypointType "CYCLE";  
                */
				
            };  
        } forEach _garrison;    
        
        // Simple capture detection function
        private _checkCapture = {
            params ["_site"];
            private _currentSide = _site getVariable "currentSide";
            private _markerName = _site getVariable "siteMarker";
            private _pos = getPos _site;
            
            // Get all units in 50m radius
            private _units = allUnits select {_x distance _pos < 50 && alive _x};
            
            if (count _units == 0) exitWith {false};
            
            // Count units by side
            private _westCount = {side _x == west} count _units;
            private _eastCount = {side _x == east} count _units;
            private _indepCount = {side _x == independent} count _units;
            
            // Determine which side has majority
            private _maxCount = _westCount max _eastCount max _indepCount;
            private _newSide = sideEmpty;
            
            if (_westCount == _maxCount && _westCount > 0) then {_newSide = west;};
            if (_eastCount == _maxCount && _eastCount > 0) then {_newSide = east;};
            if (_indepCount == _maxCount && _indepCount > 0) then {_newSide = independent;};
            
            // If side changed and there's a clear majority (at least 2 units more than others)
            if (_newSide != sideEmpty && _newSide != _currentSide) then {
                private _totalEnemies = count _units - _maxCount;
                
                if (_maxCount >= _totalEnemies + 2) then { // Need at least 2 more units than enemies
                    // Update marker
                    private _newFlag = "";
                    switch (_newSide) do {
                        case west: { _newFlag = "flag_USA"; };
                        case east: { _newFlag = "flag_Russia"; };
                        case independent: { _newFlag = "flag_AAF"; };
                        case resistance: { _newFlag = "flag_AAF"; };
                    };
                    
                    if (_newFlag != "") then {
                        _markerName setMarkerType _newFlag;
                        _site setVariable ["currentSide", _newSide, true];
                        
                        // Optional: Brief flash effect
                        private _color = getMarkerColor _markerName;
                        _markerName setMarkerColor "ColorBlack";
                        sleep 0.5;
                        _markerName setMarkerColor _color;
                        
                        // Optional notification
                        private _sideName = switch (_newSide) do {
                            case west: { "USEC" };
                            case east: { "BEAR" };
                            case independent: { "SCAV" };
                            case resistance: { "SCAV" };
                            default{ "Civilians" };
                        };
                        systemChat format ["%1 captured by %2",(_site getVariable ["_locationName","Site"]), _sideName];
                    };
                    true
                } else {
                    false
                };
            } else {
                false
            };
        };
        
        // Start capture monitoring loop
        [_site, _checkCapture] spawn {
            params ["_site", "_checkCapture"];
            
            while {alive _site} do {
                sleep 10; // Check every 10 seconds
                
                // Check if site is captured
                [_site] call _checkCapture;
                
                // Also check garrison status
                private _garrison = _site getVariable ["garrison", []];
                private _allDead = true;
                
                {
                    if (!isNull _x) then {
                        if ({alive _x} count units _x > 0) then {
                            _allDead = false;
                        };
                    };
                } forEach _garrison;
                
                // If all garrison dead, check for immediate capture
                if (_allDead) then {
                    [_site] call _checkCapture;
                };
            };
        };
    };
};
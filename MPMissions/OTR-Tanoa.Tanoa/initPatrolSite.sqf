//null = [this,false,"ATTACK",objNull,5,"resistance"] execVm "initPatrolSite.sqf";

if (!isServer) exitWith {}; 
params["_this","_randpos","_taskType","_target","_radius","_factionSide"];
private _centerPos = getPos _this; 

if (_factionSide isEqualTo objNull) then {
	_factionSide = ["scav","scav","rogue","usec","bear"] call BIS_fnc_selectRandom;
};

///randpos
if (_randPos == true) then { 
 
 private _locations = [];            //"Mount","Hill","ViewPoint","RockArea","BorderCrossing","VegetationBroadleaf","VegetationFir","VegetationPalm","VegetationVineyard", "Name","NameCityCapital","NameCity","NameVillage","NameLocal","ViewPoint"
 private _allLocations = nearestLocations [[worldSize/2,worldSize/2,0], ["Name","Mount","Hill","BorderCrossing","VegetationBroadleaf","VegetationFir","VegetationPalm","VegetationVineyard","NameVillage","NameLocal","ViewPoint"], worldSize/2];           
    
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
   
 private _pos = [_location select 1, 5, 50, 3, 0, 0.2, 0] call BIS_fnc_findSafePos;      
 _centerPos = _pos; 
 _this setPos _pos;
}; 

///trigger
_trigger = createTrigger ["EmptyDetector", _centerPos];
_trigger setTriggerArea [100, 100, 0, false];
_trigger setTriggerActivation ["ANYPLAYER", "PRESENT", true];
_trigger setTriggerTimeout [120, 120, 120, false];

// Store variables on the trigger object
_trigger setVariable ["spawnCenterPos", _centerPos];
_trigger setVariable ["spawnTaskType", _taskType];
_trigger setVariable ["spawnTarget", _target];
_trigger setVariable ["spawnRadius", _radius];
_trigger setVariable ["spawnFactionSide", _factionSide];

_trigger setTriggerStatements [
    "this && player in thisList", 
    "
    _centerPos = (thisTrigger getVariable 'spawnCenterPos');
    _taskType = (thisTrigger getVariable 'spawnTaskType');
    _target = (thisTrigger getVariable 'spawnTarget');
    _radius = (thisTrigger getVariable 'spawnRadius');
    _factionSide = (thisTrigger getVariable 'spawnFactionSide');
    
    null = [_centerPos, _taskType, _target, _radius, _factionSide] execVM 'spawnRandomSquad.sqf';
    ",
    ""
];

// Now you have full control
_trigger setPos _centerPos;

private _spawnflag = switch (_factionSide) do {
 case "usec": {"Flag_FD_Blue_F" createVehicle _centerPos;};
 case "bear": {"Flag_FD_Red_F" createVehicle _centerPos;};
 case "rogue": {"Flag_FD_Green_F" createVehicle _centerPos;};
 case "scav": {"Flag_FD_Green_F" createVehicle _centerPos;};
 default {"Flag_FD_Purple_F" createVehicle _centerPos;};
};

_randomID = floor(diag_tickTime * 1000);
_spawnZoneMarker = createMarker [format["spawnZoneArea_%1", _randomID],_centerPos]; 
_spawnZoneMarker setMarkerShape "ELLIPSE"; 
_spawnZoneMarker setMarkerSize [triggerArea _trigger select 0, triggerArea _trigger select 1]; 
_spawnZoneMarker setMarkerColor "ColorRed"; 
_spawnZoneMarker setMarkerAlpha 0.25; 
_spawnZoneMarker setMarkerBrush "DiagGrid"; 
 

_spawnZoneMarker = createMarker [format["spawnZoneLabel_%1", _randomID],_centerPos];  
_spawnZoneMarker setMarkerType "mil_warning"; 
_spawnZoneMarker setMarkerColor "ColorRed"; 
_spawnZoneMarker setMarkerText "SPAWN ZONE"; 
_spawnZoneMarker setMarkerAlpha 0.7;








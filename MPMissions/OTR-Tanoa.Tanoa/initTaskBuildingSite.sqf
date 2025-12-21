// initTaskSite.sqf - Initialize task-based logic entity
params ["_rt", "_rt_target", "_spawntime", "_rt_oppside"];

// Only run on server
//if (!isServer) exitWith {};

// Wait for scav_hq1 to be defined if not already
if (isNil "_rt_target") then { 
    waitUntil {sleep 1; !isNil "_rt_target"}; 
};
 
private _rt_taskowners = [_rt_oppside];       
private _rt_opppos = false;         
private _rt_randpos = false;         
private _initpos = getPos _rt;        
private _rt_rand_zones = ["Hill","Mount","Name","NameCityCapital","NameCity","NameVillage","NameLocal","ViewPoint"];         
private _rt_killstate = "FAILED";         
private _rt_dname = [configFile >> "CfgVehicles" >> typeOf _rt] call BIS_fnc_displayName;         
private _rt_taskid_defend = str (random 10) + _rt_dname;         
private _rt_taskid_kill = str (random 10) + _rt_dname;        
private _rt_type = typeOf _rt;         
private _rt_captive = false;       
private _side = switch (_rt_oppside) do {
	case west: {"USEC"};
	case east: {"BEAR"};
	case independent: {"SCAV"};
	case resistance: {"SCAV"};
	default { "SCAV" };
};     
private _flag = "n_hq";     
private _rt_taskowners_defend = _rt_taskowners;       
private _rt_taskowners_kill = [independent, west, east] - _rt_taskowners_defend;       
private _rt_tasktype_defend = "Defend";       
private _rt_tasktype_kill = "Destroy";       
     
// Position the entity near target if it exists
if (!isNull _rt_target) then { 
    private _pos = [_rt_target, 1, 50, 3, 0, 10, 0] call BIS_fnc_findSafePos;   
    _rt setPos _pos;   
} else { 
    _rt_target = objNull; 
}; 
   
// Create tasks
[_rt_taskowners_defend, _rt_taskid_defend, [[_rt_tasktype_defend + " " + _rt_dname + " owned by " + _side], [_rt_tasktype_defend + " " + _side + " " + _rt_dname]], _rt, "AUTOASSIGNED", 1, true, _rt_tasktype_defend] call BIS_fnc_taskCreate;          
[_rt_taskowners_kill, _rt_taskid_kill, [[_rt_tasktype_kill + " " + _rt_dname + " owned by " + _side], [_rt_tasktype_kill + " " + _side + " " + _rt_dname]], _rt, "AUTOASSIGNED", 1, true, _rt_tasktype_kill] call BIS_fnc_taskCreate;          
         
// Start main monitoring loop
[_rt, _initpos, _spawntime, _rt_tasktype_defend, _rt_tasktype_kill, _rt_taskowners_defend, _rt_taskowners_kill, _rt_oppside, _rt_opppos, _rt_randpos, _rt_rand_zones, _rt_killstate, _rt_dname, _rt_taskid_defend, _rt_taskid_kill, _rt_type, _side, _rt_target] spawn {         
 params ["_rt", "_initpos", "_spawntime", "_rt_tasktype_defend", "_rt_tasktype_kill", "_rt_taskowners_defend", "_rt_taskowners_kill", "_rt_oppside", "_rt_opppos", "_rt_randpos", "_rt_rand_zones", "_rt_killstate", "_rt_dname", "_rt_taskid_defend", "_rt_taskid_kill", "_rt_type", "_side", "_rt_target"];         
  
 private _target = _rt_target; 
 // Ensure target exists
 if (isNull _target) then { 
    _target = scav_hq1; 
    waitUntil {sleep 1; !isNull _target}; 
 }; 
 
 // Position entity near target
 if (!isNull _target) then { 
    _bbox_diameter = abs(((boundingBox aafbunker select 0) select 0) - ((boundingBox aafbunker select 1) select 0));

    private _pos = [_target, 1, 50, _bbox_diameter, 0, 10, 0] call BIS_fnc_findSafePos;   
    _rt setPos _pos;   
 }; 
  
 // Main monitoring loop
 while {true} do {     
   waitUntil {sleep 30; damage _rt == 1};         
   [_rt_taskid_defend, "FAILED"] call BIS_fnc_taskSetState;          
   [_rt_taskid_kill, "SUCCEEDED"] call BIS_fnc_taskSetState;          
   sleep _spawntime;      
   
   // Respawn logic after spawn time
   if (_spawntime > 0) then {         
     _rt setDamage 0;          
     [_rt_taskowners_defend, _rt_taskid_defend, [[_rt_tasktype_defend + " " + _rt_dname + " owned by " + _side], [_rt_tasktype_defend + " " + _side + " " + _rt_dname]], _rt, "AUTOASSIGNED", 1, true, _rt_tasktype_defend] call BIS_fnc_taskCreate;         
     [[independent, west, east] - _rt_taskowners_defend, _rt_taskid_kill, [[_rt_tasktype_kill + " " + _rt_dname + " owned by " + _side], [_rt_tasktype_kill + " " + _side + " " + _rt_dname]], _rt, "AUTOASSIGNED", 1, true, _rt_tasktype_kill] call BIS_fnc_taskCreate;         
   };         
 };         
};
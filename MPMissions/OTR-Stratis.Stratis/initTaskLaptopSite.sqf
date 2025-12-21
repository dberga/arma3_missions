// initTaskSite.sqf - Initialize task-based logic entity
params ["_rt", "_rt_target", "_spawntime", "_rt_oppside"];

_rt_tasktype="Download";     
_rt_taskowners = [west,east,independent] - [_rt_target];   
_rt_opppos = false;     
_rt_randpos = false;     
_rt_rand_zones = ["Hill","Mount","Name","NameCityCapital","NameCity","NameVillage","NameLocal","ViewPoint"];      
_rt_killstate = "FAILED";     
_rt_action = false;     
_rt_dname = [configFile >> "CfgVehicles" >> typeOf vehicle _rt] call BIS_fnc_displayName;     
_rt_taskid = str (random 10) + typeOf _rt;     
   
_side = "";   
_flag = "";   
_siteName = "";   
_side_eval = _rt_oppside;   
switch (_side_eval) do {   
    case sideLogic: {   
        _timeout = time + 5;   
        waitUntil {   
            _side = _site getVariable ["side", ""];   
            _side != "" || time > _timeout   
        };   
        _side = toLower (_site getVariable ["side", ""]);   
        switch (_side) do {   
            case "blufor": {   
                _side = "USEC";    
                _flag = "b_hq";    
            };   
            case "opfor": {   
                _side = "BEAR";    
                _flag = "o_hq";    
            };   
            case "independent": {   
                _side = "SCAV";    
                _flag = "n_hq";    
            };   
            default {    
                _side = _site getVariable ["faction", "UNKN"];    
                _flag = "flag_UN";   
            };   
        };   
    };   
    case west: {   
        _side = "USEC";    
        _flag = "b_hq";    
    };   
    case east: {   
        _side = "BEAR";    
        _flag = "o_hq";    
    };   
    case independent: {   
        _side = "SCAV";    
        _flag = "n_hq";    
    };   
    default {    
        _side = _site getVariable ["faction", "UNKN"];   
        _flag = "flag_UN";   
    };   
};   
   
if (_rt_opppos) then {      
_opp_pos = getPos ((units _rt_oppside) call BIS_fnc_selectRandom);     
_new_pos = [_opp_pos,1,100] call BIS_fnc_findSafePos;     
_rt setPos _new_pos;     
};     
if (_rt_randpos) then {     
_rand_loc = nearestLocations [getPos _rt, _rt_rand_zones, worldSize];     
_random_loc= _rand_loc call BIS_fnc_selectRandom;     
_new_pos = [getPos _random_loc, 1, 100] call BIS_fnc_findSafePos;     
_rt setPos _new_pos;     
};     
 
_pos = [_rt_target, 1, 10, 3, 0, 20, 0] call BIS_fnc_findSafePos; 
_rt setPos _pos; 
 
[_rt_taskowners, _rt_taskid, [[_rt_tasktype+" "+ _rt_dname+" owned by "+_side ], [_rt_tasktype+" "+_side+" "+_rt_dname]], _rt ,"AUTOASSIGNED", 1, true, _rt_tasktype] call BIS_fnc_taskCreate;      
   
[_rt, _spawntime, _rt_tasktype, _rt_taskowners, _rt_oppside, _rt_opppos, _rt_randpos, _rt_rand_zones, _rt_killstate,_rt_dname, _rt_taskid, _side, _rt_target] spawn {   
 params ["_rt", "_spawntime", "_rt_tasktype", "_rt_taskowners", "_rt_oppside", "_rt_opppos", "_rt_randpos", "_rt_rand_zones", "_rt_killstate", "_rt_dname", "_rt_taskid", "_side", "_rt_target"];     
   
_rt setvariable ["action",false];   
_rt addAction ["Download", {params ["_rt"]; _rt setvariable ["action",true]},[_rt]];   
_pos = [_rt_target, 1, 10, 3, 0, 20, 0] call BIS_fnc_findSafePos; 
_rt setPos _pos; 
 while {true} do {     
   sleep 5;    
   _rt_action = _rt getVariable "action";   
   if (_rt_action == true && damage _rt < 1) then {    
      [_rt_taskid,"SUCCEEDED"] call BIS_fnc_taskSetState;   
   };    
   if (_rt_action == false && damage _rt == 1) then {    
      [_rt_taskid,_rt_killstate] call BIS_fnc_taskSetState;    
   };    
   if (_rt_opppos) then {      
    _opp_pos = getPos ((units _rt_oppside) call BIS_fnc_selectRandom);     
    _new_pos = [_opp_pos,1,100] call BIS_fnc_findSafePos;     
    _rt setPos _new_pos;     
   };     
   if (_rt_randpos) then {     
    _rand_loc = nearestLocations [getPos _rt, _rt_zones, worldSize];     
    _random_loc= _rand_loc call BIS_fnc_selectRandom;     
    _new_pos = [getPos _random_loc, 1, 100] call BIS_fnc_findSafePos;     
    _rt setPos _new_pos;     
   };     
   if (_spawntime>0 && (damage _rt == 1 || _rt_action == true)) then {    
     sleep (_spawntime);   
     _rt setDamage 0;    
     _rt setvariable ["action",false];   
     _rt_taskid = str (random 10) + typeOf _rt;     
     [_rt_taskowners, _rt_taskid, [[_rt_tasktype+" "+_rt_dname+" owned by "+_side], [_rt_tasktype+" "+_side+" "+_rt_dname]], _rt ,"AUTOASSIGNED", 1, true, _rt_tasktype] call BIS_fnc_taskCreate;   
   }   
 }     
 }
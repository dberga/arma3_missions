// initTaskSite.sqf - Initialize task-based logic entity
params ["_rt", "_rt_target", "_spawntime", "_rt_oppside"];
   
if (isNil "_rt_target") then { 
    waitUntil {sleep 1; !isNil "_rt_target"}; 
};       
_rt_captive = false;      
_rt_taskowners = [_rt_oppside];  
_rt_opppos = false;      
_rt_randpos = false;  
_initpos = getPos _rt;     
_rt_rand_zones = ["Hill","Mount","Name","NameCityCapital","NameCity","NameVillage","NameLocal","ViewPoint"];      
_rt_killstate = "FAILED";      
_rt_dname = [configFile >> "CfgVehicles" >> typeOf vehicle _rt] call BIS_fnc_displayName;      
_rt_taskid = str (random 10) + _rt_dname;      
_rt_group = group _rt;      
_rt_type = typeOf _rt;      
_rt_skill = skill _rt;      
_rt setCaptive (_rt_captive);      
    
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
   
_rt_taskowners_defend = _rt_taskowners;    
_rt_taskowners_kill = [independent, west, east] - _rt_taskowners_defend;    
_rt_taskid_defend = str (random 10) + _rt_dname;      
_rt_taskid_kill = str (random 10) + _rt_dname;      
_rt_tasktype_defend = "Defend";    
_rt_tasktype_kill = "Kill";    
 
 _pos = [_rt_target, 1, 2, 3, 0, 20, 0] call BIS_fnc_findSafePos;  
 _rt setPos _pos;  
 
[_rt_taskowners_defend, _rt_taskid_defend, [[_rt_tasktype_defend+" "+ _rt_dname+" owned by "+ _side ], [_rt_tasktype_defend+" "+ _side +" "+_rt_dname]], _rt ,"AUTOASSIGNED", 1, true, _rt_tasktype_defend] call BIS_fnc_taskCreate;       
[_rt_taskowners_kill, _rt_taskid_kill, [[_rt_tasktype_kill+" "+ _rt_dname+" owned by "+ _side ], [_rt_tasktype_kill+" "+ _side +" "+_rt_dname]], _rt ,"AUTOASSIGNED", 1, true, _rt_tasktype_kill] call BIS_fnc_taskCreate;       
      
[_rt, _initpos, _spawntime, _rt_tasktype_defend,_rt_tasktype_kill, _rt_taskowners_defend, _rt_oppside, _rt_opppos, _rt_randpos, _rt_rand_zones, _rt_killstate,_rt_dname, _rt_taskid_defend, _rt_taskid_kill, _rt_captive, _rt_group, _rt_type, _rt_skill, _side,_rt_target] spawn {      
 params ["_rt", "_initpos", "_spawntime", "_rt_tasktype_defend","_rt_tasktype_kill", "_rt_taskowners_defend", "_rt_oppside", "_rt_opppos", "_rt_randpos", "_rt_rand_zones", "_rt_killstate", "_rt_dname", "_rt_taskid_defend" ,"_rt_taskid_kill", "_rt_captive", "_rt_group", "_rt_type", "_rt_skill", "_side","_rt_target"];      
 _pos = [_rt_target, 1, 1, 3, 0, 20, 0] call BIS_fnc_findSafePos;  
 _rt setPos _pos;  
 while {true} do {      
   waitUntil {sleep 30; damage _rt == 1};      
   [_rt_taskid_defend,"FAILED"] call BIS_fnc_taskSetState;       
   [_rt_taskid_kill,"SUCCEEDED"] call BIS_fnc_taskSetState;       
   sleep _spawntime;   
   if (_spawntime>0) then {      
     _rt = _rt_group createUnit [_rt_type, _initpos, [], 1, "CAN_COLLIDE"];    
     _rt setDamage 0;    
     _rt setCaptive (_rt_captive);      
     [_rt_taskowners_defend, _rt_taskid_defend, [[_rt_tasktype_defend+" "+_rt_dname+" owned by "+ _side], [_rt_tasktype_defend+" "+ _side +" "+_rt_dname]], _rt ,"AUTOASSIGNED", 1, true, _rt_tasktype_defend] call BIS_fnc_taskCreate;      
     [[independent, west, east] - _rt_taskowners_defend, _rt_taskid_kill, [[_rt_tasktype_kill+" "+_rt_dname+" owned by "+ _side], [_rt_tasktype_kill+" "+ _side +" "+_rt_dname]], _rt ,"AUTOASSIGNED", 1, true, _rt_tasktype_kill] call BIS_fnc_taskCreate;      
    };      
 };      
 };      

this addRating 0;  

this addEventHandler ["Fired", {  
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];  
    if (_unit getVariable ["shootingDisabled", false]) then {  
        deleteVehicle _projectile;  
        systemChat "Shooting is disabled in this area!";  
    };  
}];
 
this addEventHandler ["killed", "
    MyPlayersCount = MyPlayersCount -1; 
    plalive = MyPlayersCount; 
    publicVariable 'MyPlayersCount'; 
    if (isPlayer (_this select 1)) then {
        remoteExec ['addKillCounter',(_this select 1)];
        _killedUnit = _this select 0;
        _killer = _this select 1;
        };
    }; 
    chatMsg = format ['%1 was killed by %2. Players alive: %3', (name (_this select 0)), (name (_this select 1)), MyPlayersCount]; 
    [(_this select 0),chatMsg] remoteExec ['globalChat'];  
    remoteExec ['updateUI'];
    (_this select 0) setVariable ['cashMoney', 0, true];
"]; 
  
isFatigueEnabled = "MPEnableFatigue" call BIS_fnc_getParamValue;        
addGPS =  "MPAddGPS" call BIS_fnc_getParamValue;        
  
if (isPlayer this) then{          
this addEventHandler ["Dammaged", "remoteExec ['updateUI'];"];          
this addEventHandler ["HandleHeal", "0 = _this spawn {params ['_injured','_healer'];_damage = damage _injured; if (_injured == _healer) then {waitUntil {damage _injured != _damage}; remoteExec ['updateUI'];};}"];          
          
};   
  
this setVariable ["playerTimeout", false];   
this setVariable ["supportTimer", 60];   
  
[this] spawn {   
    params ["_unit"];   
       
    while {true} do {   
        waitUntil {_unit getVariable ["playerTimeout", false]};   
           
        _timeLeft = _unit getVariable ["supportTimer", 420];   
        while {_timeLeft > 0 && (_unit getVariable ["playerTimeout", false])} do {   
            sleep 1;   
            _timeLeft = _timeLeft - 1;   
               
            if (_timeLeft % 60 == 0) then {   
                _minutesLeft = _timeLeft / 60;   
                systemChat format["Extraction available in %1 minutes", _minutesLeft];   
            };   
        };   
           
        if (_unit getVariable ["playerTimeout", false]) then {   
            _unit synchronizeObjectsAdd [west_support];   
            systemChat "Support units are now available!";   
            playMusic "LeadTrack02_F";   
        };   
           
        _unit setVariable ["playerTimeout", false];   
           
        sleep 0.1;   
    };   
}; 
 
params ["_teleportObject"];
_teleportObject addAction [  
    "<t color='#FFA500'>HUNT SURVIVORS</t>",    
    {    
        params ["_target", "_caller"];    
            
        if (_caller getVariable ["playerTimeout", false]) exitWith {    
            ["You are currently in timeout mode and cannot teleport again", "PLAIN DOWN", 1] remoteExec ["cutText", _caller];    
        };    
            
        _survivorList = [];    
        {    
            _varName = vehicleVarName _x;    
            if (_varName != "" && {(_varName find "Survivor") != -1}) then {    
                _faction = "Unknown";    
                _factionColor = [1, 1, 1, 0.7];    
                    
                if (_varName find "USEC" != -1) then {    
                    _faction = "USEC";    
                    _factionColor = [0, 0.8, 1, 0.7];    
                } else {    
                    if (_varName find "BEAR" != -1) then {    
                        _faction = "BEAR";    
                        _factionColor = [0.8, 0.6, 0.2, 0.7];    
                    } else {    
                        if (_varName find "Rogue" != -1) then {    
                            _faction = "Rogue";    
                            _factionColor = [0.3, 0.4, 0.3, 0.7];    
                        } else {    
                            if (_varName find "Scav" != -1) then {    
                                _faction = "Scav";    
                                _factionColor = [0.6, 0.7, 0.6, 0.7];    
                            };    
                        };    
                    };    
                };    
                    
                _survivorInfo = [    
                    _varName,    
                    _x,    
                    if (isPlayer _x) then {"(Player)"} else {"(AI)"},    
                    getPos _x,    
                    name _x,    
                    vehicle _x,    
                    _faction,    
                    _factionColor    
                ];    
                _survivorList pushBack _survivorInfo;    
            };    
        } forEach allUnits;    
            
        if (count _survivorList == 0) exitWith {    
            ["No survivors found", "PLAIN DOWN", 1] remoteExec ["cutText", _caller];    
        };    
            
        createDialog "RscDisplayEmpty";    
        private _display = findDisplay -1;    
            
        private _bg = _display ctrlCreate ["RscText", 1];    
        _bg ctrlSetPosition [0.15, 0.2, 0.7, 0.6];    
        _bg ctrlSetBackgroundColor [0, 0, 0, 0.8];    
        _bg ctrlCommit 0;    
            
        private _title = _display ctrlCreate ["RscText", 2];    
        _title ctrlSetText "TELEPORT TO SURVIVOR";    
        _title ctrlSetPosition [0.15, 0.2, 0.7, 0.05];    
        _title ctrlSetBackgroundColor [0.1, 0.3, 0.1, 1];    
        _title ctrlSetTextColor [1, 1, 1, 1];    
        _title ctrlCommit 0;    
            
        private _infoText = _display ctrlCreate ["RscText", 3];    
        _infoText ctrlSetPosition [0.175, 0.26, 0.65, 0.04];    
        _infoText ctrlSetText format["Found %1 survivors", count _survivorList];    
        _infoText ctrlSetTextColor [1, 1, 1, 1];    
        _infoText ctrlCommit 0;    
            
        private _listBox = _display ctrlCreate ["RscListBox", 4];    
        _listBox ctrlSetPosition [0.175, 0.31, 0.65, 0.3];    
        _listBox ctrlCommit 0;    
            
        {    
            _x params ["_varName", "_unit", "_type", "_pos", "_actualName", "_vehicle", "_faction", "_factionColor"];    
                
            private _distance = round (_caller distance _unit);    
            private _status = if (alive _unit) then {"Alive"} else {"Dead"};    
                
            _nearestLocations = nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage","NameLocal","Hill"], worldSize/2];    
            _locationName = "Wilderness";    
            if (count _nearestLocations > 0) then {    
                _nearestLocation = _nearestLocations select 0;    
                _locationName = text _nearestLocation;    
            };    
                
            _vehicleSuffix = "";    
            _isAirOrWater = false;    
            if (_vehicle != _unit) then {    
                if (_vehicle isKindOf "Air") then {    
                    _vehicleSuffix = " [Plane]";    
                    _isAirOrWater = true;    
                } else {    
                    if (_vehicle isKindOf "Ship") then {    
                        _vehicleSuffix = " [Ship]";    
                        _isAirOrWater = true;    
                    } else {    
                        if (_vehicle isKindOf "Tank") then {    
                            _vehicleSuffix = " [Tank]";    
                        } else {    
                            if (_vehicle isKindOf "Car") then {    
                                _vehicleSuffix = " [Car]";    
                            } else {    
                                _vehicleSuffix = " [Vehicle]";    
                            };    
                        };    
                    };    
                };    
            };    
                
            private _index = _listBox lbAdd format["[%1] %2%3 %4 - %5 - %6m - Near %7", _faction, _actualName, _vehicleSuffix, _type, _status, _distance, _locationName];    
            _listBox lbSetData [_index, netId _unit];    
                
            if (!alive _unit) then {    
                _listBox lbSetColor [_index, [1, 0, 0, 0.7]];    
            } else {    
                if (_isAirOrWater) then {    
                    _listBox lbSetColor [_index, [1, 0, 0, 0.7]];    
                } else {    
                    _listBox lbSetColor [_index, _factionColor];    
                };    
            };    
        } forEach _survivorList;    
            
        private _teleportBtn = _display ctrlCreate ["RscButton", 5];    
        _teleportBtn ctrlSetText "TELEPORT TO SURVIVOR";    
        _teleportBtn ctrlSetPosition [0.175, 0.62, 0.3, 0.05];    
        _teleportBtn ctrlSetBackgroundColor [0, 0.5, 0, 1];    
        _teleportBtn ctrlSetTextColor [1, 1, 1, 1];    
        _teleportBtn ctrlCommit 0;    
            
        _teleportBtn ctrlAddEventHandler ["ButtonClick", {    
            params ["_ctrl"];    
            private _display = ctrlParent _ctrl;    
            private _listBox = _display displayCtrl 4;    
            private _selectedIndex = lbCurSel _listBox;    
                
            if (_selectedIndex != -1) then {    
                private _unitNetId = _listBox lbData _selectedIndex;    
                private _unit = objectFromNetId _unitNetId;    
                    
                if (!isNull _unit && alive _unit) then {    
                    _vehicle = vehicle _unit;    
                        
                    if (_vehicle != _unit && (_vehicle isKindOf "Air" || _vehicle isKindOf "Ship")) then {    
                        _vehicleType = "";    
                        if (_vehicle isKindOf "Air") then {    
                            _vehicleType = "Air";    
                        } else {    
                            _vehicleType = "Water";    
                        };    
                        _message = format["Please, wait for %1 [%2] to land", name _unit, _vehicleType];    
                        ["<t size='1.2' color='#FF0000'>" + _message + "</t>", 0, 0.4, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];    
                    } else {    
                        _pos = getPos _unit;    
                        _nearestLocations = nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage","NameLocal","Hill"], worldSize/2];    
                        _locationName = "Wilderness";    
                        if (count _nearestLocations > 0) then {    
                            _nearestLocation = _nearestLocations select 0;    
                            _locationName = text _nearestLocation;    
                        };    
                            
                        _locationPos = _pos;    
                        if (count _nearestLocations > 0) then {    
                            _nearestLocation = _nearestLocations select 0;    
                            _locationPos = locationPosition _nearestLocation;    
                        };    
                            
                        _randomPos = [_locationPos, 300, 500, 5, 0, 0.5, 0] call BIS_fnc_findSafePos;    
                            
                        [player, _unit, _randomPos, _locationName, name _unit] spawn {    
                            params ["_player", "_target", "_teleportPos", "_locationName", "_targetName"];    
                                
                            _huntText = format ["<t size='1.5' color='#FF0000'>HUNTING %1 in %2</t>", _targetName, _locationName];    
                            [_huntText, 0, 0.4, 5, 1] remoteExec ["BIS_fnc_dynamicText", _player];    
                                
                            playMusic "AmbientTrack01b_F";    
                                
                            _player setPos _teleportPos;    
                                
                            {    
                                _x setPos _teleportPos;    
                                _x setVariable ["shootingDisabled", false, true];    
                                _x setVariable ["playerTimeout", true];    
                            } forEach units group _player;    
                                
                            _targetPos = getPos _target;    
                            _playerPos = getPos _player;    
                                
                            _cam1 = "camera" camCreate ([_playerPos, 30, getDir _player] call BIS_fnc_relPos);    
                            _cam1 setPos [getPos _cam1 select 0, getPos _cam1 select 1, (_playerPos select 2) + 25];    
                            _cam1 cameraEffect ["Internal","back"];    
                                
                            showCinemaBorder true;    
                            _cam1 camPrepareTarget _target;    
                            _cam1 camPreparePos (getPos _cam1);    
                            _cam1 camPrepareFOV 0.700;    
                            _cam1 camCommitPrepared 0;    
                            WaitUntil {camCommitted _cam1};    
                            sleep 2;    
                                
                            showCinemaBorder true;    
                            _cam1 camPrepareTarget _target;    
                            _cam1 camPreparePos (getPos _cam1);    
                            _cam1 camPrepareFOV 0.100;    
                            _cam1 camCommitPrepared 6;    
                            WaitUntil {camCommitted _cam1};    
                            sleep 4;    
                                
                            showCinemaBorder true;    
                            _cam1 camPrepareTarget _target;    
                            _playerDir = getDir _player;    
                            _behindPlayerPos = [_playerPos, -3, _playerDir] call BIS_fnc_relPos;    
                            _cam1 camPreparePos [_behindPlayerPos select 0, _behindPlayerPos select 1, (_playerPos select 2) + 3.5];    
                            _cam1 camPrepareFOV 0.500;    
                            _cam1 camCommitPrepared 4;    
                            WaitUntil {camCommitted _cam1};    
                            sleep 3;    
                                
                            showCinemaBorder false;    
                            _cam1 camPrepareTarget _player;    
                            _playerDir = getDir _player;    
                            _behindPlayerPos = [_playerPos, -2, _playerDir] call BIS_fnc_relPos;    
                            _cam1 camPreparePos [_behindPlayerPos select 0, _behindPlayerPos select 1, (_playerPos select 2) + 3.0];    
                            _cam1 camPrepareFOV 0.700;    
                            _cam1 camCommitPrepared 3;    
                            WaitUntil {camCommitted _cam1};    
                            sleep 1;    
                                
                            _cam1 cameraEffect ["Terminate","back"];    
                            camDestroy _cam1;    
                                
                            _arrivedText = format ["<t size='1.5' color='#00FF00'>ARRIVED at %1</t>", _locationName];    
                            [_arrivedText, 0, 0.4, 3, 1] remoteExec ["BIS_fnc_dynamicText", _player];    
                        };    
                            
                        private _infohint = "Teleported near survivor location";    
                        [1,[_infohint, "PLAIN DOWN", 0.7]] remoteExec ["cutText", player];    
                            
                        _timerDuration = player getVariable ["supportTimer", 420];    
                        _minutes = _timerDuration / 60;    
                        systemChat format["Extraction Incoming! %1 minutes countdown started.", _minutes];    
   
                        if (EnableCustomHudMode>0) then {   
                            [["BRSEMissionInfoUI", "PLAIN"]] remoteExec ["cutRsc"];   
                            remoteExec ["updateUI"];   
                        };   
                    };    
                        
                    closeDialog 0;    
                } else {    
                    ["Selected survivor is dead or no longer exists", "PLAIN DOWN", 1] remoteExec ["cutText", player];    
                };    
            } else {    
                ["Please select a survivor first", "PLAIN DOWN", 1] remoteExec ["cutText", player];    
            };    
        }];    
            
        private _closeBtn = _display ctrlCreate ["RscButton", 6];    
        _closeBtn ctrlSetText "CLOSE";    
        _closeBtn ctrlSetPosition [0.525, 0.62, 0.3, 0.05];    
        _closeBtn ctrlSetBackgroundColor [0.5, 0, 0, 1];    
        _closeBtn ctrlSetTextColor [1, 1, 1, 1];    
        _closeBtn ctrlCommit 0;    
            
        _closeBtn ctrlAddEventHandler ["ButtonClick", {    
            closeDialog 0;    
        }];    
            
        if (count _survivorList > 0) then {    
            _listBox lbSetCurSel 0;    
        };    
            
    },    
    nil,    
    1.5,    
    true,    
    true,    
    "",    
    "!(_this getVariable ['playerTimeout', false])",    
    5    
];

_teleportObject addAction [   
    "<t color='#00FF00'>Teleport Menu</t>",   
    {   
        params ["_target", "_caller"];   
           
        if (_caller getVariable ["playerTimeout", false]) exitWith {   
            ["You are currently in timeout mode and cannot teleport again", "PLAIN DOWN", 1] remoteExec ["cutText", _caller];   
        };   
           
        _locations = [];   
        _allLocations = nearestLocations [[worldSize/2,worldSize/2,0], ["NameCityCapital","NameCity","NameVillage","NameLocal","Airport"], worldSize/2];  
          
        {  
            _locationName = text _x;  
            _locationPos = locationPosition _x;  
              
            if (_locationName != "") then {  
                _locations pushBack [_locationName, _locationPos, type _x];  
            };  
        } forEach _allLocations;  
           
        createDialog "RscDisplayEmpty";   
        private _display = findDisplay -1;   
           
        private _bg = _display ctrlCreate ["RscText", 1];   
        _bg ctrlSetPosition [0.15, 0.2, 0.7, 0.6];   
        _bg ctrlSetBackgroundColor [0, 0, 0, 0.8];   
        _bg ctrlCommit 0;   
           
        private _title = _display ctrlCreate ["RscText", 2];   
        _title ctrlSetText "TELEPORT MENU";   
        _title ctrlSetPosition [0.15, 0.2, 0.7, 0.05];   
        _title ctrlSetBackgroundColor [0.1, 0.3, 0.1, 1];   
        _title ctrlSetTextColor [1, 1, 1, 1];   
        _title ctrlCommit 0;   
           
        private _infoText = _display ctrlCreate ["RscText", 3];   
        _infoText ctrlSetPosition [0.175, 0.26, 0.65, 0.04];   
        _infoText ctrlSetText format["Found %1 locations", count _locations];   
        _infoText ctrlSetTextColor [1, 1, 1, 1];   
        _infoText ctrlCommit 0;   
           
        private _listBox = _display ctrlCreate ["RscListBox", 4];   
        _listBox ctrlSetPosition [0.175, 0.31, 0.65, 0.3];   
        _listBox ctrlCommit 0;   
           
        {   
            _x params ["_locationName", "_locationPos", "_locationType"];   
               
            private _distance = round (_caller distance _locationPos);   
            private _typeText = "";  
              
            switch (_locationType) do {  
                case "NameCityCapital": { _typeText = "Capital City"; };  
                case "NameCity": { _typeText = "City"; };  
                case "NameVillage": { _typeText = "Village"; };  
                case "NameLocal": { _typeText = "Local"; };  
                case "Airport": { _typeText = "Airport"; };  
                default { _typeText = _locationType; };  
            };  
               
            private _index = _listBox lbAdd format["%1 - %2 - %3m", _locationName, _typeText, _distance];   
            _listBox lbSetData [_index, str [_locationName, _locationPos]];   
               
            _listBox lbSetColor [_index, [1, 1, 1, 0.7]];   
        } forEach _locations;   
           
        private _teleportBtn = _display ctrlCreate ["RscButton", 5];   
        _teleportBtn ctrlSetText "TELEPORT TO LOCATION";   
        _teleportBtn ctrlSetPosition [0.175, 0.62, 0.3, 0.05];   
        _teleportBtn ctrlSetBackgroundColor [0, 0.5, 0, 1];   
        _teleportBtn ctrlSetTextColor [1, 1, 1, 1];   
        _teleportBtn ctrlCommit 0;   
           
        _teleportBtn ctrlAddEventHandler ["ButtonClick", {   
            params ["_ctrl"];   
            private _display = ctrlParent _ctrl;   
            private _listBox = _display displayCtrl 4;   
            private _selectedIndex = lbCurSel _listBox;   
               
            if (_selectedIndex != -1) then {   
                private _locationData = parseSimpleArray (_listBox lbData _selectedIndex);  
                _locationData params ["_locationName", "_locationPos"];  
                   
                [player, _locationName, _locationPos] spawn {   
                    params ["_player", "_locationName", "_locationPos"];   
                       
                    _teleportText = format ["<t size='1.5' color='#00FF00'>TELEPORTING TO %1</t>", _locationName];   
                    [_teleportText, 0, 0.4, 5, 1] remoteExec ["BIS_fnc_dynamicText", _player];   
                       
                    playMusic "AmbientTrack01a_F";   
                       
                    _safePos = [_locationPos, 0, 500, 10, 0, 0.5, 0] call BIS_fnc_findSafePos;  
                    if (count _safePos == 0) then {_safePos = _locationPos;};  
                      
                    _currentPos = getPos _player;  
                    _dirToTarget = _currentPos getDir _locationPos;  
                      
                    _startCamPos = [_currentPos, 100, _dirToTarget] call BIS_fnc_relPos;  
                    _startCamPos set [2, 800];  
                      
                    _camera = "camera" camCreate _startCamPos;  
                    _camera cameraEffect ["internal", "BACK"];  
                    _camera camSetTarget _currentPos;  
                    _camera camSetFov 0.7;  
                    _camera camCommit 0;  
                    showCinemaBorder false;  
                      
                    _camera camSetPos [_currentPos select 0, _currentPos select 1, 600];  
                    _camera camCommit 2;  
                      
                    sleep 2;  
                      
                    _camera camSetTarget _locationPos;  
                    _camera camSetPos [_locationPos select 0, _locationPos select 1, 1000];  
                    _camera camCommit 6;  
                      
                    sleep 6;  
                      
                    _player setPos _safePos;   
                    {   
                        _x setPos _safePos;   
                        _x setVariable ["shootingDisabled", false, true];   
                        _x setVariable ["playerTimeout", true];   
                    } forEach units group _player;  
                      
                    _playerDir = getDir _player;  
                    _camera camSetTarget _player;  
                      
                    _thirdPersonPos = [_safePos, 8, _playerDir] call BIS_fnc_relPos;  
                    _thirdPersonPos set [2, 4];  
                    _camera camSetPos _thirdPersonPos;  
                    _camera camCommit 4;  
                      
                    sleep 4;  
                      
                    _firstPersonPos = [_safePos, 0.5, _playerDir] call BIS_fnc_relPos;  
                    _firstPersonPos set [2, 1.6];  
                    _camera camSetPos _firstPersonPos;  
                    _camera camCommit 3;  
                      
                    sleep 3;  
                      
                    _camera cameraEffect ["terminate", "BACK"];  
                    camDestroy _camera;  
                       
                    if (EnableCustomHudMode>0) then {  
                        [["BRSEMissionInfoUI", "PLAIN"]] remoteExec ["cutRsc", _player];  
                        remoteExec ["updateUI", _player];  
                    };  
                       
                    _arrivedText = format ["<t size='1.5' color='#00FF00'>ARRIVED at %1</t>", _locationName];   
                    [_arrivedText, 0, 0.4, 3, 1] remoteExec ["BIS_fnc_dynamicText", _player];   
                       
                    private _infohint = format ["Teleported to %1", _locationName];   
                    [1,[_infohint, "PLAIN DOWN", 0.7]] remoteExec ["cutText", _player];   
                       
                    _timerDuration = _player getVariable ["supportTimer", 420];   
                    _minutes = _timerDuration / 60;   
                    systemChat format["Extraction Incoming! %1 minutes countdown started.", _minutes];   
                };   
                   
                closeDialog 0;   
            } else {   
                ["Please select a location first", "PLAIN DOWN", 1] remoteExec ["cutText", player];   
            };   
        }];   
           
        private _randomBtn = _display ctrlCreate ["RscButton", 6];   
        _randomBtn ctrlSetText "TELEPORT RANDOM";   
        _randomBtn ctrlSetPosition [0.525, 0.62, 0.3, 0.05];   
        _randomBtn ctrlSetBackgroundColor [0.5, 0.3, 0, 1];   
        _randomBtn ctrlSetTextColor [1, 1, 1, 1];   
        _randomBtn ctrlCommit 0;   
           
        _randomBtn ctrlAddEventHandler ["ButtonClick", {   
            params ["_ctrl"];   
            private _display = ctrlParent _ctrl;   
               
            [] spawn {   
                _allLocations = nearestLocations [[worldSize/2,worldSize/2,0], ["NameCityCapital","NameCity","NameVillage","NameLocal","Airport"], worldSize/2];  
                if (count _allLocations > 0) then {  
                    _randomLocation = selectRandom _allLocations;  
                    _locationName = text _randomLocation;  
                    _locationPos = locationPosition _randomLocation;  
                      
                    _safePos = [_locationPos, 0, 500, 10, 0, 0.5, 0] call BIS_fnc_findSafePos;  
                    if (count _safePos == 0) then {_safePos = _locationPos;};  
                      
                    _teleportText = format ["<t size='1.5' color='#FFA500'>TELEPORTING TO %1</t>", _locationName];   
                    [_teleportText, 0, 0.4, 5, 1] remoteExec ["BIS_fnc_dynamicText", player];   
                       
                    playMusic "AmbientTrack01a_F";   
                      
                    _currentPos = getPos player;  
                    _dirToTarget = _currentPos getDir _locationPos;  
                      
                    _startCamPos = [_currentPos, 100, _dirToTarget] call BIS_fnc_relPos;  
                    _startCamPos set [2, 800];  
                      
                    _camera = "camera" camCreate _startCamPos;  
                    _camera cameraEffect ["internal", "BACK"];  
                    _camera camSetTarget _currentPos;  
                    _camera camSetFov 0.7;  
                    _camera camCommit 0;  
                    showCinemaBorder false;  
                      
                    _camera camSetPos [_currentPos select 0, _currentPos select 1, 600];  
                    _camera camCommit 2;  
                      
                    sleep 2;  
                      
                    _camera camSetTarget _locationPos;  
                    _camera camSetPos [_locationPos select 0, _locationPos select 1, 1000];  
                    _camera camCommit 6;  
                      
                    sleep 6;  
                      
                    player setPos _safePos;   
                    {   
                        _x setPos _safePos;   
                        _x setVariable ["shootingDisabled", false, true];   
                        _x setVariable ["playerTimeout", true];   
                    } forEach units group player;  
                      
                    _playerDir = getDir player;  
                    _camera camSetTarget player;  
                      
                    _thirdPersonPos = [_safePos, 8, _playerDir] call BIS_fnc_relPos;  
                    _thirdPersonPos set [2, 4];  
                    _camera camSetPos _thirdPersonPos;  
                    _camera camCommit 4;  
                      
                    sleep 4;  
                      
                    _firstPersonPos = [_safePos, 0.5, _playerDir] call BIS_fnc_relPos;  
                    _firstPersonPos set [2, 1.6];  
                    _camera camSetPos _firstPersonPos;  
                    _camera camCommit 3;  
                      
                    sleep 3;  
                      
                    _camera cameraEffect ["terminate", "BACK"];  
                    camDestroy _camera;  
                       
                    if (EnableCustomHudMode>0) then {  
                        [["BRSEMissionInfoUI", "PLAIN"]] remoteExec ["cutRsc", player];  
                        remoteExec ["updateUI", player];  
                    };  
                       
                    _arrivedText = format ["<t size='1.5' color='#00FF00'>ARRIVED at %1</t>", _locationName];   
                    [_arrivedText, 0, 0.4, 3, 1] remoteExec ["BIS_fnc_dynamicText", player];   
                       
                    private _infohint = format ["Teleported to %1", _locationName];   
                    [1,[_infohint, "PLAIN DOWN", 0.7]] remoteExec ["cutText", player];   
                       
                    _timerDuration = player getVariable ["supportTimer", 420];   
                    _minutes = _timerDuration / 60;   
                    systemChat format["Extraction Incoming! %1 minutes countdown started.", _minutes];   
                } else {  
                    ["No locations found on map", "PLAIN DOWN", 1] remoteExec ["cutText", player];  
                };  
            };   
               
            closeDialog 0;   
        }];   
           
        private _closeBtn = _display ctrlCreate ["RscButton", 7];   
        _closeBtn ctrlSetText "CLOSE";   
        _closeBtn ctrlSetPosition [0.175, 0.68, 0.3, 0.05];   
        _closeBtn ctrlSetBackgroundColor [0.5, 0, 0, 1];   
        _closeBtn ctrlSetTextColor [1, 1, 1, 1];   
        _closeBtn ctrlCommit 0;   
           
        _closeBtn ctrlAddEventHandler ["ButtonClick", {   
            closeDialog 0;   
        }];   
           
        if (count _locations > 0) then {   
            _listBox lbSetCurSel 0;   
        };   
           
    },   
    nil,   
    1.5,   
    true,   
    true,   
    "",   
    "!(_this getVariable ['playerTimeout', false])",   
    5   
]; 
_teleportObject addAction [   
    "<t color='#FF0000'>Waiting for Timeout...</t>",   
    {   
        params ["_target", "_caller"];   
        ["You are in timeout mode and cannot use teleport yet", 0, 0.4, 3, 1] remoteExec ["BIS_fnc_dynamicText", _caller];   
    },   
    nil,   
    1.5,   
    true,   
    true,   
    "",   
    "(_this getVariable ['playerTimeout', true])",   
    4.9  
];
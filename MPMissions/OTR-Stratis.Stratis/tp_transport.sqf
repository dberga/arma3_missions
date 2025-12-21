params ["_teleportObject"];
_teleportObject addAction [  
    "<t color='#00FFFF'>TRANSPORT TICKET</t>",   
    {   
        params ["_target", "_caller"];   
           
           
        _dropPlanes = [];   
        {   
            _varName = vehicleVarName _x;   
            if (_varName != "" && {(_varName find "dropPlane") != -1}) then {   
                _planeInfo = [   
                    _varName,   
                    _x,   
                    getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"),   
                    getPos _x,   
                    crew _x,   
                    typeOf _x   
                ];   
                _dropPlanes pushBack _planeInfo;   
            };   
        } forEach vehicles;   
           
        if (count _dropPlanes == 0) exitWith {   
            ["No transport planes available", "PLAIN DOWN", 1] remoteExec ["cutText", _caller];   
        };   
           
        createDialog "RscDisplayEmpty";   
        private _display = findDisplay -1;   
           
        private _bg = _display ctrlCreate ["RscText", 1];   
        _bg ctrlSetPosition [0.15, 0.2, 0.7, 0.6];   
        _bg ctrlSetBackgroundColor [0, 0, 0, 0.8];   
        _bg ctrlCommit 0;   
           
        private _title = _display ctrlCreate ["RscText", 2];   
        _title ctrlSetText "TRANSPORT TICKET";   
        _title ctrlSetPosition [0.15, 0.2, 0.7, 0.05];   
        _title ctrlSetBackgroundColor [0.1, 0.3, 0.5, 1];   
        _title ctrlSetTextColor [1, 1, 1, 1];   
        _title ctrlCommit 0;   
           
        private _infoText = _display ctrlCreate ["RscText", 3];   
        _infoText ctrlSetPosition [0.175, 0.26, 0.65, 0.04];   
        _infoText ctrlSetText format["Found %1 transport planes", count _dropPlanes];   
        _infoText ctrlSetTextColor [1, 1, 1, 1];   
        _infoText ctrlCommit 0;   
           
        private _listBox = _display ctrlCreate ["RscListBox", 4];   
        _listBox ctrlSetPosition [0.175, 0.31, 0.65, 0.3];   
        _listBox ctrlCommit 0;   
           
        {   
            _x params ["_varName", "_plane", "_displayName", "_pos", "_crew", "_type"];   
               
            private _distance = round (_caller distance _pos);   
            _totalSeats = getNumber (configFile >> "CfgVehicles" >> _type >> "transportSoldier");   
            _currentCrew = {alive _x} count _crew;   
            _filledSeats = _currentCrew;   
            _availableSeats = _totalSeats - _currentCrew;   
               
            _nearestLocations = nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage","NameLocal","Airport"], 2000];   
            _locationName = "Unknown Location";   
            if (count _nearestLocations > 0) then {   
                _nearestLocation = _nearestLocations select 0;   
                _locationName = text _nearestLocation;   
            };   
               
            private _status = "";   
            private _color = [1, 1, 1, 0.7];   
               
            if (!alive _plane || !canMove _plane) then {   
                _status = " [DAMAGED]";   
                _color = [1, 0, 0, 0.7];   
            } else {   
                if (_availableSeats <= 0) then {   
                    _status = " [FULL]";   
                    _color = [1, 0, 0, 0.7];   
                } else {   
                    _status = " [AVAILABLE]";   
                    _color = [0, 1, 0, 0.7];   
                };   
            };   
               
            private _index = _listBox lbAdd format["%1%2 - %3/%4 seats - %5m - Near %6", _displayName, _status, _filledSeats, _totalSeats, _distance, _locationName];   
            _listBox lbSetData [_index, netId _plane];   
            _listBox lbSetColor [_index, _color];   
        } forEach _dropPlanes;   
           
        private _transportAloneBtn = _display ctrlCreate ["RscButton", 5];   
        _transportAloneBtn ctrlSetText "TRAVEL ALONE";   
        _transportAloneBtn ctrlSetPosition [0.175, 0.62, 0.3, 0.05];   
        _transportAloneBtn ctrlSetBackgroundColor [0, 0.5, 1, 1];   
        _transportAloneBtn ctrlSetTextColor [1, 1, 1, 1];   
        _transportAloneBtn ctrlCommit 0;   
           
        _transportAloneBtn ctrlAddEventHandler ["ButtonClick", {   
            params ["_ctrl"];   
            private _display = ctrlParent _ctrl;   
            private _listBox = _display displayCtrl 4;   
            private _selectedIndex = lbCurSel _listBox;   
               
            if (_selectedIndex != -1) then {   
                private _planeNetId = _listBox lbData _selectedIndex;   
                private _plane = objectFromNetId _planeNetId;   
                   
                if (!isNull _plane && alive _plane && canMove _plane) then {   
                    _totalSeats = getNumber (configFile >> "CfgVehicles" >> typeOf _plane >> "transportSoldier");   
                    _currentCrew = {alive _x} count crew _plane;   
                    _availableSeats = _totalSeats - _currentCrew;   
                       
                    if (_availableSeats > 0) then {   
                        [player, _plane, false] spawn {   
                            params ["_player", "_plane", "_withSquad"];   
                               
                            _transportText = "<t size='1.5' color='#00FFFF'>TRANSPORT TO PLANE</t>";   
                            [_transportText, 0, 0.4, 5, 1] remoteExec ["BIS_fnc_dynamicText", _player];   
                               
                            playMusic "LeadTrack03_F";   
                              
                            if (!_withSquad) then {  
                                _holdcount = 0;   
                                {      
                                    if (!isPlayer _x) then {   
                                        doStop _x;   
                                        _holdcount = _holdcount + 1;   
                                    };   
                                } forEach units group _player;   
                                if (_holdcount > 0) then {   
                                    systemChat format["%1 Squad units remain in base holding position.", _holdcount];        
                                };   
                            };  
                              
                               
                                  
                            removeUniform _player;      
                            removeVest _player;      
                            removeHeadgear _player;      
                            removeGoggles _player;      
                            removeBackpack _player;      
                            removeAllAssignedItems _player;      
                            removeAllWeapons _player;      
                            removeAllItems _player;      
                              
                            _civilianUniforms = [      
                                "U_C_Poloshirt_blue", "U_C_Poloshirt_burgundy", "U_C_Poloshirt_stripped",      
                                "U_C_Poloshirt_tricolour", "U_C_Poloshirt_salmon", "U_C_Poloshirt_redwhite",      
                                "U_C_Commoner1_1", "U_C_Commoner1_2", "U_C_Commoner1_3",      
                                "U_Rangemaster", "U_C_Poor_1", "U_C_Poor_2",      
                                "U_C_WorkerCoveralls", "U_C_HunterBody_grn", "U_C_Journalist"      
                            ];      
                                  
                            _civilianHeadgear = [      
                                "H_Cap_red", "H_Cap_blu", "H_Cap_oli", "H_Cap_headphones",      
                                "H_Cap_tan", "H_Cap_blk", "H_Cap_blk_CMMG", "H_Cap_grn",      
                                "H_Cap_grn_BI", "H_Cap_blk_Raven", "H_Cap_blk_ION",      
                                "H_Hat_blue", "H_Hat_brown", "H_Hat_checker", "H_Hat_grey",      
                                "H_Hat_tan", "H_StrawHat", "H_StrawHat_dark"      
                            ];      
                              
                            _survivorUniforms = [    
                                "U_B_CombatUniform_mcam",    
                                "U_O_CombatUniform_ocamo",     
                                "U_I_CombatUniform",    
                                "U_BG_Guerrila1_1"  
                            ];  
  
                            _player forceAddUniform (selectRandom _civilianUniforms);      
                            _player addHeadgear (selectRandom _civilianHeadgear);      
                              
                            _player addBackPack 'B_parachute';   
                              
                            _planePos = getPos _plane;  
                            _worldSize = worldSize;  
                            _cenitalHeight = _worldSize / 2;  
                              
                            _camera = "camera" camCreate [(_planePos select 0), (_planePos select 1), _cenitalHeight];  
                            _camera cameraEffect ["internal", "BACK"];   
                            _camera camSetTarget _plane;   
                            _camera camSetFov 0.5;   
                            _camera camCommit 0;   
                            showCinemaBorder false;   
                              
                            sleep 3;   
                              
                            _followHeight = _cenitalHeight / 4;  
                            _camera camSetPos [(_planePos select 0), (_planePos select 1), _followHeight];  
                            _camera camCommit 6;   
                              
                            sleep 6;   
                              
                            _thirdPersonPos = [(_planePos select 0) - 15, (_planePos select 1) - 15, 8];  
                            _camera camSetPos _thirdPersonPos;   
                            _camera camCommit 4;   
                              
                            sleep 4;   
                              
                            _closeThirdPersonPos = [(_planePos select 0) - 8, (_planePos select 1) - 8, 4];  
                            _camera camSetPos _closeThirdPersonPos;   
                            _camera camCommit 3;   
                              
                            sleep 3;   
                              
                            _player assignAsCargo _plane;   
                            _player moveInCargo _plane;   
                              
                            _planePos = getPos _plane;  
                            _camera camSetTarget _player;   
                            _camera camCommit 2;   
                              
                            sleep 2;   
                              
                            _playerThirdPersonPos = [(_planePos select 0) - 3, (_planePos select 1) - 3, (_planePos select 2) - 10];  
                            _camera camSetPos _playerThirdPersonPos;   
                            _camera camCommit 3;   
                              
                            sleep 3;   
                              
                            _closePlayerPos = [(_planePos select 0) - 1.5, (_planePos select 1) - 1.5, (_planePos select 2) - 5];  
                            _camera camSetPos _closePlayerPos;   
                            _camera camCommit 2;    
                              
                            sleep 2;   
                            _shoulderPos = [(_planePos select 0) - 0.4, (_planePos select 1) - 0.4, (_planePos select 2)];  
                            _camera camSetPos _shoulderPos;   
                            _camera camCommit 3;   
                              
                            sleep 3;   
                              
                            _planePos = getPos _plane;  
                            _firstPersonPos = [(_planePos select 0), (_planePos select 1), (_planePos select 2)];  
                            _camera camSetPos _firstPersonPos;   
                            _camera camCommit 4;   
                              
                            sleep 4;   
                              
                            _camera cameraEffect ["terminate", "BACK"];   
                            camDestroy _camera;   
  
                            if (EnableCustomHudMode>0) then {  
                                [["BRSEMissionInfoUI", "PLAIN"]] remoteExec ["cutRsc", _player];  
                                remoteExec ["updateUI", _player];  
                            };  
                               
                            _arrivedText = "<t size='1.5' color='#00FFFF'>BOARDED TRANSPORT PLANE</t>";   
                            [_arrivedText, 0, 0.4, 3, 1] remoteExec ["BIS_fnc_dynamicText", _player];   
                               
                            private _infohint = "Transport to plane completed";   
                            [1,[_infohint, "PLAIN DOWN", 0.7]] remoteExec ["cutText", _player];   
                               
                            _player setVariable ["shootingDisabled", false, true];   
                            _player setVariable ["playerTimeout", true];   
                               
                            _timerDuration = _player getVariable ["supportTimer", 420];   
                            _minutes = _timerDuration / 60;   
                            systemChat format["Extraction Incoming! %1 minutes countdown started.", _minutes];   
                        };   
                           
                        closeDialog 0;   
                    } else {   
                        ["Selected plane is full", "PLAIN DOWN", 1] remoteExec ["BIS_fnc_dynamicText", player];   
                    };   
                } else {   
                    ["Selected plane is not available", "PLAIN DOWN", 1] remoteExec ["BIS_fnc_dynamicText", player];   
                };   
            } else {   
                ["Please select a plane first", "PLAIN DOWN", 1] remoteExec ["BIS_fnc_dynamicText", player];   
            };   
        }];   
           
        private _transportSquadBtn = _display ctrlCreate ["RscButton", 7];   
        _transportSquadBtn ctrlSetText "TRAVEL WITH SQUAD";   
        _transportSquadBtn ctrlSetPosition [0.525, 0.62, 0.3, 0.05];   
        _transportSquadBtn ctrlSetBackgroundColor [0, 0.7, 0, 1];   
        _transportSquadBtn ctrlSetTextColor [1, 1, 1, 1];   
        _transportSquadBtn ctrlCommit 0;   
           
        _transportSquadBtn ctrlAddEventHandler ["ButtonClick", {   
            params ["_ctrl"];   
            private _display = ctrlParent _ctrl;   
            private _listBox = _display displayCtrl 4;   
            private _selectedIndex = lbCurSel _listBox;   
               
            if (_selectedIndex != -1) then {   
                private _planeNetId = _listBox lbData _selectedIndex;   
                private _plane = objectFromNetId _planeNetId;   
                   
                if (!isNull _plane && alive _plane && canMove _plane) then {   
                    _totalSeats = getNumber (configFile >> "CfgVehicles" >> typeOf _plane >> "transportSoldier");   
                    _currentCrew = {alive _x} count crew _plane;   
                    _availableSeats = _totalSeats - _currentCrew;   
                      
                    _squadSize = {!isPlayer _x} count units group player;  
                      
                    if (_availableSeats >= _squadSize + 1) then {   
                        [player, _plane, true] spawn {  
                            params ["_player", "_plane", "_withSquad"];  
                              
                            _transportText = "<t size='1.5' color='#00FFFF'>TRANSPORT TO PLANE</t>";   
                            [_transportText, 0, 0.4, 5, 1] remoteExec ["BIS_fnc_dynamicText", _player];   
                               
                            playMusic "LeadTrack03_F";   
                              
                            removeUniform _player;      
                            removeVest _player;      
                            removeHeadgear _player;      
                            removeGoggles _player;      
                            removeBackpack _player;      
                            removeAllAssignedItems _player;      
                            removeAllWeapons _player;      
                            removeAllItems _player;      
                                  
                            _civilianUniforms = [      
                                "U_C_Poloshirt_blue", "U_C_Poloshirt_burgundy", "U_C_Poloshirt_stripped",      
                                "U_C_Poloshirt_tricolour", "U_C_Poloshirt_salmon", "U_C_Poloshirt_redwhite",      
                                "U_C_Commoner1_1", "U_C_Commoner1_2", "U_C_Commoner1_3",      
                                "U_Rangemaster", "U_C_Poor_1", "U_C_Poor_2",      
                                "U_C_WorkerCoveralls", "U_C_HunterBody_grn", "U_C_Journalist"      
                            ];      
                                  
                            _civilianHeadgear = [      
                                "H_Cap_red", "H_Cap_blu", "H_Cap_oli", "H_Cap_headphones",      
                                "H_Cap_tan", "H_Cap_blk", "H_Cap_blk_CMMG", "H_Cap_grn",      
                                "H_Cap_grn_BI", "H_Cap_blk_Raven", "H_Cap_blk_ION",      
                                "H_Hat_blue", "H_Hat_brown", "H_Hat_checker", "H_Hat_grey",      
                                "H_Hat_tan", "H_StrawHat", "H_StrawHat_dark"      
                            ];      
                              
                            _survivorUniforms = [    
                                "U_B_CombatUniform_mcam",    
                                "U_O_CombatUniform_ocamo",     
                                "U_I_CombatUniform",    
                                "U_BG_Guerrila1_1"  
                            ];  
   
                            _player forceAddUniform (selectRandom _civilianUniforms);      
                            _player addHeadgear (selectRandom _civilianHeadgear);      
                              
                            _player addBackPack 'B_parachute';   
                              
                            _planePos = getPos _plane;  
                            _worldSize = worldSize;  
                            _cenitalHeight = _worldSize / 2;  
                              
                            _camera = "camera" camCreate [(_planePos select 0), (_planePos select 1), _cenitalHeight];  
                            _camera cameraEffect ["internal", "BACK"];   
                            _camera camSetTarget _plane;   
                            _camera camSetFov 0.5;   
                            _camera camCommit 0;   
                            showCinemaBorder false;   
                              
                            sleep 3;   
                              
                            _followHeight = _cenitalHeight / 4;  
                            _camera camSetPos [(_planePos select 0), (_planePos select 1), _followHeight];  
                            _camera camCommit 6;   
                              
                            sleep 6;   
                              
                            _thirdPersonPos = [(_planePos select 0) - 15, (_planePos select 1) - 15, 8];  
                            _camera camSetPos _thirdPersonPos;   
                            _camera camCommit 4;   
                              
                            sleep 4;   
                              
                            _closeThirdPersonPos = [(_planePos select 0) - 8, (_planePos select 1) - 8, 4];  
                            _camera camSetPos _closeThirdPersonPos;   
                            _camera camCommit 3;   
                              
                            sleep 3;   
                              
                            _player assignAsCargo _plane;   
                            _player moveInCargo _plane;   
                              
                            {  
                                if (!isPlayer _x) then {  
                                    removeHeadgear _x;  
                                    removeGoggles _x;  
                                    removeVest _x;  
                                    removeBackpack _x;  
                                    removeAllWeapons _x;  
                                    removeAllAssignedItems _x;  
                                    _x forceAddUniform (selectRandom _civilianUniforms);  
                                    _x addHeadgear (selectRandom _civilianHeadgear);  
                                          
                                    _x addBackPack 'B_parachute';  
                                    _x assignAsCargo _plane;  
                                    _x moveInCargo _plane;  
                                    _x setVariable ["shootingDisabled", false, true];  
                                };  
                            } forEach units group _player;  
                              
                            _planePos = getPos _plane;  
                            _camera camSetTarget _player;   
                            _camera camCommit 2;   
                              
                            sleep 2;   
                              
                            _playerThirdPersonPos = [(_planePos select 0) - 3, (_planePos select 1) - 3, (_planePos select 2) - 10];  
                            _camera camSetPos _playerThirdPersonPos;   
                            _camera camCommit 3;   
                              
                            sleep 3;   
                              
                            _closePlayerPos = [(_planePos select 0) - 1.5, (_planePos select 1) - 1.5, (_planePos select 2) - 5];  
                            _camera camSetPos _closePlayerPos;   
                            _camera camCommit 2;   
                              
                            sleep 2;   
                            _shoulderPos = [(_planePos select 0) - 0.4, (_planePos select 1) - 0.4, (_planePos select 2)];  
                            _camera camSetPos _shoulderPos;   
                            _camera camCommit 3;   
                              
                            sleep 3;   
                              
                            _planePos = getPos _plane;  
                            _firstPersonPos = [(_planePos select 0), (_planePos select 1), (_planePos select 2)];  
                            _camera camSetPos _firstPersonPos;   
                            _camera camCommit 4;   
                              
                            sleep 4;   
                              
                            _camera cameraEffect ["terminate", "BACK"];   
                            camDestroy _camera;   
  
                            _player addAction [  
                                "[COMMAND] Squad - PARACHUTE OUT",   
                                {  
                                    params ["_target", "_caller"];  
                                    _vehicle = vehicle _caller;  
                                    _pilot = driver _vehicle;  
                                      
                                    {  
                                        if (!isPlayer _x && vehicle _x == _vehicle) then {  
                                            moveOut _x;  
                                            unassignVehicle _x;  
                                            [_x] spawn {  
                                                params ["_unit"];  
                                                sleep 1;  
                                                if (backpack _unit == "B_Parachute" && (getPos _unit) select 2 > 50) then {  
                                                    _unit action ["OpenParachute", _unit];  
                                                };  
                                            };  
                                        };  
                                    } forEach units group _caller;  
                                      
                                    if (!isNull _pilot) then {  
                                        _pilot disableAI "AUTOTARGET";  
                                        _pilot disableAI "TARGET";  
                                        _pilot disableAI "AUTOCOMBAT";  
                                        _group = group _pilot;  
                                        _group setCombatMode "BLUE";  
                                        _group setBehaviour "CARELESS";  
                                          
                                        _wp = currentWaypoint _group;  
                                        if (_wp != -1) then {  
                                            _group setCurrentWaypoint [_group, _wp];  
                                        };  
                                    };  
                                      
                                    _caller removeAction (_this select 2);  
                                },   
                                nil, 1.5, false, true, "",   
                                "vehicle _this != _this && driver vehicle _this != _this"  
                            ];  
  
                            if (EnableCustomHudMode>0) then {  
                                [["BRSEMissionInfoUI", "PLAIN"]] remoteExec ["cutRsc", _player];  
                                remoteExec ["updateUI", _player];  
                            };  
                               
                            _arrivedText = "<t size='1.5' color='#00FFFF'>BOARDED TRANSPORT PLANE</t>";   
                            [_arrivedText, 0, 0.4, 3, 1] remoteExec ["BIS_fnc_dynamicText", _player];   
                               
                            private _infohint = "Transport to plane completed";   
                            [1,[_infohint, "PLAIN DOWN", 0.7]] remoteExec ["cutText", _player];   
                               
                            _player setVariable ["shootingDisabled", false, true];   
                            _player setVariable ["playerTimeout", true];   
                               
                            _timerDuration = _player getVariable ["supportTimer", 420];   
                            _minutes = _timerDuration / 60;   
                            systemChat format["Extraction Incoming! %1 minutes countdown started.", _minutes];   
                        };   
                           
                        closeDialog 0;   
                    } else {   
                        ["Selected plane doesn't have enough seats for your squad", "PLAIN DOWN", 1] remoteExec ["BIS_fnc_dynamicText", player];   
                    };   
                } else {   
                    ["Selected plane is not available", "PLAIN DOWN", 1] remoteExec ["BIS_fnc_dynamicText", player];   
                };   
            } else {   
                ["Please select a plane first", "PLAIN DOWN", 1] remoteExec ["BIS_fnc_dynamicText", player];   
            };   
        }];  
           
        private _closeBtn = _display ctrlCreate ["RscButton", 6];   
        _closeBtn ctrlSetText "CLOSE";   
        _closeBtn ctrlSetPosition [0.35, 0.68, 0.3, 0.05];   
        _closeBtn ctrlSetBackgroundColor [0.5, 0, 0, 1];   
        _closeBtn ctrlSetTextColor [1, 1, 1, 1];   
        _closeBtn ctrlCommit 0;   
           
        _closeBtn ctrlAddEventHandler ["ButtonClick", {   
            closeDialog 0;   
        }];   
           
        if (count _dropPlanes > 0) then {   
            _listBox lbSetCurSel 0;   
        };   
           
    },   
    nil,   
    1.5,   
    true,   
    true,   
    "",   
    "true",   
    5   
];
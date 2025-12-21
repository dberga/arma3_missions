params["_box"];
_box addAction ["Arma 3 Arsenal (need 50000 rating)", {  
    params ["_target", "_caller"];  
    private _playerUID = getPlayerUID _caller;
    private _PlayerRating = missionProfileNamespace getVariable [_playerUID + "_rating", 0];
    if (_PlayerRating >= 50000) then {  
        _playerID = getPlayerUID _caller; 
        _crate = missionNamespaceNamespace getVariable [format["personalCrate_%1", _playerID], objNull]; 
         
        if (isNull _crate) then { 
            _crate = "Box_NATO_Ammo_F" createVehicle [0,0,0]; 
            _crate hideObjectGlobal true; 
             
            _crateData = missionProfileNamespace getVariable [format["personalCrateData_%1", _playerID], []]; 
             
            clearWeaponCargoGlobal _crate;       
            clearMagazineCargoGlobal _crate;       
            clearItemCargoGlobal _crate;       
            clearBackpackCargoGlobal _crate;   
               
            if (count _crateData > 0) then {   
                {  
                    _item = _x select 0;  
                    _count = _x select 1;  
                      
                    if (_item isKindOf "Bag_Base") then {  
                        _crate addBackpackCargoGlobal [_item, _count];  
                    } else {  
                        _config = configFile >> "CfgWeapons" >> _item;  
                        if (isClass _config) then {  
                            if (getNumber (_config >> "type") in [1,2,4]) then {  
                                _crate addWeaponCargoGlobal [_item, _count];  
                            } else {  
                                _crate addItemCargoGlobal [_item, _count];  
                            };  
                        } else {  
                            _crate addItemCargoGlobal [_item, _count];  
                        };  
                    };  
                } forEach _crateData;  
            }; 
             
            missionNamespace setVariable [format["tempArsenalCrate_%1", _playerID], _crate]; 
            missionNamespace setVariable [format["arsenalCaller_%1", _playerID], _caller]; 
             
            ["Open", true] call BIS_fnc_arsenal; 
             
            [_playerID] spawn { 
                params ["_playerID"]; 
                waitUntil {isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull])}; 
                sleep 0.1; 
                 
                _caller = missionNamespace getVariable [format["arsenalCaller_%1", _playerID], objNull]; 
                _crate = missionNamespace getVariable [format["tempArsenalCrate_%1", _playerID], objNull]; 
                 
                if (isNull _crate || isNull _caller) exitWith {}; 
                 
                _crateContents = []; 
                   
                _weapons = weaponsItemsCargo _crate;   
                if (!isNil "_weapons") then {   
                    {   
                        _crateContents pushBack [_x select 0, 1];   
                        {   
                            if (_x isEqualType "" && {_x != ""}) then {   
                                _crateContents pushBack [_x, 1];   
                            };   
                        } forEach (_x select [1, 4]);   
                    } forEach _weapons;   
                };   
                   
                _magazines = magazinesAmmoCargo _crate;   
                if (!isNil "_magazines") then {   
                    {   
                        _crateContents pushBack [_x select 0, 1];   
                    } forEach _magazines;   
                };   
                   
                _items = getItemCargo _crate;   
                if (!isNil "_items") then {   
                    {   
                        for "_i" from 1 to (_items select 1 select _forEachIndex) do {   
                            _crateContents pushBack [_x, 1];   
                        };   
                    } forEach (_items select 0);   
                };   
                   
                _backpacks = everyBackpack _crate;   
                {   
                    _crateContents pushBack [typeOf _x, 1];   
                } forEach _backpacks;   
                   
                missionProfileNamespace setVariable [format["personalCrateData_%1", _playerID], _crateContents];   
                saveMissionProfileNamespace; 
                 
                _existingCrate = missionNamespace getVariable [format["personalCrate_%1", _playerID], objNull]; 
                if (!isNull _existingCrate) then { 
                    clearWeaponCargoGlobal _existingCrate;       
                    clearMagazineCargoGlobal _existingCrate;       
                    clearItemCargoGlobal _existingCrate;       
                    clearBackpackCargoGlobal _existingCrate; 
                     
                    { 
                        _item = _x select 0;  
                        _count = _x select 1;  
                          
                        if (_item isKindOf "Bag_Base") then {  
                            _existingCrate addBackpackCargoGlobal [_item, _count];  
                        } else {  
                            _config = configFile >> "CfgWeapons" >> _item;  
                            if (isClass _config) then {  
                                if (getNumber (_config >> "type") in [1,2,4]) then {  
                                    _existingCrate addWeaponCargoGlobal [_item, _count];  
                                } else {  
                                    _existingCrate addItemCargoGlobal [_item, _count];  
                                };  
                            } else {  
                                _existingCrate addItemCargoGlobal [_item, _count];  
                            };  
                        };  
                    } forEach _crateContents; 
                }; 
                 
                deleteVehicle _crate; 
                missionNamespace setVariable [format["tempArsenalCrate_%1", _playerID], nil]; 
                missionNamespace setVariable [format["arsenalCaller_%1", _playerID], nil]; 
                 
                systemChat "Arsenal changes saved to your personal crate!"; 
                 
                if (!visibleMap && !dialog) then { 
                    openMap [false, false]; 
                    openMap [false, false]; 
                }; 
                 
                showHUD true; 
                enableEnvironment true; 
            }; 
        } else { 
            ["Open", true] call BIS_fnc_arsenal; 
        }; 
    } else {  
        systemChat "You need a rating above 5000 to access the Arsenal!";  
    };  
}];
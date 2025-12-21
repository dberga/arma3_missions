params["_box"];
_box addAction [   
    "Access Personal Arsenal (spawn storage)",   
    {   
        params ["_target", "_caller"];   
        _playerID = getPlayerUID _caller;   
        _crate = missionNamespace getVariable [format["personalCrate_%1", _playerID], objNull];   
           
        if (isNull _crate) then {   
            _crateData = missionProfileNamespace getVariable [format["personalCrateData_%1", _playerID], []];   
            systemChat format["DEBUG: Loading crate data - %1 items", count _crateData];   
               
            _crate = "Box_NATO_Ammo_F" createVehicle [0,0,0];   
            _crate setPos (_caller modelToWorld [0, 1, 0]);   
            _crate setVariable ["owner", _playerID, true];   
            _crate setVariable ["ownerName", name _caller, true];   
            _crate allowDamage false;   
            _crate lockInventory true;   
            _crate setMaxLoad 99999;   
               
            clearWeaponCargoGlobal _crate;   
            clearMagazineCargoGlobal _crate;   
            clearItemCargoGlobal _crate;   
            clearBackpackCargoGlobal _crate;   
               
            if (count _crateData > 0) then {     
                {    
                    if (_x isEqualType [] && {count _x >= 2}) then {   
                        _item = _x select 0;    
                        _count = _x select 1;    
                           
                        if (_item isEqualType "") then {   
                            if (_item isKindOf "Bag_Base") then {    
                                _crate addBackpackCargoGlobal [_item, _count];    
                            } else {    
                                _config = configFile >> "CfgWeapons" >> _item;    
                                if (isClass _config) then {    
                                    if (getNumber (_config >> "type") in [1,2,4,4096]) then {    
                                        _crate addWeaponCargoGlobal [_item, _count];    
                                    } else {    
                                        _crate addItemCargoGlobal [_item, _count];    
                                    };    
                                } else {    
                                    _crate addItemCargoGlobal [_item, _count];    
                                };    
                            };   
                        };   
                    };   
                } forEach _crateData;    
            };     
               
            _fnc_saveCrate = {   
                params ["_crate"];   
                _owner = _crate getVariable "owner";   
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
                   
                missionProfileNamespace setVariable [format["personalCrateData_%1", _owner], _crateContents];   
                saveMissionProfileNamespace;   
                systemChat "Crate saved!";   
            };   
               
            _crate setVariable ["saveFunction", _fnc_saveCrate];   
            missionNamespace setVariable [format["personalCrate_%1", _playerID], _crate, true];   
        } else {   
            detach _crate;   
            _crate setPos (_caller modelToWorld [0, 1, 0]);   
        };   
           
        _lockActionID = _crate getVariable ["lockActionID", -1];   
        _unlockActionID = _crate getVariable ["unlockActionID", -1];   
        _carryActionID = _crate getVariable ["carryActionID", -1];   
        _dropActionID = _crate getVariable ["dropActionID", -1];   
        _arsenalActionID = _crate getVariable ["arsenalActionID", -1];   
           
        if (_lockActionID != -1) then { _crate removeAction _lockActionID; };   
        if (_unlockActionID != -1) then { _crate removeAction _unlockActionID; };   
        if (_carryActionID != -1) then { _crate removeAction _carryActionID; };   
        if (_dropActionID != -1) then { _crate removeAction _dropActionID; };   
        if (_arsenalActionID != -1) then { _crate removeAction _arsenalActionID; };   
           
        _lockID = _crate addAction [   
            "Lock My Crate",   
            {   
                params ["_target", "_caller"];   
                _target lockInventory true;   
                [_target] call (_target getVariable "saveFunction");   
            },   
            nil,   
            1.5,   
            true,   
            true,   
            "",   
            "getPlayerUID _this == (_target getVariable 'owner') && !lockedInventory _target",   
            3   
        ];   
           
        _unlockID = _crate addAction [   
            "Unlock My Crate",   
            {   
                params ["_target", "_caller"];   
                _target lockInventory false;   
                [_target] call (_target getVariable "saveFunction");   
            },   
            nil,   
            1.5,   
            true,   
            true,   
            "",   
            "getPlayerUID _this == (_target getVariable 'owner') && lockedInventory _target",   
            3   
        ];   
           
        _carryID = _crate addAction [   
            "Carry Crate",   
            {   
                params ["_target", "_caller"];   
                _target attachTo [_caller, [0, 1, 0.5]];   
            },   
            nil,   
            1.5,   
            true,   
            true,   
            "",   
            "getPlayerUID _this == (_target getVariable 'owner') && isNull attachedTo _target",   
            3   
        ];   
           
        _dropID = _crate addAction [   
            "Drop Crate",   
            {   
                params ["_target", "_caller"];   
                detach _target;   
                _target setPos (_caller modelToWorld [0, 1, 0]);   
                [_target] call (_target getVariable "saveFunction");   
            },   
            nil,   
            1.5,   
            true,   
            true,   
            "",   
            "getPlayerUID _this == (_target getVariable 'owner') && !isNull attachedTo _target",   
            3   
        ];   
           
        _arsenalID = _crate addAction [   
    "Open Crate Arsenal",   
    {   
        params ["_target", "_caller"];   
        if (getPlayerUID _caller == (_target getVariable "owner")) then {   
            [_target, _caller] spawn {   
                params ["_crate", "_caller"];   
                   
                _crateData = missionProfileNamespace getVariable [format["personalCrateData_%1", _crate getVariable "owner"], []];   
                systemChat format["DEBUG: Found %1 items in crate data", count _crateData];   
                   
                _playerItemsBefore = createHashMap;  
                {  
                    _playerItemsBefore set [_x, (_playerItemsBefore getOrDefault [_x, 0]) + 1];  
                } forEach (weapons _caller);  
                {  
                    _playerItemsBefore set [_x, (_playerItemsBefore getOrDefault [_x, 0]) + 1];  
                } forEach (items _caller);  
                {  
                    _playerItemsBefore set [_x, (_playerItemsBefore getOrDefault [_x, 0]) + 1];  
                } forEach (magazines _caller);  
                if (backpack _caller != "") then { _playerItemsBefore set [backpack _caller, (_playerItemsBefore getOrDefault [backpack _caller, 0]) + 1]; };  
                if (goggles _caller != "") then { _playerItemsBefore set [goggles _caller, (_playerItemsBefore getOrDefault [goggles _caller, 0]) + 1]; };  
                if (uniform _caller != "") then { _playerItemsBefore set [uniform _caller, (_playerItemsBefore getOrDefault [uniform _caller, 0]) + 1]; };  
                if (vest _caller != "") then { _playerItemsBefore set [vest _caller, (_playerItemsBefore getOrDefault [vest _caller, 0]) + 1]; };  
                if (headgear _caller != "") then { _playerItemsBefore set [headgear _caller, (_playerItemsBefore getOrDefault [headgear _caller, 0]) + 1]; };  
                {  
                    _playerItemsBefore set [_x, (_playerItemsBefore getOrDefault [_x, 0]) + 1];  
                } forEach (assignedItems _caller);  
  
                   
                _crateItems = createHashMap;   
                {   
                    _className = _x select 0;   
                    _count = _x select 1;   
                    _crateItems set [_className, (_crateItems getOrDefault [_className, 0]) + _count];   
                } forEach _crateData;   
                   
                _allAvailableItems = createHashMap;   
                { _allAvailableItems set [_x, _y] } forEach _playerItemsBefore;   
                { _allAvailableItems set [_x, (_allAvailableItems getOrDefault [_x, 0]) + _y] } forEach _crateItems;   
                   
                _weaponClasses = [];   
                _itemClasses = [];   
                _backpackClasses = [];   
                _magazineClasses = [];   
   
                {   
                    _className = _x select 0;   
                    if (_className isKindOf "Bag_Base") then {   
                        _backpackClasses pushBack _className;   
                    } else {   
                        if (isClass (configFile >> "CfgGlasses" >> _className)) then {   
                            _itemClasses pushBack _className;   
                        } else {   
                            if (isClass (configFile >> "CfgVehicles" >> _className)) then {   
                                _itemClasses pushBack _className;   
                            } else {   
                                if (isClass (configFile >> "CfgMagazines" >> _className)) then {   
                                    _magazineClasses pushBack _className;   
                                } else {   
                                    _config = configFile >> "CfgWeapons" >> _className;   
                                    if (isClass _config) then {   
                                        _type = getNumber (_config >> "type");   
                                        if (_type in [1,2,4,4096]) then {   
                                            _weaponClasses pushBack _className;   
                                        } else {   
                                            _itemClasses pushBack _className;   
                                        };   
                                    } else {   
                                        _itemClasses pushBack _className;   
                                    };   
                                };   
                            };   
                        };   
                    };   
                } forEach _crateData;   
                   
                ["AmmoboxInit", [_crate, false]] call BIS_fnc_arsenal;   
                   
                if (count _weaponClasses > 0) then {   
                    [_crate, _weaponClasses, true] call BIS_fnc_addVirtualWeaponCargo;   
                };   
                   
                if (count _itemClasses > 0) then {   
                    [_crate, _itemClasses, true] call BIS_fnc_addVirtualItemCargo;   
                };   
                   
                if (count _backpackClasses > 0) then {   
                    [_crate, _backpackClasses, true] call BIS_fnc_addVirtualBackpackCargo;   
                };   
                   
                if (count _magazineClasses > 0) then {   
                    [_crate, _magazineClasses, true] call BIS_fnc_addVirtualMagazineCargo;   
                };   
                   
                ["Open", [false, _crate, _caller]] call BIS_fnc_arsenal;   
   
                waitUntil {isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull])};   
                sleep 0.5;   
   
                _playerItemsAfter = createHashMap;  
                {  
                    _playerItemsAfter set [_x, (_playerItemsAfter getOrDefault [_x, 0]) + 1];  
                } forEach (weapons _caller);  
                {  
                    _playerItemsAfter set [_x, (_playerItemsAfter getOrDefault [_x, 0]) + 1];  
                } forEach (items _caller);  
                {  
                    _playerItemsAfter set [_x, (_playerItemsAfter getOrDefault [_x, 0]) + 1];  
                } forEach (magazines _caller);  
                if (backpack _caller != "") then { _playerItemsAfter set [backpack _caller, (_playerItemsAfter getOrDefault [backpack _caller, 0]) + 1]; };  
                if (goggles _caller != "") then { _playerItemsAfter set [goggles _caller, (_playerItemsAfter getOrDefault [goggles _caller, 0]) + 1]; };  
                if (uniform _caller != "") then { _playerItemsAfter set [uniform _caller, (_playerItemsAfter getOrDefault [uniform _caller, 0]) + 1]; };  
                if (vest _caller != "") then { _playerItemsAfter set [vest _caller, (_playerItemsAfter getOrDefault [vest _caller, 0]) + 1]; };  
                if (headgear _caller != "") then { _playerItemsAfter set [headgear _caller, (_playerItemsAfter getOrDefault [headgear _caller, 0]) + 1]; };  
                {  
                    _playerItemsAfter set [_x, (_playerItemsAfter getOrDefault [_x, 0]) + 1];  
                } forEach (assignedItems _caller);  
  
   
                _illegalItems = [];   
                {   
                    _className = _x;   
                    _countAfter = _playerItemsAfter getOrDefault [_className, 0];   
                    _countAvailable = _allAvailableItems getOrDefault [_className, 0];   
                       
                    if (_countAfter > _countAvailable) then {   
                        _illegalCount = _countAfter - _countAvailable;   
                        for "_i" from 1 to _illegalCount do {   
                            _illegalItems pushBack _className;   
                        };   
                    };   
                } forEach (keys _playerItemsAfter);   
   
                if (count _illegalItems > 0) then {   
                    systemChat format["ANTI-CHEAT: Removed %1 illegal items!", count _illegalItems];   
                       
                    _backpackContainer = backpackContainer _caller;   
                    if (!isNull _backpackContainer) then {   
                        clearWeaponCargoGlobal _backpackContainer;   
                        clearMagazineCargoGlobal _backpackContainer;   
                        clearItemCargoGlobal _backpackContainer;   
                    };   
                       
                    {   
                        if (backpack _caller == _x) then {   
                            removeBackpack _caller;   
                        };   
                        if (goggles _caller == _x) then {   
                            removeGoggles _caller;   
                        };   
                        if (uniform _caller == _x) then {   
                            removeUniform _caller;   
                        };   
                        if (vest _caller == _x) then {   
                            removeVest _caller;   
                        };   
                        if (headgear _caller == _x) then {   
                            removeHeadgear _caller;   
                        };   
                        _caller removeWeapon _x;   
                        _caller removeItem _x;   
                        _caller removeMagazine _x;   
                        _caller unassignItem _x;   
                    } forEach _illegalItems;   
                };   
   
                _playerItemsAfter = createHashMap;   
                {   
                    _playerItemsAfter set [_x, (_playerItemsAfter getOrDefault [_x, 0]) + 1];   
                } forEach (weapons _caller);   
                {   
                    _playerItemsAfter set [_x, (_playerItemsAfter getOrDefault [_x, 0]) + 1];   
                } forEach (items _caller);   
                {   
                    _playerItemsAfter set [_x, (_playerItemsAfter getOrDefault [_x, 0]) + 1];   
                } forEach (magazines _caller);   
                if (backpack _caller != "") then { _playerItemsAfter set [backpack _caller, (_playerItemsAfter getOrDefault [backpack _caller, 0]) + 1]; };   
                if (goggles _caller != "") then { _playerItemsAfter set [goggles _caller, (_playerItemsAfter getOrDefault [goggles _caller, 0]) + 1]; };   
                if (uniform _caller != "") then { _playerItemsAfter set [uniform _caller, (_playerItemsAfter getOrDefault [uniform _caller, 0]) + 1]; };   
                if (vest _caller != "") then { _playerItemsAfter set [vest _caller, (_playerItemsAfter getOrDefault [vest _caller, 0]) + 1]; };   
                if (headgear _caller != "") then { _playerItemsAfter set [headgear _caller, (_playerItemsAfter getOrDefault [headgear _caller, 0]) + 1]; };   
                {   
                    _playerItemsAfter set [_x, (_playerItemsAfter getOrDefault [_x, 0]) + 1];   
                } forEach (assignedItems _caller);   
   
                _finalCrateData = [];   
                   
                {   
                    _className = _x;   
                    _countBeforePlayer = _playerItemsBefore getOrDefault [_className, 0];   
                    _countAfterPlayer = _playerItemsAfter getOrDefault [_className, 0];   
                    _countBeforeCrate = _crateItems getOrDefault [_className, 0];   
                       
                    _netChange = _countBeforePlayer - _countAfterPlayer;   
                    _finalCount = _countBeforeCrate + _netChange;   
                       
                    if (_finalCount > 0) then {   
                        _finalCrateData pushBack [_className, _finalCount];   
                    };   
                } forEach (keys _allAvailableItems);   
   
                missionProfileNamespace setVariable [format["personalCrateData_%1", _crate getVariable "owner"], _finalCrateData];   
                saveMissionProfileNamespace;   
   
                deleteVehicle _crate;   
                missionNamespace setVariable [format["personalCrate_%1", _crate getVariable "owner"], objNull, true];   
   
                systemChat format["DEBUG: Crate updated with %1 items", count _finalCrateData];   
                systemChat "Crate arsenal changes saved! Crate will be respawned on next access.";   
   
                if (!visibleMap && !dialog) then {   
                    openMap [false, false];   
                    openMap [false, false];   
                };   
   
                showHUD true;   
                enableEnvironment true;   
   
                if (EnableCustomHudMode > 0) then {   
                    [["BRSEMissionInfoUI", "PLAIN"]] remoteExec ["cutRsc"];   
                    remoteExec ["updateUI"];   
                };   
            };   
        } else {   
            systemChat "Only the crate owner can use this arsenal!";   
        };   
    },   
    nil,   
    1.5,   
    true,   
    true,   
    "",   
    "getPlayerUID _this == (_target getVariable 'owner')",   
    3   
];   
           
        _crate setVariable ["lockActionID", _lockID, true];   
        _crate setVariable ["unlockActionID", _unlockID, true];   
        _crate setVariable ["carryActionID", _carryID, true];   
        _crate setVariable ["dropActionID", _dropID, true];   
        _crate setVariable ["arsenalActionID", _arsenalID, true];   
    },   
    nil,   
    1.5,   
    true,   
    true,   
    "",   
    "isNull attachedTo _this",   
    3   
]; 
_box addAction [ 
    "Save loadout ($1000)", 
    { 
        params ["_target", "_caller"]; 
         
        _playerUID = getPlayerUID _caller; 
         
        private _bankMoney = missionProfileNamespace getVariable [_playerUID + "_bankMoney", 0];     
         
        if (_bankMoney < 1000) then { 
            systemChat "Not enough money in bank! You need $1000 to save your loadout."; 
        } else { 
            _newMoney = _bankMoney - 1000; 
            missionProfileNamespace setVariable [_playerUID + "_bankMoney", _newMoney]; 
            missionNamespace setVariable [format["%1_bankMoney", _playerUID], _newMoney, true]; 
             
            _weaponsArray = []; 
            _weaponsList = weapons _caller; 
            _weaponsItemsList = weaponsItems _caller; 
             
             
            { 
                _weaponClass = _x; 
                _weaponIndex = _forEachIndex; 
                _weaponInfo = _weaponsItemsList select _weaponIndex; 
                 
                 
                if (count _weaponInfo >= 7) then { 
                    _weaponsArray pushBack [_weaponClass, _weaponInfo]; 
                } else { 
                    _weaponsArray pushBack [_weaponClass, []]; 
                }; 
            } forEach _weaponsList; 
             
            _magazinesArray = []; 
            _magazinesFull = magazinesAmmoFull _caller; 
            { 
                if (_x isEqualType [] && {count _x >= 2}) then { 
                    _magazineClass = _x select 0; 
                    if (_magazineClass != "") then { 
                        _found = false; 
                        { 
                            if ((_x select 0) == _magazineClass) then { 
                                _x set [1, (_x select 1) + 1]; 
                                _found = true; 
                            }; 
                        } forEach _magazinesArray; 
                         
                        if (!_found) then { 
                            _magazinesArray pushBack [_magazineClass, 1]; 
                        }; 
                    }; 
                }; 
            } forEach _magazinesFull; 
             
            _allItemsArray = []; 
             
            if (uniform _caller != "") then { 
                { 
                    if (_x != "") then { 
                        _allItemsArray pushBack _x; 
                    }; 
                } forEach (uniformItems _caller); 
            }; 
             
            if (vest _caller != "") then { 
                { 
                    if (_x != "") then { 
                        _allItemsArray pushBack _x; 
                    }; 
                } forEach (vestItems _caller); 
            }; 
             
            if (backpack _caller != "") then { 
                { 
                    if (_x != "") then { 
                        _allItemsArray pushBack _x; 
                    }; 
                } forEach (backpackItems _caller); 
            }; 
             
            _itemsArray = []; 
            { 
                _itemClass = _x; 
                if (_itemClass != "") then { 
                    _found = false; 
                    { 
                        if ((_x select 0) == _itemClass) then { 
                            _x set [1, (_x select 1) + 1]; 
                            _found = true; 
                        }; 
                    } forEach _itemsArray; 
                     
                    if (!_found) then { 
                        _itemsArray pushBack [_itemClass, 1]; 
                    }; 
                }; 
            } forEach _allItemsArray; 
             
            _currentHeadgear = headgear _caller; 
            _currentGoggles = goggles _caller; 
            _currentUniform = uniform _caller; 
            _currentVest = vest _caller; 
            _currentBackpack = backpack _caller; 
             
            _currentAssignedItems = []; 
            { 
                if (_x != "") then { 
                    _currentAssignedItems pushBack _x; 
                }; 
            } forEach (assignedItems _caller); 
             
            _uniformContents = if (_currentUniform != "") then { uniformItems _caller } else { [] }; 
            _vestContents = if (_currentVest != "") then { vestItems _caller } else { [] }; 
            _backpackContents = if (_currentBackpack != "") then { backpackItems _caller } else { [] }; 
             
            _loadoutData = [ 
                weapons _caller, 
                _magazinesArray, 
                _itemsArray, 
                _currentAssignedItems, 
                _currentHeadgear, 
                _currentGoggles, 
                _currentUniform, 
                _currentVest, 
                _currentBackpack, 
                _uniformContents, 
                _vestContents, 
                _backpackContents, 
                _weaponsArray 
            ]; 
             
            missionProfileNamespace setVariable [format["personalLoadout_%1", _playerUID], _loadoutData]; 
            saveMissionProfileNamespace; 
             
            systemChat "Loadout secured successfully! Cost: $1000"; 
        }; 
    }, 
    nil, 
    1.5, 
    true, 
    true, 
    "", 
    "isNull attachedTo _this", 
    3 
]; 
 
_box addAction [ 
    "Load secured loadout", 
    { 
        params ["_target", "_caller"]; 
         
        _playerUID = getPlayerUID _caller; 
         
        private _loadoutData = missionProfileNamespace getVariable [format["personalLoadout_%1", _playerUID], []]; 
         
        if (count _loadoutData == 0) then { 
            systemChat "No saved loadout found! Save a loadout first."; 
        } else { 
            removeAllWeapons _caller; 
            removeAllItems _caller; 
            removeAllAssignedItems _caller; 
            removeHeadgear _caller; 
            removeGoggles _caller; 
            removeUniform _caller; 
            removeVest _caller; 
            removeBackpack _caller; 
             
            private _weapons = _loadoutData select 0; 
            private _magazines = _loadoutData select 1; 
            private _items = _loadoutData select 2;
            private _assignedItems = _loadoutData select 3; 
            private _headgear = _loadoutData select 4; 
            private _goggles = _loadoutData select 5; 
            private _uniform = _loadoutData select 6; 
            private _vest = _loadoutData select 7; 
            private _backpack = _loadoutData select 8; 
            private _uniformContents = if (count _loadoutData > 9) then { _loadoutData select 9 } else { [] }; 
            private _vestContents = if (count _loadoutData > 10) then { _loadoutData select 10 } else { [] }; 
            private _backpackContents = if (count _loadoutData > 11) then { _loadoutData select 11 } else { [] }; 
            private _weaponsWithAttachments = if (count _loadoutData > 12) then { _loadoutData select 12 } else { [] }; 
             
            if (_uniform != "") then { _caller forceAddUniform _uniform; }; 
            if (_vest != "") then { _caller addVest _vest; }; 
            if (_backpack != "") then { _caller addBackpack _backpack; }; 
            if (_headgear != "") then { _caller addHeadgear _headgear; }; 
            if (_goggles != "") then { _caller addGoggles _goggles; }; 
             
            sleep 0.1; 
             
            { if (_x != "") then { _caller addWeapon _x; }; } forEach _weapons; 
             
            sleep 0.1; 
             
            { 
                if (_x isEqualType [] && {count _x >= 2}) then { 
                    _magazineClass = _x select 0; 
                    _magazineCount = _x select 1; 
                    if (_magazineClass != "" && _magazineCount > 0) then { 
                        for "_i" from 1 to _magazineCount do { 
                            _caller addMagazine _magazineClass; 
                        }; 
                    }; 
                }; 
            } forEach _magazines; 
             
            sleep 0.1; 
             
            if (count _weaponsWithAttachments > 0) then { 
                { 
                    _weaponData = _x; 
                    if (_weaponData isEqualType [] && {count _weaponData >= 2}) then { 
                        _weaponClass = _weaponData select 0; 
                        _attachments = _weaponData select 1; 
                         
                        if (_weaponClass != "" && _attachments isEqualType [] && {count _attachments >= 7}) then { 
                            _silencer = _attachments select 1; 
                            _pointer = _attachments select 2; 
                            _optic = _attachments select 3; 
                            _bipod = _attachments select 6; 
                             
                            if (_weaponClass in weapons _caller) then { 
                                { 
                                    _attachment = _x; 
                                    if (_attachment isEqualType "" && _attachment != "") then { 
                                        if (_weaponClass == primaryWeapon _caller) then { 
                                            _caller addPrimaryWeaponItem _attachment; 
                                        } else { 
                                            if (_weaponClass == handgunWeapon _caller) then { 
                                                _caller addHandgunItem _attachment; 
                                            } else { 
                                                if (_weaponClass == secondaryWeapon _caller) then { 
                                                    _caller addSecondaryWeaponItem _attachment; 
                                                }; 
                                            }; 
                                        }; 
                                    }; 
                                } forEach [_silencer, _pointer, _optic]; 
                                 
                                _bipodClass = ""; 
                                if (_bipod isEqualType "") then { 
                                    if (_bipod != "") then { 
                                        _bipodClass = _bipod; 
                                    }; 
                                } else { 
                                    if (_bipod isEqualType [] && {count _bipod > 0}) then { 
                                        _bipodClass = _bipod select 0; 
                                    }; 
                                }; 
                                 
                                if (_bipodClass != "") then { 
                                    if (_weaponClass == primaryWeapon _caller) then { 
                                        _caller addPrimaryWeaponItem _bipodClass; 
                                    } else { 
                                        if (_weaponClass == secondaryWeapon _caller) then { 
                                            _caller addSecondaryWeaponItem _bipodClass; 
                                        }; 
                                    }; 
                                }; 
                            }; 
                        }; 
                    }; 
                } forEach _weaponsWithAttachments; 
            }; 
             
            sleep 0.1; 

        if (uniform _caller != "") then { 
                { if (_x != "") then { _caller addItemToUniform _x; }; } forEach _uniformContents; 
            }; 
             
            if (vest _caller != "") then { 
                { if (_x != "") then { _caller addItemToVest _x; }; } forEach _vestContents; 
            }; 
             
            if (backpack _caller != "") then { 
                { if (_x != "") then { _caller addItemToBackpack _x; }; } forEach _backpackContents; 
            }; 

            sleep 0.1; 
             
            { 
                if (_x isEqualType "" && _x != "") then { 
                    _caller unassignItem _x; 
                    if !(_x in (items _caller + assignedItems _caller)) then { 
                        _caller addItem _x; 
                    }; 
                    _caller assignItem _x; 
                }; 
            } forEach _assignedItems; 
             
            if (primaryWeapon _caller != "") then { 
                _caller selectWeapon primaryWeapon _caller; 
            }; 
             
            systemChat "Loadout loaded!"; 
        }; 
    }, 
    nil, 
    1.5, 
    true, 
    true, 
    "", 
    "isNull attachedTo _this", 
    3 
];
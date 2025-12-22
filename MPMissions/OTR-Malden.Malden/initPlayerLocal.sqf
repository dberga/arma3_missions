private _playerUID = getPlayerUID player;
KillsCounter = missionProfileNamespace getVariable [_playerUID + "_KillsCounter", 0];
PlayerRating = missionProfileNamespace getVariable [_playerUID + "_rating", 0];

addKillCounter  = {
private _playerUID = getPlayerUID player;
KillsCounter = missionProfileNamespace getVariable [_playerUID + "_KillsCounter", 0];
KillsCounter= KillsCounter +1;
missionProfileNamespace setVariable [_playerUID + "_KillsCounter", KillsCounter];
saveMissionProfileNamespace;
remoteExec ["updateUI"];     
call updateUI;
};

updateUI = {
if (EnableCustomHudMode>0) then {
disableSerialization;
try{
_display = uiNamespace getVariable "hudScrDisplay";
_textPlayersAlive = _display displayCtrl 1905;
_textPlayersAlive ctrlSetText format["%1",MyPlayersCount];

_textCivilians = _display displayCtrl 1908;
_textCivilians ctrlSetText format["%1",CivilianEnemyCount];

_textHP = _display displayCtrl 1902;
_playerDmg = (damage player)*100;
_playerDmg = floor (100 - _playerDmg);
_textHP ctrlSetText format["HP: %1/100",_playerDmg];	

_textBlack = _display displayCtrl 1900;
_WidthAr = ctrlPosition _textBlack;
_Width = _WidthAr select 2;

_textHPRed = _display displayCtrl 1901;
_textHPRedpos = ctrlPosition _textHPRed;
_textHPRedposX= _textHPRedpos select 0;
_textHPRedposY= _textHPRedpos select 1;
_textHPRedWidth = _textHPRedpos select 2;
_textHPRedHeight = _textHPRedpos select 3;
_textHPRedWidth = (_Width/100) * _playerDmg;
_textHPRed ctrlSetPosition [_textHPRedposX,_textHPRedposY,_textHPRedWidth,_textHPRedHeight];
_textHPRed ctrlCommit 0;

_playerUID = getPlayerUID player;   
KillsCounter = missionProfileNamespace getVariable [_playerUID + "_KillsCounter", 0];
_textKillsCounter = _display displayCtrl 1911;
_textKillsCounter ctrlSetText format["%1",KillsCounter];

_PlayerRating = missionProfileNamespace getVariable [_playerUID + "_rating", 0];
_textRating = _display displayCtrl 1914;
_textRating ctrlSetText format["%1",_PlayerRating];
       
_bankMoney = missionProfileNamespace getVariable [_playerUID + "_bankMoney", 0];
_textMoney = _display displayCtrl 1917;
_textMoney ctrlSetText format["%1",_bankMoney];
     
_cashMoney = missionProfileNamespace getVariable [_playerUID + "_cashMoney", 0]; 
_textCash = _display displayCtrl 1920;
_textCash ctrlSetText format["%1",_cashMoney];

}

catch{};
};
};

[] spawn {
    waitUntil {!isNull player && alive player};
    sleep 2;
    
    private _playerUID = getPlayerUID player;
    private _squadData = missionProfileNamespace getVariable [_playerUID + "_squadData", []];
    
    if (count _squadData > 0) then {
        private _playerSide = side group player;
        private _spawnedCount = 0;
        
        {
            private _spawnPos = (getPos player) findEmptyPosition [5, 15, _x];
            if (count _spawnPos > 0) then {
                private _group = createGroup [_playerSide, true];
                private _unit = _group createUnit [_x, _spawnPos, [], 0, "NONE"];
                [_unit] join (group player);
                _unit setSkill 0.5;
                _unit setBehaviour "AWARE";
                _unit setCombatMode "GREEN";
                
                _unit addEventHandler ["Killed", {
                    params ["_unit"];
                    private _player = leader group _unit;
                    if (!isNull _player) then {
                        [_player] remoteExec ["fnc_saveSquadData", 2];
                    };
                }];
                
                _spawnedCount = _spawnedCount + 1;
            };
        } forEach _squadData;
        
        [format ["<t size='0.7' color='#00ff00'>%1 squad members rejoined you!</t>", _spawnedCount], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];
    };
	if ((assignedItems player) find "ItemMap" == -1) then {
		player addItem "ItemMap";
		player assignItem "ItemMap";
	};
};

[] spawn {
    waitUntil {!isNull player && alive player};
    sleep 0.5;
    
    private _playerUID = getPlayerUID player;
    private _loadoutData = missionProfileNamespace getVariable [format["personalLoadout_%1", _playerUID], []];
    
    if (count _loadoutData > 0) then {
        private _currentPos = getPos player;
        private _currentVehicle = vehicle player;
        private _isInVehicle = (_currentVehicle != player);
        
        removeAllWeapons player;
        removeAllItems player;
        removeAllAssignedItems player;
        removeHeadgear player;
        removeGoggles player;
        removeUniform player;
        removeVest player;
        removeBackpack player;
        
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
        
        if (_uniform != "") then { 
            player forceAddUniform _uniform; 
        };
        
        if (_vest != "") then { 
            player addVest _vest; 
        };
        
        if (_backpack != "") then { 
            player addBackpack _backpack; 
        };
        
        if (_headgear != "") then { 
            player addHeadgear _headgear; 
        };
        
        if (_goggles != "") then { 
            player addGoggles _goggles; 
        };
        
        sleep 0.1;
        
        { 
            if (_x != "") then {
                player addWeapon _x; 
            };
        } forEach _weapons;
        
        sleep 0.1;
        
        {
            if (_x isEqualType [] && {count _x >= 2}) then {
                _magazineClass = _x select 0;
                _magazineCount = _x select 1;
                
                if (_magazineClass != "" && _magazineCount > 0) then {
                    for "_i" from 1 to _magazineCount do {
                        player addMagazine _magazineClass;
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
                        _silencer = _attachments select 1;  // Index 1 is silencer
                        _pointer = _attachments select 2;   // Index 2 is pointer
                        _optic = _attachments select 3;     // Index 3 is optic
                        _bipod = _attachments select 6;     // Index 6 is bipod
                        
                        
                        // Check if weapon exists on player
                        if (_weaponClass in weapons player) then {
                            {
                                _attachment = _x;
                                if (_attachment isEqualType "" && _attachment != "") then {
                                    
                                    if (_weaponClass == primaryWeapon player) then {
                                        player addPrimaryWeaponItem _attachment;
                                    } else {
                                        if (_weaponClass == handgunWeapon player) then {
                                            player addHandgunItem _attachment;
                                        } else {
                                            if (_weaponClass == secondaryWeapon player) then {
                                                player addSecondaryWeaponItem _attachment;
                                            };
                                        };
                                    };
                                };
                            } forEach [_silencer, _pointer, _optic];
                            
                            // Handle bipod
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
                                if (_weaponClass == primaryWeapon player) then {
                                    player addPrimaryWeaponItem _bipodClass;
                                } else {
                                    if (_weaponClass == secondaryWeapon player) then {
                                        player addSecondaryWeaponItem _bipodClass;
                                    };
                                };
                            };
                        };
                    };
                };
            } forEach _weaponsWithAttachments;
        };
        
        sleep 0.1;
        
        if (uniform player != "") then {
            {
                if (_x != "") then {
                    player addItemToUniform _x;
                };
            } forEach _uniformContents;
        };
        
        if (vest player != "") then {
            {
                if (_x != "") then {
                    player addItemToVest _x;
                };
            } forEach _vestContents;
        };
        
        if (backpack player != "") then {
            {
                if (_x != "") then {
                    player addItemToBackpack _x;
                };
            } forEach _backpackContents;
        };
        
        sleep 0.1;
        
        {
            if (_x isEqualType "" && _x != "") then {
                player unassignItem _x;
                if !(_x in (items player + assignedItems player)) then {
                    player addItem _x;
                };
                player assignItem _x;
            };
        } forEach _assignedItems;
        
        if (primaryWeapon player != "") then {
            player selectWeapon primaryWeapon player;
        };
        
        if (_isInVehicle && alive _currentVehicle) then {
            player moveInAny _currentVehicle;
        } else {
            player setPos _currentPos;
        };
        
        systemChat "Secure loadout loaded successfully!";
    } else {
        systemChat "No secure loadout found. Using default equipment.";
    };
	if ((assignedItems player) find "ItemMap" == -1) then {
		player addItem "ItemMap";
		player assignItem "ItemMap";
	};
};

moneyChangeHandler = {
    [] spawn {
        private _lastCash = missionProfileNamespace getVariable [getPlayerUID player + "_cashMoney", 0];
        private _lastBank = missionProfileNamespace getVariable [getPlayerUID player + "_bankMoney", 0];
        
        waitUntil {
            private _playerUID = getPlayerUID player;
            private _currentCash = missionProfileNamespace getVariable [_playerUID + "_cashMoney", 0];
            private _currentBank = missionProfileNamespace getVariable [_playerUID + "_bankMoney", 0];
            
            if (_currentCash != _lastCash || _currentBank != _lastBank) then {
                _lastCash = _currentCash;
                _lastBank = _currentBank;
                call updateUI;
            };
            
            sleep 1;
            false
        };
    };
};

//call moneyChangeHandler;


 // spawnRandomSquad.sqf
// Simplified version using default faction units

params [
	"_centerPos",
    "_taskType", // "PATROL" or "ATTACK"
    "_target", // For ATTACK: player or position
    "_radius", // For PATROL: patrol radius
    "_factionSide" // "blufor", "opfor", "independent", "resistance"
];

playMusic "LeadTrack04a_F";
private _spawnText = format ["<t size='1.0' color='#C50074'> A %1 squad is roaming around </t>", _factionSide];   
[_spawnText, 0, 0.4, 5, 1] remoteExec ["BIS_fnc_dynamicText", player]; 


// Determine side
private _side = switch (_factionSide) do {
    case "usec": { west };
    case "bear": { east };
    case "rogue": { independent };
    case "scav": { resistance };
    default { resistance };
};

// Choose faction classnames based on side
private _unitClasses = [];
switch (_factionSide) do {
    case "usec": {
        _unitClasses = [
            "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", // Riflemen
            "B_Soldier_GL_F", // Grenadier
            "B_soldier_AR_F", // Autorifleman
            "B_soldier_M_F", // Marksman
            "B_medic_F", // Medic
            "B_Soldier_TL_F", "B_Soldier_SL_F" // Team leaders
        ];
    };
    case "bear": {
        _unitClasses = [
            "O_Soldier_F", "O_Soldier_F", "O_Soldier_F",
            "O_Soldier_GL_F",
            "O_Soldier_AR_F",
            "O_soldier_M_F",
            "O_medic_F",
            "O_Soldier_TL_F", "O_Soldier_SL_F"
        ];
    };
    case "rogue": {
        _unitClasses = [
            "I_Soldier_F", "I_Soldier_F", "I_Soldier_F",
            "I_Soldier_GL_F",
            "I_Soldier_AR_F",
            "I_Soldier_M_F",
            "I_medic_F",
            "I_Soldier_TL_F", "I_Soldier_SL_F"
        ];
    };
	case "scav": {
        _unitClasses = [
            "I_G_Soldier_F", "I_G_Soldier_F", "I_G_Soldier_F",
            "I_G_Soldier_GL_F",
            "I_G_Soldier_AR_F",
            "I_G_Soldier_M_F",
            "I_G_medic_F",
            "I_G_Soldier_TL_F", "I_G_Soldier_SL_F"
        ];
    };
	default {
		_unitClasses = [
            "I_G_Soldier_F", "I_G_Soldier_F", "I_G_Soldier_F",
            "I_G_Soldier_GL_F",
            "I_G_Soldier_AR_F",
            "I_G_Soldier_M_F",
            "I_G_medic_F",
            "I_G_Soldier_TL_F", "I_G_Soldier_SL_F"
        ];
	};
};


// Random squad size (3-6 units)
private _squadSize = 2;
switch (_side) do {
    case west: {_squadSize = _squadSize  + floor(random 5)};
    case east: {_squadSize = _squadSize  + floor(random 5)};
    case independent: {_squadSize = _squadSize  + floor(random 2)};
	case resistance: {_squadSize = _squadSize  + floor(random 2)};
	default {_squadSize = _squadSize  + floor(random 2)};
};

private _selectedClasses = [];
for "_i" from 1 to _squadSize do {
    _selectedClasses pushBack (selectRandom _unitClasses);
};

// Find safe spawn position
private _spawnPos = [_centerPos, 1, _radius, 3, 0, 0.5, 0] call BIS_fnc_findSafePos;




// Create group and units
private _group = createGroup _side;

{
    _group createUnit [_x, _spawnPos, [], 0, "NONE"];
} forEach _selectedClasses;

// Set group behavior
_group setBehaviour "AWARE";
_group setCombatMode "RED";
_group allowFleeing 0.3;

// Assign task based on type
switch (_taskType) do {
    case "PATROL": {
        [_group, _centerPos, _radius] call BIS_fnc_taskPatrol;
    };
    case "ATTACK": {
        if (_target isEqualTo objNull) then {
            [_group, player] call BIS_fnc_taskAttack;
        } else {
            [_group, _target] call BIS_fnc_taskAttack;
        };
    };
};

//systemChat format ["TEST: Generated spawn worked! Group: %1", _group];

// Cleanup when all units are dead
[_group] spawn {
    params ["_group"];
    waitUntil {sleep 60; {alive _x} count units _group == 0};
    deleteGroup _group;
};




params ["_site"];

private _pos = getPos _site;

private _safezoneProp = "Flag_UNO_F" createVehicle _pos;
_safezoneProp setPos _pos;

private _marker = createMarker [format ["safeZoneArea_%1", random 10000], _pos];
_marker setMarkerShape "ELLIPSE";
_marker setMarkerSize [250, 250];
_marker setMarkerColor "ColorBlue";
_marker setMarkerAlpha 0.25;
_marker setMarkerBrush "DiagGrid";

private _textMarker = createMarker [format ["safeZoneLabel_%1", random 10000], _pos];
_textMarker setMarkerType "mil_warning";
_textMarker setMarkerColor "ColorBlue";
_textMarker setMarkerText "SAFE ZONE";
_textMarker setMarkerAlpha 0.7;

private _playerTrigger = createTrigger ["EmptyDetector", _pos];
_playerTrigger setTriggerArea [250, 250, 0, false];
_playerTrigger setTriggerActivation ["ANYPLAYER", "PRESENT", true];
_playerTrigger setTriggerStatements [
    "this && player in thisList",
    "inZoneH = [] execVM 'inSafeZone.sqf';",
    "null = [] execVM 'leftSafeZone.sqf';"
];

private _aiTrigger = createTrigger ["EmptyDetector", _pos];
_aiTrigger setTriggerArea [250, 250, 0, false];
_aiTrigger setTriggerActivation ["ANYPLAYER", "PRESENT", true];
_aiTrigger setTriggerStatements [
    "this",
    "{ if (!isPlayer _x) then { _x disableAI 'TARGET'; _x disableAI 'AUTOTARGET'; _x disableAI 'WEAPONAIM'; _x setBehaviour 'CARELESS'; _x setCombatMode 'BLUE'; _x setVariable ['safezoneDisabledAI', true]; }; } forEach thisList;",
    "{ if (!isPlayer _x && {_x getVariable ['safezoneDisabledAI', false]}) then { _x enableAI 'TARGET'; _x enableAI 'AUTOTARGET'; _x enableAI 'WEAPONAIM'; _x setBehaviour 'AWARE'; _x setCombatMode 'YELLOW'; _x setVariable ['safezoneDisabledAI', false]; }; } forEach thisList;"
];


_site setVariable ["safeZoneObjects", [_safezoneProp, _playerTrigger, _aiTrigger, _marker, _textMarker], true];
private "_time";
disableSerialization;
_time = _this select 0;
_roundTimeStr = [((_time)/60)+.01,"HH:MM"] call BIS_fnc_timetostring;
missionNamespace setVariable ["roundTimeStr", _roundTimeStr];
while {_time > 0} do {
_time = _time - 1;  
_roundTimeStr = [((_time)/60)+.01,"HH:MM"] call BIS_fnc_timetostring;
missionNamespace setVariable ["roundTimeStr", _roundTimeStr];
//hintSilent format["Round Time Remaining: \n %1", [((_time)/60)+.01,"HH:MM"] call BIS_fnc_timetostring];	
//systemChat format["Round Time Remaining: %1", roundTimeStr];	
//disableSerialization;
_display = findDisplay 2055;
_textRoundTime = _display displayCtrl 1013;
_textRoundTime ctrlSetText format ["%1", [((_time)/60)+.01,"HH:MM"] call BIS_fnc_timetostring];

_display = uiNamespace getVariable "hudScrDisplay";
_textRoundTime = _display displayCtrl 1913;
_textRoundTime ctrlSetText format ["%1", [((_time)/60)+.01,"HH:MM"] call BIS_fnc_timetostring];

sleep 1;
};

disableSerialization;
_display = findDisplay 2055;

_textPlayersAlive = _display displayCtrl 1000;
_textPlayersAlive ctrlSetText format["       %1 Alive",MyPlayersCount];

_textHP = _display displayCtrl 1001;
playerDmg = damage player*100;
playerDmg = floor (100 - playerDmg);
_textHP ctrlSetText format["       HP: %1",playerDmg];


_textRound = _display displayCtrl 1011;
_textRound ctrlSetText format["%1",roundCounter];

_textRoundTime = _display displayCtrl 1013;
_roundTimeStr = missionNameSpace getVariable ["roundTimeStr",0];
_textRoundTime ctrlSetText format ["%1", _roundTimeStr];
//_currentTime = triggerTimeoutCurrent (TriggersArray select roundCounter);
//_currentTimeMMSS = [_time-floor(_currentTime)+1, "HH:MM"] call BIS_fnc_secondsToString;
//_textRoundTime ctrlSetText format ["%1", _currentTimeMMSS];
//_currentTimeMMSS = [floor(_currentTime)+1-((_time)/60)+.01, "HH:MM"] call BIS_fnc_timetostring;
//_textRoundTime ctrlSetText format ["%1", _currentTimeMMSS];
  
//_display ctrlCreate ["Round", 1010];
//_display ctrlCreate ["Remaining", 1011];

KillsCounter =0;

addKillCounter  = {
KillsCounter= KillsCounter +1;
call updateUI;
};

updateUI = {
if (EnableCustomHudMode>0) then {
disableSerialization;
try{
_display = uiNamespace getVariable "hudScrDisplay";
_textPlayersAlive = _display displayCtrl 1905;
_textPlayersAlive ctrlSetText format["%1",MyPlayersCount];
//[_textPlayersAlive,"format['%1',MyPlayersCount]" ] remoteExec["ctrlSetText"];

_textKillsCounter = _display displayCtrl 1908;
_textKillsCounter ctrlSetText format["%1",KillsCounter];

_textHP = _display displayCtrl 1902;
_playerDmg = (damage player)*100;
_playerDmg = floor (100 - _playerDmg);
_textHP ctrlSetText format["HP: %1/100",_playerDmg];	

_textRound = _display displayCtrl 1911;
_textRound ctrlSetText format["%1",roundCounter];

//_textRoundTime = _display displayCtrl 1913;
//_roundTimeStr = missionNameSpace getVariable ["roundTimeStr",0];
//_textRoundTime ctrlSetText format ["%1", _roundTimeStr];
//_currentTime = triggerTimeoutCurrent (TriggersArray select roundCounter);
//_currentTimeMMSS = [floor(_currentTime)+1, "HH:MM"] call BIS_fnc_secondsToString;
//_textRoundTime ctrlSetText format ["%1", _currentTimeMMSS];
//_remainingTime = floor(triggerTimeoutCurrent (TriggersArray select roundCounter))+1; 
//_remainingTimeMMSS = [floor(_remainingTime)+1, "HH:MM"] call BIS_fnc_secondsToString;
//_textRoundTime ctrlSetText format ["%1", _remainingTimeMMSS];


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
}

catch{};
};
};
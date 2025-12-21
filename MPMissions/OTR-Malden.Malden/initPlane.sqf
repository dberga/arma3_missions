params ["_plane"];
_plane allowDamage false; 
_plane setCaptive true; 
private _driver = driver _plane;
if (!isNull _driver) then {
    _driver allowDamage false;
    //_driver setCaptive true;
};

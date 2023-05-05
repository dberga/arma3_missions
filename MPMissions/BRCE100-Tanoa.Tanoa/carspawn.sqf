_carPosition = _this select 0;
//_markerName = "Marker_MyCarSpawnTrigger_"+str (floor random (1000));
//createMarker [_markerName, _carPosition];
//_markerName setMarkerType "hd_arrow";
//_markerName setMarkerColor "ColorRed";
//_markerName setMarkerText "car";
//_markerName setMarkerAlpha 1; 
_cars = ["O_Quadbike_01_F","C_Quadbike_01_F","B_Quadbike_01_F","I_Quadbike_01_F","B_GEN_Offroad_01_gen_F","B_GEN_Offroad_01_gen_F","C_SUV_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F"];
_trucks = ["C_Truck_02_box_F", "C_Van_01_transport_F", "C_Van_01_box_F", "C_Van_01_fuel_F", "I_Truck_02_MRL_F"];
_karts = ["C_Kart_01_F", "C_Kart_01_Fuel_F", "C_Kart_01_Blu_F", "C_Kart_01_Red_F", "C_Kart_01_Vrana_F"];
_mraps = ["I_G_Offroad_01_armed_F", "I_G_Offroad_01_AT_F", "I_MRAP_03_F", "I_MRAP_03_gmg_F", "I_LT_01_AT_F", "I_LT_01_scout_F", "I_LT_01_AA_F", "I_LT_01_cannon_F" ]; //  "I_UGV_01_rcws_F"
_tanks = ["I_APC_tracked_03_cannon_F", "B_APC_Tracked_01_AA_F","B_MBT_01_arty_F", "B_MBT_01_cannon_F","B_MBT_01_mlrs_F" ,"I_MBT_03_cannon_F", "I_APC_Wheeled_03_cannon_F"];
_helis = ["I_Heli_Transport_02_F", "I_Heli_light_03_F", "I_Heli_light_03_dynamicLoadout_F", "I_Heli_light_03_unarmed_F", "I_C_Heli_Light_01_civil_F"];
_vehicles = _cars + _trucks + _karts + _mraps + _tanks + _helis;
_nvehicles = count(_vehicles);
_randomCar = floor random (_nvehicles);
if (isServer) then {
//if (_randomCar < _nvehicles) then {
_mycar = _vehicles select _randomCar;
_carpos = position _carPosition;
//_zcarpos = _carpos select 2;
//_carpos set [2,_zcarpos+0.5];
_car_safepos = [_carpos, 0, 30, 5, 0, 20, 0] call BIS_fnc_findSafePos;
_carpos = _car_safepos;
_createdCar = createVehicle [_mycar,_carpos, [], 0, "NONE"];
clearweaponcargo _createdCar;
clearmagazinecargo _createdCar;
clearItemCargo _createdCar;
clearBackpackCargo _createdCar;
//};
};
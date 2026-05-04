forward OnVehUpdate(playerid, vehicleid);

new Timer:onvehicle_timer[MAX_PLAYERS] = {Timer:-1, ...};

timer OnVehUpdate[100](playerid, vehicleid) 
{
	static keys, updown, leftright;
	GetPlayerKeys(playerid, keys, updown, leftright);

	if(updown && IsABike(vehicleid) && GetVehicleSpeed(vehicleid) > 70) {
		SetVehicleSpeed(vehicleid, GetVehicleSpeed(vehicleid)-10);
	}

	CallLocalFunction("OnVehUpdate", "dd", playerid, vehicleid);
	return 1;
}

#include <YSI\y_hooks>
hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) != INVALID_VEHICLE_ID)
	{
		static vehicleid;

		vehicleid = GetPlayerVehicleID(playerid);
		onvehicle_timer[playerid] = repeat OnVehUpdate(playerid, vehicleid);
	}
	else if(oldstate == PLAYER_STATE_DRIVER) {
		stop onvehicle_timer[playerid];
		onvehicle_timer[playerid] = Timer:-1;
	}
	return 1;
}


hook OnPlayerDisconnectEx(playerid)
{
	if(onvehicle_timer[playerid] != Timer:-1) {
		stop onvehicle_timer[playerid];
		onvehicle_timer[playerid] = Timer:-1;
	}
	return 1;
}

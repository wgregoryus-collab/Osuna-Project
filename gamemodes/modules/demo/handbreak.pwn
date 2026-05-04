/*	Vehicle hand break module */
#define IsVehicleHandBrake(%0)	vehicle_handbreak[%0]

new
	bool:vehicle_handbreak[MAX_VEHICLES] = {false, ...};

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	if(vehicle_handbreak[vehicleid])
	{
		static
			Float:x,
			Float:y,
			Float:z
		;
		GetVehiclePos(vehicleid, x, y, z);
		SetVehiclePos(vehicleid, x, y, z);
	}
	return 1;
}

// hook OnVehicleDeath(vehicleid, killerid)
// {
// 	if(vehicle_handbreak[vehicleid]) {
// 		vehicle_handbreak[vehicleid] = false;	
// 	}
// }

// OnVehicleDestroyed(vehicleid)
// {
// 	if(vehicle_handbreak[vehicleid]) {
// 		vehicle_handbreak[vehicleid] = false;	
// 	}
// }

CMD:handbrake(playerid, params[])
{
	new
        id = -1,
		vehicleid = GetPlayerVehicleID(playerid);

	if(IsABike(GetPlayerVehicleID(playerid)))
		return SendErrorMessage(playerid, "Tidak bisa digunakan pada kendaraan ini.");

	if(!IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) != PLAYER_STATE_DRIVER) 
		return SendErrorMessage(playerid, "Kamu sedang tidak berada dalam kendaraan sebagai driver.");
		
    if((id = Vehicle_GetID(vehicleid)) != -1)
    {
        if(Vehicle_IsOwner(playerid, id) || (PlayerData[playerid][pFaction] != -1 && VehicleData[id][cFaction] == GetFactionSQLID(playerid)) || (PlayerData[playerid][pJob] != 0 && VehicleData[id][cJob] == PlayerData[playerid][pJob]) || (VehicleData[id][cRentOwned] == PlayerData[playerid][pID]))
        {
			vehicle_handbreak[VehicleData[id][cVehicle]] = (vehicle_handbreak[VehicleData[id][cVehicle]]) ? (false) : (true);
			SendServerMessage(playerid, "Rem tangan kendaraan telah %s", vehicle_handbreak[VehicleData[id][cVehicle]] ? (""GREEN"diaktifkan") : (""RED"dinonaktifkan"));
			return 1;
        }
        return SendErrorMessage(playerid, "Kamu tidak dapat melakukan ini pada kendaraan yang kamu naiki.");
    }
	return 1;
}

#include <YSI\y_hooks>

new bool:IsSpeeding[MAX_PLAYERS],
	Float:pSpeed[MAX_PLAYERS];

timer StopCameraEffect[30000](playerid) {
    SetPlayerDrunkLevel(playerid, 0);
    IsSpeeding[playerid] = false;
    return 1;
}

timer Speeding[500](playerid, vehicleid)
{
	new Float:nvx, Float:nvy, Float:nvz, Float:crashhealth = ReturnHealth2(playerid);
	if(IsPlayerInAnyVehicle(playerid) && IsSpeeding[playerid] && Seatbelt{playerid} != 1)
	{
		GetVehicleVelocity(vehicleid, nvx, nvy, nvz);
		// GetVehicleHealth(GetPlayerVehicleID(playerid), health);
		if(nvx > -0.1 && nvx < 0.1 && nvy > -0.1 && nvy < 0.1) {
			if(PlayerData[playerid][pMigrainRate] < 1) {
				PlayerData[playerid][pMigrainRate]++;
			}
            crashhealth -= (pSpeed[playerid] * 100.0);
            SetPlayerHealth(playerid, crashhealth);
            SetPlayerDrunkLevel(playerid, 50000);
            defer StopCameraEffect(playerid);
		}
	}
	return 1;
}

hook OnVehUpdate(playerid, vehicleid)
{
	new Float:ovx, Float:ovy, Float:ovz;
	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehicleVelocity(vehicleid, ovx, ovy, ovz);
		if(ovx < -0.4 || ovx > 0.4 || ovy < -0.4 || ovy > 0.4 && !IsSpeeding[playerid])
		{
			defer Speeding(playerid, vehicleid);
			ovx = (ovx >= 0) ? ovx : -ovx;
			ovy = (ovy >= 0) ? ovy : -ovy;
			pSpeed[playerid] = ((ovx+ovy)/2);
			IsSpeeding[playerid] = true;
		}
		else
		{
			pSpeed[playerid] = 0.0;
			IsSpeeding[playerid] = false;
		}
	}
	return 1;
}

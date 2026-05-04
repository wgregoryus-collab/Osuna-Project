#include <YSI\y_hooks>


hook OnGameModeInitEx()
{
	mysql_tquery(g_iHandle, "SELECT * FROM `underground` ORDER BY `id` ASC LIMIT "#MAX_DYNAMIC_UNDERGROUND"", "Underground_Load", "");
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_CROUCH && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		static index;
		if((index = Underground_Nearest(playerid)) != -1 && IsPlayerInDynamicCP(playerid, UndergroundData[index][enterCP]))
		{
			if(UndergroundData[index][underExitSpawn][0] == 0.0)
				return SendErrorMessage(playerid, "Basement ini belum dapat digunakan, silahkan kontak admin dengan perintah '/atalk'");

            if (UndergroundData[index][underFaction] != -1 && PlayerData[playerid][pFaction] != UndergroundData[index][underFaction]) 
                return SendErrorMessage(playerid, "You don't have any permission to entering this Basement.");

			SetCameraBehindPlayer(playerid);
			SetVehiclePos(GetPlayerVehicleID(playerid), UndergroundData[index][underEnter][0],UndergroundData[index][underEnter][1], UndergroundData[index][underEnter][2]);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 270.7731);

			SetPlayerVirtualWorld(playerid, UndergroundData[index][enterVW]);
    		SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), UndergroundData[index][enterInt]);

    		foreach(new i : Player) if(IsPlayerInVehicle(i, GetPlayerVehicleID(playerid)) && GetPlayerState(i) != PLAYER_STATE_DRIVER)
    		{
		        SetPlayerVirtualWorld(i, UndergroundData[index][enterVW]);
		        SetCameraBehindPlayer(i);
		    }
		}
		else
		{
			//index = (GetPlayerVirtualWorld(playerid) - 2);
			index = Underground_Nearest(playerid);
			if(IsPlayerInDynamicCP(playerid, UndergroundData[index][exitCP]) && IsPlayerInRangeOfPoint(playerid, 3.0, -1745.4021,987.9285,17.6099))
			{
				SetCameraBehindPlayer(playerid);

				SetVehiclePos(GetPlayerVehicleID(playerid), UndergroundData[index][underExitSpawn][0], UndergroundData[index][underExitSpawn][1], UndergroundData[index][underExitSpawn][2]);
				SetVehicleZAngle(GetPlayerVehicleID(playerid), UndergroundData[index][underExitSpawn][3]);

				SetPlayerVirtualWorld(playerid, UndergroundData[index][exitVW]);
	    		SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), UndergroundData[index][exitInt]);

	    		foreach(new i : Player) if(IsPlayerInVehicle(i, GetPlayerVehicleID(playerid)) && GetPlayerState(i) != PLAYER_STATE_DRIVER)
	    		{
			        SetPlayerVirtualWorld(i, UndergroundData[index][exitVW]);
			        SetCameraBehindPlayer(i);
			    }
			}
		}
	}

	if(newkeys & KEY_CTRL_BACK && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		static index;
		if((index = Underground_Nearest(playerid)) != -1 && IsPlayerInDynamicCP(playerid, UndergroundData[index][enterCP]))
		{
			if(UndergroundData[index][underExitSpawn][0] == 0.0)
				return SendErrorMessage(playerid, "Basement ini belum dapat digunakan, silahkan kontak admin dengan perintah '/atalk'");

            if (UndergroundData[index][underFaction] != -1 && PlayerData[playerid][pFaction] != UndergroundData[index][underFaction]) 
                return SendErrorMessage(playerid, "You don't have any permission to entering this Basement.");

			SetCameraBehindPlayer(playerid);
			SetPlayerInterior(playerid, UndergroundData[index][enterInt]);
            SetPlayerVirtualWorld(playerid, UndergroundData[index][enterVW]);

			SetPlayerPos(playerid, UndergroundData[index][underEnter][0], UndergroundData[index][underEnter][1], UndergroundData[index][underEnter][2]);
			SetPlayerFacingAngle(playerid, 270.7731);
		}
		else
		{
			//index = (GetPlayerVirtualWorld(playerid) -2) < 0 ? 0 : (GetPlayerVirtualWorld(playerid) -2);
			index = Underground_NearestExit(playerid);
			if(index>=0)
			{
				if(IsPlayerInDynamicCP(playerid, UndergroundData[index][exitCP]) && IsPlayerInRangeOfPoint(playerid, 3.0, -1745.4021,987.9285,17.6099))
				{
					SetCameraBehindPlayer(playerid);
					SetPlayerVirtualWorld(playerid, UndergroundData[index][exitVW]);
                    SetPlayerInterior(playerid, UndergroundData[index][exitInt]);

					SetPlayerPos(playerid, UndergroundData[index][underExitSpawn][0], UndergroundData[index][underExitSpawn][1], UndergroundData[index][underExitSpawn][2]);
					SetPlayerFacingAngle(playerid, UndergroundData[index][underExitSpawn][3]);
				}		
			}	
		}
	}
	return 1;
}
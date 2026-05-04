//defined
#define MAX_SWEEPER_VEHICLE		3
#define SWEEPER_SALARY			8000


// global variable
static
	sweeperVehicle[MAX_SWEEPER_VEHICLE] = {INVALID_VEHICLE_ID, ...};
	
new bool:DialogSSidejob[MAX_SWEEPER_VEHICLE];
new PlayerSSidejob[MAX_PLAYERS];

// player variable
static
	bool:hasSweeper[MAX_PLAYERS] = {false, ...},
	sweeperRoute[MAX_PLAYERS] = {0, ...},
	currentSRoute[MAX_PLAYERS] = {0, ...},
	sweOut[MAX_PLAYERS] = {0, ...},
	outCheckswe[MAX_PLAYERS],
	Timer:outTimerswe[MAX_PLAYERS],
	Timer:outTimeswe[MAX_PLAYERS];

// vehicle arrays
/*stock const Float:arr_sweeperPosition[][] =
{
	{1393.069, -1554.634, 13.422, 76.4216},
	{1392.207, -1557.772, 13.422, 76.4216},
	{1391.416, -1560.913, 13.422, 76.4216}
};*/

stock const Float:arr_sweeperRoute1[][] = {
	{1378.2147,-1583.3353,13.0968},
	{1315.6332,-1569.6871,13.1080},
	{1334.2397,-1509.6725,13.1079},
	{1359.6375,-1421.8394,13.1079},
	{1320.4907,-1393.2935,13.0604},
	{1265.2231,-1392.7772,12.8837},
	{1262.3806,-1278.8788,13.0431},
	{1196.2695,-1278.1820,13.0658},
	{1195.9363,-1392.5574,12.8965},
	{1061.2185,-1392.6384,13.2145},
	{1057.5387,-1452.7839,13.0901},
	{1035.7518,-1557.8513,13.0819},
	{1034.5358,-1713.1666,13.1099},
	{1146.7697,-1714.7200,13.5064},
	{1294.3937,-1715.1047,13.1080},
	{1295.0546,-1854.7382,13.1079},
	{1391.5858,-1875.5431,13.1080},
	{1391.3439,-1735.1486,13.1149},
	{1431.0377,-1735.5879,13.1080},
	{1432.7080,-1590.3550,13.1158},
	{1380.1821,-1584.3375,13.0956},
	{1385.16,-1556.59,13.69}
};

stock const Float:arr_sweeperRoute2[][] = {
	{1378.2147,-1583.3353,13.0968},
	{1416.0228,-1594.5168,13.0894},
	{1525.9496,-1594.5038,13.1157},
	{1527.2015,-1715.2076,13.1079},
	{1571.0892,-1734.6486,13.1097},
	{1690.6659,-1734.9031,13.1183},
	{1818.2689,-1734.5735,13.1080},
	{1845.8044,-1754.4082,13.1078},
	{1942.1942,-1755.0146,13.1079},
	{1938.5110,-1612.4591,13.1079},
	{1825.5416,-1609.9858,13.1058},
	{1713.6425,-1591.8118,13.0866},
	{1661.5282,-1590.5726,13.1173},
	{1660.4248,-1439.5377,13.1079},
	{1609.1470,-1438.1656,13.1080},
	{1611.2473,-1297.4122,17.0064},
	{1468.8929,-1296.1992,13.1611},
	{1452.1372,-1316.3556,13.1080},
	{1452.2960,-1423.8989,13.1079},
	{1434.2109,-1535.4905,13.1026},
	{1427.3871,-1588.5927,13.1157},
	{1380.1821,-1584.3375,13.0956},
	{1385.16,-1556.59,13.69}
};

stock const Float:arr_sweeperRoute3[][] = {
	{1378.2147,-1583.3353,13.0968},
	{1426.1704,-1594.1392,13.1160},
	{1427.2870,-1647.9890,13.0908},
	{1426.7964,-1716.4054,13.1079},
	{1388.7852,-1729.7666,13.1080},
	{1386.4607,-1853.6068,13.1079},
	{1401.3813,-1875.2633,13.1080},
	{1514.1666,-1875.0796,13.1080},
	{1603.3969,-1875.4104,13.1079},
	{1686.2434,-1858.6086,13.1119},
	{1691.8575,-1816.6533,13.1140},
	{1751.7976,-1824.4037,13.1130},
	{1817.7424,-1834.1172,13.1392},
	{1820.9419,-1933.1539,13.1024},
	{1945.3389,-1934.7996,13.1079},
	{1963.7144,-1877.2684,13.1079},
	{1963.9944,-1750.3612,13.1080},
	{1835.4379,-1749.7634,13.1080},
	{1807.3591,-1730.6323,13.1158},
	{1670.0962,-1729.3608,13.1079},
	{1543.2943,-1729.9379,13.1079},
	{1436.1337,-1730.5010,13.1079},
	{1431.6207,-1679.4716,13.1079},
	{1432.3372,-1590.7336,13.1160},
	{1380.1821,-1584.3375,13.0956},
	{1385.16,-1556.59,13.69}
};

// SAMP callback
#include <YSI\y_hooks>
hook OnGameModeInitEx()
{
	CreateDynamicMapIcon(1396.8718,-1570.8198,14.2710, 56, -1, -1, 0); //Map Icon
	return 1;
}


hook OnPlayerConnect(playerid)
{
    PlayerData[playerid][pSweepersidejob] = 0;
  	PlayerSSidejob[playerid] = -1;
	hasSweeper[playerid] = false;
	sweeperRoute[playerid] = 0;
	currentSRoute[playerid] = 0;
	outCheckswe[playerid] = 0;
	stop outTimerswe[playerid];
	stop outTimeswe[playerid];

	return 1;
}

hook OnPlayerSpawn(playerid)
{
	hasSweeper[playerid] = false;
	sweeperRoute[playerid] = 0;
	currentSRoute[playerid] = 0;
	outCheckswe[playerid] = 0;
	stop outTimerswe[playerid];
	stop outTimeswe[playerid];

	return 1;
}


hook OnPlayerDisconnectEx(playerid)
{
    if (PlayerData[playerid][pSweepersidejob])
	{
	    PlayerData[playerid][pSweepersidejob] = 0;

	    if (PlayerSSidejob[playerid] != -1)
	      	DialogSSidejob[PlayerSSidejob[playerid]] = false;

	    PlayerSSidejob[playerid] = -1;

	    DestroyVehicle(GetPlayerLastVehicle(playerid));
		DisablePlayerRaceCheckpoint(playerid);
		stop outTimerswe[playerid];
		stop outTimeswe[playerid];
		outCheckswe[playerid] = 0;

		SetSweeperDelay(playerid, 600);
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_CTRL_BACK) //Key H
    {
        if(IsPlayerInRangeOfPoint(playerid, 2,1292.9812,-1878.1991,13.5469,175.2073,0,0,0,0,0,0))
        {
            if(PlayerData[playerid][pSweepersidejob] == 1)
				return SendErrorMessage(playerid, "Kamu sedang bekerja Sweeper, tidak bisa mengambil Sweeper kembali");

            if(PlayerData[playerid][pMaskOn])
				return SendErrorMessage(playerid, "Disable your mask first."), RemovePlayerFromVehicle(playerid);

            if(GetSweeperDelay(playerid) > 0)
			{
				SendCustomMessage(playerid, "Sweeper", "Kamu tidak dapat bekerja sekarang, tunggu %d menit untuk memulainya kembali.", (GetSweeperDelay(playerid)/60));
				return 1;
			}
	        new str[640];

    		format(str, sizeof(str), "Sweeper\tStatus\n");
		  	for (new i = 0; i < 3; i ++) {
		    	format(str, sizeof(str), "%sSweepType %d\t"GREEN"%s\n", str, i, (DialogSSidejob[i] == true) ? (RED"Taken") : (GREEN"Availeble"));
		  	}
		  	Dialog_Show(playerid, SidejobSweeperstatus, DIALOG_STYLE_TABLIST_HEADERS, "Sweeper Sidejob", str, "Start", "Close");
		}
    }
	return 1;
}

Dialog:SidejobSweeperstatus(playerid, response, listitem, inputtext[]) {
  if (response && listitem != -1) {
    if (DialogSSidejob[listitem] == true)
      return SendErrorMessage(playerid, "This Sweeper Sidejob has already taken by someone!");

    if(listitem == 0)
	{
		DialogSSidejob[listitem] = true;
	    PlayerSSidejob[playerid] = listitem;
	    PlayerData[playerid][pSweepersidejob] = 1;

	    sweeperVehicle[0] = CreateVehicle(574, 1393.069, -1554.634, 13.422, 76.4216, 1, 2, 1000);
	    ResetVehicle(sweeperVehicle[0]);

	    CoreVehicles[sweeperVehicle[0]][vehTemporary] = true;
	    SetVehicleNumberPlate(sweeperVehicle[0], "SWEEP VEHICLE-0");
	    PutPlayerInVehicle(playerid, sweeperVehicle[0], 0);
		SetCameraBehindPlayer(playerid);
		Dialog_Show(playerid, SweeperJob, DIALOG_STYLE_MSGBOX, "Sweeper Sidejob", ""WHITE"Kamu menaiki kendaraan sweeper. Apakah kamu ingin memulai pekerjaan ini?.\nKamu akan di tugaskan untuk membersihkan jalan di kota Los Santos.\n\nPilik opsi \"Mulai\" untuk melakukan pekerjaan.", "Mulai", "Turun");
	}
	if(listitem == 1)
	{
		DialogSSidejob[listitem] = true;
	    PlayerSSidejob[playerid] = listitem;
	    PlayerData[playerid][pSweepersidejob] = 1;

	    sweeperVehicle[1] = CreateVehicle(574, 1392.207, -1557.772, 13.422, 76.4216, 1, 2, 1000);
	    ResetVehicle(sweeperVehicle[1]);

	    CoreVehicles[sweeperVehicle[1]][vehTemporary] = true;
	    SetVehicleNumberPlate(sweeperVehicle[1], "SWEEP VEHICLE-1");
	    PutPlayerInVehicle(playerid, sweeperVehicle[1], 0);
		SetCameraBehindPlayer(playerid);
		Dialog_Show(playerid, SweeperJob, DIALOG_STYLE_MSGBOX, "Sweeper Sidejob", ""WHITE"Kamu menaiki kendaraan sweeper. Apakah kamu ingin memulai pekerjaan ini?.\nKamu akan di tugaskan untuk membersihkan jalan di kota Los Santos.\n\nPilik opsi \"Mulai\" untuk melakukan pekerjaan.", "Mulai", "Turun");
	}
	if(listitem == 2)
	{
		DialogSSidejob[listitem] = true;
	    PlayerSSidejob[playerid] = listitem;
	    PlayerData[playerid][pSweepersidejob] = 1;

	    sweeperVehicle[2] = CreateVehicle(574, 1391.416, -1560.913, 13.422, 76.4216, 1, 2, 1000);
	    ResetVehicle(sweeperVehicle[2]);

	    CoreVehicles[sweeperVehicle[2]][vehTemporary] = true;
	    SetVehicleNumberPlate(sweeperVehicle[2], "SWEEP VEHICLE-2");
	    PutPlayerInVehicle(playerid, sweeperVehicle[2], 0);
		SetCameraBehindPlayer(playerid);
		Dialog_Show(playerid, SweeperJob, DIALOG_STYLE_MSGBOX, "Sweeper Sidejob", ""WHITE"Kamu menaiki kendaraan sweeper. Apakah kamu ingin memulai pekerjaan ini?.\nKamu akan di tugaskan untuk membersihkan jalan di kota Los Santos.\n\nPilik opsi \"Mulai\" untuk melakukan pekerjaan.", "Mulai", "Turun");
	}
  }
  return 1;
}


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT)
	{
	    if(outCheckswe[playerid] == 1)
		{
      		if(IsSweeperVehicle(GetPlayerLastVehicle(playerid)))
			{
			    if(!GetPlayerLastVehicle(playerid))
				{
					SendCustomMessage(playerid, "SWEEPER", "Silahkan pilih sweeper yang terakhir kamu naiki.");
					RemovePlayerFromVehicle(playerid);
					return 1;
				}
				outCheckswe[playerid] = 0;
			    stop outTimerswe[playerid];
				stop outTimeswe[playerid];
			}
			return 1;
		}
		/*if(outCheckswe[playerid] == 0)
		{
      		if(IsSweeperVehicle(GetPlayerVehicleID(playerid)))
			{
				if(GetSweeperDelay(playerid) > 0)
				{
					SendCustomMessage(playerid, "SWEEPER", "Kamu tidak dapat bekerja sekarang, tunggu %d menit untuk memulainya kembali.", (GetSweeperDelay(playerid)/60));
					RemovePlayerFromVehicle(playerid);
					SetCameraBehindPlayer(playerid);
					return 1;
				}

				if(PlayerData[playerid][pMaskOn])
		    		return SendErrorMessage(playerid, "Disable your mask first."), RemovePlayerFromVehicle(playerid);

				SetCameraBehindPlayer(playerid);
				Dialog_Show(playerid, SweeperJob, DIALOG_STYLE_MSGBOX, "Sweeper Sidejob", ""WHITE"Kamu menaiki kendaraan sweeper. Apakah kamu ingin memulai pekerjaan ini?.\nKamu akan di tugaskan untuk membersihkan jalan di kota Los Santos.\n\nPilik opsi \"Mulai\" untuk melakukan pekerjaan.", "Mulai", "Turun");
			}
			return 1;
		}*/
	}

	if(newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER)
	{
		if(hasSweeper[playerid])
		{
			/*if (IssweeperVehicle(GetPlayerLastVehicle(playerid)))
			{
				hasSweeper[playerid] = false;
				currentSRoute[playerid] = 0;
				sweeperRoute[playerid] = 0;

				SetVehicleToRespawn(GetPlayerLastVehicle(playerid));
				DisablePlayerRaceCheckpoint(playerid);

				SetSweeperDelay(playerid, 600);
				SendCustomMessage(playerid, "SWEEPER","Kamu gagal dan tidak tuntas menyelesaikan pekerjaan ini.");
			}*/
			if (IsSweeperVehicle(GetPlayerLastVehicle(playerid)))
			{
			    sweOut[playerid] = 25;
			    outCheckswe[playerid] = 1;
				outTimerswe[playerid] = repeat InsideSweOut(playerid);
				outTimeswe[playerid] = defer SetPlayerToCancelswe[25000](playerid);
				GameTextForPlayer(playerid, sprintf("ENTER THE SWEEPER~n~~y~%02d SECONDS", sweOut[playerid]), 1000, 6);
				PlayerPlaySoundEx(playerid, 43000);
				/*StopPlayerWorkInSweeper(playerid);
				currentBRoute[playerid] = 0;
				SweeperRoute[playerid] = 0;
				SweeperCounter[playerid] = 0;

				stop SweeperTimer[playerid];

				SetVehicleToRespawn(GetPlayerLastVehicle(playerid));
				DisablePlayerRaceCheckpoint(playerid);

				SetSweeperDelay(playerid, 600);
				SendCustomMessage(playerid, "Sweeper","Kamu gagal dan tidak tuntas menyelesaikan pekerjaan ini.");*/
			}
		}
	}
	return 1;
}

timer SetPlayerToCancelswe[1000](playerid)
{
    PlayerData[playerid][pSweepersidejob] = 0;

    if (PlayerSSidejob[playerid] != -1)
      	DialogSSidejob[PlayerSSidejob[playerid]] = false;

    PlayerSSidejob[playerid] = -1;
	hasSweeper[playerid] = false;
	currentSRoute[playerid] = 0;
	sweeperRoute[playerid] = 0;
	outCheckswe[playerid] = 0;
	
	stop outTimerswe[playerid];
	stop outTimeswe[playerid];

	SetVehicleToRespawn(GetPlayerLastVehicle(playerid));
	DisablePlayerRaceCheckpoint(playerid);

	SetSweeperDelay(playerid, 600);
	SendCustomMessage(playerid, "SWEEPER","Kamu gagal dan tidak tuntas menyelesaikan pekerjaan ini.");
    return 1;
}

timer InsideSweOut[1000](playerid)
{
    sweOut[playerid]--;
	GameTextForPlayer(playerid, sprintf("ENTER THE SWEEPER~n~~y~%02d SECONDS", sweOut[playerid]), 1000, 6);
	PlayerPlaySoundEx(playerid, 43000);
	return 1;
}


hook OnPlayerEnterRaceCP(playerid)
{
	if(hasSweeper[playerid])
	{
		currentSRoute[playerid] ++;

		if((sweeperRoute[playerid] == 1 && currentSRoute[playerid] == sizeof(arr_sweeperRoute1)) ||
			(sweeperRoute[playerid] == 2 && currentSRoute[playerid] == sizeof(arr_sweeperRoute2)) ||
			(sweeperRoute[playerid] == 3 && currentSRoute[playerid] == sizeof(arr_sweeperRoute3))
		)
		{
		    new index = PlayerSSidejob[playerid];
		    PlayerData[playerid][pSweepersidejob] = 0;
		    DialogSSidejob[index] = false;
			hasSweeper[playerid] = false;
			currentSRoute[playerid] = 0;
			sweeperRoute[playerid] = 0;

			SetVehicleToRespawn(GetPlayerVehicleID(playerid));
			DisablePlayerRaceCheckpoint(playerid);

			new bonus = RandomEx(25,99);
			SendCustomMessage(playerid, "SWEEPER","Kamu telah menyelesaikan pekerjaan, dan kamu mendapat upah "COL_GREEN"$%s "WHITE"dari pekerjaan ini, dan bonus sebesar "COL_GREEN"$0.%d",FormatNumber(7500), bonus);
			AddPlayerSalary(playerid, SWEEPER_SALARY+bonus, "Sweeper Sidejob + Bonus");
			SetSweeperDelay(playerid, 1200);
			PlayerSSidejob[playerid] = -1;
		}
		else if((sweeperRoute[playerid] == 1 && currentSRoute[playerid] == sizeof(arr_sweeperRoute1) - 1) ||
			(sweeperRoute[playerid] == 2 && currentSRoute[playerid] == sizeof(arr_sweeperRoute2) - 1) ||
			(sweeperRoute[playerid] == 3 && currentSRoute[playerid] == sizeof(arr_sweeperRoute3) - 1)
		)
		{
			SetSweeperCheckpoin(playerid, 1);
		}
		else SetSweeperCheckpoin(playerid, 0);
	}

	return 1;
}

// 
// hook OnVehicleDeath(vehicleid, killerid)
// {
// 	if (IssweeperVehicle(vehicleid)) {
// 		// SetVehicleToRespawn(vehicleid);
// 		if(hasSweeper[killerid]) {
// 			hasSweeper[killerid] = false;
// 			currentSRoute[killerid] = 0;
// 			sweeperRoute[killerid] = 0;

// 			DisablePlayerRaceCheckpoint(killerid);

// 			SetSweeperDelay(killerid, 600);
// 			SendCustomMessage(killerid, "SWEEPER","Kamu gagal dan tidak tuntas menyelesaikan pekerjaan ini.");
// 		}
// 	}
// 	return 1;
// }

// new function
IsSweeperVehicle(vehicleid)
{
	for(new i = 0; i < MAX_SWEEPER_VEHICLE; i++) if(vehicleid == sweeperVehicle[i])
		return 1;

	return 0;
}

SetSweeperCheckpoin(playerid, mode)
{
	if(hasSweeper[playerid])
	{
		switch(sweeperRoute[playerid])
		{
			case 1: SetPlayerRaceCheckpoint(playerid, mode, arr_sweeperRoute1[currentSRoute[playerid]][0], 
				arr_sweeperRoute1[currentSRoute[playerid]][1], arr_sweeperRoute1[currentSRoute[playerid]][2], 
				mode ? (-1.00) : (arr_sweeperRoute1[currentSRoute[playerid] + 1][0]), mode ? (-1.00) : (arr_sweeperRoute1[currentSRoute[playerid] + 1][1]), 
				mode ? (-1.00) : (arr_sweeperRoute1[currentSRoute[playerid] + 1][2]), 3);

			case 2: SetPlayerRaceCheckpoint(playerid, mode, arr_sweeperRoute2[currentSRoute[playerid]][0], 
				arr_sweeperRoute2[currentSRoute[playerid]][1], arr_sweeperRoute2[currentSRoute[playerid]][2], 
				mode ? (-1.00) : (arr_sweeperRoute2[currentSRoute[playerid] + 1][0]), mode ? (-1.00) : (arr_sweeperRoute2[currentSRoute[playerid] + 1][1]), 
				mode ? (-1.00) : (arr_sweeperRoute2[currentSRoute[playerid] + 1][2]), 3);

			case 3: SetPlayerRaceCheckpoint(playerid, mode, arr_sweeperRoute3[currentSRoute[playerid]][0], 
				arr_sweeperRoute3[currentSRoute[playerid]][1], arr_sweeperRoute3[currentSRoute[playerid]][2], 
				mode ? (-1.00) : (arr_sweeperRoute3[currentSRoute[playerid] + 1][0]), mode ? (-1.00) : (arr_sweeperRoute3[currentSRoute[playerid] + 1][1]), 
				mode ? (-1.00) : (arr_sweeperRoute3[currentSRoute[playerid] + 1][2]), 3);
		}
	}
	return 1;
}

// dialog respons
Dialog:SweeperJob(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new route = RandomEx(1, 4);

		// variable
		hasSweeper[playerid] = true;
		currentSRoute[playerid] = 0;
		sweeperRoute[playerid] = route;

		SetEngineStatus(GetPlayerVehicleID(playerid), true);
		CoreVehicles[GetPlayerVehicleID(playerid)][vehFuel] = 100;

		// output
		SetSweeperCheckpoin(playerid, 0);
	}
	else
	{
	    PlayerData[playerid][pSweepersidejob] = 0;

	    if (PlayerSSidejob[playerid] != -1)
	      	DialogSSidejob[PlayerSSidejob[playerid]] = false;

	    PlayerSSidejob[playerid] = -1;
		DestroyVehicle(GetPlayerVehicleID(playerid));
	}
	return 1;
}

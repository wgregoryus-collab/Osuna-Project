timer InsideTraOut[1000](playerid)
{
    traOut[playerid]--;
	GameTextForPlayer(playerid, sprintf("ENTER THE TRASHMASTER~n~~y~%02d SECONDS", traOut[playerid]), 1000, 6);
	PlayerPlaySoundEx(playerid, 43000);
	return 1;
}
timer InsideForOut[1000](playerid)
{
    forOut[playerid]--;
	GameTextForPlayer(playerid, sprintf("ENTER THE FORKLIFT~n~~y~%02d SECONDS", forOut[playerid]), 1000, 6);
	PlayerPlaySoundEx(playerid, 43000);
	return 1;
}
timer SetPlayerToCancelfor[1000](playerid)
{
    new vehicleid = GetPlayerLastVehicle(playerid);
    CoreVehicles[vehicleid][vehLoadType] = 0;
    DestroyDynamicObject(CoreVehicles[vehicleid][vehCrate]);
    outCheckfor[playerid] = 0;
    
    stop outTimerfor[playerid];
	stop outTimefor[playerid];

    CoreVehicles[vehicleid][vehCrate] = INVALID_STREAMER_ID;
    DisablePlayerCheckpoint(playerid);
    SetUnloaderDelay(playerid, 1800);
    new bonus = RandomEx(25,100);
    AddPlayerSalary(playerid, (PlayerData[playerid][pUnloader]*20)+bonus, "Cargo Unloader Sidejob + Bonus");
    PlayerData[playerid][pUnloader] = 0;
    SendCustomMessage(playerid, "Cargo Unloader", "Kamu terlalu lama turun dari kendaraan dan pekerjaanmu selesai.");
    SetVehicleToRespawn(vehicleid);
    return 1;
}
timer SetPlayerToCanceltra[1000](playerid)
{
	new vehicleid = GetPlayerLastVehicle(playerid);

    CoreVehicles[vehicleid][vehTrash] = 0;
    CoreVehicles[vehicleid][vehFuel] = 0.0;
    SetVehicleToRespawn(vehicleid);
    outChecktra[playerid] = 0;
    
    stop outTimertra[playerid];
	stop outTimetra[playerid];

    PlayerTextDrawHide(playerid, PlayerTextdraws[playerid][textdraw_trash][0]);
    PlayerTextDrawHide(playerid, PlayerTextdraws[playerid][textdraw_trash][1]);

    DisablePlayerCheckpoint(playerid);
    HidePlayerProgressBar(playerid, PlayerData[playerid][trash]);

    for(new i; i < MAX_GARBAGE_BINS; i++) if(GarbageData[i][garbageExists]) {
        RemovePlayerMapIcon(playerid, i);
    }
    PlayerData[playerid][pWork] = 600;
    PlayerData[playerid][pTrashmasterJob] = 0;
    SendClientMessageEx(playerid, X11_LIGHTBLUE, "TRASHMASTER: "WHITE"Anda gagal dalam melakukan pekerjaan ini dikarenakan terlalu lama turun dari kendaraan.");
    return 1;
}

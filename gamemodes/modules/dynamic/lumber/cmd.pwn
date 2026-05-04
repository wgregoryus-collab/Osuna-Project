SSCANF:LumberMenu(string[]) 
{
    if(!strcmp(string,"create",true)) return 1;
    else if(!strcmp(string,"delete",true)) return 2;
    else if(!strcmp(string,"position",true)) return 3;
    else if(!strcmp(string,"time",true)) return 4;
    return 0;
}

CMD:lumbermenu(playerid, params[])
{
    if (CheckAdmin(playerid, 5))
        return PermissionError(playerid);

    new
        lumber_id, action, nextParams[128]
    ;

    if(sscanf(params, "k<LumberMenu>S()[128]", action, nextParams))
        return SendSyntaxMessage(playerid, "/lumbermenu [create/delete/position/time]");

    switch(action)
    {
        case 1: // Create
        {
            new Float:x, Float:y, Float:z;

            GetXYInFrontOfPlayer(playerid, x, y, 2.0);
            GetPlayerPos(playerid, z, z, z);

            if((lumber_id = Lumber_Create(x, y, z)) != INVALID_ITERATOR_SLOT) {
                return SendServerMessage(playerid, "Sukses membuat lumber dengan id: %d", lumber_id);
            }
            SendErrorMessage(playerid, "Slot lumber sudah mencapai batas maksimal (%d lumber), hubungi scripter segera!.", MAX_DYNAMIC_LUMBER);
        }
        case 2: // Delete
        {
            if(sscanf(nextParams, "d", lumber_id))
                return SendSyntaxMessage(playerid, "/lumbermenu delete <lumber id>");

            if(!Lumber_Exists(lumber_id))
                return SendErrorMessage(playerid, "Id lumber tidak terdaftar diserver.");

            if(Lumber_Delete(lumber_id)) {
                SendServerMessage(playerid, "Lumber id "YELLOW"%d "WHITE"telah dihapus dari server!", lumber_id);
                return 1;
            }
            SendErrorMessage(playerid, "Id lumber tidak terdaftar diserver.", lumber_id);
        }
        case 3: // Position
        {
            if(sscanf(nextParams, "d", lumber_id))
                return SendSyntaxMessage(playerid, "/lumbermenu position <lumber id>");

            if(!Lumber_Exists(lumber_id))
                return SendErrorMessage(playerid, "Id lumber tidak terdaftar diserver.");

            new Float:x, Float:y, Float:z;

            GetXYInFrontOfPlayer(playerid, x, y, 2.0);
            GetPlayerPos(playerid, z, z, z);

            Lumber_SetPosition(lumber_id, x, y, z);
            Lumber_Sync(lumber_id);
            Lumber_Save(lumber_id, SAVE_LUMBER_POS);
            SendServerMessage(playerid, "Posisi lumber id "YELLOW"%d"WHITE" telah diperbaharui!", lumber_id);
        }
        case 4: // Time
        {
            new time;

            if(sscanf(nextParams, "dd", lumber_id, time))
                return SendSyntaxMessage(playerid, "/lumbermenu delete <lumber id> <time>");

            if(!Lumber_Exists(lumber_id))
                return SendErrorMessage(playerid, "Id lumber tidak terdaftar diserver.");

            if(time < 0)
                return SendErrorMessage(playerid, "Masukkan angka lebih dari nol!.");

            Lumber_SetTime(lumber_id, time);
            Lumber_Sync(lumber_id);
            Lumber_Save(lumber_id, SAVE_LUMBER_TIME);

            SendServerMessage(playerid, "Waktu spawn lumber id "YELLOW"%d"WHITE" telah diperbaharui menjadi "GREEN"%d detik!", lumber_id, time);
        }
        default: SendSyntaxMessage(playerid, "/lumbermenu [create/delete/position/time]");
    }
    return 1;
}

CMD:gotolumber(playerid, params[])
{
    new lumber_id;

    if (CheckAdmin(playerid, 5))
        return PermissionError(playerid);

    if(sscanf(params, "d", lumber_id))
        return SendSyntaxMessage(playerid, "/gotolumber <lumber id>");

    if(!Lumber_Exists(lumber_id))
        return SendErrorMessage(playerid, "You have specified an invalid tree ID.");

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    SetPlayerPos(playerid, LumberData[lumber_id][lumberPos][0] + 1.0, LumberData[lumber_id][lumberPos][1] + 1.0, LumberData[lumber_id][lumberPos][2] + 2.0);
    SendServerMessage(playerid, "Kamu telah teleportasi ke lumber id: "YELLOW"%d", lumber_id);
    return 1;
}

CMD:nearestlumber(playerid, params[])
{
    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);

    new lumber_id = Lumber_Nearest(playerid);
    SendServerMessage(playerid, "Nearest lumber id: "YELLOW"%s", (lumber_id == -1) ? ("none") : sprintf("%d", lumber_id));
    return 1;
}

CMD:lumberhelp(playerid, params[])
{
    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);

    SendServerMessage(playerid, "/lumbermenu, /gotolumber, /nearestlumber.");
    return 1;
}


// Job commands
CMD:loadtree(playerid, params[])
{
    if(GetPlayerJob(playerid, 0) != JOB_LUMBERJACK && GetPlayerJob(playerid, 1) != JOB_LUMBERJACK)
        return SendErrorMessage(playerid, "Kamu tidak seorang lumberjack.");

    new lumber_id, vehicleid = -1, kapasitas;

    if((lumber_id = Lumber_Nearest(playerid, 2)) != -1)
    {
        if(!LumberData[lumber_id][lumberCut])
            return SendErrorMessage(playerid, "Tebang terlebih dahulu pohon yang akan diangkut.");

        if((vehicleid = Vehicle_GetID(GetNearestVehicleToPlayer(playerid,3.0,false))) != -1)
        {
            if(GetVehicleModel(VehicleData[vehicleid][cVehicle]) != 543 && GetVehicleModel(VehicleData[vehicleid][cVehicle]) != 554 && GetVehicleModel(VehicleData[vehicleid][cVehicle]) != 422) 
                return SendErrorMessage(playerid, "Ini bukan kendaraan pickup, seperti Bobcat, Sadler, atau Yosemite.");

            if(!GetTrunkStatus(VehicleData[vehicleid][cVehicle])) 
                return SendErrorMessage(playerid, "Buka terlebih penutup bagasi pickup.");

            switch(GetVehicleModel(VehicleData[vehicleid][cVehicle]))
            {
                case 543: kapasitas = 8;
                case 422: kapasitas = 10;
                case 554: kapasitas = 12;
            }

            new vehName[32];
            GetVehicleNameByVehicle(VehicleData[vehicleid][cVehicle], vehName);
            if(VehicleData[vehicleid][cLumber] >= kapasitas)
                return SendErrorMessage(playerid, "Kapasitas penyimpanan untuk mobil %s hanya muat %d pohon.", vehName, kapasitas);

            VehicleData[vehicleid][cLumber] ++;

            LumberData[lumber_id][lumberCut]   = 0;
            LumberData[lumber_id][lumberTime]  = 3600;

            Lumber_Sync(lumber_id);
            Lumber_Save(lumber_id, SAVE_LUMBER_TIME);
            Lumber_Save(lumber_id, SAVE_LUMBER_CUTTING);

            SendServerMessage(playerid, "Sukses meletakkan kayu ke bak mobil %s, bak mobil kini menampung "YELLOW"%d/%d.", vehName, VehicleData[vehicleid][cLumber], kapasitas);
            ApplyAnimation(playerid, "CARRY", "putdwn105", 4.1, 0, 0, 0, 0, 0, 1);
            return 1;
        }
        SendErrorMessage(playerid, "Tidak ada kendaraan di dekatmu atau kendaraan disekitarmu adalah kendaraan statis.");
        return 1;
    }
    SendErrorMessage(playerid, "Kamu tidak berada di dekat pohon.");
    return 1;
}

CMD:unloadtree(playerid, params[])
{
    new id, carid = Vehicle_GetID(GetPlayerVehicleID(playerid));

    if((id = Job_NearestPoint(playerid)) != -1 && JobData[id][jobType] == JOB_LUMBERJACK)
    {
        if(GetPlayerJob(playerid, 0) != JOB_LUMBERJACK && GetPlayerJob(playerid, 1) != JOB_LUMBERJACK) 
            return SendErrorMessage(playerid, "Anda bukan pekerja lumberjack.");

        if(!IsPlayerInAnyVehicle(playerid))
            return 1;

        if(GetVehicleModel(VehicleData[carid][cVehicle]) != 543 && GetVehicleModel(VehicleData[carid][cVehicle]) != 554 && GetVehicleModel(VehicleData[carid][cVehicle]) != 422) 
            return SendErrorMessage(playerid, "Ini bukan kendaraan pickup, seperti Bobcat, Sadler, atau Yosemite.");

        if(!VehicleData[carid][cLumber]) 
            return SendErrorMessage(playerid, "Pickup tidak memuat pohon untuk dijual.");

        if(JobData[id][jobStock] > 150) 
            return SendErrorMessage(playerid, "Stock gudang penuh, tidak dapat menjual pohon sementara waktu.");

        if(!GetTrunkStatus(GetPlayerVehicleID(playerid))) 
            return SendErrorMessage(playerid, "Buka terlebih dahulu penutup pickup.");

        if(PlayerData[playerid][pLumberDelay] > 0) 
            return SendErrorMessage(playerid, "Kamu memiliki waktu jeda "YELLOW"%d "WHITE"menit untuk menjual pohon kembali.", (PlayerData[playerid][pLumberDelay]/60));

        PlayerData[playerid][pLumberDelay] = 1800; 
        AddPlayerSalary(playerid, (VehicleData[carid][cLumber]*4000), "Unload Tree");
        
        JobData[id][jobStock] += VehicleData[carid][cLumber];
        Cargo_PlusStock(4, VehicleData[carid][cLumber]);

        if(JobData[id][jobStock] > 150)
            JobData[id][jobStock] = 150;

        VehicleData[carid][cLumber] = 0;
        Job_Refresh(id);
    }
    else SendServerMessage(playerid, "Kamu tidak berada di lumberjack point.");

    return 1;
}

CMD:buychainsaw(playerid, params[])
{
    if(IsPlayerDuty(playerid))
        return SendErrorMessage(playerid, "You're on duty faction.");

    new id;

    if((id = Job_NearestPoint(playerid)) != -1 && JobData[id][jobType] == JOB_LUMBERJACK) 
    {   
        if(GetPlayerJob(playerid, 0) != JOB_LUMBERJACK && GetPlayerJob(playerid, 1) != JOB_LUMBERJACK) 
            return SendErrorMessage(playerid, "Anda bukan pekerja lumberjack.");
        
        if(GetMoney(playerid) < 2500)
            return SendErrorMessage(playerid, "Uang kamu tidak cukup, butuh ($25.00) untuk membeli.");

        if(PlayerHasWeaponInSlot(playerid, 9))
            return SendErrorMessage(playerid, "Kamu memiliki item senjata lain dislot yang sama dengan chainsaw.");

        GiveMoney(playerid, -2500);
        GivePlayerWeaponEx(playerid, 9, 1);
        SendServerMessage(playerid, "Anda membeli "RED"Chainsaw "WHITE"dengan harga "GREEN"$25.00.");
    }
    else SendServerMessage(playerid, "Kamu tidak berada di lumberjack point.");

    return 1;
}

#define MAX_VEHSPAWN_POINT (50)

enum spawnPointData {
    sID,
    sName[32],
    Float:sPos[3],
    sWorld,
    sInterior,
    sFaction,
    sPickup,
    Text3D:sText
};

new VehSpawnPoint[MAX_VEHSPAWN_POINT][spawnPointData],
    Iterator:SpawnPoints<MAX_VEHSPAWN_POINT>;

#include <YSI\y_hooks>
hook OnGameModeInitEx() {
    mysql_tquery(g_iHandle,"SELECT * FROM `vehspawnpoint`", "SpawnPoint_Load", "");
    return 1;
}


hook OnGameModeExit() {
    foreach (new i : SpawnPoints) {
        SpawnPoint_Save(i);
    }
    return 1;
}

Function:SpawnPoint_Load() {
    new rows = cache_num_rows();

    for (new i = 0; i < rows; i ++) {
        Iter_Add(SpawnPoints, i);

        cache_get_value_int(i, "ID", VehSpawnPoint[i][sID]);
        cache_get_value(i, "Name", VehSpawnPoint[i][sName]);
        cache_get_value_float(i, "X", VehSpawnPoint[i][sPos][0]);
        cache_get_value_float(i, "Y", VehSpawnPoint[i][sPos][1]);
        cache_get_value_float(i, "Z", VehSpawnPoint[i][sPos][2]);
        cache_get_value_int(i, "World", VehSpawnPoint[i][sWorld]);
        cache_get_value_int(i, "Interior", VehSpawnPoint[i][sInterior]);
        cache_get_value_int(i, "Faction", VehSpawnPoint[i][sFaction]);

        SpawnPoint_Refresh(i);
    }
    printf("*** [GTA:LSS Database: Loaded] veh spawn point data loaded (%d count)", rows);
    return 1;
}

Function:OnSpawnPointCreated(id) {
    if (!Iter_Contains(SpawnPoints, id))
        return 0;
    
    VehSpawnPoint[id][sID] = cache_insert_id();
    SpawnPoint_Save(id);
    return 1;
}

SpawnPoint_Create(name[], Float:x, Float:y, Float:z, vw = 0, int = 0, faction = 0) {
    new id = Iter_Free(SpawnPoints);

    if (id != cellmin) {
        Iter_Add(SpawnPoints, id);

        format(VehSpawnPoint[id][sName], 32, name);
        VehSpawnPoint[id][sPos][0] = x;
        VehSpawnPoint[id][sPos][1] = y;
        VehSpawnPoint[id][sPos][2] = z;
        VehSpawnPoint[id][sWorld] = vw;
        VehSpawnPoint[id][sInterior] = int;
        VehSpawnPoint[id][sFaction] = faction;

        SpawnPoint_Refresh(id);

        mysql_tquery(g_iHandle, sprintf("INSERT INTO `vehspawnpoint` (`World`) VALUES ('%d')", vw), "OnSpawnPointCreated", "d", id);
        return id;
    }
    return cellmin;
}

SpawnPoint_Refresh(id) {
    if (!Iter_Contains(SpawnPoints, id))
        return 0;
    
    if (IsValidDynamicPickup(VehSpawnPoint[id][sPickup]))
        DestroyDynamicPickup(VehSpawnPoint[id][sPickup]);
    
    if (IsValidDynamic3DTextLabel(VehSpawnPoint[id][sText]))
        DestroyDynamic3DTextLabel(VehSpawnPoint[id][sText]);
    
    new string[256];
    format(string,sizeof(string),"[VehicleSpawner:%d]\n"GREEN"%s\n"WHITE"Type '/spawn' to spawning static vehicle\nType '/despawn' to despawning your current vehicle",id,VehSpawnPoint[id][sName]);
    VehSpawnPoint[id][sPickup] = CreateDynamicPickup(1239, 23, VehSpawnPoint[id][sPos][0], VehSpawnPoint[id][sPos][1], VehSpawnPoint[id][sPos][2], VehSpawnPoint[id][sWorld], VehSpawnPoint[id][sInterior]);
    VehSpawnPoint[id][sText] = CreateDynamic3DTextLabel(string, COLOR_CLIENT, VehSpawnPoint[id][sPos][0], VehSpawnPoint[id][sPos][1], VehSpawnPoint[id][sPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, VehSpawnPoint[id][sWorld], VehSpawnPoint[id][sInterior]);
    return 1;
}

SpawnPoint_Save(id) {
    if (!Iter_Contains(SpawnPoints, id))
        return 0;
    
    new query[600];
    format(query,sizeof(query),"UPDATE `vehspawnpoint` SET `Name` = '%s', `X` = '%f', `Y` = '%f', `Z` = '%f', `World` = '%d', `Interior` = '%d', `Faction` = '%d' WHERE `ID` = '%d'", VehSpawnPoint[id][sName], VehSpawnPoint[id][sPos][0], VehSpawnPoint[id][sPos][1], VehSpawnPoint[id][sPos][2], VehSpawnPoint[id][sWorld], VehSpawnPoint[id][sInterior], VehSpawnPoint[id][sFaction], VehSpawnPoint[id][sID]);
    mysql_tquery(g_iHandle, query);
    return 1;
}

SpawnPoint_Delete(id) {
    if (!Iter_Contains(SpawnPoints, id))
        return 0;
    
    if (IsValidDynamicPickup(VehSpawnPoint[id][sPickup]))
        DestroyDynamicPickup(VehSpawnPoint[id][sPickup]);
    
    if (IsValidDynamic3DTextLabel(VehSpawnPoint[id][sText]))
        DestroyDynamic3DTextLabel(VehSpawnPoint[id][sText]);

    mysql_tquery(g_iHandle, sprintf("DELETE FROM `vehspawnpoint` WHERE `ID` = '%d'", VehSpawnPoint[id][sID]));
    Iter_Remove(SpawnPoints, id);
    return 1;
}

// GetVehSpawnPointID(id) {
//     foreach (new i : SpawnPoints) if (VehSpawnPoint[i][sID] == id) {
//         return i;
//     }
//     return -1;
// }

SSCANF:VehSpawnPointMenu(string[]) {
    if (!strcmp(string,"create",true)) return 1;
    else if (!strcmp(string,"delete",true)) return 2;
    else if (!strcmp(string,"name",true)) return 3;
    else if (!strcmp(string,"location",true)) return 4;
    else if (!strcmp(string,"vw",true)) return 5;
    else if (!strcmp(string,"int",true)) return 6;
    else if (!strcmp(string,"faction",true)) return 7;
    else return 0;
}

CMD:vehspawnpoint(playerid, params[]) {
    if (CheckAdmin(playerid, 8))
        return PermissionError(playerid);
    
    new option, string[128];
    if (sscanf(params, "k<VehSpawnPointMenu>S()[128]", option, string))
        return SendSyntaxMessage(playerid, "/vehspawnpoint [create/delete/name/location/vw/int/faction]");
    
    switch (option) {
        case 1: {
            new faction, name[32];
            if (sscanf(string,"ds[32]",faction,name))
                return SendSyntaxMessage(playerid, "/vehspawnpoint create [faction id] [name]");
            
            if (strlen(name) > 32 || strlen(name) < 1)
                return SendErrorMessage(playerid, "Name is too long");
            
            if (!FactionData[faction][factionExists])
                return SendErrorMessage(playerid, "Faction doesn't exist");
            
            new Float:pos[3];
            GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
            new id = SpawnPoint_Create(name, pos[0], pos[1], pos[2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), FactionData[faction][factionID]);

            if (id == cellmin)
                return SendErrorMessage(playerid, "Failed to create spawn point");
            
            SendCustomMessage(playerid, "VEHSPAWNPOINT", "Vehicle spawn point created with ID: "YELLOW"%d", id);
        }
        case 2: {
            new id;
            if (sscanf(string,"d",id))
                return SendSyntaxMessage(playerid, "/vehspawnpoint delete [spawnpoint id]");
            
            if (!Iter_Contains(SpawnPoints, id))
                return SendErrorMessage(playerid, "Spawn point doesn't exist");
            
            if (!SpawnPoint_Delete(id))
                return SendErrorMessage(playerid, "Failed to delete spawn point");
            
            SendCustomMessage(playerid, "VEHSPAWNPOINT", "Vehicle spawn point deleted with ID: "YELLOW"%d", id);
        }
        case 3: {
            new id, name[32];
            if (sscanf(string,"ds[32]",id,name))
                return SendSyntaxMessage(playerid, "/vehspawnpoint name [spawnpoint id] [name]");
            
            if (!Iter_Contains(SpawnPoints, id))
                return SendErrorMessage(playerid, "Spawn point doesn't exist");
            
            if (strlen(name) > 32 || strlen(name) < 1)
                return SendErrorMessage(playerid, "Name is too long");
            
            format(VehSpawnPoint[id][sName],32,name);
            SpawnPoint_Refresh(id);
            SpawnPoint_Save(id);
            SendCustomMessage(playerid, "VEHSPAWNPOINT", "Vehicle spawn point name changed to: "YELLOW"%s", name);
        }
        case 4: {
            new id, Float:pos[3];
            if (sscanf(string,"d",id))
                return SendSyntaxMessage(playerid, "/vehspawnpoint location [spawnpoint id]");
            
            if (!Iter_Contains(SpawnPoints, id))
                return SendErrorMessage(playerid, "Spawn point doesn't exist");
            
            GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
            VehSpawnPoint[id][sPos][0] = pos[0];
            VehSpawnPoint[id][sPos][1] = pos[1];
            VehSpawnPoint[id][sPos][2] = pos[2];
            SpawnPoint_Refresh(id);
            SpawnPoint_Save(id);
            SendCustomMessage(playerid, "VEHSPAWNPOINT", "Vehicle spawn point location ID: "YELLOW"%d "WHITE"changed to your current location", id);
        }
        case 5: {
            new id, vw;
            if (sscanf(string,"dd",id,vw))
                return SendSyntaxMessage(playerid, "/vehspawnpoint vw [spawnpoint id] [virtual world]");
            
            if (!Iter_Contains(SpawnPoints, id))
                return SendErrorMessage(playerid, "Spawn point doesn't exist");

            VehSpawnPoint[id][sWorld] = vw;
            SpawnPoint_Refresh(id);
            SpawnPoint_Save(id);
            SendCustomMessage(playerid, "VEHSPAWNPOINT", "Vehicle spawn point virtual world ID: "YELLOW"%d "WHITE"has changed to "YELLOW"%d", id, vw);
        }
        case 6: {
            new id, int;
            if (sscanf(string,"dd",id,int))
                return SendSyntaxMessage(playerid, "/vehspawnpoint int [spawnpoint id] [interior id]");
            
            if (!Iter_Contains(SpawnPoints, id))
                return SendErrorMessage(playerid, "Spawn point doesn't exist");

            VehSpawnPoint[id][sInterior] = int;
            SpawnPoint_Refresh(id);
            SpawnPoint_Save(id);
            SendCustomMessage(playerid, "VEHSPAWNPOINT", "Vehicle spawn point interior ID: "YELLOW"%d "WHITE"has changed to "YELLOW"%d", id, int);
        }
        case 7: {
            new id, faction;
            if (sscanf(string,"dd",id,faction))
                return SendSyntaxMessage(playerid, "/vehspawnpoint faction [spawnpoint id] [faction id]");
            
            if (!Iter_Contains(SpawnPoints, id))
                return SendErrorMessage(playerid, "Spawn point doesn't exist");
            
            if (!FactionData[faction][factionExists])
                return SendErrorMessage(playerid, "Faction doesn't exist");

            VehSpawnPoint[id][sFaction] = FactionData[faction][factionID];
            SpawnPoint_Refresh(id);
            SpawnPoint_Save(id);
            SendCustomMessage(playerid, "VEHSPAWNPOINT", "Vehicle spawn point faction ID: "YELLOW"%d "WHITE"has changed to "YELLOW"%d", id, faction);
        }
        default: {
            SendSyntaxMessage(playerid, "/vehspawnpoint [create/delete/name/location/vw/int/faction]");
        }
    }
    return 1;
}
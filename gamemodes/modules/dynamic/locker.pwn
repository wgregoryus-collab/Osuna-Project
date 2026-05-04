#define MAX_DYNAMIC_LOCKER  (50)

enum lockerData {
    lID,
    lName[32],
    Float:lPos[3],
    lWorld,
    lInterior,
    lFaction,
    lPickup,
    Text3D:lText
};

new LockerData[MAX_DYNAMIC_LOCKER][lockerData],
    Iterator:Lockers<MAX_DYNAMIC_LOCKER>;

#include <YSI\y_hooks>
hook OnGameModeInitEx() {
    mysql_tquery(g_iHandle, "SELECT * FROM `lockers`", "Locker_Load", "");
    return 1;
}


hook OnGameModeExit() {
    foreach (new i : Lockers) {
        Locker_Save(i);
    }
    return 1;
}

Function:Locker_Load() {
    new rows = cache_num_rows();

    for (new i = 0; i < rows; i ++) {
        Iter_Add(Lockers, i);

        cache_get_value_int(i, "ID", LockerData[i][lID]);
        cache_get_value(i, "Name", LockerData[i][lName]);
        cache_get_value_float(i, "X", LockerData[i][lPos][0]);
        cache_get_value_float(i, "Y", LockerData[i][lPos][1]);
        cache_get_value_float(i, "Z", LockerData[i][lPos][2]);
        cache_get_value_int(i, "World", LockerData[i][lWorld]);
        cache_get_value_int(i, "Interior", LockerData[i][lInterior]);
        cache_get_value_int(i, "Faction", LockerData[i][lFaction]);

        Locker_Refresh(i);
    }
    printf("*** [GarudaPride Database: Loaded] locker data loaded (%d count)", rows);
    return 1;
}

Function:OnLockerCreated(id) {
    if (!Iter_Contains(Lockers, id))
        return 0;
    
    LockerData[id][lID] = cache_insert_id();
    Locker_Save(id);
    return 1;
}

Locker_Create(name[], Float:x, Float:y, Float:z, vw = 0, int = 0, faction = 0) {
    new id = Iter_Free(Lockers);

    if (id != cellmin) {
        Iter_Add(Lockers, id);

        format(LockerData[id][lName], 32, name);
        LockerData[id][lPos][0] = x;
        LockerData[id][lPos][1] = y;
        LockerData[id][lPos][2] = z;
        LockerData[id][lWorld] = vw;
        LockerData[id][lInterior] = int;
        LockerData[id][lFaction] = faction;

        Locker_Refresh(id);

        mysql_tquery(g_iHandle, sprintf("INSERT INTO `lockers` (`Faction`) VALUES ('%d')", LockerData[id][lFaction]), "OnLockerCreated", "d", id);
        return id;
    }
    return cellmin;
}

Locker_Refresh(id) {
    if (!Iter_Contains(Lockers, id))
        return 0;
    
    new string[256];
    if (IsValidDynamicPickup(LockerData[id][lPickup]))
        DestroyDynamicPickup(LockerData[id][lPickup]);
    
    if (IsValidDynamic3DTextLabel(LockerData[id][lText]))
        DestroyDynamic3DTextLabel(LockerData[id][lText]);
    
    LockerData[id][lPickup] = CreateDynamicPickup(1239, 23, LockerData[id][lPos][0], LockerData[id][lPos][1], LockerData[id][lPos][2], LockerData[id][lWorld], LockerData[id][lInterior]);

    format(string,sizeof(string),"[Locker:%d]\n"GREEN"%s\n"WHITE"Type '"YELLOW"/locker"WHITE"' to access the locker.", id, LockerData[id][lName]);
    LockerData[id][lText] = CreateDynamic3DTextLabel(string, COLOR_CLIENT, LockerData[id][lPos][0], LockerData[id][lPos][1], LockerData[id][lPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, LockerData[id][lWorld], LockerData[id][lInterior]);
    return 1;
}

Locker_Save(id) {
    if (!Iter_Contains(Lockers, id))
        return 0;
    
    new query[600];

    format(query,sizeof(query),"UPDATE `lockers` SET `Name` = '%s', `X` = '%f', `Y` = '%f', `Z` = '%f', `World` = '%d', `Interior` = '%d', `Faction` = '%d' WHERE `ID` = '%d'", LockerData[id][lName], LockerData[id][lPos][0], LockerData[id][lPos][1], LockerData[id][lPos][2], LockerData[id][lWorld], LockerData[id][lInterior], LockerData[id][lFaction], LockerData[id][lID]);
    mysql_tquery(g_iHandle, query);
    return 1;
}

Locker_Delete(id) {
    if (!Iter_Contains(Lockers, id))
        return 0;
    
    if (IsValidDynamicPickup(LockerData[id][lPickup]))
        DestroyDynamicPickup(LockerData[id][lPickup]);
    
    if (IsValidDynamic3DTextLabel(LockerData[id][lText]))
        DestroyDynamic3DTextLabel(LockerData[id][lText]);
    
    LockerData[id][lPickup] = INVALID_STREAMER_ID;
    LockerData[id][lText] = Text3D:INVALID_STREAMER_ID;

    mysql_tquery(g_iHandle, sprintf("DELETE FROM `lockers` WHERE `ID` = '%d'", LockerData[id][lID]));
    Iter_Remove(Lockers, id);
    return 1;
}

SSCANF:LockerMenu(string[]) {
    if (!strcmp(string,"create",true)) return 1;
    else if (!strcmp(string,"delete",true)) return 2;
    else if (!strcmp(string,"name",true)) return 3;
    else if (!strcmp(string,"location",true)) return 4;
    else if (!strcmp(string,"faction",true)) return 5;
    else if (!strcmp(string,"vw",true)) return 6;
    else if (!strcmp(string,"int",true)) return 7;
    return 0;
}

CMD:lockermenu(playerid, params[]) {
    if (CheckAdmin(playerid, 8))
        return PermissionError(playerid);

    new option, string[128];
    if (sscanf(params, "k<LockerMenu>S()[128]", option, string))
        return SendSyntaxMessage(playerid, "/lockermenu [create/delete/name/location/faction/vw/int]");

    switch (option) {
        case 1: {
            new name[32], faction;
            
            if (sscanf(string, "ds[32]", faction, name))
                return SendSyntaxMessage(playerid, "/lockermenu create [faction id] [name]");
            
            if (strlen(name) < 3 || strlen(name) > 32)
                return SendErrorMessage(playerid, "The name must be at least 3 characters long.");
            
            if (!FactionData[faction][factionExists])
                return SendErrorMessage(playerid, "Faction doesn't exist");

            new Float:pos[3];
            GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
            new id = Locker_Create(name, pos[0], pos[1], pos[2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), FactionData[faction][factionID]);

            if (id == cellmin)
                return SendErrorMessage(playerid, "Server has reached maximum of Dynamic Faction Locker.");
            
            SendCustomMessage(playerid, "LOCKER", "Locker has been created with ID: %d.", id);
        }
        case 2: {
            new id;
            if (sscanf(string, "d", id))
                return SendSyntaxMessage(playerid, "/lockermenu delete [locker id]");
            
            if (!Iter_Contains(Lockers, id))
                return SendErrorMessage(playerid, "Locker does not exist.");
            
            if (Locker_Delete(id))
                SendCustomMessage(playerid, "LOCKER", "Locker has been deleted with ID: %d.", id);
        }
        case 3: {
            new name[32], id;
            if (sscanf(string, "ds[32]", id, name))
                return SendSyntaxMessage(playerid, "/lockermenu name [locker id] [name]");
            
            if (strlen(name) < 3 || strlen(name) > 32)
                return SendErrorMessage(playerid, "The name must be at least 3 characters long.");
            
            if (!Iter_Contains(Lockers, id))
                return SendErrorMessage(playerid, "Locker does not exist.");
            
            format(LockerData[id][lName], 32, name);
            Locker_Refresh(id);
            Locker_Save(id);
            SendCustomMessage(playerid, "LOCKER", "Locker name has been changed to: "YELLOW"%s", name);
        }
        case 4: {
            new id, Float:pos[3];
            if (sscanf(string, "d", id))
                return SendSyntaxMessage(playerid, "/lockermenu location [locker id]");
            
            if (!Iter_Contains(Lockers, id))
                return SendErrorMessage(playerid, "Locker does not exist.");
            
            GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
            LockerData[id][lPos][0] = pos[0];
            LockerData[id][lPos][1] = pos[1];
            LockerData[id][lPos][2] = pos[2];
            Locker_Refresh(id);
            Locker_Save(id);
            SendCustomMessage(playerid, "LOCKER", "Locker location has been changed.");
        }
        case 5: {
            new id, faction;
            if (sscanf(string, "dd", id, faction))
                return SendSyntaxMessage(playerid, "/lockermenu faction [locker id] [faction id]");
            
            if (!Iter_Contains(Lockers, id))
                return SendErrorMessage(playerid, "Locker does not exist.");
            
            LockerData[id][lFaction] = FactionData[faction][factionID];
            Locker_Refresh(id);
            Locker_Save(id);
            SendCustomMessage(playerid, "LOCKER", "Locker faction has been changed to: "YELLOW"%s", faction);
        }
        case 6: {
            new id, vw;
            if (sscanf(string, "dd", id, vw))
                return SendSyntaxMessage(playerid, "/lockermenu vw [locker id] [virtual world]");
            
            if (!Iter_Contains(Lockers, id))
                return SendErrorMessage(playerid, "Locker does not exist.");
            
            LockerData[id][lWorld] = vw;
            Locker_Refresh(id);
            Locker_Save(id);
            SendCustomMessage(playerid, "LOCKER", "Locker virtual world has been changed to: "YELLOW"%d", vw);
        }
        case 7: {
            new id, int;
            if (sscanf(string, "dd", id, int))
                return SendSyntaxMessage(playerid, "/lockermenu int [locker id] [interior]");
            
            if (!Iter_Contains(Lockers, id))
                return SendErrorMessage(playerid, "Locker does not exist.");
            
            LockerData[id][lInterior] = int;
            Locker_Refresh(id);
            Locker_Save(id);
            SendCustomMessage(playerid, "LOCKER", "Locker interior has been changed to: "YELLOW"%d", int);
        }
        default: {
            SendSyntaxMessage(playerid, "/lockermenu [create/delete/name/location/faction/vw/int]");
        }
    }
    return 1;
}

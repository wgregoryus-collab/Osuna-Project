#define MAX_APARTMENT       (50)
#define MAX_APARTMENT_ROOM  (1000)

#define MAX_OWNED_APARTMENT 1
#define MAX_ROOM_STORAGE    (5)

enum apartData {
    aID,
    aName[32],
    Float:aPos[3],
    aType,
    Float:aIntPos[3],
    aVw,
    aInt,
    aIntVw,
    aIntInt,
    aGarage,
    Float:aGaragePos[3],
    aGaragePickup,
    Text3D:aGarageLabel,
    aPickup,
    Text3D:aLabel,
    aCP,
    aCPInt,
    aPickupInt
};

enum apartRoom {
    rID,
    rApartID,
    rOwner,
    rOwnerName[MAX_PLAYER_NAME],
    rDuration,
    rPrice,
    rVw,
    rInt,
    rLocked,
    rInteriorVw,
    rInteriorInt,
    Float:rPos[3],
    Float:rPosInt[3],
    rWeapon[3],
    rAmmo[3],
    rDurability[3],
    rMoney,
    rPickup,
    Text3D:rLabel,
    rCP
};

new ApartData[MAX_APARTMENT][apartData],
    Iterator:Aparts<MAX_APARTMENT>;

new ApartRoom[MAX_APARTMENT_ROOM][apartRoom],
    Iterator:ApartRooms<MAX_APARTMENT_ROOM>;

enum roomStorage {
    rItemID,
    rItemExists,
    rItemName[32 char],
    rItemModel,
    rItemQuantity
};
new RoomStorage[MAX_APARTMENT_ROOM][MAX_ROOM_STORAGE][roomStorage];

// All Samp Callbacks
#include <YSI\y_hooks>
hook OnGameModeInitEx() {
    mysql_tquery(g_iHandle, "SELECT * FROM `aparts`", "Apart_Load", "");
    mysql_tquery(g_iHandle, "SELECT * FROM `apartrooms`", "ApartRoom_Load", "");
    return 1;
}


hook OnGameModeExit() {
    foreach (new a : Aparts) if (Iter_Contains(Aparts, a)) {
        Apart_Save(a);
    }

    foreach (new r : ApartRooms) if (Iter_Contains(ApartRooms, r)) {
        ApartRoom_Save(r);
    }

    return 1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) {
        new id = -1;

        if ((id = Apart_Nearest(playerid)) != -1 && IsPlayerInDynamicCP(playerid, ApartData[id][aCP])) {
            if (ApartData[id][aIntPos][0] == 0.0 && ApartData[id][aIntPos][1] == 0.0 && ApartData[id][aIntPos][2] == 0.0) return SendErrorMessage(playerid, "Interior Apartment ini masih kosong atau belum memiliki interior.");
            SetPlayerPosEx(playerid, ApartData[id][aIntPos][0], ApartData[id][aIntPos][1], ApartData[id][aIntPos][2]);
            SetPlayerVirtualWorld(playerid, ApartData[id][aIntVw]);
            SetPlayerInterior(playerid, ApartData[id][aIntInt]);
            SetPlayerWeather(playerid, 1);
            SetPlayerTime(playerid, 12, 0);
            PlayerData[playerid][pApartment] = ApartData[id][aID];
            return 1;
        }

        if ((id = ApartRoom_Nearest(playerid)) != -1) {
            if (ApartRoom[id][rPosInt][0] == 0.0 && ApartRoom[id][rPosInt][1] == 0.0 && ApartRoom[id][rPosInt][2] == 0.0) return SendErrorMessage(playerid, "Interior Room ini masih kosong atau belum memiliki interior.");
            if (ApartRoom[id][rLocked]) return GameTextForPlayer(playerid, "~r~Room Locked", 1000, 1);
            SetPlayerPosEx(playerid, ApartRoom[id][rPosInt][0], ApartRoom[id][rPosInt][1], ApartRoom[id][rPosInt][2]);
            SetPlayerVirtualWorld(playerid, ApartRoom[id][rInteriorVw]);
            SetPlayerInterior(playerid, ApartRoom[id][rInteriorInt]);
            SetPlayerWeather(playerid, 1);
            SetPlayerTime(playerid, 12, 0);
            PlayerData[playerid][pApartmentRoom] = ApartRoom[id][rID];
            return 1;
        }

        if ((id = ApartInt_Nearest(playerid)) != -1) {
            SetPlayerPosEx(playerid, ApartData[id][aPos][0], ApartData[id][aPos][1], ApartData[id][aPos][2]);
            SetPlayerVirtualWorld(playerid, ApartData[id][aVw]);
            SetPlayerInterior(playerid, ApartData[id][aInt]);
            SetPlayerWeather(playerid, current_weather);
            SetPlayerTime(playerid, current_hour, 0);
            PlayerData[playerid][pApartment] = -1;
            return 1;
        }

        if ((id = ApartRoomInt_Nearest(playerid)) != -1) {
            SetPlayerPosEx(playerid, ApartRoom[id][rPos][0], ApartRoom[id][rPos][1], ApartRoom[id][rPos][2]);
            SetPlayerVirtualWorld(playerid, ApartRoom[id][rVw]);
            SetPlayerInterior(playerid, ApartRoom[id][rInt]);
            SetPlayerWeather(playerid, 1);
            SetPlayerTime(playerid, 12, 0);
            PlayerData[playerid][pApartmentRoom] = -1;
            return 1;
        }
    }
    return 1;
}

// All Callbacks
Function:Apart_Load() {
    new rows = cache_num_rows();

    for (new id = 0; id < rows; id ++) {
        cache_get_value_int(id, "ID", ApartData[id][aID]);
        cache_get_value(id, "Name", ApartData[id][aName], 32);
        cache_get_value_float(id, "Pos0", ApartData[id][aPos][0]);
        cache_get_value_float(id, "Pos1", ApartData[id][aPos][1]);
        cache_get_value_float(id, "Pos2", ApartData[id][aPos][2]);
        cache_get_value_int(id, "Type", ApartData[id][aType]);
        cache_get_value_float(id, "PosInt0", ApartData[id][aIntPos][0]);
        cache_get_value_float(id, "PosInt1", ApartData[id][aIntPos][1]);
        cache_get_value_float(id, "PosInt2", ApartData[id][aIntPos][2]);
        cache_get_value_int(id, "Garage", ApartData[id][aGarage]);
        cache_get_value_float(id, "GaragePos0", ApartData[id][aGaragePos][0]);
        cache_get_value_float(id, "GaragePos1", ApartData[id][aGaragePos][1]);
        cache_get_value_float(id, "GaragePos2", ApartData[id][aGaragePos][2]);
        cache_get_value_int(id, "Vw", ApartData[id][aVw]);
        cache_get_value_int(id, "Int", ApartData[id][aInt]);
        cache_get_value_int(id, "IntVw", ApartData[id][aIntVw]);
        cache_get_value_int(id, "IntInt", ApartData[id][aIntInt]);
        Iter_Add(Aparts, id);
        Apart_Refresh(id);
    }
    printf("*** [GarudaPride Database: Loaded] apartment data loaded (%d count)", rows);
    return 1;
}

Function:OnLoadRoomStorage(id) {
    new
        rows = cache_num_rows(),
        str[32];

    for (new i = 0; i != rows; i ++) if(!RoomStorage[id][i][rItemExists]) {
        RoomStorage[id][i][rItemExists] = true;
        cache_get_value_int(i, "itemID", RoomStorage[id][i][rItemID]);
        cache_get_value_int(i, "itemModel", RoomStorage[id][i][rItemModel]);
        cache_get_value_int(i, "itemQuantity", RoomStorage[id][i][rItemQuantity]);

        cache_get_value(i, "itemName", str, sizeof(str));
        strpack(RoomStorage[id][i][rItemName], str, 32 char);
    }
    return 1;
}

Function:OnRoomLoadWeapon(roomid)
{
    new
        rows = cache_num_rows();

    for (new i = 0; i != rows; i ++) {
        cache_get_value_int(i, "weaponid", ApartRoom[roomid][rWeapon][i]);
        cache_get_value_int(i, "ammo", ApartRoom[roomid][rAmmo][i]);
        cache_get_value_int(i, "durability", ApartRoom[roomid][rDurability][i]);
    }
    return 1;
}

Function:OnRoomStorageAdd(roomid, itemid)
{
    RoomStorage[roomid][itemid][rItemID] = cache_insert_id();
    return 1;
}

Function:ApartRoom_Load() {
    new rows = cache_num_rows(), str[512];

    for (new i = 0; i < rows; i ++) {
        Iter_Add(ApartRooms, i);
        cache_get_value_int(i, "ID", ApartRoom[i][rID]);
        cache_get_value_int(i, "ApartID", ApartRoom[i][rApartID]);
        cache_get_value_int(i, "Owner", ApartRoom[i][rOwner]);
        cache_get_value(i, "OwnerName", ApartRoom[i][rOwnerName], MAX_PLAYER_NAME);
        cache_get_value_int(i, "Duration", ApartRoom[i][rDuration]);
        cache_get_value_int(i, "Price", ApartRoom[i][rPrice]);
        cache_get_value_int(i, "Vw", ApartRoom[i][rVw]);
        cache_get_value_int(i, "Int", ApartRoom[i][rInt]);
        cache_get_value_int(i, "Locked", ApartRoom[i][rLocked]);
        cache_get_value_int(i, "InteriorVw", ApartRoom[i][rInteriorVw]);
        cache_get_value_int(i, "InteriorInt", ApartRoom[i][rInteriorInt]);
        cache_get_value_float(i, "Pos0", ApartRoom[i][rPos][0]);
        cache_get_value_float(i, "Pos1", ApartRoom[i][rPos][1]);
        cache_get_value_float(i, "Pos2", ApartRoom[i][rPos][2]);
        cache_get_value_float(i, "PosInt0", ApartRoom[i][rPosInt][0]);
        cache_get_value_float(i, "PosInt1", ApartRoom[i][rPosInt][1]);
        cache_get_value_float(i, "PosInt2", ApartRoom[i][rPosInt][2]);
        cache_get_value_int(i, "Money", ApartRoom[i][rMoney]);
        ApartRoom_Refresh(i);
    }

    for (new i = 0; i < MAX_APARTMENT_ROOM; i ++) if (Iter_Contains(ApartRooms, i)) {
        format(str, sizeof(str), "SELECT * FROM `apartroom_weapon` WHERE `apartroomid` = '%d' ORDER BY `id` DESC LIMIT 3", ApartRoom[i][rID]);
        mysql_tquery(g_iHandle, str, "OnRoomLoadWeapon", "d", i);

        format(str, sizeof(str), "SELECT * FROM `apartroom_storage` WHERE `ID` = '%d'", ApartRoom[i][rID]);
        mysql_tquery(g_iHandle, str, "OnLoadRoomStorage", "d", i);
    }

    printf("*** [GarudaPride Database: Loaded] apart room data loaded (%d count)", rows);
    return 1;
}

Function:OnApartCreated(id) {
    if (!Iter_Contains(Aparts, id))
        return 0;

    ApartData[id][aID] = cache_insert_id();
    Apart_Save(id);
    return 1;
}

Function:OnApartRoomCreated(id) {
    if (!Iter_Contains(ApartRooms, id))
        return 0;

    ApartRoom[id][rID] = cache_insert_id();
    ApartRoom_Save(id);
    return 1;
}

// All Function
Apart_Refresh(id) {
    if (!Iter_Contains(Aparts, id))
        return 0;

    if (IsValidDynamicPickup(ApartData[id][aPickup]))
        DestroyDynamicPickup(ApartData[id][aPickup]);

    if (IsValidDynamic3DTextLabel(ApartData[id][aLabel]))
        DestroyDynamic3DTextLabel(ApartData[id][aLabel]);

    if (IsValidDynamicCP(ApartData[id][aCP]))
        DestroyDynamicCP(ApartData[id][aCP]);

    if (IsValidDynamicCP(ApartData[id][aCPInt]))
        DestroyDynamicCP(ApartData[id][aCPInt]);

    if (IsValidDynamicPickup(ApartData[id][aPickupInt]))
        DestroyDynamicPickup(ApartData[id][aPickupInt]);

    new str[512];
    if (ApartData[id][aGarage]) {
        if (IsValidDynamicPickup(ApartData[id][aGaragePickup]))
            DestroyDynamicPickup(ApartData[id][aGaragePickup]);

        if (IsValidDynamic3DTextLabel(ApartData[id][aGarageLabel]))
            DestroyDynamic3DTextLabel(ApartData[id][aGarageLabel]);

        ApartData[id][aGaragePickup] = CreateDynamicPickup(1239, 23, ApartData[id][aGaragePos][0], ApartData[id][aGaragePos][1], ApartData[id][aGaragePos][2]);
        format(str,sizeof(str),"[Apartment Garage ID: %d]\n"YELLOW"%s", id, ApartData[id][aName]);
        ApartData[id][aGarageLabel] = CreateDynamic3DTextLabel(str, X11_SKY_BLUE, ApartData[id][aGaragePos][0], ApartData[id][aGaragePos][1], ApartData[id][aGaragePos][2]+1, 20.0);
    }

    format(str,sizeof(str),"[Apartment ID: %d]\n"YELLOW"%s\n"WHITE"Type: "YELLOW"%s\n"WHITE"Press "YELLOW"H "WHITE"to enter/exit", id, ApartData[id][aName], GetApartType(id));
    ApartData[id][aPickup] = CreateDynamicPickup(19130, 23, ApartData[id][aPos][0], ApartData[id][aPos][1], ApartData[id][aPos][2], ApartData[id][aVw], ApartData[id][aInt]);
    ApartData[id][aLabel] = CreateDynamic3DTextLabel(str, COLOR_CLIENT, ApartData[id][aPos][0], ApartData[id][aPos][1], ApartData[id][aPos][2]+1, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, ApartData[id][aVw], ApartData[id][aInt]);
    ApartData[id][aCP] = CreateDynamicCP(ApartData[id][aPos][0], ApartData[id][aPos][1], ApartData[id][aPos][2], 1.5, ApartData[id][aVw], ApartData[id][aInt], _, 3.0);
    ApartData[id][aCPInt] = CreateDynamicCP(ApartData[id][aIntPos][0], ApartData[id][aIntPos][1], ApartData[id][aIntPos][2], 1.5, ApartData[id][aIntVw], ApartData[id][aIntInt], _, 3.0);
    ApartData[id][aPickupInt] = CreateDynamicPickup(19130, 23, ApartData[id][aIntPos][0], ApartData[id][aIntPos][1], ApartData[id][aIntPos][2], ApartData[id][aIntVw], ApartData[id][aIntInt]);
    return 1;
}

ApartRoom_Refresh(id) {
    if (!Iter_Contains(ApartRooms, id))
        return 0;

    if (IsValidDynamicPickup(ApartRoom[id][rPickup]))
        DestroyDynamicPickup(ApartRoom[id][rPickup]);

    if (IsValidDynamic3DTextLabel(ApartRoom[id][rLabel]))
        DestroyDynamic3DTextLabel(ApartRoom[id][rLabel]);

    if (IsValidDynamicCP(ApartRoom[id][rCP]))
        DestroyDynamicCP(ApartRoom[id][rCP]);

    if (ApartRoom[id][rOwner] > 0) {
        ApartRoom[id][rPickup] = CreateDynamicPickup(1318, 23, ApartRoom[id][rPos][0], ApartRoom[id][rPos][1], ApartRoom[id][rPos][2], ApartRoom[id][rVw], ApartRoom[id][rInt]);
        ApartRoom[id][rLabel] = CreateDynamic3DTextLabel(sprintf("[ID: %d]\n"YELLOW"Owner: "WHITE"%s", id, ApartRoom[id][rOwnerName]), COLOR_CLIENT, ApartRoom[id][rPos][0], ApartRoom[id][rPos][1], ApartRoom[id][rPos][2]+1, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, ApartRoom[id][rVw], ApartRoom[id][rInt]);
        ApartRoom[id][rCP] = CreateDynamicCP(ApartRoom[id][rPos][0], ApartRoom[id][rPos][1], ApartRoom[id][rPos][2], 1.5, ApartRoom[id][rVw], ApartRoom[id][rInt], _, 3.0);
    } else {
        ApartRoom[id][rPickup] = CreateDynamicPickup(1273, 23, ApartRoom[id][rPos][0], ApartRoom[id][rPos][1], ApartRoom[id][rPos][2], ApartRoom[id][rVw], ApartRoom[id][rInt]);
        ApartRoom[id][rLabel] = CreateDynamic3DTextLabel(sprintf("[ID: %d]\n"YELLOW"Owner: "WHITE"None\n"YELLOW"Price: "GREEN"$%s / week", id, FormatNumber(ApartRoom[id][rPrice])), COLOR_CLIENT, ApartRoom[id][rPos][0], ApartRoom[id][rPos][1], ApartRoom[id][rPos][2]+1, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, ApartRoom[id][rVw], ApartRoom[id][rInt]);
        ApartRoom[id][rCP] = CreateDynamicCP(ApartRoom[id][rPos][0], ApartRoom[id][rPos][1], ApartRoom[id][rPos][2], 1.5, ApartRoom[id][rVw], ApartRoom[id][rInt], _, 3.0);
    }
    return 1;
}

Apart_Save(id) {
    new query[2024];

    format(query,sizeof(query),"UPDATE `aparts` SET `Name` = '%s', `Pos0` = '%f', `Pos1` = '%f', `Pos2` = '%f', `Type` = '%d', `PosInt0` = '%f', `PosInt1` = '%f', `PosInt2` = '%f', `Vw` = '%d', `Int` = '%d', `IntVw` = '%d', `IntInt` = '%d', `Garage` = '%d', `GaragePos0` = '%f', `GaragePos1` = '%f', `GaragePos2` = '%f' WHERE `ID` = '%d'",
    SQL_ReturnEscaped(ApartData[id][aName]),
    ApartData[id][aPos][0],
    ApartData[id][aPos][1],
    ApartData[id][aPos][2],
    ApartData[id][aType],
    ApartData[id][aIntPos][0],
    ApartData[id][aIntPos][1],
    ApartData[id][aIntPos][2],
    ApartData[id][aVw],
    ApartData[id][aInt],
    ApartData[id][aIntVw],
    ApartData[id][aIntInt],
    ApartData[id][aGarage],
    ApartData[id][aGaragePos][0],
    ApartData[id][aGaragePos][1],
    ApartData[id][aGaragePos][2],
    ApartData[id][aID]
    );
    return mysql_tquery(g_iHandle, query);
}

ApartRoom_Save(id) {
    new query[2024];

    format(query,sizeof(query),"UPDATE `apartrooms` SET `ApartID` = '%d', `Owner` = '%d', `OwnerName` = '%s', `Duration` = '%d', `Price` = '%d', `Vw` = '%d', `Int` = '%d', `Locked` = '%d', `InteriorVw` = '%d', `InteriorInt` = '%d', `Pos0` = '%f', `Pos1` = '%f', `Pos2` = '%f', `PosInt0` = '%f', `PosInt1` = '%f', `PosInt2` = '%f', `Money` = '%d' WHERE `ID` = '%d'",
    ApartRoom[id][rApartID],
    ApartRoom[id][rOwner],
    SQL_ReturnEscaped(ApartRoom[id][rOwnerName]),
    ApartRoom[id][rDuration],
    ApartRoom[id][rPrice],
    ApartRoom[id][rVw],
    ApartRoom[id][rInt],
    ApartRoom[id][rLocked],
    ApartRoom[id][rInteriorVw],
    ApartRoom[id][rInteriorInt],
    ApartRoom[id][rPos][0],
    ApartRoom[id][rPos][1],
    ApartRoom[id][rPos][2],
    ApartRoom[id][rPosInt][0],
    ApartRoom[id][rPosInt][1],
    ApartRoom[id][rPosInt][2],
    ApartRoom[id][rMoney],
    ApartRoom[id][rID]
    );
    return mysql_tquery(g_iHandle, query);
}

Apart_Create(playerid, type, name[]) {
    new id = INVALID_ITERATOR_SLOT;

    if ((id = Iter_Free(Aparts)) != INVALID_ITERATOR_SLOT) {
        new Float:pos[3];
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        ApartData[id][aPos][0] = pos[0];
        ApartData[id][aPos][1] = pos[1];
        ApartData[id][aPos][2] = pos[2];
        ApartData[id][aType] = type;
        ApartData[id][aIntPos][0] = 0.0;
        ApartData[id][aIntPos][1] = 0.0;
        ApartData[id][aIntPos][2] = 0.0;
        format(ApartData[id][aName], 32, name);

        Iter_Add(Aparts, id);
        Apart_Refresh(id);

        mysql_tquery(g_iHandle, sprintf("INSERT INTO `aparts` (`Type`) VALUES ('%d')", ApartData[id][aType]), "OnApartCreated", "d", id);

        return id;
    }
    return INVALID_ITERATOR_SLOT;
}

ApartRoom_Create(playerid, price) {
    new id = INVALID_ITERATOR_SLOT;

    if ((id = Iter_Free(ApartRooms)) != INVALID_ITERATOR_SLOT) {
        new Float:pos[3], apartid = -1;
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        if ((apartid = ApartInt_Nearest(playerid)) != -1) {
            ApartRoom[id][rApartID] = apartid;
        }
        ApartRoom[id][rOwner] = 0;
        format(ApartRoom[id][rOwnerName], MAX_PLAYER_NAME, "None");
        ApartRoom[id][rDuration] = 0;
        ApartRoom[id][rPrice] = price;
        ApartRoom[id][rVw] = GetPlayerVirtualWorld(playerid);
        ApartRoom[id][rInt] = GetPlayerInterior(playerid);
        ApartRoom[id][rLocked] = 1;
        ApartRoom[id][rInteriorVw] = 0;
        ApartRoom[id][rInteriorInt] = 0;
        ApartRoom[id][rPos][0] = pos[0];
        ApartRoom[id][rPos][1] = pos[1];
        ApartRoom[id][rPos][2] = pos[2];
        ApartRoom[id][rPosInt][0] = 0.0;
        ApartRoom[id][rPosInt][1] = 0.0;
        ApartRoom[id][rPosInt][2] = 0.0;
        ApartRoom[id][rMoney] = 0;

        for (new i = 0; i < 3; i ++) {
            ApartRoom[id][rWeapon][i] = 0;
            ApartRoom[id][rAmmo][i] = 0;
            ApartRoom[id][rDurability][i] = 0;
        }

        Iter_Add(ApartRooms, id);
        ApartRoom_Refresh(id);

        new query[512];
        format(query,sizeof(query),"INSERT INTO `apartrooms` (`Price`) VALUES ('%d')",ApartRoom[id][rPrice]);
        mysql_tquery(g_iHandle, query, "OnApartRoomCreated", "d", id);

        return id;
    }
    return INVALID_ITERATOR_SLOT;
}

Apart_Delete(id) {
    if (Iter_Contains(Aparts, id)) {
        Iter_Remove(Aparts, id);
        mysql_tquery(g_iHandle, sprintf("DELETE FROM `aparts` WHERE `ID` = '%d'", ApartData[id][aID]));

        DestroyDynamicPickup(ApartData[id][aPickup]);
        DestroyDynamic3DTextLabel(ApartData[id][aLabel]);
        DestroyDynamicCP(ApartData[id][aCP]);
        DestroyDynamicCP(ApartData[id][aCPInt]);
        DestroyDynamicPickup(ApartData[id][aPickupInt]);

        if (ApartData[id][aGarage]) {
            DestroyDynamicPickup(ApartData[id][aGaragePickup]);
            DestroyDynamic3DTextLabel(ApartData[id][aGarageLabel]);
            ApartData[id][aGaragePickup] = INVALID_STREAMER_ID;
            ApartData[id][aGarageLabel] = Text3D:INVALID_3DTEXT_ID;
        }

        ApartData[id][aID] = INVALID_ITERATOR_SLOT;
        ApartData[id][aPickup] = INVALID_STREAMER_ID;
        ApartData[id][aLabel] = Text3D:INVALID_3DTEXT_ID;
        ApartData[id][aCP] = INVALID_STREAMER_ID;
        ApartData[id][aCPInt] = INVALID_STREAMER_ID;
        ApartData[id][aPickupInt] = INVALID_STREAMER_ID;
        return 1;
    }
    return 0;
}

ApartRoom_Delete(id) {
    if (Iter_Contains(ApartRooms, id)) {
        Iter_Remove(ApartRooms, id);
        mysql_tquery(g_iHandle, sprintf("DELETE FROM `apartrooms` WHERE `ID` = '%d'", ApartRoom[id][rID]));

        DestroyDynamicPickup(ApartRoom[id][rPickup]);
        DestroyDynamic3DTextLabel(ApartRoom[id][rLabel]);
        DestroyDynamicCP(ApartRoom[id][rCP]);

        ApartRoom[id][rID] = INVALID_ITERATOR_SLOT;
        ApartRoom[id][rLabel] = INVALID_3DTEXT_ID;
        ApartRoom[id][rPickup] = ApartRoom[id][rCP] = INVALID_STREAMER_ID;
        return 1;
    }
    return 0;
}

Room_ShowItems(playerid, roomid)
{
    if(!Iter_Contains(ApartRooms, roomid))
        return 0;

    static
        string[MAX_ROOM_STORAGE * 32],
        name[32];

    string[0] = 0;

    for (new i = 0; i != MAX_ROOM_STORAGE; i ++)
    {
        if(!RoomStorage[roomid][i][rItemExists])
            format(string, sizeof(string), "%sEmpty Slot\n", string);

        else {
            strunpack(name, RoomStorage[roomid][i][rItemName]);

            if(RoomStorage[roomid][i][rItemQuantity] == 1) {
                format(string, sizeof(string), "%s%s\n", string, name);
            }
            else format(string, sizeof(string), "%s%s (%d)\n", string, name, RoomStorage[roomid][i][rItemQuantity]);
        }
    }
    Dialog_Show(playerid, Dialog_RoomItems, DIALOG_STYLE_LIST, "Item Storage", string, "Select", "Cancel");
    return 1;
}

Room_OpenStorage(playerid, roomid)
{
    if(!Iter_Contains(ApartRooms, roomid))
        return 0;

    new
        items[2],
        string[MAX_ROOM_STORAGE * 32];

    for (new i = 0; i < MAX_ROOM_STORAGE; i ++) if(RoomStorage[roomid][i][rItemExists]) {
        items[0]++;
    }
    for (new i = 0; i < 3; i ++) if(ApartRoom[roomid][rWeapon][i]) {
        items[1]++;
    }
    format(string, sizeof(string), "Item Storage (%d/%d)\nWeapon Storage (%d/3)\nMoney Safe ($%s)", items[0], MAX_ROOM_STORAGE, items[1], FormatNumber(ApartRoom[roomid][rMoney]));
    Dialog_Show(playerid, Dialog_RoomStorage, DIALOG_STYLE_LIST, "Room Storage", string, "Select", "Cancel");
    return 1;
}

Room_GetItemID(roomid, item[])
{
    if(!Iter_Contains(ApartRooms, roomid))
        return 0;

    for (new i = 0; i < MAX_ROOM_STORAGE; i ++)
    {
        if(!RoomStorage[roomid][i][rItemExists])
            continue;

        if(!strcmp(RoomStorage[roomid][i][rItemName], item)) return i;
    }
    return -1;
}

Room_GetFreeID(roomid)
{
    if(!Iter_Contains(ApartRooms, roomid))
        return 0;

    for (new i = 0; i < MAX_ROOM_STORAGE; i ++)
    {
        if(!RoomStorage[roomid][i][rItemExists])
        return i;
    }
    return -1;
}

Room_AddItem(roomid, item[], model, quantity = 1, slotid = -1)
{
    if(!Iter_Contains(ApartRooms, roomid))
        return 0;

    new
        itemid = Room_GetItemID(roomid, item),
        string[256];

    if(itemid == -1)
    {
        itemid = Room_GetFreeID(roomid);

        if(itemid != -1)
        {
            if(slotid != -1)
                itemid = slotid;

            RoomStorage[roomid][itemid][rItemExists] = true;
            RoomStorage[roomid][itemid][rItemModel] = model;
            RoomStorage[roomid][itemid][rItemQuantity] = quantity;

            strpack(RoomStorage[roomid][itemid][rItemName], item, 32 char);

            format(string, sizeof(string), "INSERT INTO `apartroom_storage` (`ID`, `itemName`, `itemModel`, `itemQuantity`) VALUES ('%d', '%s', '%d', '%d')", ApartRoom[roomid][rID], item, model, quantity);
            mysql_tquery(g_iHandle, string, "OnRoomStorageAdd", "dd", roomid, itemid);

            return itemid;
        }
        return -1;
    }
    else
    {
        format(string, sizeof(string), "UPDATE `apartroom_storage` SET `itemQuantity` = `itemQuantity` + %d WHERE `ID` = '%d' AND `itemID` = '%d'", quantity, ApartRoom[roomid][rID], RoomStorage[roomid][itemid][rItemID]);
        mysql_tquery(g_iHandle, string);

        RoomStorage[roomid][itemid][rItemQuantity] += quantity;
    }
    return itemid;
}

Room_RemoveItem(roomid, item[], quantity = 1)
{
    if(!Iter_Contains(ApartRooms, roomid))
        return 0;

    new
        itemid = Room_GetItemID(roomid, item),
        string[128];

    if(itemid != -1)
    {
        if(RoomStorage[roomid][itemid][rItemQuantity] > 0)
        {
            RoomStorage[roomid][itemid][rItemQuantity] -= quantity;
        }
        if(quantity == -1 || RoomStorage[roomid][itemid][rItemQuantity] < 1)
        {
            RoomStorage[roomid][itemid][rItemExists] = false;
            RoomStorage[roomid][itemid][rItemModel] = 0;
            RoomStorage[roomid][itemid][rItemQuantity] = 0;

            format(string, sizeof(string), "DELETE FROM `apartroom_storage` WHERE `ID` = '%d' AND `itemID` = '%d'", ApartRoom[roomid][rID], RoomStorage[roomid][itemid][rItemID]);
            mysql_tquery(g_iHandle, string);
        }
        else if(quantity != -1 && RoomStorage[roomid][itemid][rItemQuantity] > 0)
        {
            format(string, sizeof(string), "UPDATE `apartroom_storage` SET `itemQuantity` = `itemQuantity` - %d WHERE `ID` = '%d' AND `itemID` = '%d'", quantity, ApartRoom[roomid][rID], RoomStorage[roomid][itemid][rItemID]);
            mysql_tquery(g_iHandle, string);
        }
        return 1;
    }
    return 0;
}

Room_RemoveAllItems(roomid)
{
    for (new i = 0; i != MAX_ROOM_STORAGE; i ++) {
        RoomStorage[roomid][i][rItemExists] = false;
        RoomStorage[roomid][i][rItemModel] = 0;
        RoomStorage[roomid][i][rItemQuantity] = 0;
    }
    mysql_tquery(g_iHandle, sprintf("DELETE FROM `apartroom_storage` WHERE `ID` = '%d'", ApartRoom[roomid][rID]));

    for (new i = 0; i < 3; i ++) {
        ApartRoom[roomid][rWeapon][i] = 0;
        ApartRoom[roomid][rAmmo][i] = 0;
        ApartRoom[roomid][rDurability][i] = 0;
    }
    mysql_tquery(g_iHandle, sprintf("DELETE FROM `apartroom_weapon` WHERE `apartroomid` = '%d'", ApartRoom[roomid][rID]));
    return 1;
}

Room_WeaponStorage(playerid, roomid)
{
    if(!Iter_Contains(ApartRooms, roomid))
        return 0;

    new
        string[320];

    for (new i = 0; i < 3; i ++)
    {
        if(!ApartRoom[roomid][rWeapon][i]) format(string, sizeof(string), "%sEmpty Slot\n", string);
        else format(string, sizeof(string), "%s%s ("YELLOW"Ammo: %d"WHITE") ("CYAN"Durability: %d"WHITE")\n", string, ReturnWeaponName(ApartRoom[roomid][rWeapon][i]), ApartRoom[roomid][rAmmo][i], ApartRoom[roomid][rDurability][i]);
    }
    Dialog_Show(playerid, RoomWeapons, DIALOG_STYLE_LIST, "Weapon Storage", string, "Select", "Cancel");
    return 1;
}

Apart_Nearest(playerid) {
    for (new i = 0; i != MAX_APARTMENT; i ++) if(Iter_Contains(Aparts, i) && IsPlayerInRangeOfPoint(playerid, 2.5, ApartData[i][aPos][0], ApartData[i][aPos][1], ApartData[i][aPos][2]))
    {
        return i;
    }
    return -1;
}

ApartGarage_Nearest(playerid) {
    for (new i = 0; i != MAX_APARTMENT; i ++) if(Iter_Contains(Aparts, i) && ApartData[i][aGarage] == 1 && IsPlayerInRangeOfPoint(playerid, 5.0, ApartData[i][aGaragePos][0], ApartData[i][aGaragePos][1], ApartData[i][aGaragePos][2]))
    {
        return i;
    }
    return -1;
}

ApartInt_Nearest(playerid) {
    if(PlayerData[playerid][pApartment] != -1)
    {
        for (new i = 0; i != MAX_APARTMENT; i ++) if(Iter_Contains(Aparts, i) && ApartData[i][aID] == PlayerData[playerid][pApartment] && GetPlayerInterior(playerid) == ApartData[i][aIntInt] && GetPlayerVirtualWorld(playerid) == ApartData[i][aIntVw]) {
            return i;
        }
    }
    return -1;
}

ApartRoomInt_Nearest(playerid) {
    if(PlayerData[playerid][pApartmentRoom] != -1)
    {
        for (new i = 0; i != MAX_APARTMENT_ROOM; i ++) if(Iter_Contains(ApartRooms, i) && ApartRoom[i][rID] == PlayerData[playerid][pApartmentRoom] && GetPlayerInterior(playerid) == ApartRoom[i][rInteriorInt] && GetPlayerVirtualWorld(playerid) > 0) {
            return i;
        }
    }
    return -1;
}

ApartRoom_Nearest(playerid) {
    for (new i = 0; i != MAX_APARTMENT_ROOM; i ++) if (Iter_Contains(ApartRooms, i) && IsPlayerInRangeOfPoint(playerid, 2.5, ApartRoom[i][rPos][0], ApartRoom[i][rPos][1], ApartRoom[i][rPos][2]) && (GetPlayerVirtualWorld(playerid) == ApartRoom[i][rVw] && GetPlayerInterior(playerid) == ApartRoom[i][rInt])) {
        return i;
    }
    return -1;
}

GetApartType(id) {
    new str[32];
    switch (ApartData[id][aType]) {
        case 1: format(str,sizeof(str),"Low");
        case 2: format(str,sizeof(str),"Medium");
        case 3: format(str,sizeof(str),"High");
        default: format(str,sizeof(str),"Undefined Type");
    }
    return str;
}

ApartRoom_IsOwner(playerid, id)
{
    if(!PlayerData[playerid][pLogged] || PlayerData[playerid][pID] == -1)
        return 0;

    if((Iter_Contains(ApartRooms, id) && ApartRoom[id][rOwner] != 0) && ApartRoom[id][rOwner] == PlayerData[playerid][pID])
        return 1;

    return 0;
}

ApartRoom_GetCount(playerid)
{
    new count = 0;
    for (new i = 0; i != MAX_APARTMENT_ROOM; i ++) if(Iter_Contains(ApartRooms, i) && ApartRoom_IsOwner(playerid, i)) {
        count++;
    }
    return count;
}

CMD:apart(playerid, params[]) {
    if (CheckAdmin(playerid, 6))
        return PermissionError(playerid);

    new subparam[24], value[128];
    if (sscanf(params, "s[24]S()[128]", subparam, value)) {
        SendSyntaxMessage(playerid, "/apart [options]");
        SendClientMessage(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"create, delete, location, interior, type, name, garagepos, deletegarage, goto");
        return 1;
    }

    if (!strcmp(subparam, "create", true)) {
        new type, name[32];

        if (sscanf(value, "ds[32]", type, name))
            return SendSyntaxMessage(playerid, "/apart create [type] [name]");

        if (strlen(name) > 32)
            return SendErrorMessage(playerid, "Max character name is 32 characters!");

        if ((type > 3) || (type < 1))
            return SendErrorMessage(playerid, "Type harus diatas 3 dan 1");

        new id;
        id = Apart_Create(playerid, type, name);
        SendCustomMessage(playerid, "APARTMENT", "You've successfully created apartment ID "YELLOW"%d", id);
    } else if (!strcmp(subparam, "delete", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apart delete [apart id]");

        if (!Iter_Contains(Aparts, id))
            return SendErrorMessage(playerid, "Invalid apartment ID!");

        Apart_Delete(id);
        SendCustomMessage(playerid, "APARTMENT", "You've successfully deleted apartment ID "YELLOW"%d", id);
    } else if (!strcmp(subparam, "location", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apart location [apart id]");

        if (!Iter_Contains(Aparts, id))
            return SendErrorMessage(playerid, "Invalid apartment ID!");

        new Float:pos[3];
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        ApartData[id][aPos][0] = pos[0];
        ApartData[id][aPos][1] = pos[1];
        ApartData[id][aPos][2] = pos[2];
        ApartData[id][aVw] = GetPlayerVirtualWorld(playerid);
        ApartData[id][aInt] = GetPlayerInterior(playerid);
        Apart_Save(id);
        Apart_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've successfully changed apartment ID "YELLOW"%d "WHITE"location to your location", id);
    } else if (!strcmp(subparam, "interior", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apart interior [apart id]");

        if (!Iter_Contains(Aparts, id))
            return SendErrorMessage(playerid, "Invalid apartment ID!");

        new Float:intpos[3];
        GetPlayerPos(playerid, intpos[0], intpos[1], intpos[2]);
        ApartData[id][aIntPos][0] = intpos[0];
        ApartData[id][aIntPos][1] = intpos[1];
        ApartData[id][aIntPos][2] = intpos[2];
        ApartData[id][aIntVw] = GetPlayerVirtualWorld(playerid);
        ApartData[id][aIntInt] = GetPlayerInterior(playerid);
        Apart_Save(id);
        Apart_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've successfully changed apartment ID "YELLOW"%d "WHITE"interior to your location", id);
    } else if (!strcmp(subparam, "type", true)) {
        new id, type;
        if (sscanf(value, "dd", id, type))
            return SendSyntaxMessage(playerid, "/apart type [apart id] [type]");

        if (!Iter_Contains(Aparts, id))
            return SendErrorMessage(playerid, "Invalid apartment ID!");

        SendCustomMessage(playerid, "APARTMENT", "You've successfully changed type of apartment ID "YELLOW"%d "WHITE"from "CYAN"%s "WHITE"to "CYAN"%s", id, GetApartType(id), ((type == 1) ? ("Low") : ((type == 2) ? ("Medium") : ("High"))));
        ApartData[id][aType] = type;
        Apart_Save(id);
        Apart_Refresh(id);
    } else if (!strcmp(subparam, "name", true)) {
        new id, name[32];
        if (sscanf(value, "ds[32]", id, name))
            return SendSyntaxMessage(playerid, "/apart name [apart id] [name]");

        if (!Iter_Contains(Aparts, id))
            return SendErrorMessage(playerid, "Invalid apartment ID!");

        format(ApartData[id][aName], 32, name);
        Apart_Save(id);
        Apart_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've successfully changed name of apartment ID "YELLOW"%d", id);
    } else if (!strcmp(subparam, "garagepos", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apart garagepos [apart id]");

        if (!Iter_Contains(Aparts, id))
            return SendErrorMessage(playerid, "Invalid apartment ID!");

        new Float:pos[3];
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        ApartData[id][aGarage] = 1;
        ApartData[id][aGaragePos][0] = pos[0];
        ApartData[id][aGaragePos][1] = pos[1];
        ApartData[id][aGaragePos][2] = pos[2];
        Apart_Save(id);
        Apart_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've successfully changed garage position of apartment ID "YELLOW"%d", id);
    } else if (!strcmp(subparam, "deletegarage", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apart deletegarage [apart id]");

        if (!Iter_Contains(Aparts, id))
            return SendErrorMessage(playerid, "Invalid apartment ID!");

        ApartData[id][aGarage] = 0;
        ApartData[id][aGaragePos][0] = 0.0;
        ApartData[id][aGaragePos][1] = 0.0;
        ApartData[id][aGaragePos][2] = 0.0;
        DestroyDynamicPickup(ApartData[id][aGaragePickup]);
        DestroyDynamic3DTextLabel(ApartData[id][aGarageLabel]);
        ApartData[id][aGaragePickup] = INVALID_STREAMER_ID;
        ApartData[id][aGarageLabel] = Text3D:INVALID_3DTEXT_ID;
        Apart_Save(id);
        Apart_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've successfully deleted garage apartment ID "YELLOW"%d", id);
    } else if (!strcmp(subparam, "goto", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apart goto [apart id]");

        if (!Iter_Contains(Aparts, id))
            return SendErrorMessage(playerid, "Invalid apartment ID!");

        SetPlayerPosEx(playerid, ApartData[id][aPos][0], ApartData[id][aPos][1], ApartData[id][aPos][2]);
        SetPlayerInterior(playerid, ApartData[id][aInt]);
        SetPlayerVirtualWorld(playerid, ApartData[id][aVw]);

        SendCustomMessage(playerid, "TELEPORT", "You've been teleported to Apartment ID: "YELLOW"%d", id);
    } else {
        SendSyntaxMessage(playerid, "/apart [options]");
        SendClientMessage(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"create, delete, location, interior, type, name, garagepos, deletegarage, goto");
    }
    return 1;
}

CMD:apartroom(playerid, params[]) {
    if (CheckAdmin(playerid, 6))
        return PermissionError(playerid);

    new subparam[24], value[128];
    if (sscanf(params, "s[24]S()[128]", subparam, value)) {
        SendSyntaxMessage(playerid, "/apartroom [options]");
        SendClientMessage(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"create, delete, location, interior, price, resetowner, lock, apartid, goto");
        return 1;
    }

    if (!strcmp(subparam, "create", true)) {
        new price;
        if (sscanf(value, "d", price))
            return SendSyntaxMessage(playerid, "/apartroom create [price]");

        new id;

        id = ApartRoom_Create(playerid, price);

        if (id == INVALID_ITERATOR_SLOT)
            return SendErrorMessage(playerid, "Cannot create more Apartment Room!");

        SendCustomMessage(playerid, "APARTMENT", "Room has been created successfully with ID "YELLOW"%d", id);
    } else if (!strcmp(subparam, "delete", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apartroom delete [apartroom id]");

        if (!Iter_Contains(ApartRooms, id))
            return SendErrorMessage(playerid, "Invalid Apartroom ID!");

        ApartRoom_Delete(id);
        SendCustomMessage(playerid, "APARTMENT", "Room ID "YELLOW"%d "WHITE"has been successfully deleted!", id);
    } else if (!strcmp(subparam, "location", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apartroom location [apartroom id]");

        if (!Iter_Contains(ApartRooms, id))
            return SendErrorMessage(playerid, "Invalid Apartroom ID!");

        new Float:pos[3];
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        ApartRoom[id][rPos][0] = pos[0];
        ApartRoom[id][rPos][1] = pos[1];
        ApartRoom[id][rPos][2] = pos[2];
        ApartRoom[id][rVw] = GetPlayerVirtualWorld(playerid);
        ApartRoom[id][rInt] = GetPlayerInterior(playerid);

        ApartRoom_Save(id);
        ApartRoom_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've been changed location of Apartment Room ID "YELLOW"%d "WHITE"to your current location", id);
    } else if (!strcmp(subparam, "interior", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apartroom interior [apartroom id]");

        if (!Iter_Contains(ApartRooms, id))
            return SendErrorMessage(playerid, "Invalid Apartroom ID!");

        new Float:pos[3];
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        ApartRoom[id][rPosInt][0] = pos[0];
        ApartRoom[id][rPosInt][1] = pos[1];
        ApartRoom[id][rPosInt][2] = pos[2];
        ApartRoom[id][rInteriorVw] = id+1;
        ApartRoom[id][rInteriorInt] = GetPlayerInterior(playerid);

        ApartRoom_Save(id);
        ApartRoom_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've been changed interior of Apartment Room ID "YELLOW"%d "WHITE"to your current interior", id);
    } else if (!strcmp(subparam, "price", true)) {
        new id, newprice;
        if (sscanf(value, "dd", id, newprice))
            return SendSyntaxMessage(playerid, "/apartroom price [apartroom id] [new price]");

        if (!Iter_Contains(ApartRooms, id))
            return SendErrorMessage(playerid, "Invalid Apartroom ID!");

        ApartRoom[id][rPrice] = newprice;

        ApartRoom_Save(id);
        ApartRoom_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've been changed price of Apartment Room ID "YELLOW"%d "WHITE"to "GREEN"$%s", id, FormatNumber(newprice));
    } else if (!strcmp(subparam, "resetowner", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apartroom resetowner [apartroom id]");

        if (!Iter_Contains(ApartRooms, id))
            return SendErrorMessage(playerid, "Invalid Apartroom ID!");

        ApartRoom[id][rOwner] = 0;
        format(ApartRoom[id][rOwnerName], MAX_PLAYER_NAME, "None");
        ApartRoom[id][rDuration] = 0;

        ApartRoom_Save(id);
        ApartRoom_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've been reseted owner of Apartment Room ID "YELLOW"%d", id);
    } else if (!strcmp(subparam, "lock", true)) {
        new id, status;
        if (sscanf(value, "dd", id, status))
            return SendSyntaxMessage(playerid, "/apartroom lock [apartroom id] [0 = unlock, 1 = locked]");

        if (!Iter_Contains(ApartRooms, id))
            return SendErrorMessage(playerid, "Invalid Apartroom ID!");

        if (status > 1 || status < 0)
            return SendErrorMessage(playerid, "Status must be 0 or 1");

        ApartRoom[id][rLocked] = status;

        ApartRoom_Save(id);
        ApartRoom_Refresh(id);

        SendCustomMessage(playerid, "APARTMENT", "You've been %s Apartment Room ID "YELLOW"%d", (status) ? (RED"locked"WHITE) : (GREEN"unlocked"WHITE), id);
    } else if (!strcmp(subparam, "apartid", true)) {
        new id, apartid;
        if (sscanf(value, "dd", id, apartid))
            return SendSyntaxMessage(playerid, "/apartroom apartid [apartroom id] [apart id]");

        if (!Iter_Contains(ApartRooms, id))
            return SendErrorMessage(playerid, "Invalid Apartroom ID!");

        ApartRoom[id][rApartID] = apartid;
        ApartRoom_Save(id);

        SendCustomMessage(playerid, "APARTMENT", "You've been changed apart id of Apartment Room ID "YELLOW"%d", id);
    } else if (!strcmp(subparam, "goto", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/apartroom goto [apartroom id]");

        if (!Iter_Contains(ApartRooms, id))
            return SendErrorMessage(playerid, "Invalid Apartroom ID!");

        SetPlayerPosEx(playerid, ApartRoom[id][rPos][0], ApartRoom[id][rPos][1], ApartRoom[id][rPos][2]);
        SetPlayerInterior(playerid, ApartRoom[id][rInt]);
        SetPlayerVirtualWorld(playerid, ApartRoom[id][rVw]);

        SendCustomMessage(playerid, "TELEPORT", "You've been teleported to Apartment Room ID: "YELLOW"%d", id);
    } else {
        SendSyntaxMessage(playerid, "/apartroom [options]");
        SendClientMessage(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"create, delete, location, interior, price, resetowner, lock, apartid, goto");
    }
    return 1;
}

CMD:rentroom(playerid, params[]) {
    static
        id = -1;

    if ((id = ApartRoom_Nearest(playerid)) == -1)
        return SendErrorMessage(playerid, "You're not near in any Apartment Room!");

    if (ApartRoom_GetCount(playerid) >= MAX_OWNED_APARTMENT)
        return SendErrorMessage(playerid, "Maximal for rented the Apartment Room is %d", MAX_OWNED_APARTMENT);

    if ((id = ApartRoom_Nearest(playerid)) != -1) {
        if (ApartRoom[id][rOwner] != 0)
            return SendErrorMessage(playerid, "This room has already rented to other players");

        if (GetMoney(playerid) < ApartRoom[id][rPrice])
            return SendErrorMessage(playerid, "You don't have enough money for rented this Apartment Room");

        Dialog_Show(playerid, Dialog_RentRoom, DIALOG_STYLE_INPUT, "Rent Room", WHITE"Please input the number of week you want to rented this room: "GREEN"(input below)", "Rent", "Cancel");
    }
    return 1;
}

CMD:rlock(playerid, params[]) {
    static
        id = -1;

    if ((id = ApartRoom_Nearest(playerid)) != -1 || (id = ApartRoomInt_Nearest(playerid)) != -1) {
        if (ApartRoom_IsOwner(playerid, id)) {
            ApartRoom[id][rLocked] = ApartRoom[id][rLocked] ? 0 : 1;
            GameTextForPlayer(playerid, sprintf("~w~Room %s", (ApartRoom[id][rLocked]) ? ("~r~Locked") : ("~g~Unlocked")), 1000, 3);
        } else SendErrorMessage(playerid, "You don't have permission to lock or unlock this Apartment Room");
    } else SendErrorMessage(playerid, "You're not near in any exterior or interior of Apartment Room");
    return 1;
}

CMD:rm(playerid, params[])
    return cmd_roommenu(playerid, "\0");

CMD:roommenu(playerid, params[]) {
    new id = -1, text[512];

    if ((id = ApartRoomInt_Nearest(playerid)) != -1) {
        if (ApartRoom_IsOwner(playerid, id)) {
            strcat(text, sprintf("%s Room\nRoom Storage\nStop Rent Room\nRent Duration\nTransfer Rent", (ApartRoom[id][rLocked]) ? ("Unlock") : ("Lock")));
            Dialog_Show(playerid, Dialog_RoomMenu, DIALOG_STYLE_LIST, "Room Menu", text, "Select", "Cancel");
        } else SendErrorMessage(playerid, "You must on inside your Apartment Room");
    } else SendErrorMessage(playerid, "You're not in any inside of Apartment Room");

    return 1;
}

CMD:storeveh(playerid, params[]) {
    static
        vehicleid = -1,
        id = -1;
    
    if (!IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendErrorMessage(playerid, "You need to be driver to use this command!");

    if ((id = ApartGarage_Nearest(playerid)) != -1) {
        if ((vehicleid = Vehicle_GetID(GetPlayerVehicleID(playerid))) != -1) {
            if (PlayerData[playerid][pOwnedApartment] != id) return SendErrorMessage(playerid, "You're not rent any room on this Apartment");
            if (!Vehicle_IsOwner(playerid, vehicleid)) return SendErrorMessage(playerid, "This is not your vehicle.");
            if (IsAPlane(GetPlayerVehicleID(playerid)) || IsAHelicopter(GetPlayerVehicleID(playerid))) return SendErrorMessage(playerid, "Can't loaded this vehicle.");

            foreach (new carid : DynamicVehicles) if (Vehicle_IsOwner(playerid, carid)) {
                if (VehicleData[carid][cGarageApart] == ApartData[id][aID]) return SendErrorMessage(playerid, "Only one car can stored into Apartment Garage");
            }

            VehicleData[vehicleid][cGarageApart] = ApartData[id][aID];

            GetVehiclePos(VehicleData[vehicleid][cVehicle], VehicleData[vehicleid][cPos][0], VehicleData[vehicleid][cPos][1], VehicleData[vehicleid][cPos][2]);
            if (VehicleData[vehicleid][cNeon]) VehicleData[vehicleid][cNeonToggle] = 0;
            ReloadVehicleNeon(vehicleid);

            for (new slot = 0; slot < MAX_VEHICLE_OBJECT+5; slot ++) if (VehicleObjects[vehicleid][slot][object_exists]) {
                if(IsValidDynamicObject(VehicleObjects[vehicleid][slot][object_streamer]))
                    DestroyDynamicObject(VehicleObjects[vehicleid][slot][object_streamer]);

                VehicleObjects[vehicleid][slot][object_streamer] = INVALID_STREAMER_ID;
            }

            Vehicle_Save(vehicleid);
            
            if (IsValidVehicle(VehicleData[vehicleid][cVehicle]))
                DestroyVehicle(VehicleData[vehicleid][cVehicle]);

            VehicleData[vehicleid][cVehicle] = INVALID_VEHICLE_ID;
        }
        return 1;
    }

    if ((id = Flat_NearestGarage(playerid)) != -1) {
        if ((vehicleid = Vehicle_GetID(GetPlayerVehicleID(playerid))) != -1) {
            if (!FlatRoom_IsOwnerByFlat(playerid, id)) return SendErrorMessage(playerid, "You're not owned any room on this Flat");
            if (!Vehicle_IsOwner(playerid, vehicleid)) return SendErrorMessage(playerid, "This is not your vehicle.");
            if (IsAPlane(GetPlayerVehicleID(playerid)) || IsAHelicopter(GetPlayerVehicleID(playerid))) return SendErrorMessage(playerid, "Can't loaded this vehicle.");

            foreach (new carid : DynamicVehicles) if (Vehicle_IsOwner(playerid, carid)) {
                if (VehicleData[carid][cGarageFlat] == FlatData[id][flatID]) return SendErrorMessage(playerid, "Only one car can stored into Flat Garage");
            }

            VehicleData[vehicleid][cGarageFlat] = FlatData[id][flatID];

            GetVehiclePos(VehicleData[vehicleid][cVehicle], VehicleData[vehicleid][cPos][0], VehicleData[vehicleid][cPos][1], VehicleData[vehicleid][cPos][2]);
            if (VehicleData[vehicleid][cNeon]) VehicleData[vehicleid][cNeonToggle] = 0;
            ReloadVehicleNeon(vehicleid);

            for (new slot = 0; slot < MAX_VEHICLE_OBJECT+5; slot ++) if (VehicleObjects[vehicleid][slot][object_exists]) {
                if(IsValidDynamicObject(VehicleObjects[vehicleid][slot][object_streamer]))
                    DestroyDynamicObject(VehicleObjects[vehicleid][slot][object_streamer]);

                VehicleObjects[vehicleid][slot][object_streamer] = INVALID_STREAMER_ID;
            }

            Vehicle_Save(vehicleid);
            
            if (IsValidVehicle(VehicleData[vehicleid][cVehicle]))
                DestroyVehicle(VehicleData[vehicleid][cVehicle]);

            VehicleData[vehicleid][cVehicle] = INVALID_VEHICLE_ID;
        }
        return 1;
    }
    SendErrorMessage(playerid, "You're not nearest in any garage");
    return 1;
}

CMD:takeveh(playerid, params[]) {
    static
        id = -1;
    
    if (IsPlayerInAnyVehicle(playerid))
        return SendErrorMessage(playerid, "You need to be on foot to use this command!");

    if (PlayerData[playerid][pVipTime] > 0 && PlayerData[playerid][pVip] == 3) {
        if(Vehicle_GetCount(playerid) >= MAX_PLAYER_VEHICLE+1)
            return SendErrorMessage(playerid, "You vehicle slot is full!");
    } else if (PlayerData[playerid][pVipTime] > 0 && PlayerData[playerid][pVip] == 4) {
        if(Vehicle_GetCount(playerid) >= MAX_PLAYER_VEHICLE+2)
            return SendErrorMessage(playerid, "You vehicle slot is full!");
    } else {
        if(Vehicle_GetCount(playerid) >= MAX_PLAYER_VEHICLE)
            return SendErrorMessage(playerid, "You vehicle slot is full!");
    }

    if ((id = ApartGarage_Nearest(playerid)) != -1) {
        if (PlayerData[playerid][pOwnedApartment] != id) return SendErrorMessage(playerid, "You're not rent any room on this Apartment");

        new text[300], count = 0;

        format(text,sizeof(text),"Model\tInsurance\n");
        foreach (new vehicleid : DynamicVehicles) if (VehicleData[vehicleid][cGarageApart] == ApartData[id][aID] && Vehicle_IsOwner(playerid, vehicleid)) {
            format(text,sizeof(text),"%s%s\t%d\n",text,GetVehicleNameByModel(VehicleData[vehicleid][cModel]),VehicleData[vehicleid][cInsurance]);
            ListedVehicles[playerid][count++] = vehicleid;
        }
        if (count) Dialog_Show(playerid, TakeVeh, DIALOG_STYLE_TABLIST_HEADERS, "Take Car", text, "Take", "Cancel");
        else SendErrorMessage(playerid, "There are nothing vehicle in here.");
        return 1;
    }

    if ((id = Flat_NearestGarage(playerid)) != -1) {
        if (!FlatRoom_IsOwnerByFlat(playerid, id)) return SendErrorMessage(playerid, "You're not owned any room on this Flat");

        new text[300], count = 0;

        format(text,sizeof(text),"Model\tInsurance\n");
        foreach (new vehicleid : DynamicVehicles) if (VehicleData[vehicleid][cGarageFlat] == FlatData[id][flatID] && Vehicle_IsOwner(playerid, vehicleid)) {
            format(text,sizeof(text),"%s%s\t%d\n",text,GetVehicleNameByModel(VehicleData[vehicleid][cModel]),VehicleData[vehicleid][cInsurance]);
            ListedVehicles[playerid][count++] = vehicleid;
        }
        if (count) Dialog_Show(playerid, TakeVeh, DIALOG_STYLE_TABLIST_HEADERS, "Take Car", text, "Take", "Cancel");
        else SendErrorMessage(playerid, "There are nothing vehicle in here.");
        return 1;
    }
    SendErrorMessage(playerid, "You must to be near in any Garage");
    return 1;
}

CMD:switchveh(playerid, params[]) {
    static
        id = -1;

    if (!IsPlayerInAnyVehicle(playerid))
		return SendErrorMessage(playerid, "You need to be in any vehicle to use this command!");

    if ((id = ApartGarage_Nearest(playerid)) != -1) {
        if (PlayerData[playerid][pOwnedApartment] != id) return SendErrorMessage(playerid, "You're not rent any room on this Apartment");

        new text[300], count = 0;

        format(text,sizeof(text),"Model\tInsurance\n");
        foreach (new vehicleid : DynamicVehicles) if (VehicleData[vehicleid][cGarageApart] == ApartData[id][aID] && Vehicle_IsOwner(playerid, vehicleid)) {
            format(text,sizeof(text),"%s%s\t%d\n",text,GetVehicleNameByModel(VehicleData[vehicleid][cModel]),VehicleData[vehicleid][cInsurance]);
            ListedVehicles[playerid][count++] = vehicleid;
        }
        if (count) Dialog_Show(playerid, SwitchVeh, DIALOG_STYLE_TABLIST_HEADERS, "Switch Veh", text, "Switch", "Cancel");
        else SendErrorMessage(playerid, "There are nothing vehicle in here.");
        return 1;
    }

    if ((id = Flat_NearestGarage(playerid)) != -1) {
        if (!FlatRoom_IsOwnerByFlat(playerid, id)) return SendErrorMessage(playerid, "You're not owned any room on this Flat");

        new text[300], count = 0;

        format(text,sizeof(text),"Model\tInsurance\n");
        foreach (new vehicleid : DynamicVehicles) if (VehicleData[vehicleid][cGarageFlat] == FlatData[id][flatID] && Vehicle_IsOwner(playerid, vehicleid)) {
            format(text,sizeof(text),"%s%s\t%d\n",text,GetVehicleNameByModel(VehicleData[vehicleid][cModel]),VehicleData[vehicleid][cInsurance]);
            ListedVehicles[playerid][count++] = vehicleid;
        }
        if (count) Dialog_Show(playerid, SwitchVeh, DIALOG_STYLE_TABLIST_HEADERS, "Switch Car", text, "Take", "Cancel");
        else SendErrorMessage(playerid, "There are nothing vehicle in here.");
        return 1;
    }
    SendErrorMessage(playerid, "You must to be near in any Garage");
    return 1;
}

Dialog:Dialog_RentRoom(playerid, response, listitem, inputtext[]) {
    if (response) {
        static
            id = -1;

        if ((id = ApartRoom_Nearest(playerid)) != -1) {
            if (isnull(inputtext))
                return Dialog_Show(playerid, Dialog_RentRoom, DIALOG_STYLE_INPUT, "Rent Room", WHITE"Please input the number of week you want to rented this room: "GREEN"(input below)", "Rent", "Cancel");

            if (strval(inputtext) < 1 || strval(inputtext) > 4)
                return SendErrorMessage(playerid, "Cannot rented Apartment Room below 1 week and more than 4 weeks");

            new week = (strval(inputtext)*7),
                price = ApartRoom[id][rPrice]*strval(inputtext);

            if (GetMoney(playerid) < price)
                return SendErrorMessage(playerid, "You don't have enough money for rented this Apartment Room");

            ApartRoom[id][rOwner] = PlayerData[playerid][pID];
            ApartRoom[id][rDuration] = (gettime()+((24*3600)*week));
            PlayerData[playerid][pOwnedApartment] = ApartRoom[id][rApartID];
            format(ApartRoom[id][rOwnerName], MAX_PLAYER_NAME, "%s", NormalName(playerid));
            ApartRoom_Save(id);
            ApartRoom_Refresh(id);
            GiveMoney(playerid, -price);

            SendCustomMessage(playerid, "APARTMENT", "You've been rented this room for "GREEN"$%s "WHITE"until "YELLOW"%s", FormatNumber(price), ConvertTimestamp(Time:ApartRoom[id][rDuration]));
            return 1;
        }
    }
    return 1;
}

Dialog:Dialog_RoomMenu(playerid, response, listitem, inputtext[]) {
    new
        roomid,
        text[512];

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && ApartRoom_IsOwner(playerid, roomid)) {
        if (response) {
            switch (listitem) {
                case 0: {
                    cmd_rlock(playerid, "\0");
                    strcat(text, sprintf("%s Room\nRoom Storage\nStop Rent Room\nRent Duration", (ApartRoom[roomid][rLocked]) ? ("Unlock") : ("Lock")));
                    Dialog_Show(playerid, Dialog_RoomMenu, DIALOG_STYLE_LIST, "Room Menu", text, "Select", "Cancel");
                }
                case 1: {
                    Room_OpenStorage(playerid, roomid);
                }
                case 2: {
                    Dialog_Show(playerid, Dialog_StopRent, DIALOG_STYLE_MSGBOX, "Stop Rent Room", WHITE"Are you sure want to stoped this rent room?", "Yes", "Cancel");
                }
                case 3: {
                    SendCustomMessage(playerid, "APARTMENT", "Your Apartment Room will be expire on "GREEN"%s", ConvertTimestamp(Time:ApartRoom[roomid][rDuration]));
                    strcat(text, sprintf("%s Room\nRoom Storage\nStop Rent Room\nRent Duration", (ApartRoom[roomid][rLocked]) ? ("Unlock") : ("Lock")));
                    Dialog_Show(playerid, Dialog_RoomMenu, DIALOG_STYLE_LIST, "Room Menu", text, "Select", "Cancel");
                }
                case 4: {
                    Dialog_Show(playerid, Dialog_TransferRent, DIALOG_STYLE_INPUT, "Room Transfer", "Please input the playerid or name wish your want to transfer: "GREEN"(input below)", "Transfer", "Cancel");
                }
            }
        }
    }
    return 1;
}

Dialog:Dialog_TransferRent(playerid, response, listitem, inputtext[]) {
    if (response) {
        new userid, apartid = PlayerData[playerid][pOwnedApartment], roomid = PlayerData[playerid][pApartmentRoom];
        if (isnull(inputtext))
            return Dialog_Show(playerid, Dialog_TransferRent, DIALOG_STYLE_INPUT, "Room Transfer", "Please input the playerid or name wish you want to transfer: "GREEN"(input below)", "Transfer", "Cancel");
            
        if (sscanf(inputtext, "u", userid))
            return Dialog_Show(playerid, Dialog_TransferRent, DIALOG_STYLE_INPUT, "Room Transfer", "Please input the playerid or name wish you want to transfer: "GREEN"(input below)", "Transfer", "Cancel");

        if(userid == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, userid, 3.0)) return SendErrorMessage(playerid, "That player is disconnected or not near you.");
        if(userid == playerid) return SendErrorMessage(playerid, "You can't transfer to yourself.");

        foreach (new vehicleid : DynamicVehicles) if (VehicleData[vehicleid][cGarageApart] == ApartData[apartid][aID] && Vehicle_IsOwner(playerid, vehicleid)) return SendErrorMessage(playerid, "Please take your vehicle on apartment garage before your transfer this room.");

        if (ApartRoom_GetCount(userid) >= 1)
            return SendErrorMessage(playerid, "That player is already owned the apartment room!");

        ApartRoom[roomid][rOwner] = PlayerData[userid][pID];
        PlayerData[userid][pOwnedApartment] = ApartRoom[roomid][rApartID];
        PlayerData[playerid][pOwnedApartment] = -1;
        format(ApartRoom[roomid][rOwnerName], MAX_PLAYER_NAME, "%s", NormalName(userid));
        ApartRoom_Save(roomid);
        ApartRoom_Refresh(roomid);
        SendCustomMessage(playerid, "APARTMENT", "You've been transfered your apartment room to "YELLOW"%s", NormalName(userid));
        SendCustomMessage(userid, "APARTMENT", YELLOW"%s "WHITE"has been transfered his apartment room to you", NormalName(playerid));
    }
    else cmd_rm(playerid, "\1");
    return 1;
}

Dialog:Dialog_StopRent(playerid, response, listitem, inputtext[]) {
    new
        roomid;

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && ApartRoom_IsOwner(playerid, roomid)) {
        if (response) {
            ApartRoom[roomid][rOwner] = 0;
            ApartRoom[roomid][rDuration] = 0;
            format(ApartRoom[roomid][rOwnerName], MAX_PLAYER_NAME, "None");
            ApartRoom[roomid][rMoney] = 0;
            ApartRoom[roomid][rLocked] = 1;
            PlayerData[playerid][pOwnedApartment] = -1;
            Room_RemoveAllItems(roomid);
            ApartRoom_Save(roomid);
            ApartRoom_Refresh(roomid);

            SendCustomMessage(playerid, "APARTMENT", "You've been stoped for rent this room");
        }
    }

    return 1;
}

Dialog:RoomTake(playerid, response, listitem, inputtext[]) {
    new
        roomid,
        string[32];

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && (ApartRoom_IsOwner(playerid, roomid) || AccountData[playerid][pAdmin] > 5))
    {
        strunpack(string, RoomStorage[roomid][PlayerData[playerid][pStorageItem]][rItemName]);

        if(response)
        {
            new amount = strval(inputtext);

            if(amount < 1 || amount > RoomStorage[roomid][PlayerData[playerid][pStorageItem]][rItemQuantity])
                return Dialog_Show(playerid, RoomTake, DIALOG_STYLE_INPUT, "Room Take", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to take for this item:", "Take", "Back", string, RoomStorage[roomid][PlayerData[playerid][pInventoryItem]][rItemQuantity]);

            for (new i = 0; i < sizeof(g_aInventoryItems); i ++) if(!strcmp(g_aInventoryItems[i][e_InventoryItem], string, true)) {
                if((Inventory_Count(playerid, g_aInventoryItems[i][e_InventoryItem])+amount) > g_aInventoryItems[i][e_InventoryMax])
                    return Dialog_Show(playerid, RoomTake, DIALOG_STYLE_INPUT, "Room Take", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to take for this item:\n(You can take %d %s now!)", "Take", "Back", string, RoomStorage[roomid][PlayerData[playerid][pInventoryItem]][rItemQuantity], (g_aInventoryItems[i][e_InventoryMax]-Inventory_Count(playerid, g_aInventoryItems[i][e_InventoryItem])), string);
            }

            new id = Inventory_Add(playerid, string, RoomStorage[roomid][PlayerData[playerid][pStorageItem]][rItemModel], amount);

            if(id == -1)
                return SendErrorMessage(playerid, "You don't have any inventory slots left.");

            Room_RemoveItem(roomid, string, amount);
            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has taken a \"%s\" from their room storage.", ReturnName(playerid, 0), string);

            Room_ShowItems(playerid, roomid);
            Log_Write("logs/storage_log.txt", "[%s] %s has taken %d \"%s\" from room ID: %d (owner: %s).", ReturnDate(), NormalName(playerid), amount, string, roomid, (ApartRoom_IsOwner(playerid, roomid)) ? ("Yes") : ("No"));
        }
        else Room_OpenStorage(playerid, roomid);
    }
    return 1;
}

Dialog:Dialog_RoomStorage(playerid, response, listitem, inputtext[]) {
    new
        roomid = -1;

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && (ApartRoom_IsOwner(playerid, roomid) || AccountData[playerid][pAdmin] >= 3))
    {
        if(response)
        {
            if(listitem == 0) {
                Room_ShowItems(playerid, roomid);
            }
            else if(listitem == 1) {
                if(PlayerData[playerid][pScore] < 2)
                    return SendErrorMessage(playerid, "You're not allowed to access this storage if you're not level 2.");

                if (!PlayerData[playerid][pStory])
                    return SendErrorMessage(playerid, "You must have an active character story to access this option.");

                Room_WeaponStorage(playerid, roomid);
            }
            else if(listitem == 2) {
                Dialog_Show(playerid, RoomMoney, DIALOG_STYLE_LIST, "Money Safe", "Withdraw from safe\nDeposit into safe", "Select", "Back");
            }
        }
    }
    return 1;
}

Dialog:Dialog_RoomItems(playerid, response, listitem, inputtext[]) {
    new
        roomid,
        string[64];

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && (ApartRoom_IsOwner(playerid, roomid) || AccountData[playerid][pAdmin] > 5))
    {
        if(response)
        {
            if(RoomStorage[roomid][listitem][rItemExists])
            {
                PlayerData[playerid][pStorageItem] = listitem;
                PlayerData[playerid][pInventoryItem] = listitem;

                strunpack(string, RoomStorage[roomid][listitem][rItemName]);

                format(string, sizeof(string), "%s (Quantity: %d)", string, RoomStorage[roomid][listitem][rItemQuantity]);
                Dialog_Show(playerid, Room_StorageOptions, DIALOG_STYLE_LIST, string, "Take Item\nStore Item", "Select", "Back");
            }
            else {
                OpenInventory(playerid);

                PlayerData[playerid][pStorageSelect] = 4;
            }
        }
        else Room_OpenStorage(playerid, roomid);
    }
    return 1;
}

Dialog:Room_StorageOptions(playerid, response, listitem, inputtext[]) {
    new
        roomid = -1,
        itemid = -1,
        string[32];

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && (ApartRoom_IsOwner(playerid, roomid) || AccountData[playerid][pAdmin] >= 3))
    {
        itemid = PlayerData[playerid][pStorageItem];

        strunpack(string, RoomStorage[roomid][itemid][rItemName]);

        if(response)
        {
            switch (listitem)
            {
                case 0:
                {
                    if(RoomStorage[roomid][itemid][rItemQuantity] == 1)
                    {
                        if(!strcmp(string, "Backpack") && Inventory_HasItem(playerid, "Backpack"))
                            return SendErrorMessage(playerid, "You already have a backpack in your inventory.");

                        for (new i = 0; i < sizeof(g_aInventoryItems); i ++) if(!strcmp(g_aInventoryItems[i][e_InventoryItem], string, true)) {
                            if((Inventory_Count(playerid, g_aInventoryItems[i][e_InventoryItem])+1) > g_aInventoryItems[i][e_InventoryMax])
                                return SendErrorMessage(playerid, "You're limited %d for %s.", g_aInventoryItems[i][e_InventoryMax], string);
                        }

                        new id = Inventory_Add(playerid, string, RoomStorage[roomid][itemid][rItemModel], 1);

                        if(id == -1)
                            return SendErrorMessage(playerid, "You don't have any inventory slots left.");

                        Room_RemoveItem(roomid, string);
                        SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has taken a \"%s\" from their room storage.", ReturnName(playerid, 0), string);

                        Room_ShowItems(playerid, roomid);
                        Log_Write("logs/storage_log.txt", "[%s] %s has taken \"%s\" from room ID: %d.", ReturnDate(), ReturnName(playerid, 0), string, roomid);
                    }
                    else
                    {
                        Dialog_Show(playerid, RoomTake, DIALOG_STYLE_INPUT, "Room Take", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to take for this item:", "Take", "Back", string, RoomStorage[roomid][itemid][rItemQuantity]);
                    }
                }
                case 1:
                {
                    new id = Inventory_GetItemID(playerid, string);

                    if(!strcmp(string, "Backpack")) {
                        Room_ShowItems(playerid, roomid);

                        return SendErrorMessage(playerid, "You can only store one backpack in your room.");
                    }
                    else if(id == -1) {
                        Room_ShowItems(playerid, roomid);

                        return SendErrorMessage(playerid, "You don't have anymore of this item to store!");
                    }
                    else if(InventoryData[playerid][id][invQuantity] == 1)
                    {
                        Room_AddItem(roomid, string, InventoryData[playerid][id][invModel]);
                        Inventory_Remove(playerid, string);

                        SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has stored a \"%s\" into their room storage.", ReturnName(playerid, 0), string);
                        Log_Write("logs/storage_log.txt", "[%s] %s has stored \"%s\" into their room ID: %d.", ReturnDate(), ReturnName(playerid, 0), string, roomid);
                        Room_ShowItems(playerid, roomid);
                    }
                    else if(InventoryData[playerid][id][invQuantity] > 1) {
                        PlayerData[playerid][pInventoryItem] = id;

                        Dialog_Show(playerid, RoomDeposit, DIALOG_STYLE_INPUT, "Room Deposit", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to store for this item:", "Store", "Back", string, InventoryData[playerid][id][invQuantity]);
                    }
                }
            }
        }
        else
        {
            Room_ShowItems(playerid, roomid);
        }
    }
    return 1;
}

Dialog:RoomDeposit(playerid, response, listitem, inputtext[]) {
    new
        roomid,
        string[32];

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && (ApartRoom_IsOwner(playerid, roomid)))
    {
        strunpack(string, InventoryData[playerid][PlayerData[playerid][pInventoryItem]][invItem]);

        if(response)
        {
            new amount = strval(inputtext);

            if(amount < 1 || amount > InventoryData[playerid][PlayerData[playerid][pInventoryItem]][invQuantity])
                return Dialog_Show(playerid, RoomDeposit, DIALOG_STYLE_INPUT, "Room Deposit", "Item: %s (Quantity: %d)\n\nPlease enter the quantity that you wish to store for this item:", "Store", "Back", string, InventoryData[playerid][PlayerData[playerid][pInventoryItem]][invQuantity]);

            Room_AddItem(roomid, string, InventoryData[playerid][PlayerData[playerid][pInventoryItem]][invModel], amount);
            Inventory_Remove(playerid, string, amount);

            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has stored a \"%s\" into their room storage.", ReturnName(playerid, 0), string);
            Log_Write("logs/storage_log.txt", "[%s] %s has stored \"%s\" (%d) into their room ID: %d.", ReturnDate(), ReturnName(playerid, 0), string, amount, roomid);

            Room_ShowItems(playerid, roomid);
        }
        else Room_OpenStorage(playerid, roomid);
    }	
    return 1;
}

Dialog:RoomWeapons(playerid, response, listitem, inputtext[]) {
    new
        roomid;

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && (ApartRoom_IsOwner(playerid, roomid) || AccountData[playerid][pAdmin] > 5))
    {
        if(response)
        {
            if(ApartRoom[roomid][rWeapon][listitem] != 0)
            {
                if(IsPlayerDuty(playerid))
                    return SendErrorMessage(playerid, "Duty faction tidak dapat mengambil senjata.");

                if(PlayerHasWeapon(playerid, ApartRoom[roomid][rWeapon][listitem]))
                    return SendErrorMessage(playerid, "Kamu sudah memiliki senjata yang sama.");

                if(PlayerHasWeaponInSlot(playerid, ApartRoom[roomid][rWeapon][listitem]))
                    return SendErrorMessage(playerid, "Senjata ini berada satu slot dengan senjata yang kamu punya.");

                GivePlayerWeaponEx(playerid, ApartRoom[roomid][rWeapon][listitem], ApartRoom[roomid][rAmmo][listitem], ApartRoom[roomid][rDurability][listitem]);

                SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has taken a \"%s\" from their weapon storage.", ReturnName(playerid, 0), ReturnWeaponName(ApartRoom[roomid][rWeapon][listitem]));
                Log_Write("logs/storage_log.txt", "[%s] %s has taken a \"%s\" from room ID: %d (owner: %s).", ReturnDate(), NormalName(playerid), ReturnWeaponName(ApartRoom[roomid][rWeapon][listitem]), roomid, (ApartRoom_IsOwner(playerid, roomid)) ? ("Yes") : ("No"));

                mysql_tquery(g_iHandle, sprintf("DELETE FROM `apartroom_weapon` WHERE `apartroomid` = '%d' AND `ammo`='%d' AND `weaponid`='%d' AND `durability`='%d';", ApartRoom[roomid][rID], ApartRoom[roomid][rAmmo][listitem], ApartRoom[roomid][rWeapon][listitem], ApartRoom[roomid][rDurability][listitem]));

                ApartRoom[roomid][rWeapon][listitem]      = 0;
                ApartRoom[roomid][rAmmo][listitem]         = 0;
                ApartRoom[roomid][rDurability][listitem]   = 0;
                
                Room_WeaponStorage(playerid, roomid);
            }
            else
            {
                new
                    weaponid = GetWeapon(playerid),
                    ammo = ReturnWeaponAmmo(playerid, weaponid),
                    durability = ReturnWeaponDurability(playerid, weaponid);

                if(IsPlayerDuty(playerid))
                    return SendErrorMessage(playerid, "Duty faction tidak dapat menyimpan senjata.");

                if(!weaponid)
                    return SendErrorMessage(playerid, "You are not holding any weapon!");

                ApartRoom[roomid][rWeapon][listitem] = weaponid;
                ApartRoom[roomid][rAmmo][listitem] = ammo;
                ApartRoom[roomid][rDurability][listitem] = durability;

                mysql_tquery(g_iHandle, sprintf("INSERT INTO `apartroom_weapon` (`apartroomid`, `weaponid`, `ammo`, `durability`) VALUES ('%d','%d','%d','%d');", ApartRoom[roomid][rID], weaponid, ammo, durability));

                ResetWeaponID(playerid, weaponid);
                Room_WeaponStorage(playerid, roomid);
                
                SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has stored a \"%s\" into their weapon storage.", ReturnName(playerid, 0), ReturnWeaponName(weaponid));
                Log_Write("logs/storage_log.txt", "[%s] %s has stored a \"%s\" into their room ID: %d.", ReturnDate(), ReturnName(playerid, 0), ReturnWeaponName(weaponid), roomid);
            }
        }
        else Room_OpenStorage(playerid, roomid);
    }
    return 1;
}

Dialog:RoomMoney(playerid, response, listitem, inputtext[]) {
    new
        roomid;

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && ApartRoom_IsOwner(playerid, roomid) || AccountData[playerid][pAdmin] > 5)
    {
        if(response)
        {
            switch (listitem)
            {
                case 0: Dialog_Show(playerid, RoomWithdrawCash, DIALOG_STYLE_INPUT, "Withdraw from safe", "Safe Balance: $%s\n\nPlease enter how much money you wish to withdraw from the safe:", "Withdraw", "Back", FormatNumber(ApartRoom[roomid][rMoney]));
                case 1: Dialog_Show(playerid, RoomDepositCash, DIALOG_STYLE_INPUT, "Deposit into safe", "Safe Balance: $%s\n\nPlease enter how much money you wish to deposit into the safe:", "Deposit", "Back", FormatNumber(ApartRoom[roomid][rMoney]));
            }
        }
        else Room_OpenStorage(playerid, roomid);
    }
    return 1;
}

Dialog:RoomWithdrawCash(playerid, response, listitem, inputtext[]) {
    new
        roomid;

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && (ApartRoom_IsOwner(playerid, roomid) || AccountData[playerid][pAdmin] > 5))
    {
        if(response)
        {
            new amount = strval(inputtext),
	    		totalcash[25];
	    	format(totalcash, sizeof(totalcash), "%d00", amount);

            if(isnull(inputtext))
                return Dialog_Show(playerid, RoomWithdrawCash, DIALOG_STYLE_INPUT, "Withdraw from safe", "Safe Balance: $%s\n\nPlease enter how much money you wish to withdraw from the safe:", "Withdraw", "Back", FormatNumber(ApartRoom[roomid][rMoney]));

            if(strval(totalcash) < 1 || strval(totalcash) > ApartRoom[roomid][rMoney])
                return Dialog_Show(playerid, RoomWithdrawCash, DIALOG_STYLE_INPUT, "Withdraw from safe", "Error: Insufficient funds.\n\nSafe Balance: $%s\n\nPlease enter how much money you wish to withdraw from the safe:", "Withdraw", "Back", FormatNumber(ApartRoom[roomid][rMoney]));

            ApartRoom[roomid][rMoney] -= strval(totalcash);
            GiveMoney(playerid, strval(totalcash));

            ApartRoom_Save(roomid);
            Room_OpenStorage(playerid, roomid);

            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has withdrawn $%s from their room safe.", ReturnName(playerid, 0), FormatNumber(strval(totalcash)));
            Log_Write("logs/housestorage_log.txt", "[%s] %s has withdrawn \"$%s\" from their room id: %d.", ReturnDate(), ReturnName(playerid, 0), FormatNumber(strval(totalcash)), roomid);
        }
        else Dialog_Show(playerid, RoomMoney, DIALOG_STYLE_LIST, "Money Safe", "Withdraw from safe\nDeposit into safe", "Select", "Back");
    }
    return 1;
}

Dialog:RoomDepositCash(playerid, response, listitem, inputtext[]) {
    new
        roomid;

    if((roomid = ApartRoomInt_Nearest(playerid)) != -1 && ApartRoom_IsOwner(playerid, roomid))
    {
        if(response)
        {
            new amount = strval(inputtext),
	    		totalcash[25];
	    	format(totalcash, sizeof(totalcash), "%d00", amount);

            if(isnull(inputtext))
                return Dialog_Show(playerid, RoomDepositCash, DIALOG_STYLE_INPUT, "Deposit into safe", "Safe Balance: $%s\n\nPlease enter how much money you wish to deposit into the safe:", "Deposit", "Back", FormatNumber(ApartRoom[roomid][rMoney]));

            if(strval(totalcash) < 1 || strval(totalcash) > GetMoney(playerid))
                return Dialog_Show(playerid, RoomDepositCash, DIALOG_STYLE_INPUT, "Deposit into safe", "Error: Insufficient funds.\n\nSafe Balance: $%s\n\nPlease enter how much money you wish to deposit into the safe:", "Deposit", "Back", FormatNumber(ApartRoom[roomid][rMoney]));

            ApartRoom[roomid][rMoney] += strval(totalcash);
            GiveMoney(playerid, -strval(totalcash));

            ApartRoom_Save(roomid);
            Room_OpenStorage(playerid, roomid);

            SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s has deposited $%s into their room safe.", ReturnName(playerid, 0), FormatNumber(strval(totalcash)));
            Log_Write("logs/housestorage_log.txt", "[%s] %s has deposited \"$%s\" into their room id: %d.", ReturnDate(), ReturnName(playerid, 0), FormatNumber(strval(totalcash)), roomid);
        }
        else Dialog_Show(playerid, RoomMoney, DIALOG_STYLE_LIST, "Money Safe", "Withdraw from safe\nDeposit into safe", "Select", "Back");
    }
    return 1;
}

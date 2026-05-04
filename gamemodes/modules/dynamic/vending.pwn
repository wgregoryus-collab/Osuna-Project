#define MAX_VENDING     500

enum vendingData {
    vID,
    vModel,
    Float:vPos[3],
    Float:vRot[3],
    Text3D:vLabel,
    vending
};
new VendingData[MAX_VENDING][vendingData],
    Iterator:Vendings<MAX_VENDING>;

#include <YSI\y_hooks>
hook OnGameModeInitEx() {
    mysql_tquery(g_iHandle, "SELECT * FROM `vendings`", "Vending_Load", "");
    return 1;
}


hook OnGameModeExit() {
    foreach (new id : Vendings) if (Iter_Contains(Vendings, id)) {
        Vending_Save(id);
    }
    return 1;
}

Function:Vending_Load() {
    new rows = cache_num_rows();
    for (new id = 0; id < rows; id ++) {
        cache_get_value_int(id, "ID", VendingData[id][vID]);
        cache_get_value_int(id, "Model", VendingData[id][vModel]);

        cache_get_value_float(id, "Pos0", VendingData[id][vPos][0]);
        cache_get_value_float(id, "Pos1", VendingData[id][vPos][1]);
        cache_get_value_float(id, "Pos2", VendingData[id][vPos][2]);

        cache_get_value_float(id, "Rot0", VendingData[id][vRot][0]);
        cache_get_value_float(id, "Rot1", VendingData[id][vRot][1]);
        cache_get_value_float(id, "Rot2", VendingData[id][vRot][2]);

        Iter_Add(Vendings, id);
        Vending_Refresh(id);
    }
    printf("*** [GarudaPride Database: Loaded] vending machine data (%d count)", rows);
    return 1;
}

Function:OnVendingCreated(id) {
    if (!Iter_Contains(Vendings, id))
        return 0;

    VendingData[id][vID] = cache_insert_id();
    Vending_Save(id);
    return 1;
}

public OnPlayerUseVendingMachine(playerid, machineid)
{
	if (GetMoney(playerid) < 5) {
        SendErrorMessage(playerid, "You don't have enough money!");
        return 0;
    }

    GiveMoney(playerid, -5);
	return 1;
}

public OnPlayerDrinkSprunk(playerid)
{
	SetPlayerEnergy(playerid, PlayerData[playerid][pEnergy]+10);
	return 1;
}

Vending_Create(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    new id = INVALID_ITERATOR_SLOT;

    if ((id = Iter_Free(Vendings)) != INVALID_ITERATOR_SLOT) {
        VendingData[id][vModel] = modelid;
        VendingData[id][vPos][0] = x;
        VendingData[id][vPos][1] = y;
        VendingData[id][vPos][2] = z;
        VendingData[id][vRot][0] = rx;
        VendingData[id][vRot][1] = ry;
        VendingData[id][vRot][2] = rz;

        Iter_Add(Vendings, id);
        Vending_Refresh(id);

        mysql_tquery(g_iHandle, sprintf("INSERT INTO `vendings` (`Model`) VALUES ('%d')", modelid), "OnVendingCreated", "d", id);

        return id;
    }
    return INVALID_ITERATOR_SLOT;
}

Vending_Save(id) {
    new query[650];

    format(query, sizeof(query), "UPDATE `vendings` SET `Model` = '%d', `Pos0` = '%f', `Pos1` = '%f', `Pos2` = '%f', `Rot0` = '%f', `Rot1` = '%f', `Rot2` = '%f' WHERE `ID` = '%d'",
    VendingData[id][vModel],
    VendingData[id][vPos][0],
    VendingData[id][vPos][1],
    VendingData[id][vPos][2],
    VendingData[id][vRot][0],
    VendingData[id][vRot][1],
    VendingData[id][vRot][2],
    VendingData[id][vID]
    );
    return mysql_tquery(g_iHandle, query);
}

Vending_Refresh(id) {
    if (!Iter_Contains(Vendings, id))
        return 0;

    if (IsValidVendingMachine(VendingData[id][vending]))
        DestroyVendingMachine(VendingData[id][vending]);

    if (IsValidDynamic3DTextLabel(VendingData[id][vLabel]))
        DestroyDynamic3DTextLabel(VendingData[id][vLabel]);

    VendingData[id][vending] = CreateVendingMachine(VendingData[id][vModel], VendingData[id][vPos][0], VendingData[id][vPos][1], VendingData[id][vPos][2], VendingData[id][vRot][0], VendingData[id][vRot][1], VendingData[id][vRot][2]);

    VendingData[id][vLabel] = CreateDynamic3DTextLabel(sprintf("[Vending Machine ID: %d]\n"WHITE"Press '"YELLOW"F/ENTER"WHITE"' to use this vending machine.", id), COLOR_CLIENT, VendingData[id][vPos][0], VendingData[id][vPos][1], VendingData[id][vPos][2]+1, 10.0);
    return 1;
}

Vending_Destroy(id) {
    if (!Iter_Contains(Vendings, id))
        return 0;

    mysql_tquery(g_iHandle, sprintf("DELETE FROM `vendings` WHERE `ID` = '%d'", VendingData[id][vID]));
    DestroyVendingMachine(VendingData[id][vending]);

    if (IsValidDynamic3DTextLabel(VendingData[id][vLabel]))
        DestroyDynamic3DTextLabel(VendingData[id][vLabel]);

    Iter_Remove(Vendings, id);
    VendingData[id][vID] = INVALID_ITERATOR_SLOT;
    VendingData[id][vending] = INVALID_MACHINE_ID;
    return 1;
}

CMD:vending(playerid, params[]) {
    if (CheckAdmin(playerid, 5))
        return PermissionError(playerid);

    new opt[24], value[32];
    if (sscanf(params, "s[24]S()[32]", opt, value))
        return SendSyntaxMessage(playerid, "/vending [create/edit/destroy/goto]");

    if (!strcmp(opt, "create", true)) {
        new model;
        if (sscanf(value, "d", model)) {
            SendSyntaxMessage(playerid, "/vending create [modelid]");
            SendClientMessage(playerid, X11_YELLOW_1, "[MODELID]: "WHITE"956, 1776, 955, 1775, 1302, 1209, 1977");
            return 1;
        }

        new id, Float:pos[3];
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        id = Vending_Create(model, pos[0], pos[1], pos[2], 0.0, 0.0, 0.0);
        SetPlayerPos(playerid, pos[0], pos[1], pos[2]+2);
        PlayerData[playerid][pEditVending] = id;
        PlayerData[playerid][pEditingMode] = VENDING;
        EditDynamicObject(playerid, GetVendingMachineObjectID(VendingData[id][vending]));
        SendCustomMessage(playerid, "VENDING", "You've successfully created vending machine ID: "YELLOW"%d", id);
    } else if (!strcmp(opt, "edit", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/vending edit [vending machine id]");

        if (!Iter_Contains(Vendings, id))
            return SendErrorMessage(playerid, "Invalid vending machine ID!");

        if (PlayerData[playerid][pEditVending] != -1)
            return SendErrorMessage(playerid, "You're now being editing!");

        PlayerData[playerid][pEditVending] = id;
        PlayerData[playerid][pEditingMode] = VENDING;
        EditDynamicObject(playerid, GetVendingMachineObjectID(VendingData[id][vending]));
        SendCustomMessage(playerid, "VENDING", "You're now editing vending machine ID: "YELLOW"%d", id);
    } else if (!strcmp(opt, "destroy", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/vending destroy [vending machine id]");

        if (!Iter_Contains(Vendings, id))
            return SendErrorMessage(playerid, "Invalid vending machine ID!");

        Vending_Destroy(id);
        SendCustomMessage(playerid, "VENDING", "You've been destroyed vending machine ID: "YELLOW"%d", id);
    } else if (!strcmp(opt, "goto", true)) {
        new id;
        if (sscanf(value, "d", id))
            return SendSyntaxMessage(playerid, "/vending goto [vending machine id]");

        if (!Iter_Contains(Vendings, id))
            return SendErrorMessage(playerid, "Invalid vending machine ID!");

        SetPlayerPos(playerid, VendingData[id][vPos][0], VendingData[id][vPos][1], VendingData[id][vPos][2]+2);
        SendCustomMessage(playerid, "VENDING", "You've been teleported vending machine ID: "YELLOW"%d", id);
    }
    return 1;
}

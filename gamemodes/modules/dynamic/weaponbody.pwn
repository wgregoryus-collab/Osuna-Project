//Weapons on body system by GoldenLion
//Credits to BlueG & Pain123 & maddinat0r for MySQL
enum weaponSettings
{
    Float:Position[6],
    Bone,
    Hidden
};

new WeaponSettings[MAX_PLAYERS][31][weaponSettings],
    WeaponTick[MAX_PLAYERS], EditingWeapon[MAX_PLAYERS];
 
GetWeaponObjectSlot(weaponid)
{
	new objectslot;

	switch (weaponid)
	{
        case 2..15: objectslot = 5;
    	case 22..27: objectslot = 6;
		case 28..32: objectslot = 7;
		case 33..38: objectslot = 8;
	}
	return objectslot;
}
 
GetHoldingWeaponModel(weaponid) //Will only return the model of wearable weapons (22-38)
{
    new model;
   
    switch(weaponid)
    {
        case 2: model = 333;
        case 3: model = 334;
        case 4: model = 335;
        case 5: model = 336;
        case 6: model = 337;
        case 7: model = 338;
        case 8: model = 339;
        case 9: model = 341;
        case 10: model = 321;
        case 11: model = 322;
        case 12: model = 323;
        case 13: model = 324;
        case 14: model = 325;
        case 15: model = 326;
        case 22..29: model = 324 + weaponid;
        case 30: model = 355;
        case 31: model = 356;
        case 32: model = 372;
        case 33..38: model = 324 + weaponid;
    }
    return model;
}
 
IsWeaponWearable(weaponid)
    return ((weaponid >= 2 && weaponid <= 15) || (weaponid >= 22 && weaponid <= 38));
 
IsWeaponHideable(weaponid)
    return ((weaponid >= 2 && weaponid <= 15) || (weaponid >= 22 && weaponid <= 24 || weaponid == 28 || weaponid == 32));

PlayerHasWeapon2(playerid, weaponid)
{
    new weapon, ammo;
    for (new i = 0; i < MAX_WEAPON_SLOT; i ++) {
        GetPlayerWeaponData(playerid, i, weapon, ammo);
        if (weapon == weaponid && ammo) return 1;
    }
    return 0;
}
 
Function:OnWeaponsLoaded(playerid)
{
    new rows = cache_num_rows(), weaponid, index;
    if (rows) {
        for (new i; i < rows; i++)
        {
            cache_get_value_int(i, "WeaponID", weaponid);
            index = (weaponid >= 22 && weaponid <= 38) ? (weaponid - 22) : (weaponid + 15);
        
            cache_get_value_float(i, "PosX", WeaponSettings[playerid][index][Position][0]);
            cache_get_value_float(i, "PosY", WeaponSettings[playerid][index][Position][1]);
            cache_get_value_float(i, "PosZ", WeaponSettings[playerid][index][Position][2]);
        
            cache_get_value_float(i, "RotX", WeaponSettings[playerid][index][Position][3]);
            cache_get_value_float(i, "RotY", WeaponSettings[playerid][index][Position][4]);
            cache_get_value_float(i, "RotZ", WeaponSettings[playerid][index][Position][5]);
        
            cache_get_value_int(i, "Bone", WeaponSettings[playerid][index][Bone]);
            cache_get_value_int(i, "Hidden", WeaponSettings[playerid][index][Hidden]);
        }
    } else {
        for (new i = 0; i < 31; i++)
        {
            WeaponSettings[playerid][i][Position][0] = -0.116;
            WeaponSettings[playerid][i][Position][1] = 0.189;
            WeaponSettings[playerid][i][Position][2] = 0.088;
            WeaponSettings[playerid][i][Position][3] = 0.0;
            WeaponSettings[playerid][i][Position][4] = 44.5;
            WeaponSettings[playerid][i][Position][5] = 0.0;
            WeaponSettings[playerid][i][Bone] = 1;
            WeaponSettings[playerid][i][Hidden] = false;
        }
    }
}

#include <YSI\y_hooks>
hook OnPlayerUpdate(playerid)
{
    if (NetStats_GetConnectedTime(playerid) - WeaponTick[playerid] >= 250)
    {
        new weaponid, ammo, objectslot, count, index;
 
        for (new i = 1; i <= 12; i++) //Loop only through the slots that may contain the wearable weapons
        {
            GetPlayerWeaponData(playerid, i, weaponid, ammo);
            if (weaponid && ammo) {
                if (weaponid >= 22 && weaponid <= 38) index = weaponid - 22;
                else if (weaponid >= 2 && weaponid <= 15) index = weaponid + 15;

                if (!WeaponSettings[playerid][index][Hidden] && IsWeaponWearable(weaponid) && EditingWeapon[playerid] != weaponid)
                {
                    objectslot = GetWeaponObjectSlot(weaponid);
    
                    if (GetPlayerWeapon(playerid) != weaponid) {
                        if (!IsPlayerInEvent(playerid)) {
                            SetPlayerAttachedObject(playerid, objectslot, GetHoldingWeaponModel(weaponid), WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], 1.0, 1.0, 1.0);
                        }
                    }
    
                    else if (IsPlayerAttachedObjectSlotUsed(playerid, objectslot)) RemovePlayerAttachedObject(playerid, objectslot);
                }
            }
        }
        for (new i = 5; i <= 8; i++) if (IsPlayerAttachedObjectSlotUsed(playerid, i))
        {
            count = 0;
 
            for (new j = 2; j <= 38; j ++) if (PlayerHasWeapon2(playerid, j) && GetWeaponObjectSlot(j) == i) {
                count++;
            }
 
            if (!count) RemovePlayerAttachedObject(playerid, i);
        }
        WeaponTick[playerid] = NetStats_GetConnectedTime(playerid);
    }
    return 1;
}


hook OnPlayerSpawn(playerid)
{
    new string[70];
   
    WeaponTick[playerid] = 0;
	EditingWeapon[playerid] = 0;
   
    mysql_format(g_iHandle, string, sizeof(string), "SELECT * FROM weaponsettings WHERE Userid = '%d'", GetPlayerSQLID(playerid));
    mysql_tquery(g_iHandle, string, "OnWeaponsLoaded", "d", playerid);
    return 1;
}

Dialog:DIALOG_EDIT_BONE(playerid, response, listitem, inputtext[]) {
    if (response)
    {
        new weaponid = EditingWeapon[playerid], weaponname[18], string[150];
        new index = (weaponid >= 22 && weaponid <= 38) ? (weaponid - 22) : (weaponid + 15);

        GetWeaponName(weaponid, weaponname, sizeof(weaponname));
        
        WeaponSettings[playerid][index][Bone] = listitem + 1;

        format(string, sizeof(string), "You have successfully changed the bone of your %s.", weaponname);
        SendCustomMessage(playerid, "WEAPON", "%s", string);
        
        mysql_format(g_iHandle, string, sizeof(string), "INSERT INTO weaponsettings VALUES (%d, %d, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %d, %d) ON DUPLICATE KEY UPDATE `Bone` = %d", GetPlayerSQLID(playerid), weaponid, WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Hidden], WeaponSettings[playerid][index][Bone]);
        mysql_tquery(g_iHandle, string);
        EditingWeapon[playerid] = 0;
    } else EditingWeapon[playerid] = 0;
    return 1;
}

Dialog:WepPosition(playerid, response, listitem, inputtext[]) {
    if (response) {
        new weaponid = EditingWeapon[playerid];
        switch (listitem) {
            case 0: {
                new index = (weaponid >= 22 && weaponid <= 38) ? (weaponid - 22) : (weaponid + 15);
                
                SetPlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid), GetHoldingWeaponModel(weaponid), WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], 1.0, 1.0, 1.0);
                EditAttachedObject(playerid, GetWeaponObjectSlot(weaponid));
                SetPlayerArmedWeapon(playerid, 0);
            }
            case 1: {
                new info[256], index = (weaponid >= 22 && weaponid <= 38) ? (weaponid - 22) : (weaponid + 15);

                format(info, sizeof(info), "Please input the weapon settings position below:\nCurrent value x y z rx ry rz:\n"CYAN"%.3f %.3f %.3f %.3f %.3f %.3f", WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5]);
                Dialog_Show(playerid, WepPosition_Manual, DIALOG_STYLE_INPUT, "Weapon Settings Position", info, "Update", "Close");
            }
        }
    } else EditingWeapon[playerid] = 0;
    return 1;
}

Dialog:WepPosition_Manual(playerid, response, listitem, inputtext[]) {
    if (response) {
        new Float:pos[6], weaponid = EditingWeapon[playerid];
        if (!sscanf(inputtext, "F(-0.116)F(0.189)F(0.088)F(0)F(44.5)F(0)",pos[0],pos[1],pos[2],pos[3],pos[4],pos[5])) {
            new string[1024], index = (weaponid >= 22 && weaponid <= 38) ? (weaponid - 22) : (weaponid + 15);
            WeaponSettings[playerid][index][Position][0] = pos[0];
            WeaponSettings[playerid][index][Position][1] = pos[1];
            WeaponSettings[playerid][index][Position][2] = pos[2];
            WeaponSettings[playerid][index][Position][3] = pos[3];
            WeaponSettings[playerid][index][Position][4] = pos[4];
            WeaponSettings[playerid][index][Position][5] = pos[5];

            RemovePlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid));
            SetPlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid), GetHoldingWeaponModel(weaponid), WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], 1.0, 1.0, 1.0);

            mysql_format(g_iHandle, string, sizeof(string), "INSERT INTO weaponsettings VALUES (%d, %d, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %d, %d) ON DUPLICATE KEY UPDATE PosX = %.3f, PosY = %.3f, PosZ = %.3f, RotX = %.3f, RotY = %.3f, RotZ = %.3f", GetPlayerSQLID(playerid), weaponid, WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Hidden], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5]);
            mysql_tquery(g_iHandle, string);

            format(string, sizeof(string), "Please input the weapon settings position below:\nCurrent value x y z rx ry rz:\n"CYAN"%.3f %.3f %.3f %.3f %.3f %.3f", WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5]);
            Dialog_Show(playerid, WepPosition_Manual, DIALOG_STYLE_INPUT, "Weapon Settings Position", string, "Update", "Close");
            return 1;
        }
    } else EditingWeapon[playerid] = 0;
    return 1;
}

CMD:attachwep(playerid, params[]) {
    new weaponid = GetPlayerWeapon(playerid);
 
    if (!weaponid)
        return SendErrorMessage(playerid, "You are not holding a weapon.");

    if (!IsWeaponWearable(weaponid))
        return SendErrorMessage(playerid, "This weapon cannot be edited.");

    if (isnull(params))
        return SendSyntaxMessage(playerid, "/attachwep [pos/bone/hide]");

    if (!strcmp(params, "pos", true))
    {
        new i = (weaponid >= 22 && weaponid <= 38) ? (weaponid - 22) : (weaponid + 15);
        if (EditingWeapon[playerid])
            return SendErrorMessage(playerid, "You are already editing a weapon.");

        if (WeaponSettings[playerid][i][Hidden])
            return SendErrorMessage(playerid, "You cannot adjust a hidden weapon.");

        Dialog_Show(playerid, WepPosition, DIALOG_STYLE_LIST, "Weapon Position", "For PC\nFor Android", "Select", "Close");
        EditingWeapon[playerid] = weaponid;
    }
    else if (!strcmp(params, "bone", true))
    {
        if (EditingWeapon[playerid])
            return SendErrorMessage(playerid, "You are already editing a weapon.");

        Dialog_Show(playerid, DIALOG_EDIT_BONE, DIALOG_STYLE_LIST, "Bone", "Spine\nHead\nLeft upper arm\nRight upper arm\nLeft hand\nRight hand\nLeft thigh\nRight thigh\nLeft foot\nRight foot\nRight calf\nLeft calf\nLeft forearm\nRight forearm\nLeft shoulder\nRight shoulder\nNeck\nJaw", "Choose", "Cancel");
        EditingWeapon[playerid] = weaponid;
    }
    else if (!strcmp(params, "hide", true))
    {
        if (EditingWeapon[playerid])
            return SendErrorMessage(playerid, "You cannot hide a weapon while you are editing it.");

        if (!IsWeaponHideable(weaponid))
            return SendErrorMessage(playerid, "This weapon cannot be hidden.");

        new index = (weaponid >= 22 && weaponid <= 38) ? (weaponid - 22) : (weaponid + 15), weaponname[18], string[150];

        GetWeaponName(weaponid, weaponname, sizeof(weaponname));
        
        if (WeaponSettings[playerid][index][Hidden])
        {
            format(string, sizeof(string), "You have set your %s to show.", weaponname);
            WeaponSettings[playerid][index][Hidden] = false;
        }
        else
        {
            if (IsPlayerAttachedObjectSlotUsed(playerid, GetWeaponObjectSlot(weaponid)))
                RemovePlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid));

            format(string, sizeof(string), "You have set your %s not to show.", weaponname);
            WeaponSettings[playerid][index][Hidden] = true;
        }
        SendCustomMessage(playerid, "WEAPON", "%s", string);
        mysql_format(g_iHandle, string, sizeof(string), "INSERT INTO weaponsettings VALUES (%d, %d, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %d, %d) ON DUPLICATE KEY UPDATE `Hidden` = %d", GetPlayerSQLID(playerid), weaponid, WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Hidden], WeaponSettings[playerid][index][Hidden]);
        mysql_tquery(g_iHandle, string);
    }
    else SendErrorMessage(playerid, "You have specified an invalid option.");
    return 1;
}
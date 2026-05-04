#define MAX_PAYPHONE    (100)

enum payPhone {
    phoneID,
    Float:phonePos[3],
    Float:phoneRot[3],
    phoneVw,
    phoneInt,
    phoneUsed,
    phoneObj,
    phonePickup,
    phoneCP
};
new PayphoneData[MAX_PAYPHONE][payPhone],
    Iterator:Payphones<MAX_PAYPHONE>;

static EditingPayphone[MAX_PLAYERS] = {-1, ...};

#include <YSI\y_hooks>
hook OnGameModeInitEx() {
    mysql_tquery(g_iHandle, "SELECT * FROM `payphones`", "Payphone_Load", "");
    return 1;
}


hook OnGameModeExit() {
    foreach (new i : Payphones) {
        Payphone_Save(i);
    }
    return 1;
}


hook OnPlayerDisconnectEx(playerid) {
    EditingPayphone[playerid] = -1;
    return 1;
}


hook OnPlayerEditDynObj(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    if (EditingPayphone[playerid] != -1) {
        if (response == EDIT_RESPONSE_CANCEL) {
            new i = EditingPayphone[playerid];

            if (Iter_Contains(Payphones, i)) {
                new Float:position[3], Float:rotation[3];
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,PayphoneData[i][phoneObj],E_STREAMER_X,position[0]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,PayphoneData[i][phoneObj],E_STREAMER_Y,position[1]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,PayphoneData[i][phoneObj],E_STREAMER_Z,position[2]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,PayphoneData[i][phoneObj],E_STREAMER_R_X,rotation[0]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,PayphoneData[i][phoneObj],E_STREAMER_R_Y,rotation[1]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,PayphoneData[i][phoneObj],E_STREAMER_R_Z,rotation[2]);
                SetDynamicObjectPos(objectid,position[0],position[1],position[2]);
                SetDynamicObjectRot(objectid,rotation[0],rotation[1],rotation[2]);

                Payphone_Refresh(i, 0);

                SendCustomMessage(playerid, "PAYPHONE", "You've been successfully canceled editing payphone id: "YELLOW"%d", i);
                EditingPayphone[playerid] = -1;
            }
        } else if (response == EDIT_RESPONSE_FINAL) {
            new i = EditingPayphone[playerid];

            if (Iter_Contains(Payphones, i)) {
                PayphoneData[i][phonePos][0] = x;
                PayphoneData[i][phonePos][1] = y;
                PayphoneData[i][phonePos][2] = z;
                PayphoneData[i][phoneRot][0] = rx;
                PayphoneData[i][phoneRot][1] = ry;
                PayphoneData[i][phoneRot][2] = rz;

                SetDynamicObjectPos(objectid, x, y, z);
                SetDynamicObjectRot(objectid, rx, ry, rz);
                Payphone_Refresh(i, 0);
                Payphone_Save(i);

                SendCustomMessage(playerid, "PAYPHONE", "You've been successfully edited payphone id: "YELLOW"%d", i);
                EditingPayphone[playerid] = -1;
            }
        }
    }
    return 1;
}


hook OnPlayerUpdate(playerid) {
    if (Payphone_Nearest(playerid) != PlayerData[playerid][pUsedPayphone] && IsPlayerOnPhone(playerid) && PlayerData[playerid][pUsedPayphone] != -1) {
        cmd_hangup(playerid);
        SendErrorMessage(playerid, "You are too far away from Payphone now your called has been ended!");
    }

    new i;
    if ((i = Payphone_Nearest(playerid)) != -1) GameTextForPlayer(playerid, sprintf("~y~Payphone:%d~n~~w~Use '~r~/pcall~w~' to using this payphone~n~~w~Cost fee: $0.50/minute", i), 1500, 4);

    return 1;
}

timer UsedPayphone[60000](playerid) {
    if (Payphone_Nearest(playerid) == PlayerData[playerid][pUsedPayphone] && IsPlayerOnPhone(playerid) && PlayerData[playerid][pUsedPayphone] != -1) {
        GiveMoney(playerid, -50);
    }
    return 1;
}

Function:Payphone_Load() {
    new rows = cache_num_rows();

    if (rows) {
        for (new i = 0; i < rows; i ++) {
            cache_get_value_int(i, "ID", PayphoneData[i][phoneID]);
            
            cache_get_value_float(i, "Pos0", PayphoneData[i][phonePos][0]);
            cache_get_value_float(i, "Pos1", PayphoneData[i][phonePos][1]);
            cache_get_value_float(i, "Pos2", PayphoneData[i][phonePos][2]);
            cache_get_value_float(i, "Rot0", PayphoneData[i][phoneRot][0]);
            cache_get_value_float(i, "Rot1", PayphoneData[i][phoneRot][1]);
            cache_get_value_float(i, "Rot2", PayphoneData[i][phoneRot][2]);

            cache_get_value_int(i, "Vw", PayphoneData[i][phoneVw]);
            cache_get_value_int(i, "Int", PayphoneData[i][phoneInt]);

            Iter_Add(Payphones, i);
            Payphone_Refresh(i);
        }
        printf("*** [GarudaPride Roleplay Database: Loaded] payphones data loaded (%d count)", rows);
    }
    return 1;
}

Function:OnPayphoneCreated(i) {
    if (!Iter_Contains(Payphones, i))
        return 0;

    PayphoneData[i][phoneID] = cache_insert_id();
    Payphone_Save(i);
    return 1;
}

Payphone_Refresh(i, sync = 1) {
    if (i != cellmin) {
        if (sync) {
            if (IsValidDynamicObject(PayphoneData[i][phoneObj]))
                DestroyDynamicObject(PayphoneData[i][phoneObj]);
        }

        if (IsValidDynamicPickup(PayphoneData[i][phonePickup]))
            DestroyDynamicPickup(PayphoneData[i][phonePickup]);

        if (IsValidDynamicCP(PayphoneData[i][phoneCP]))
            DestroyDynamicCP(PayphoneData[i][phoneCP]);

        PayphoneData[i][phoneObj] = CreateDynamicObject(1216, PayphoneData[i][phonePos][0], PayphoneData[i][phonePos][1], PayphoneData[i][phonePos][2], PayphoneData[i][phoneRot][0], PayphoneData[i][phoneRot][1], PayphoneData[i][phoneRot][2], PayphoneData[i][phoneVw], PayphoneData[i][phoneInt]);
        PayphoneData[i][phonePickup] = CreateDynamicPickup(1239, 23, PayphoneData[i][phonePos][0]-0.5, PayphoneData[i][phonePos][1], PayphoneData[i][phonePos][2], PayphoneData[i][phoneVw], PayphoneData[i][phoneInt]);
        PayphoneData[i][phoneCP] = CreateDynamicCP(PayphoneData[i][phonePos][0]-0.5, PayphoneData[i][phonePos][1], PayphoneData[i][phonePos][2]-1.6, 1, PayphoneData[i][phoneVw], PayphoneData[i][phoneInt], _, 3.0);
    }
    return 1;
}

Payphone_Create(playerid) {
    new i = cellmin;

    if ((i = Iter_Free(Payphones)) != cellmin) {
        new Float:pos[4];
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        GetPlayerFacingAngle(playerid, pos[3]);

        pos[0] += 1.0 * floatsin(-pos[3], degrees);
        pos[1] += 1.0 * floatcos(-pos[3], degrees);

        PayphoneData[i][phonePos][0] = pos[0];
        PayphoneData[i][phonePos][1] = pos[1];
        PayphoneData[i][phonePos][2] = pos[2];
        PayphoneData[i][phoneRot][0] = 0.0;
        PayphoneData[i][phoneRot][1] = 0.0;
        PayphoneData[i][phoneRot][2] = pos[3];
        PayphoneData[i][phoneVw] = GetPlayerVirtualWorld(playerid);
        PayphoneData[i][phoneInt] = GetPlayerInterior(playerid);

        Iter_Add(Payphones, i);
        Payphone_Refresh(i);

        mysql_tquery(g_iHandle, sprintf("INSERT INTO `payphones` (`Vw`) VALUES ('%d')", PayphoneData[i][phoneVw]), "OnPayphoneCreated", "d", i);

        return i;
    }

    return cellmin;
}

Payphone_Save(i) {
    if (!Iter_Contains(Payphones, i))
        return 0;

    new string[256];
    format(string,sizeof(string),"UPDATE `payphones` SET `Pos0`='%f', `Pos1`='%f', `Pos2`='%f', `Rot0`='%f', `Rot1`='%f', `Rot2`='%f', `Vw`='%d', `Int`='%d' WHERE `ID`='%d'",
    PayphoneData[i][phonePos][0],
    PayphoneData[i][phonePos][1],
    PayphoneData[i][phonePos][2],
    PayphoneData[i][phoneRot][0],
    PayphoneData[i][phoneRot][1],
    PayphoneData[i][phoneRot][2],
    PayphoneData[i][phoneVw],
    PayphoneData[i][phoneInt],
    PayphoneData[i][phoneID]
    );
    return mysql_tquery(g_iHandle, string);
}

Payphone_Delete(i) {
    if (!Iter_Contains(Payphones, i))
        return 0;

    mysql_tquery(g_iHandle, sprintf("DELETE FROM `payphones` WHERE `ID`='%d'", PayphoneData[i][phoneID]));

    DestroyDynamicObject(PayphoneData[i][phoneObj]);
    DestroyDynamicPickup(PayphoneData[i][phonePickup]);
    DestroyDynamicCP(PayphoneData[i][phoneCP]);

    PayphoneData[i][phoneID] = cellmin;
    for (new j = 0; j < 3; j ++) {
        PayphoneData[i][phonePos][j] = 0.0;
        PayphoneData[i][phoneRot][j] = 0.0;
    }
    PayphoneData[i][phoneVw] = 0;
    PayphoneData[i][phoneInt] = 0;
    PayphoneData[i][phoneUsed] = 0;

    Iter_Remove(Payphones, i);
    return 1;
}

Payphone_Nearest(playerid) {
    foreach (new i : Payphones) {
        if (IsPlayerInRangeOfPoint(playerid, 2.0, PayphoneData[i][phonePos][0], PayphoneData[i][phonePos][1], PayphoneData[i][phonePos][2])) {
            if (GetPlayerVirtualWorld(playerid) == PayphoneData[i][phoneVw] && GetPlayerInterior(playerid) == PayphoneData[i][phoneInt]) return i;
        }
    }
    return -1;
}

SSCANF:PayphoneMenu(string[]) 
{
	if (!strcmp(string,"create",true)) return 1;
 	else if (!strcmp(string,"delete",true)) return 2;
 	else if (!strcmp(string,"edit",true)) return 3;
    else if (!strcmp(string,"vw",true)) return 4;
    else if (!strcmp(string,"int",true)) return 5;
    else if (!strcmp(string,"goto",true)) return 6;
 	return 0;
}

CMD:payphone(playerid, params[]) {
    if (CheckAdmin(playerid, 4))
        return PermissionError(playerid);

    new option, value[128];

    if (sscanf(params, "k<PayphoneMenu>S()[128]",option,value))
        return SendSyntaxMessage(playerid, "/payphone [create/delete/edit/vw/int/goto]");

    switch (option) {
        case 1: {
            new i = cellmin;
            if ((i = Payphone_Create(playerid)) != cellmin) {
                return SendCustomMessage(playerid, "PAYPHONE", "You've been created payphone id: "YELLOW"%d", i);
            }
            SendErrorMessage(playerid, "The server has reached limit for payphones!");
        }
        case 2: {
            new id;
            if (sscanf(value, "d", id))
                return SendSyntaxMessage(playerid, "/payphone delete [payphone id]");

            if (!Iter_Contains(Payphones, id))
                return SendErrorMessage(playerid, "Invalid payphone id!");

            Payphone_Delete(id);
            SendCustomMessage(playerid, "PAYPHONE", "You've been deleted payphone id: "YELLOW"%d", id);
        }
        case 3: {
            new i;
            if (sscanf(value, "d", i))
                return SendSyntaxMessage(playerid, "/payphone edit [payphone id]");

            if (!Iter_Contains(Payphones, i))
                return SendErrorMessage(playerid, "Invalid payphone id!");

            EditingPayphone[playerid] = i;
            EditDynamicObject(playerid, PayphoneData[i][phoneObj]);
            SendCustomMessage(playerid, "PAYPHONE", "You're now editing payphone id: "YELLOW"%d", i);
        }
        case 4: {
            new i, vw;
            if (sscanf(value, "dd", i, vw))
                return SendSyntaxMessage(playerid, "/payphone vw [payphone id] [virtual world]");

            if (!Iter_Contains(Payphones, i))
                return SendErrorMessage(playerid, "Invalid payphone id!");

            PayphoneData[i][phoneVw] = vw;
            Streamer_SetIntData(STREAMER_TYPE_OBJECT, PayphoneData[i][phoneObj], E_STREAMER_WORLD_ID, vw);
            Payphone_Refresh(i, 0);
            Payphone_Save(i);
            SendCustomMessage(playerid, "PAYPHONE", "You've been changed payphone "YELLOW"%d "WHITE"virtual world to: "YELLOW"%d", i, vw);
        }
        case 5: {
            new i, int;
            if (sscanf(value, "dd", i, int))
                return SendSyntaxMessage(playerid, "/payphone int [payphone id] [interior id]");

            if (!Iter_Contains(Payphones, i))
                return SendErrorMessage(playerid, "Invalid payphone id!");

            PayphoneData[i][phoneInt] = int;
            Streamer_SetIntData(STREAMER_TYPE_OBJECT, PayphoneData[i][phoneObj], E_STREAMER_INTERIOR_ID, int);
            Payphone_Refresh(i, 0);
            Payphone_Save(i);
            SendCustomMessage(playerid, "PAYPHONE", "You've been changed payphone "YELLOW"%d "WHITE"interior id to: "YELLOW"%d", i, int);
        }
        case 6: {
            new i;
            if (sscanf(value, "d", i))
                return SendSyntaxMessage(playerid, "/payphone goto [payphone id]");

            if (!Iter_Contains(Payphones, i))
                return SendErrorMessage(playerid, "Invalid payphone id!");

            SetPlayerPosEx(playerid, PayphoneData[i][phonePos][0], PayphoneData[i][phonePos][1], PayphoneData[i][phonePos][2]);
            SetPlayerFacingAngle(playerid, PayphoneData[i][phoneRot][2]);
            SetPlayerVirtualWorld(playerid, PayphoneData[i][phoneVw]);
            SetPlayerInterior(playerid, PayphoneData[i][phoneInt]);
            SendCustomMessage(playerid, "TELE", "You've been teleported payphone id: "YELLOW"%d", i);
        }
        default: SendSyntaxMessage(playerid, "/payphone [create/delete/edit/vw/int/goto]");
    }
    return 1;
}

CMD:pcall(playerid, params[])
{
    new i;
    if((i = Payphone_Nearest(playerid)) == -1) return SendErrorMessage(playerid, "You're not near any payphone!");
    if (PayphoneData[i][phoneUsed]) return SendErrorMessage(playerid, "This payphone are being used by someone!");
    if(AccountData[playerid][pAdminDuty]) return SendErrorMessage(playerid, "Your must off duty admin to use this command.");
    if(PlayerData[playerid][pIncomingCall]) return SendErrorMessage(playerid, "Waiting someone to answer your call.");
    if(PlayerData[playerid][pCallLine] != INVALID_PLAYER_ID) return SendErrorMessage(playerid, "You already to call on your phone.");
    
    if(PlayerData[playerid][pHospital] != -1 || PlayerData[playerid][pCuffed] || !IsPlayerSpawned(playerid) || PlayerData[playerid][pJailTime] || PlayerData[playerid][pInjured])
        return SendErrorMessage(playerid, "You can't use this command now.");

    static
        targetid,
        number;

    if(sscanf(params, "d", number))
         return SendSyntaxMessage(playerid, "/pcall [phone number] (1222 for taxi, 911 for emergency, 666 for non emergency, 555 for mechanic, 711 for goverment, 144 for sanews)");

    if(!number) return SendErrorMessage(playerid, "The specified phone number is not in service.");

    if (GetMoney(playerid) < 50)
        return SendErrorMessage(playerid, "You don't have enough money!");

    if(number == 911)
    {
        if(PlayerData[playerid][pEmergency])
            return SendErrorMessage(playerid, "You can't use this command now.");

        PlayerData[playerid][pEmergency] = 1;
        PlayerPlaySound(playerid, 3600, 0.0, 0.0, 0.0);
        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
        GiveMoney(playerid, -50);

        SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s takes out their cellphone and places a call.", ReturnName(playerid, 0));
        SendClientMessage(playerid, X11_TURQUOISE_1, "[OPERATOR]:"WHITE" Which service do you require: \"police\" or \"medics\"?");
        PlayerData[playerid][pUsedPayphone] = i;
        PlayerData[playerid][pPayphoneTimer] = repeat UsedPayphone(playerid);
    }
    else if(number == 555)
    {
        if(PlayerData[playerid][pInjured])
            return SendErrorMessage(playerid, "You can't use this command now.");

        PlayerData[playerid][pMechanicCalled] = 1;
        PlayerPlaySound(playerid, 3600, 0.0, 0.0, 0.0);
        GiveMoney(playerid, -50);

        SendClientMessage(playerid, X11_YELLOW_2, "[OPERATOR]:"WHITE" The mechanic has been notified of your call.");

        SendClientMessage(playerid, COLOR_SERVER, "You hung up your phone.");
        SendJobMessage(JOB_MECHANIC, X11_GREEN_YELLOW, "|______________ MECHANIC CALL ______________|", ReturnName(playerid, 0), GetPlayerLocation(playerid));
        SendJobMessage(JOB_MECHANIC, X11_WHITE, "Caller: (ID: %d) %s (Ph: Unknown)", playerid, ReturnName2(playerid, 0));
        SendJobMessage(JOB_MECHANIC, X11_WHITE, "Current Location: %s (Type /acceptcall to accept mechanic call.).", GetPlayerLocation(playerid));
    }
    else if(number == 711)
    {
        if(PlayerData[playerid][pEmergency])
            return SendErrorMessage(playerid, "You can't use this command now.");

        PlayerData[playerid][pEmergency] = 4;
        PlayerPlaySound(playerid, 3600, 0.0, 0.0, 0.0);
        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
        GiveMoney(playerid, -50);

        SendClientMessage(playerid, X11_TURQUOISE_1, "[OPERATOR]:"WHITE" What can we help you? don't send junk message for this service?.");
        PlayerData[playerid][pUsedPayphone] = i;
        PlayerData[playerid][pPayphoneTimer] = repeat UsedPayphone(playerid);
    }
    else if(number == 1222)
    {
        if(PlayerData[playerid][pInjured])
            return SendErrorMessage(playerid, "You can't use this command now.");

        PlayerData[playerid][pTaxiCalled] = 1;
        PlayerPlaySound(playerid, 3600, 0.0, 0.0, 0.0);
        GiveMoney(playerid, -50);

        SendClientMessage(playerid, X11_YELLOW_2, "[OPERATOR]:"WHITE" The taxi department has been notified of your call.");

        SendClientMessage(playerid, COLOR_SERVER, "You hung up your phone.");
        SendJobMessage(JOB_TAXI, X11_YELLOW_2, "** %s (PHONE NUMBER: unknown) is requesting a taxi at %s (use /acceptcall to accept).", ReturnName(playerid, 0), GetPlayerLocation(playerid));
    }
    else if(number == 144)
    {
        if(PlayerData[playerid][pInjured])
            return SendErrorMessage(playerid, "You can't use this command now.");

        PlayerData[playerid][pEmergency] = 5;
        PlayerPlaySound(playerid, 3600, 0.0, 0.0, 0.0);
        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
        GiveMoney(playerid, -50);

        SendClientMessage(playerid, X11_TURQUOISE_1, "[OPERATOR]:"WHITE" What can we help you? don't send junk message for this service?.");
    }
    else if (number == 666) {
        if(PlayerData[playerid][pNonEmergency])
            return SendErrorMessage(playerid, "You can't use this command now.");
        
        PlayerData[playerid][pNonEmergency] = 1;
        PlayerPlaySound(playerid, 3600, 0.0, 0.0, 0.0);
        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
        GiveMoney(playerid, -50);

        SendNearbyMessage(playerid, 15.0, X11_PLUM, "* %s takes out their cellphone and places a call.", ReturnName(playerid, 0, 1));
        SendClientMessage(playerid, X11_LIGHTBLUE, "[NON-EMERGENCY]:"WHITE" Which service do you require: \"police\" or \"medics\"?");
        PlayerData[playerid][pUsedPayphone] = i;
        PlayerData[playerid][pPayphoneTimer] = repeat UsedPayphone(playerid);
    }
    else if((targetid = GetNumberOwner(number)) != INVALID_PLAYER_ID)
    {
        if(PlayerData[playerid][pInjured]) return SendErrorMessage(playerid, "You can't use this command now.");
        if(targetid == playerid) return SendErrorMessage(playerid, "You can't call yourself!");
        if(PlayerData[targetid][pPhoneOff]) 
        {
            AddMissCall(targetid, PlayerData[playerid][pPhone]);
            SendErrorMessage(playerid, "The recipient has their cellphone powered off.");
            return 1;
        }
        if(PlayerData[targetid][pCallLine] != INVALID_PLAYER_ID) return SendErrorMessage(playerid, "The recipient has calling someone, try again later.");
        if(PlayerData[targetid][pIncomingCall]) return SendErrorMessage(playerid, "Hangup first (/h) to call someone.");

        PlayerData[targetid][pIncomingCall] = 1;
        PlayerData[playerid][pIncomingCall] = 1;

        PlayerData[targetid][pCallLine] = playerid;
        PlayerData[playerid][pCallLine] = targetid;

        SendCustomMessage(playerid, "PHONE", "Attempting to dial "CYAN"%s (%d), "WHITE"please wait for an answer...", GetContactNameByNumber(playerid, number), number);
        SendCustomMessage(targetid, "PHONE", "Incoming call from "RED"Unknown "WHITE"(type \""YELLOW"/answer"WHITE"\" to answer the phone)");

        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
        GiveMoney(playerid, -50);

        PlayerPlaySound(playerid, 3600, 0.0, 0.0, 0.0);
        PlayerPlaySoundEx(targetid, 23000);
        PayphoneData[i][phoneUsed] = 1;
        PlayerData[playerid][pUsedPayphone] = i;
        PlayerData[playerid][pPayphoneTimer] = repeat UsedPayphone(playerid);
    }
    else SendErrorMessage(playerid, "The specified phone number is not in service.");

    return 1;
}

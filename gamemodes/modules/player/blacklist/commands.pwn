CMD:ban(playerid, params[])
{
    new userid, reason[64];

    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");

    if(sscanf(params, "us[64]", userid, reason))
        return SendSyntaxMessage(playerid, "/ban [playerid/PartOfName] [reason]");

    if(userid == INVALID_PLAYER_ID || (!IsPlayerConnected(userid) && PlayerData[userid][pKicked]))
        return SendErrorMessage(playerid, "Player tersebut tidak login didalam server.");

    if(PlayerData[userid][pAdmin] > PlayerData[userid][pAdmin])
        return SendErrorMessage(playerid, "Level admin yang ingin kamu ban lebih tinggi darimu.");

    foreach (new i : Player) if (!PlayerData[i][pTogAdmCmd]) {
        SendClientMessageEx(i, X11_TOMATO_1, "AdmCmd: %s has been banned by %s.", ReturnName(userid, 0), ReturnAdminName(playerid));
        SendClientMessageEx(i, X11_TOMATO_1, "Reason: %s", reason);
    }

    Blacklist_Add(PlayerData[userid][pID], "", NormalName(userid), "", ReturnAdminName(playerid), reason);
    Dialog_Show(userid, ShowOnly, DIALOG_STYLE_MSGBOX, "Banned", ""WHITE"Your account has been banned by the server.\n\n"WHITE"Username: "COL_RED"%s\n"WHITE"Reason: "COL_RED"%s\n"WHITE"Admin who banned you: "COL_RED"%s\n\n"WHITE"Press F8 to take a screenshot and request a ban appeal on our forums.", "Close", "", ReturnName(userid), reason, ReturnAdminName(playerid));

    Log_Write("logs/ban_log.txt", "[%s] %s was banned by %s for: %s.", ReturnDate(), ReturnName(userid, 1), ReturnAdminName(playerid), reason);
    KickEx(userid);
    return 1;
}

CMD:unban(playerid, params[])
{
    new character[MAX_PLAYER_NAME];

    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");

    if(sscanf(params, "s[24]", character))
        return SendSyntaxMessage(playerid, "/unban [character name]");

    if(strlen(character) > 24)
        return SendErrorMessage(playerid, "Nama karakter tidak bisa lebih dari 24 karakter.");

    if(!Blacklist_Exists("Characters", character))
        return SendErrorMessage(playerid, "Nama karakter tidak terdaftar dalam banned list.");
        
    Blacklist_RemoveChar(character);
    SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has unbanned character \"%s\".", ReturnAdminName(playerid), character);

    Log_Write("logs/ban_log.txt", "[%s] %s has unbanned character \"%s\".", ReturnDate(), ReturnAdminName(playerid), character);
    return 1;
}

CMD:banacp(playerid, params[])
{
    new username[MAX_PLAYER_NAME], reason[124];

    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");
    
    if(sscanf(params, "s[24]s[124]", username, reason))
        return SendSyntaxMessage(playerid, "/banacp [accounts name] [reason]");

    if(!Blacklist_ACPExists("Username", username))
        return SendErrorMessage(playerid, "Nama ACP tidak terdaftar diserver.");

    if(Blacklist_Exists("Username", username))
        return SendErrorMessage(playerid, "Nama telah dibanned sebelumnya.");

    foreach (new i : Player) if (!PlayerData[i][pTogAdmCmd]) {
        SendClientMessageEx(i, X11_TOMATO_1, "AdmCmd: ACP %s has been banned by %s.", username, ReturnAdminName(playerid));
        SendClientMessageEx(i, X11_TOMATO_1, "Reason: %s", reason);
    }

    Blacklist_Add(0, "", "", username, ReturnAdminName(playerid), reason);

    //KickEx(username);

    Log_Write("logs/acpban_log.txt", "[%s] %s has been banned by %s for: %s.", ReturnDate(), username, ReturnAdminName(playerid), reason);
    return 1;
}

CMD:unbanacp(playerid, params[])
{
    new username[MAX_PLAYER_NAME];

    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");

    if(sscanf(params, "s[24]", username))
        return SendSyntaxMessage(playerid, "/unbanacp [accounts name]");

    if(!Blacklist_Exists("Username", username))
        return SendErrorMessage(playerid, "Nama UCP tidak dalam list banned.");

    Blacklist_RemoveACP(username);

    foreach (new i : Player) if (!PlayerData[i][pTogAdmCmd]) {
        SendClientMessageEx(i, X11_TOMATO_1, "AdmCmd: %s has been unbanned ACP %s.", ReturnAdminName(playerid), username);
    }
    Log_Write("logs/acpban_log.txt", "[%s] %s has unbanned ACP \"%s\".", ReturnDate(), ReturnAdminName(playerid), username);
    return 1;
}

CMD:oban(playerid, params[])
{
    new username[MAX_PLAYER_NAME], reason[128];
        
    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");

    if(sscanf(params, "s[24]s[124]", username, reason))
        return SendSyntaxMessage(playerid, "/o(ffline)ban [character name] [reason]");
        
    if(!IsValidPlayerName(username))
        return SendErrorMessage(playerid, "Format nama tidak sesuai, gunakan format nama roleplay.");

    if(!Blacklist_CharExists("Character", username))
        return SendErrorMessage(playerid, "Nama karakter tidak terdaftar diserver.");

    if(Blacklist_Exists("Characters", username))
        return SendErrorMessage(playerid, "Nama karakter telah dibanned sebelumnya.");

    new Cache:check, charid;

    check = mysql_query(g_iHandle, sprintf("SELECT `ID` FROM `characters` WHERE `Character` = '%s'", username));

    if (cache_num_rows()) {
        cache_get_value_int(0, "ID", charid);
        Blacklist_Add(charid, "", username, "", ReturnAdminName(playerid), reason);

        foreach (new i : Player) if (!PlayerData[i][pTogAdmCmd]) {
            SendClientMessageEx(i, X11_TOMATO_1, "AdmCmd: %s has offline banned %s", ReturnAdminName(playerid), username);
            SendClientMessageEx(i, X11_TOMATO_1, "Reason: %s ", reason);
        }
        Log_Write("logs/ban_log.txt", "[%s] %s has offline banned \"%s\" reason: %s.", ReturnDate(), ReturnAdminName(playerid), username, reason);
    } else SendErrorMessage(playerid, "That character doesn't exists");
    cache_delete(check);
    return 1;
}

CMD:banip(playerid, params[])
{
    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");

    new ip[16], reason[128];
        
    if(sscanf(params, "s[16]s[124]", ip, reason))
        return SendSyntaxMessage(playerid, "/banip [ip address] [reason]");

    if(!IsAnIP(ip))
        return SendErrorMessage(playerid, "Format ip salah, ikuti format berikut: xx.xx.xx.xx");

    if(Blacklist_Exists("IP", ip))
        return SendErrorMessage(playerid, "IP telah dibanned sebelumnya.");
    
    foreach (new i : Player) if (!PlayerData[i][pTogAdmCmd]) {
        SendClientMessageEx(i, X11_TOMATO_1, "AdmCmd: IP \"%s\" has been banned by %s.", ip, ReturnAdminName(playerid));
        SendClientMessageEx(i, X11_TOMATO_1, "Reason: %s", reason);
    }

    Blacklist_Add(0, ip, "", "", ReturnAdminName(playerid), reason);

    foreach (new i : Player) if(!strcmp(ReturnIP(i), ip)) {
        KickEx(i);
    }
    Log_Write("logs/ipban_log.txt", "[%s] %s has banned IP \"%s\".", ReturnDate(), ReturnAdminName(playerid), ip);
    return 1;
}

CMD:unbanip(playerid, params[])
{
    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");

    new ip[16];
        
    if(sscanf(params, "s[16]", ip))
        return SendSyntaxMessage(playerid, "/unbanip [ip address]");

    if(!IsAnIP(ip))
        return SendErrorMessage(playerid, "Format ip salah, ikuti format berikut: xx.xx.xx.xx");

    if(!Blacklist_Exists("IP", ip))
        return SendErrorMessage(playerid, "IP tidak ada dalam daftar banned.");

    Blacklist_RemoveIP(ip);

    SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has unbanned IP \"%s\".", ReturnAdminName(playerid), ip);
    Log_Write("logs/ipban_log.txt", "[%s] %s has unbanned IP \"%s\".", ReturnDate(), ReturnAdminName(playerid), ip);
    return 1;
}

CMD:tempban(playerid, params[])
{
    new userid, day, reason[64];

    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");

    if(sscanf(params, "uds[64]", userid, day, reason)) 
        return SendSyntaxMessage(playerid, "/tempban [playerid/PartOfName] [day(s)] [reason]");

    if(userid == INVALID_PLAYER_ID || (!IsPlayerConnected(userid) && PlayerData[userid][pKicked]))
        return SendErrorMessage(playerid, "Player tersebut tidak login didalam server.");

    if(day < 0 || day > 30) 
        return SendErrorMessage(playerid, "Hari dibatasi dari 0 - 30.");

    foreach (new i : Player) if (!PlayerData[i][pTogAdmCmd]) {
        SendClientMessageEx(i, X11_TOMATO_1, "AdmCmd: %s have been temporary banned %d day(s) by %s.", ReturnName(userid, 0), day, ReturnAdminName(playerid), reason);
        SendClientMessageEx(i, X11_TOMATO_1, "Reason: %s", reason);
    }
    
    Blacklist_Add(PlayerData[userid][pID], "", ReturnName(userid), "", ReturnAdminName(playerid), reason, day);
    KickEx(userid);

    Log_Write("logs/tempban_log.txt", "[%s] %s was temporary banned by %s (%d days) for: %s.", ReturnDate(), ReturnName(userid), ReturnAdminName(playerid), day, reason);
    return 1;
}

CMD:otempban(playerid, params[])
{
    new day, reason[64], username[MAX_PLAYER_NAME];

    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");

    if(sscanf(params, "s[24]ds[32]", username, day, reason)) 
        return SendSyntaxMessage(playerid, "/otempban [character name] [day(s)] [reason]");

    if(day < 0 || day > 30) 
        return SendErrorMessage(playerid, "Hari dibatasi dari 0 - 30.");

    if(Blacklist_Exists("Characters", username))
        return SendErrorMessage(playerid, "Nama karakter telah dibanned sebelumnya.");

    new Cache:check, id;

    check = mysql_query(g_iHandle, sprintf("SELECT `ID` FROM `characters` WHERE `Character` = '%s'", username));

    if (cache_num_rows()) {
        foreach (new i : Player) if (!PlayerData[i][pTogAdmCmd]) {
            SendClientMessageEx(i, X11_TOMATO_1, "AdmCmd: %s have been offline temporary banned %d day(s) by %s.", username, day, ReturnAdminName(playerid), reason);
            SendClientMessageEx(i, X11_TOMATO_1, "Reason: %s", reason);
        }

        cache_get_value_int(0, "ID", id);
        Blacklist_Add(id, "", username, "", ReturnAdminName(playerid), reason, day);
        Log_Write("logs/tempban_log.txt", "[%s] %s was temporary offline banned by %s (%d days) for: %s.", ReturnDate(), username, ReturnAdminName(playerid), day, reason);
    } else SendErrorMessage(playerid, "That character doesn't exists");
    cache_delete(check);
    return 1;
}

CMD:baninfo(playerid, params[])
{
    new Cache:execute;

    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    if (!AccountData[playerid][pAdminDuty])
        return SendCustomMessage(playerid, "INFO","Anda harus onduty admin terlebih dahulu");

    if(isnull(params) || strlen(params) > 24)
        return SendSyntaxMessage(playerid, "/baninfo [character username].");

    if(!Blacklist_Exists("Characters", params))
        return SendErrorMessage(playerid, "Nama karakter tidak dalam daftar banned.");

    execute = mysql_query(g_iHandle, sprintf("SELECT * FROM `blacklist` WHERE `Characters` = '%s'", SQL_ReturnEscaped(params)));

    new reason[64], banby[24], time, date;

    if(cache_num_rows()) 
    {
        cache_get_value_int(0, "Temp", time);
        cache_get_value_int(0, "Date", date);

        cache_get_value(0, "BannedBy", banby);
        cache_get_value(0, "Reason", reason);

        if(time) Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "Banned Info", ""WHITE"Ban Lookup: "RED"%s\n"WHITE"Date Banned: "RED"%s\n"WHITE"By Admin/Helper: "RED"%s\n"WHITE"Reason: "RED"%s\n\n"WHITE"Unban Date: "RED"%s", "Close", "", params, ConvertTimestamp(Time:date), banby, reason, ConvertTimestamp(Time:time));
        else Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "Banned Info", ""WHITE"Ban Lookup: "RED"%s\n"WHITE"Date Banned: "RED"%s\n"WHITE"By Admin/Helper: "RED"%s\n"WHITE"Reason: "RED"%s\n\n"WHITE"Unban Date: "RED"Permanent", "Close", "", params, ConvertTimestamp(Time:date), banby, reason);
    }
    cache_delete(execute);
    return 1;
}

CMD:blacklisthelp(playerid, params[])
{
    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);

    SendServerMessage(playerid, "/ban, /unban, /banacp, /unbanacp, /banip, /unbanip, /oban, /tempban, /otempban, /baninfo.");
    return 1;
}

Drugtest_Show(playerid, player){

    new gText[1500];
    format(gText, sizeof(gText), "{C2A2DA}===[Status Kadar Drug]===\n");
    if(PlayerData[player][pKadarCocain] > 0)
    {
        
        format(gText, sizeof(gText), "%s"WHITE"Pecandu: "YELLOW"Kadar Cocain Total:%d\n", gText, PlayerData[player][pKadarCocain]);
    }
    else {
        format(gText, sizeof(gText), "%s"WHITE"Player Bukan Pecandu Cocain\n", gText);
    }

    if(PlayerData[player][pKadarMarijuana] > 0)
    {

        format(gText, sizeof(gText), "%s"WHITE"Pecandu: "YELLOW"Kadar Marijuana Total:%d\n", gText, PlayerData[player][pKadarMarijuana]);
    }
    else {
        format(gText, sizeof(gText), "%s"WHITE"Player Bukan Pecandu Marijuana\n", gText);
    }

    if(PlayerData[player][pkadarHeroin] > 0)
    {
        
        format(gText, sizeof(gText), "%s"WHITE"Pecandu: "YELLOW"Kadar Heroin Total:%d\n", gText, PlayerData[player][pkadarHeroin]);
    }
    else {
        format(gText, sizeof(gText), "%s"WHITE"Player Bukan Pecandu Heroin\n", gText);
    }

    if(PlayerData[player][pKadarSteroids] > 0)
    {
        
        format(gText, sizeof(gText), "%s"WHITE"Pecandu: "YELLOW"Kadar Steroids Total:%d\n", gText, PlayerData[player][pKadarSteroids]);
    }
    else {
        format(gText, sizeof(gText), "%s"WHITE"Player Bukan Pecandu Steroids\n", gText);
    }

    Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, ReturnName2(player), gText, "Close", "");
    return 1;
}

CMD:resetdrugtest(playerid, params[])
{
    new player;

    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);

    if(sscanf(params, "u", player))
        return SendSyntaxMessage(playerid, "/resetdrugtest [playerid/part of name]");

    if(!IsPlayerConnected(player))
        return SendErrorMessage(playerid, "That player isn't logged in.");

    PlayerData[player][pKadarCocain] = 0;
    PlayerData[player][pKadarMarijuana] = 0;
    PlayerData[player][pkadarHeroin] = 0;
    PlayerData[player][pKadarSteroids] = 0;
    SendServerMessage(player, "Admin %s telah mereset kadar drug anda.", ReturnAdminName(playerid));
    SendAdminWarning(X11_TOMATO_1, "AdmWarn: %s reset %s kadar drug.", ReturnName2(playerid),ReturnName2(player));
    return 1;
}

CMD:drugtest(playerid, params[]) {
    
    new userid;
    if(GetFactionType(playerid) != FACTION_FIRE) return SendErrorMessage(playerid, "You're not medic.");

    if (sscanf(params, "u", userid))
        return SendSyntaxMessage(playerid, "/drugtest [playerid/name]");
    
    if (userid == INVALID_PLAYER_ID || !IsPlayerConnected(playerid))
        return SendErrorMessage(playerid, "Invalid playerid or name!");
    
    Drugtest_Show(playerid, userid);
    return 1;
}
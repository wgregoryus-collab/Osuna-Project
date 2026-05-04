/*	Prison Script Module	*/
#include <YSI\y_hooks>

stock const Float:prisonArrays[][4] = {
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {}
};

CMD:prison(playerid, params[])
{
    static
        userid,
        times,
        fine;

    if(GetFactionType(playerid) != FACTION_POLICE) return SendErrorMessage(playerid, "You must be a Police.");
    if(GetFactionType(playerid) != FACTION_POLICE) return SendErrorMessage(playerid, "You must be a Police.");
    if(!PlayerData[playerid][pOnDuty]) return SendErrorMessage(playerid, "You must duty first.");
    if(sscanf(params, "udd", userid, times, fine)) return SendSyntaxMessage(playerid, "/prison [playerid/PartOfName] [minutes] [fine] Maximun 120 Minutes");
    if(userid == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, userid, 5.0)) return SendErrorMessage(playerid, "The player is disconnected or not near you.");
    if(times < 1 || times > 120) return SendErrorMessage(playerid, "The specified time can't be below 1 or above 120.");
    if(!PlayerData[userid][pCuffed]) return SendErrorMessage(playerid, "The player must be cuffed before an prison is made.");
    if(!IsPlayerNearArrest(playerid)) return SendErrorMessage(playerid, "You must be near an prison point.");
    if(fine < 1 || fine > 50000) return SendErrorMessage(playerid, "Fine must be between 0 -  50,000$");

    PlayerData[userid][pPrisoned] = 1;
    PlayerData[userid][pJailTime] = times * 60;
    format(PlayerData[userid][pJailReason], 32, "prison");
    GiveMoney(userid, -fine);

    FactionData[PlayerData[playerid][pFaction]][factionMoney] += fine;
    Faction_Save(PlayerData[playerid][pFaction]);

    StopDragging(userid);

    /*new idx = random(sizeof(prisonArrays));
    SetPlayerPosEx(userid, prisonArrays[idx][0], prisonArrays[idx][1], prisonArrays[idx][2] + 0.3);
    SetPlayerFacingAngle(userid, prisonArrays[idx][3]);

    SetPlayerInterior(userid, 16);
    SetPlayerVirtualWorld(userid, PRISON_WORLD);*/

    ResetPlayer(userid);
    ResetNameTag(userid);

    PlayerData[userid][pWarrants] = 0;
    PlayerData[userid][pCuffed] = 0;

    PlayerTextDrawShow(userid, PlayerTextdraws[userid][textdraw_prison]);
    SetPlayerSpecialAction(userid, SPECIAL_ACTION_NONE);

    SendCustomMessage(userid, "PRISON", "You have been prisoned by "YELLOW"%s "WHITE"for "RED"%d days "WHITE"at Twin Towers Correctional Facility Prison.", ReturnName(playerid, 0), times);
    SendCustomMessage(userid, "PRISON", "You have fined for "COL_RED"%s.", FormatNumber(fine));
    return 1;
}

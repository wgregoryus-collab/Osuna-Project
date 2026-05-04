//=========[ Anticheat ]
new AntiCheatKontol = 1;
#define MAX_ANTICHEAT_WARNINGS    2


public OnPlayerTeleport(playerid, Float:distance)
{
   	if(AccountData[playerid][pAdmin] < 2)
    {
        Kick(playerid);
    }
    return 1;
}

public OnPlayerAirbreak(playerid)
{
    if(AccountData[playerid][pAdmin] < 1 && GetPlayerInterior(playerid) == 0 || GetPlayerInterior(playerid) == 0)
    {
        Kick(playerid);
    }
    return 1;
}


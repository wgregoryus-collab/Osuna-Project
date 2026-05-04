/*	Anti spam detection	*/
#define MAX_FLOODS	5

static
	chat_flood[MAX_PLAYERS] = {0, ...},
	cmd_flood[MAX_PLAYERS] = {0, ...},
	bool:flood_detect[MAX_PLAYERS] = {false, ...};

timer EnableChat[5000](playerid)
{
	chat_flood[playerid] = 0;
	flood_detect[playerid] = false;
	return 1;
}

timer ResetFlood[1000](playerid) {
	cmd_flood[playerid] = 0;
	return 1;
}

#include <YSI\y_hooks>
hook OnPlayerText(playerid, text[])
{
	if(chat_flood[playerid] < MAX_FLOODS)
	{
		chat_flood[playerid]++;
		if(chat_flood[playerid] == MAX_FLOODS)
		{
			defer EnableChat(playerid);
			flood_detect[playerid] = true;
		}
		return 1;
	}
	return 0;
}

IsPlayerFlooding(playerid) {
	return flood_detect[playerid];
}

ptask FloodTimer[2500](playerid)
{
	if(SQL_IsLogged(playerid) && flood_detect[playerid] == false)
	{
		chat_flood[playerid] = 0;
	}
	return 1;
}

hook OnPlayerCommandReceived(playerid, cmd[], params[], flags) {
	if (cmd_flood[playerid]) {
		SendClientMessage(playerid, X11_GREY_80, "CMDINFO: Harap tunggu 1 detik");
		return 0;
	}
	cmd_flood[playerid] = 1;
	defer ResetFlood(playerid);
	return 1;
}

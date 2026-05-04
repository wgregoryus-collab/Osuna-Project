#define IsPlayerInEvent(%0)	eventJoin[%0]

new
	eventJoin[MAX_PLAYERS] = {0, ...},
	eventTeams[MAX_PLAYERS] = {0, ...},
	eventWaitingSpawn[MAX_PLAYERS] = {0, ...},
	eventCheckpoint[MAX_PLAYERS] = {0, ...},
	Text:eventTextdraws[8],
	// eventWeapon[MAX_PLAYERS][13],
	eventMessageText[4][128],
	Timer:haupdate[MAX_PLAYERS];

enum 	_:E_EVENT_TEAM
{
	TEAM_NONE = 0,
	TEAM_A,
	TEAM_B
}

enum 	_:E_EVENT_TYPE
{
	TYPE_NONE = 0,
	TYPE_TDM,
	TYPE_JETPACK
}

enum event_Jetpack {
    Float:jX,
    Float:jY,
    Float:jZ
};

new const arrJetEvent[][event_Jetpack] = {
	//Los Santos
	{725.51,-1476.08,29.68},
	{725.10,-1584.11,5.44},
	{725.26,-1667.08,17.05},
	{724.54,-1766.82,6.23},
	{724.42,-1842.11,20.70},
	{724.41,-1857.00,5.35},
	{715.27,-1914.62,19.21},
	{749.51,-1985.47,25.89},
	{805.21,-2048.82,11.13},
	{843.19,-2061.51,3.03},
	{911.29,-2065.96,14.53},
	{993.35,-2064.41,32.82},
	{1060.26,-2041.09,83.97},
	{1130.01,-2039.44,94.28},
	{1232.69,-2037.65,75.04},
	{1148.08,-2037.00,69.00},

    //San Fierro
	{-1533.40, -417.72, 11.40},
	{-1567.65, -452.43, 6.21},
	{-1612.69, -497.22, 13.74},
	{-1734.83, -580.01, 18.18},
	{-1872.11, -579.87, 50.09},
	{-1965.11, -579.28, 29.44},
	{-2069.07, -574.30, 74.39},
	{-2163.35, -481.39, 53.86},
	{-2161.57, -457.08, 44.74},
	{-2110.10, -397.55, 38.23},
	{-2068.84, -394.53, 39.59},
	{-2036.40, -386.08, 39.81},
	{-1996.79, -393.14, 43.32},
	{-1919.60, -450.80, 31.89},
	{-1820.38, -557.38, 30.91},
	{-1491.26,-377.14,15.53},

	//Las Venturas
	{1733.75, 2319.28, 28.35},
	{1696.49, 2328.40, 17.70},
	{1690.81, 2274.46, 21.56},
	{1596.32, 2208.17, 10.82},
	{1596.12, 2187.56, 15.79},
	{1572.73, 2150.90, 12.80},
	{1572.75, 2131.49, 29.58},
	{1572.52, 2085.22, 11.49},
	{1572.65, 2061.60, 30.63},
	{1546.65, 1999.93, 14.73},
	{1484.20, 2009.34, 12.07},
	{1483.90, 1983.16, 13.53},
	{1471.25, 1980.38, 14.19},
	{1472.40, 2013.94, 15.29},
	{1476.86,2052.31,20.87},
	{1518.72, 2062.13, 10.82}
};

enum 	E_EVENT
{
	eventMessage[128],
	eventType,
	eventJetpackType,
	eventCreated,
	eventStart,
	Float:eventHealth,
	Float:eventArmor,
	eventTarget,
	eventBonus,
	eventSelectTeam,
	eventWinner,
	eventOpen,
	eventWorld,
	eventInt,
	eventWeapons[3],
	eventAmmo[3],

	//Team enum's
	eventSkin[2],
	eventTeamScore[2],
	eventScore[2],
	Float:eventSpawnX[2],
	Float:eventSpawnY[2],
	Float:eventSpawnZ[2],
	Float:eventSpawnA[2]
};

new eventData[E_EVENT];

stock GiveEventWeaponToPlayer(playerid, weaponid, ammo) {
	GivePlayerWeapon(playerid, weaponid, ammo);
	return 1;
}

stock ResetEventWeapons(playerid) {
	ResetPlayerWeapons(playerid);
	return 1;
}

stock EventType(type)
{
	new name[10];
	switch(type)
	{
		case TYPE_TDM: name = "TDM";
		case TYPE_JETPACK: name = "Jetpack";
		case TYPE_NONE: name = "N/A";
	}
	return name;
}

stock eventCount()
{
	new count = 0;
	foreach(new i : Player) if(IsPlayerInEvent(i)) {
		count++;
	}
	return count;
}

stock SendEventMessageAll(color, message[])
{
	foreach(new i : Player) if(IsPlayerInEvent(i)) 
	{
		SendClientMessage(i, color, message);
	}
	return 1;
}
stock SendEventTeamMessage(playerid, color, message[])
{
	foreach(new i : Player) if(IsPlayerInEvent(i) && eventTeams[playerid] == eventTeams[i]) {
		SendClientMessage(i, color, message);
	}
	return 1;
}

stock eventTextdraw(playerid, text[])
{
	if(IsPlayerInEvent(playerid))
	{
		TextDrawSetString(eventTextdraws[2], sprintf("%d!", eventData[eventTarget]));
		TextDrawSetString(eventTextdraws[3], sprintf("~r~Team_A:_%d~n~~b~Team_B:_%d", eventData[eventScore][0], eventData[eventScore][1]));

		eventMessageText[0] = eventMessageText[1];
		eventMessageText[1] = eventMessageText[2];
		eventMessageText[2] = eventMessageText[3];
		format(eventMessageText[3], 128, text);

		TextDrawSetString(eventTextdraws[4],eventMessageText[0]);
		TextDrawSetString(eventTextdraws[5],eventMessageText[1]);
		TextDrawSetString(eventTextdraws[6],eventMessageText[2]);
		TextDrawSetString(eventTextdraws[7],eventMessageText[3]);
	}
	return 1;
}

timer eventSpawnProp[500](playerid)
{
	if(SQL_IsLogged(playerid) && IsPlayerInEvent(playerid))
	{
		SetPlayerHealth(playerid, eventData[eventHealth]);
		SetPlayerArmour(playerid, eventData[eventArmor]);
	}
}

Function:eventSpawnTimer(playerid)
{
	SetPlayerVirtualWorld(playerid, eventData[eventWorld]);
	TogglePlayerControllable(playerid, 1);
	SendCustomMessage(playerid, "EVENT", "You can kill enemy now!.");

	eventWaitingSpawn[playerid] = 0;
	eventSpawn(playerid);
	return 1;
}

stock eventSpawn(playerid)
{
	if(IsPlayerInEvent(playerid))
	{
		SetPlayerPos(playerid, eventData[eventSpawnX][eventTeams[playerid]-1], eventData[eventSpawnY][eventTeams[playerid]-1], eventData[eventSpawnZ][eventTeams[playerid]-1]);
		SetPlayerFacingAngle(playerid, eventData[eventSpawnA][eventTeams[playerid]-1]);
		SetCameraBehindPlayer(playerid);

		SetPlayerSkinEx(playerid, eventData[eventSkin][eventTeams[playerid]-1], 0, 1);

		SetPlayerInterior(playerid, eventData[eventInt]);
		SetPlayerVirtualWorld(playerid, eventData[eventWorld]);

		ResetPlayerWeapons(playerid);

		for(new i = 0; i != 3; i++) if(eventData[eventWeapons][i]) {
			GiveEventWeaponToPlayer(playerid, eventData[eventWeapons][i], eventData[eventAmmo][i]);
			// GivePlayerWeaponEx(playerid, eventData[eventWeapons][0], eventData[eventAmmo][0], eventData[eventWeapons][1], eventData[eventAmmo][1], eventData[eventWeapons][2], eventData[eventAmmo][2]);
		}
		SendServerMessage(playerid, "You're spawn to the event.");

		haupdate[playerid] = defer eventSpawnProp[500](playerid);

		if(eventWaitingSpawn[playerid])
		{
			SetPlayerVirtualWorld(playerid, (playerid+1));
			TogglePlayerControllable(playerid, 0);
			SetPlayerPos(playerid, eventData[eventSpawnX][eventTeams[playerid]-1], eventData[eventSpawnY][eventTeams[playerid]-1], eventData[eventSpawnZ][eventTeams[playerid]-1]);
			SetTimerEx("eventSpawnTimer", 3000, false, "d", playerid);
			SendCustomMessage(playerid, "EVENT", "Waiting 3 seconds to spawn with other player.");
		}
	}
	return 1;
}

stock eventLeave(playerid)
{
	if(eventData[eventType] == TYPE_TDM)
	{
		eventTeams[playerid] = TEAM_NONE;
		SetPlayerTeam(playerid, NO_TEAM);
		ResetEventWeapons(playerid);
		
		if(IsPlayerDuty(playerid)) RefreshFactionWeapon(playerid); 
		else RefreshWeapon(playerid);

		for(new id = 0; id != 8; id++) {
			TextDrawHideForPlayer(playerid, eventTextdraws[id]);
		}
	}

	eventJoin[playerid] = 0;

	SetPlayerInterior(playerid, PlayerData[playerid][pInterior]);
	SetPlayerVirtualWorld(playerid, PlayerData[playerid][pWorld]);

	SetPlayerPosEx(playerid, PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2]);

	SetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
	SetPlayerArmour(playerid, PlayerData[playerid][pArmorStatus]);

	if(AccountData[playerid][pAdminDuty]) SetPlayerSkinEx(playerid, PlayerData[playerid][pSkin], 0, 1), SetPlayerColor(playerid, X11_RED);
	else if (PlayerData[playerid][pOnDuty]) SetFactionColor(playerid), SetPlayerSkinEx(playerid, PlayerData[playerid][pSkinFaction], 1);
	else SetPlayerSkinEx(playerid, PlayerData[playerid][pSkin], 0, 1), SetPlayerColor(playerid, DEFAULT_COLOR);

	DisablePlayerRaceCheckpoint(playerid);

	if(IsPlayerDuty(playerid)) RefreshFactionWeapon(playerid); 
	else RefreshWeapon(playerid);

	for (new i = 0; i != MAX_ACC; i ++) if (AccData[playerid][i][accExists] && AccData[playerid][i][accShow]) {
		Aksesoris_Attach(playerid, i);
	}

	return 1;
}

#include <YSI\y_hooks>
hook OnPlayerText(playerid, text[])
{
	if(IsPlayerInEvent(playerid))
	{
		foreach(new i : Player) if(IsPlayerInEvent(i) && eventTeams[playerid] == eventTeams[i]) {
			SendClientMessageEx(i, eventTeams[playerid] == TEAM_A ? X11_RED : COLOR_BLUE, "%s: "WHITE"%s", ReturnName(playerid, 0), text);
		}
	}

	return 1;
}


hook OnPlayerConnect(playerid)
{
	eventJoin[playerid] = 0;
	eventTeams[playerid] = 0;

	return 1;
}

// hook OnPlayerDisconnectEx(playerid) {
// 	if (IsPlayerInEvent(playerid)) {
// 		eventTeams[playerid] = TEAM_NONE;
// 		SetPlayerTeam(playerid, NO_TEAM);
// 		ResetEventWeapons(playerid);

// 		eventJoin[playerid] = 0;
// 	}

//	return 1;
// }


hook OnGameModeInit()
{
	eventTextdraws[0] = TextDrawCreate(503.306060, 147.999954, "box");
	TextDrawLetterSize(eventTextdraws[0], 0.000000, 8.594435);
	TextDrawTextSize(eventTextdraws[0], 631.395507, 0.000000);
	TextDrawAlignment(eventTextdraws[0], 1);
	TextDrawColor(eventTextdraws[0], -1);
	TextDrawUseBox(eventTextdraws[0], 1);
	TextDrawBoxColor(eventTextdraws[0], 189);
	TextDrawSetShadow(eventTextdraws[0], 0);
	TextDrawSetOutline(eventTextdraws[0], 0);
	TextDrawBackgroundColor(eventTextdraws[0], 255);
	TextDrawFont(eventTextdraws[0], 1);
	TextDrawSetProportional(eventTextdraws[0], 1);
	TextDrawSetShadow(eventTextdraws[0], 0);

	eventTextdraws[1] = TextDrawCreate(567.464721, 150.716690, "TDM_EVENT_SCOREBOARD");
	TextDrawLetterSize(eventTextdraws[1], 0.251010, 1.349166);
	TextDrawTextSize(eventTextdraws[1], 0.000000, 123.000000);
	TextDrawAlignment(eventTextdraws[1], 2);
	TextDrawColor(eventTextdraws[1], -1061109505);
	TextDrawUseBox(eventTextdraws[1], 1);
	TextDrawBoxColor(eventTextdraws[1], -1061109505);
	TextDrawSetShadow(eventTextdraws[1], 0);
	TextDrawSetOutline(eventTextdraws[1], 1);
	TextDrawBackgroundColor(eventTextdraws[1], 255);
	TextDrawFont(eventTextdraws[1], 1);
	TextDrawSetProportional(eventTextdraws[1], 1);
	TextDrawSetShadow(eventTextdraws[1], 0);

	eventTextdraws[2] = TextDrawCreate(565.522460, 166.834075, "0!");
	TextDrawLetterSize(eventTextdraws[2], 0.466158, 2.332501);
	TextDrawAlignment(eventTextdraws[2], 2);
	TextDrawColor(eventTextdraws[2], -1061109505);
	TextDrawSetShadow(eventTextdraws[2], 0);
	TextDrawSetOutline(eventTextdraws[2], 1);
	TextDrawBackgroundColor(eventTextdraws[2], 255);
	TextDrawFont(eventTextdraws[2], 3);
	TextDrawSetProportional(eventTextdraws[2], 1);
	TextDrawSetShadow(eventTextdraws[2], 0);

	eventTextdraws[3] = TextDrawCreate(505.045623, 190.785247, "Team_A:_0");
	TextDrawLetterSize(eventTextdraws[3], 0.270000, 1.399999);
	TextDrawAlignment(eventTextdraws[3], 1);
	TextDrawColor(eventTextdraws[3], -16777023);
	TextDrawSetShadow(eventTextdraws[3], 0);
	TextDrawSetOutline(eventTextdraws[3], 1);
	TextDrawBackgroundColor(eventTextdraws[3], 255);
	TextDrawFont(eventTextdraws[3], 1);
	TextDrawSetProportional(eventTextdraws[3], 1);
	TextDrawSetShadow(eventTextdraws[3], 0);

	eventTextdraws[4] = TextDrawCreate(635.461364, 332.133422, "_");
	TextDrawLetterSize(eventTextdraws[4], 0.203220, 1.174166);
	TextDrawAlignment(eventTextdraws[4], 3);
	TextDrawColor(eventTextdraws[4], -1);
	TextDrawSetShadow(eventTextdraws[4], 0);
	TextDrawSetOutline(eventTextdraws[4], 1);
	TextDrawBackgroundColor(eventTextdraws[4], 255);
	TextDrawFont(eventTextdraws[4], 1);
	TextDrawSetProportional(eventTextdraws[4], 1);
	TextDrawSetShadow(eventTextdraws[4], 0);

	eventTextdraws[5] = TextDrawCreate(635.461364, 343.133422, "_");
	TextDrawLetterSize(eventTextdraws[5], 0.203220, 1.174166);
	TextDrawAlignment(eventTextdraws[5], 3);
	TextDrawColor(eventTextdraws[5], -1);
	TextDrawSetShadow(eventTextdraws[5], 0);
	TextDrawSetOutline(eventTextdraws[5], 1);
	TextDrawBackgroundColor(eventTextdraws[5], 255);
	TextDrawFont(eventTextdraws[5], 1);
	TextDrawSetProportional(eventTextdraws[5], 1);
	TextDrawSetShadow(eventTextdraws[5], 0);

	eventTextdraws[6] = TextDrawCreate(635.461364, 354.133422, "_");
	TextDrawLetterSize(eventTextdraws[6], 0.203220, 1.174166);
	TextDrawAlignment(eventTextdraws[6], 3);
	TextDrawColor(eventTextdraws[6], -1);
	TextDrawSetShadow(eventTextdraws[6], 0);
	TextDrawSetOutline(eventTextdraws[6], 1);
	TextDrawBackgroundColor(eventTextdraws[6], 255);
	TextDrawFont(eventTextdraws[6], 1);
	TextDrawSetProportional(eventTextdraws[6], 1);
	TextDrawSetShadow(eventTextdraws[6], 0);

	eventTextdraws[7] = TextDrawCreate(635.461364, 365.133422, "_");
	TextDrawLetterSize(eventTextdraws[7], 0.203220, 1.174166);
	TextDrawAlignment(eventTextdraws[7], 3);
	TextDrawColor(eventTextdraws[7], -1);
	TextDrawSetShadow(eventTextdraws[7], 0);
	TextDrawSetOutline(eventTextdraws[7], 1);
	TextDrawBackgroundColor(eventTextdraws[7], 255);
	TextDrawFont(eventTextdraws[7], 1);
	TextDrawSetProportional(eventTextdraws[7], 1);
	TextDrawSetShadow(eventTextdraws[7], 0);

	return 1;
}


hook OnPlayerDeath(playerid, killerid, reason) {
	if (killerid != INVALID_PLAYER_ID) {
		if (IsPlayerInEvent(playerid)) {
			eventData[eventScore][eventTeams[killerid]-1]++;

			eventTextdraw(playerid, sprintf("%s%s~w~_has_killed_by_%s%s_~w~Team_%s%s:_~g~%d", eventTeams[playerid] == TEAM_A ? ("~r~") : ("~b~"), 
				ReturnName(playerid), eventTeams[killerid] == TEAM_A ? ("~r~") : ("~b~"),
				ReturnName(killerid), eventTeams[killerid] == TEAM_A ? ("~r~") : ("~b~"),
				eventTeams[killerid] == TEAM_A ? ("A") : ("B"), eventData[eventScore][eventTeams[killerid]-1])
			);

			if(eventData[eventScore][eventTeams[killerid]-1] == eventData[eventTarget]) {
				eventData[eventWinner] = eventTeams[killerid];

				SendEventMessageAll(COLOR_CLIENT, sprintf("EVENT: "WHITE"Event telah selesai dan "YELLOW"team %s "WHITE"sebagai pemenang.", (eventTeams[killerid] == TEAM_A) ? ("A") : ("B")));

				foreach(new i : Player) if(IsPlayerInEvent(i))
				{
					if(eventTeams[i] == eventData[eventWinner]) GiveMoney(i, eventData[eventBonus]*3), SendCustomMessage(i, "EVENT", "Team anda menang dalam event ini dan mendapat hadiah sebanyak {00FF00}%s.", FormatNumber(eventData[eventBonus]*3));
					else GiveMoney(i, eventData[eventBonus]), SendCustomMessage(i, "EVENT", "Kamu mendapat bonus {00FF00}%s "WHITE"dari partisipasi event.", FormatNumber(eventData[eventBonus]));

					eventLeave(i);
				}
				static const empty_player[E_EVENT];
				eventData = empty_player;
			}
			else eventWaitingSpawn[playerid] = 1;
		}
	}

	return 1;
}


hook OnPlayerSpawn(playerid)
{
	if (IsPlayerInEvent(playerid)) {
		if (eventTeams[playerid] == TEAM_A) {
			SetPlayerColor(playerid, RemoveAlpha(X11_RED));
		} else SetPlayerColor(playerid, RemoveAlpha(COLOR_BLUE));
		eventSpawn(playerid);
	}

	return 1;
}

CMD:event(playerid, params[])
{
	static
		option[10],
		extendstring[128];

	if(sscanf(params, "s[10]S()[128]", option, extendstring))
	{
		if(AccountData[playerid][pAdmin] > 4) return SendSyntaxMessage(playerid, "/event [create/end/open/start/weapon/spawn1/spawn2/message]");
		else return SendSyntaxMessage(playerid, "/event [join/leave/respawn]");
	}
	if(!strcmp(option, "message")) {
		new message[128];
		if (CheckAdmin(playerid, 4)) return PermissionError(playerid);
		
		if(!eventData[eventCreated])
			return SendErrorMessage(playerid, "Tidak ada event yang di lakukan sekarang.");

		if(sscanf(extendstring, "s[128]", message))
			return SendSyntaxMessage(playerid, "/event message [text]");

		format(eventData[eventMessage], 128, ColouredText(message));
		SendCustomMessage(playerid, "EVENT", "%s", message);
	}
	else if(!strcmp(option, "open")) {
		if (CheckAdmin(playerid, 4)) return PermissionError(playerid);
		if(!eventData[eventCreated])
			return SendErrorMessage(playerid, "Tidak ada event yang di lakukan sekarang.");

		if(eventData[eventType] == TYPE_TDM && (eventData[eventSpawnX][0] == 0.0 || eventData[eventSpawnX][1] == 0.0))
			return SendErrorMessage(playerid, "Lokasi team belum di tentukan, /event [spawn1/2].");

		eventData[eventOpen] = 1;
		eventMessageText[0] = "_";
		eventMessageText[1] = "_";
		eventMessageText[2] = "_";
		eventMessageText[3] = "_";
		SendClientMessageToAllEx(COLOR_CLIENT, "EVENT: "RED"%s "WHITE"mengadakan %s event, "YELLOW"/event join "WHITE"untuk berpartisipasi!.", ReturnAdminName(playerid), EventType(eventData[eventType]));
	}
	else if(!strcmp(option, "leave")) {
		if(!eventData[eventCreated])
			return SendErrorMessage(playerid, "Tidak ada event yang di lakukan sekarang.");

		if(!IsPlayerInEvent(playerid))
			return SendErrorMessage(playerid, "Kamu tidak dalam acara event.");

		if(!eventData[eventStart])
			return SendErrorMessage(playerid, "Event belum di mulai, tidak dapat meninggalkan event.");

		eventLeave(playerid);

        SendServerMessage(playerid, "Kamu telah meninggalkan event yang sedang berlangsung, kamu tidak mendapatkan bonus dari event.");
	}
	else if(!strcmp(option, "start")) {
		if (CheckAdmin(playerid, 4)) return PermissionError(playerid);

		if(!eventData[eventCreated])
			return SendErrorMessage(playerid, "Tidak ada event yang di lakukan sekarang.");

		if(!eventData[eventOpen])
			return SendErrorMessage(playerid, "Buka partisipasi event terlebih dahulu dengan perintah "WHITE"'/event open'.");

		if(eventData[eventStart])
			return SendErrorMessage(playerid, "Event telah dimulai sebelumnya.");

		if(!eventCount())
			return SendErrorMessage(playerid, "Tidak ada satupun yang ikut berpartisipasi.");

		eventData[eventStart] = 1;
		eventData[eventOpen] = 0;

		foreach(new i : Player) if(IsPlayerInEvent(i)) {
			TogglePlayerControllable(i, 1);
			SetPlayerVirtualWorld(i, eventData[eventWorld]);

			if(eventData[eventType] == TYPE_JETPACK) {
				PlayerData[i][pJetpack] = 1;
				SetPlayerSpecialAction(i, SPECIAL_ACTION_USEJETPACK);
			}
		}

		if(eventData[eventType] == TYPE_JETPACK)
		{
			for(new id = 4; id != 8; id++) {
				TextDrawHideForPlayer(playerid, eventTextdraws[id]);
			}
		}

		SendClientMessageToAllEx(COLOR_CLIENT, "EVENT: "RED"%s "WHITE"memulai event "RED"%s"WHITE", tidak dapat bergabung bagi yang belum masuk ke dalam event.", ReturnAdminName(playerid), EventType(eventData[eventType]));
	}
	else if(!strcmp(option, "join")) {
		if(PlayerData[playerid][pInjured])
			return SendErrorMessage(playerid, "You're on injured mode.");

		if(!eventData[eventCreated] || !eventData[eventOpen])
			return SendErrorMessage(playerid, "Tidak ada event yang di lakukan sekarang.");

		if(eventData[eventStart])
			return SendErrorMessage(playerid, "Event sedang berlangsung, tidak dapat mengikutinya lagi.");

		if(PlayerData[playerid][pJailTime])
			return SendErrorMessage(playerid, "Waktu di penjara belum habis, tidak dapat mengikuti event.");

		if (AccountData[playerid][pAdminDuty])
			return SendErrorMessage(playerid, "You must off duty admin to join event.");

		if (PlayerData[playerid][pMaskOn])
			return SendErrorMessage(playerid, "Disable your mask first!");

		if(IsPlayerInEvent(playerid))
			return SendErrorMessage(playerid, "Kamu telah berada dalam event.");

		if(PlayerData[playerid][pTazer])
			cmd_tazer(playerid, "\0");

		for (new id = 0; id < MAX_PLAYER_ATTACHED_OBJECTS; id++) if(IsPlayerAttachedObjectSlotUsed(playerid, id)) 
		{
			RemovePlayerAttachedObject(playerid, id);
		}

		//Team Selection

		eventJoin[playerid] = 1;

		//Player default data
		PlayerData[playerid][pInterior] = GetPlayerInterior(playerid);
		PlayerData[playerid][pWorld] = GetPlayerVirtualWorld(playerid);

		GetPlayerPos(playerid, PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2]);
		GetPlayerFacingAngle(playerid, PlayerData[playerid][pPos][3]);

		GetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
		GetPlayerArmour(playerid, PlayerData[playerid][pArmorStatus]);
	
		if(eventData[eventType] == TYPE_TDM)
		{
			ResetPlayerWeapons(playerid);

			if(eventData[eventSelectTeam])  {
				eventData[eventSelectTeam] = 0;
				eventTeams[playerid] = TEAM_A;
				SetPlayerColor(playerid, RemoveAlpha(X11_RED));
			}
			else {
				eventData[eventSelectTeam] = 1; 
				eventTeams[playerid] = TEAM_B;
				SetPlayerColor(playerid, RemoveAlpha(COLOR_BLUE));
			}

			SetPlayerTeam(playerid, eventTeams[playerid]);

			//Event textdraw
			for(new id = 0; id != 8; id++) {
				TextDrawShowForPlayer(playerid, eventTextdraws[id]);
			}

			//New event data
			eventSpawn(playerid);
			TogglePlayerControllable(playerid, 0);
			SetPlayerVirtualWorld(playerid, (playerid+1));

			eventTextdraw(playerid, sprintf("%s%s~w~_bergabung dalam event sebagai team %s", eventTeams[playerid] == TEAM_A ? ("~r~") : ("~b~"), ReturnName(playerid), eventTeams[playerid] == TEAM_A ? ("~r~A") : ("~b~B")));
			SendCustomMessage(playerid, "EVENT", "Kamu memasuki event sebagai team %s"WHITE", Kamu akan melihat player lain saat event dimulai.", eventTeams[playerid] == TEAM_A ? (""RED"A") : ("{0049FF}B"));
		}
		else if(eventData[eventType] == TYPE_JETPACK)
		{
			SetPlayerSkinEx(playerid, 5, 0, 1);

			SetPlayerInterior(playerid, eventData[eventInt]);
			SetPlayerVirtualWorld(playerid, eventData[eventWorld]);
			SetPlayerColor(playerid, RemoveAlpha(COLOR_ORANGE));

			for(new id = 4; id != 8; id++) {
				TextDrawShowForPlayer(playerid, eventTextdraws[id]);
			}

			eventTextdraw(playerid, sprintf("~y~%s~w~_bergabung dalam ~r~jetpack event", ReturnName(playerid)));
			SendCustomMessage(playerid, "EVENT", "Kamu memasuki jetpack event, Kamu akan melihat player lain saat event dimulai.");

			eventCheckpoint[playerid] = ((eventData[eventJetpackType]*16)-16);

			switch(eventData[eventJetpackType])
			{
				case 1: SetPlayerPosEx(playerid, 726.0457,-1460.6995,22.2109), SetPlayerFacingAngle(playerid, 178.90); 
				case 2: SetPlayerPosEx(playerid, -1513.5300,-397.7400,7.0781), SetPlayerFacingAngle(playerid, 135.09);
				case 3: SetPlayerPosEx(playerid, 1748.9951,2318.4055,22.8222), SetPlayerFacingAngle(playerid, 90.66);
			}
			
			SetCameraBehindPlayer(playerid);
			SetPlayerInterior(playerid, eventData[eventInt]);
			SetPlayerVirtualWorld(playerid, eventData[eventWorld]);

			SetPlayerRaceCheckpoint(playerid, 4, arrJetEvent[eventCheckpoint[playerid]][jX], arrJetEvent[eventCheckpoint[playerid]][jY], 
				arrJetEvent[eventCheckpoint[playerid]][jZ], arrJetEvent[eventCheckpoint[playerid]+1][jX], arrJetEvent[eventCheckpoint[playerid]+1][jY], 
				arrJetEvent[eventCheckpoint[playerid]+1][jZ], 3
			);
		}
		SendCustomMessage(playerid, "EVENT","%s.", eventData[eventMessage]);
	}
	else if (!strcmp(option, "respawn")) {
		if (!IsPlayerInEvent(playerid))
			return SendErrorMessage(playerid, "Kamu tidak berada di dalam event.");

		if(eventWaitingSpawn[playerid]) {
			eventSpawn(playerid);
		} else {
			SendErrorMessage(playerid, "Kamu sudah spawn ke dalam event.");
		}
	}
	else if(!strcmp(option, "create")) {
		if (CheckAdmin(playerid, 4)) return PermissionError(playerid);
		if(eventData[eventStart])
			return SendErrorMessage(playerid, "Event telah berlangsung.");

		Dialog_Show(playerid, eventType, DIALOG_STYLE_LIST, "Event Type", "TDM\nJetpack", "Select", "Close");
	}
	else if(!strcmp(option, "end")) {
		if (CheckAdmin(playerid, 4)) return PermissionError(playerid);

		static const empty_player[E_EVENT];
		eventData = empty_player;

		SendEventMessageAll(COLOR_CLIENT, sprintf("EVENT: "WHITE"%s menghentikan event yang sedang berlangsung.", ReturnAdminName(playerid)));
		SendServerMessage(playerid, "Kamu menghentikan event.");

		foreach (new i : Player) {
			for(new id = 0; id != 8; id++) {
				TextDrawHideForPlayer(i, eventTextdraws[id]);
			}
		}
			
		foreach(new i : Player) if(IsPlayerInEvent(i)) {
			eventLeave(i);
		}
	}
	else if(!strcmp(option, "spawn1")) {
		if (CheckAdmin(playerid, 4)) return PermissionError(playerid);

		if(!eventData[eventCreated])
			return SendErrorMessage(playerid, "Tidak ada event yang di lakukan sekarang.");

		GetPlayerPos(playerid, eventData[eventSpawnX][0], eventData[eventSpawnY][0], eventData[eventSpawnZ][0]);
		GetPlayerFacingAngle(playerid, eventData[eventSpawnA][0]);
		SendServerMessage(playerid, "Kamu telah menentukan spawn untuk "RED"team A");
	}
	else if(!strcmp(option, "spawn2")) {
		if (CheckAdmin(playerid, 4)) return PermissionError(playerid);
		if(!eventData[eventCreated])
			return SendErrorMessage(playerid, "Tidak ada event yang di lakukan sekarang.");

		GetPlayerPos(playerid, eventData[eventSpawnX][1], eventData[eventSpawnY][1], eventData[eventSpawnZ][1]);
		GetPlayerFacingAngle(playerid, eventData[eventSpawnA][1]);
		SendServerMessage(playerid, "Kamu telah menentukan spawn untuk {0049FF}team B");
	}
	else if(!strcmp(option, "weapon")) {
		if (CheckAdmin(playerid, 4)) return PermissionError(playerid);

		if(!eventData[eventCreated])
			return SendErrorMessage(playerid, "Tidak ada event yang di lakukan sekarang.");

		Dialog_Show(playerid, eventWeapon, DIALOG_STYLE_LIST, "Event Weapon", "Weapon 1: %s - %d\nWeapon 2: %s - %d\nWeapon 3: %s - %d", "Edit", "Close", 
			ReturnWeaponName(eventData[eventWeapons][0]),
			eventData[eventAmmo][0],
			ReturnWeaponName(eventData[eventWeapons][1]),
			eventData[eventAmmo][1],
			ReturnWeaponName(eventData[eventWeapons][2]),
			eventData[eventAmmo][2]
		);
	}
	return 1;
}

Dialog:eventWeapon(playerid, response, listitem, inputtext[])
{
	if(response) {
		SetPVarInt(playerid, "selectWeapon", listitem);
		Dialog_Show(playerid, editWeaponId, DIALOG_STYLE_INPUT, "Weapon Id", "Insert Weapon ID:", "Set", "Back");
	}
	return 1;
}

Dialog:editWeaponId(playerid, response, listitem, inputtext[])
{
	if(response) {
		new id = GetPVarInt(playerid, "selectWeapon");

		if(strval(inputtext) <= 0 || strval(inputtext) > 46 || (strval(inputtext) >= 19 && strval(inputtext) <= 21))
			return Dialog_Show(playerid, editWeaponId, DIALOG_STYLE_INPUT, "Weapon Id", "You have specified an invalid weapon!\n\nInsert Weapon ID:", "Set", "Back");

		eventData[eventWeapons][id] = strval(inputtext);
		Dialog_Show(playerid, editWeaponAmmo, DIALOG_STYLE_INPUT, "Weapon Ammo", "Insert the ammo for %s:", "Set", "Back", ReturnWeaponName(eventData[eventWeapons][id]));
	}
	else cmd_event(playerid, "weapon");
	return 1;
}

Dialog:editWeaponAmmo(playerid, response, listitem, inputtext[])
{
	if(response) {
		new id = GetPVarInt(playerid, "selectWeapon");

		if(strval(inputtext) < 1 || strval(inputtext) > 1000)
			return Dialog_Show(playerid, editWeaponId, DIALOG_STYLE_INPUT, "Weapon Id", "You have specified an invalid weapon ammo, 1 - 1,000!\n\nInsert the ammo for %s:", "Set", "Back", eventData[eventWeapons][id]);

		eventData[eventAmmo][id] = strval(inputtext);
		DeletePVar(playerid, "selectWeapon");

		cmd_event(playerid, "weapon");
	}
	else Dialog_Show(playerid, editWeaponId, DIALOG_STYLE_INPUT, "Weapon Id", "Insert Weapon ID:", "Set", "Back");
	return 1;
}

Dialog:eventType(playerid, response, listitem, inputtext[])
{
	if(response) {
		eventData[eventType] = (listitem+1);

		if(eventData[eventType] == TYPE_TDM)
			Dialog_Show(playerid, eventTarget, DIALOG_STYLE_INPUT, "Target Score", "How much target:", "Set", "Back");

		if(eventData[eventType] == TYPE_JETPACK)
			Dialog_Show(playerid, eventBonus, DIALOG_STYLE_INPUT, "Event {00FF00}Bonus", "Masukkan berapa bonus yang akan di berikan:", "Set", "Back");
	}
	return 1;
}

Dialog:eventTarget(playerid, response, listitem, inputtext[])
{
	if(response) {
		if(strval(inputtext) < 1 || strval(inputtext) > 150)
			return Dialog_Show(playerid, eventTarget, DIALOG_STYLE_INPUT, "Target Score", "Target score must be betweed 1 - 150\n\nHow much target:", "Set", "Back");

		eventData[eventTarget] = strval(inputtext);

		Dialog_Show(playerid, eventSkin, DIALOG_STYLE_LIST, "Skin Event", "Team 1: %d\nTeam 2: %d\nNext", "Set", "Back", eventData[eventSkin][0], eventData[eventSkin][1]);
	}
	else cmd_event(playerid, "create");
	return 1;
}

Dialog:eventSkin(playerid, response, listitem, inputtext[])
{
	if(response) {
		switch(listitem)
		{
			case 0: Dialog_Show(playerid, eventSkin1, DIALOG_STYLE_INPUT, "Skin Team 1", "Masukkan id skin:", "Set", "Back");
			case 1: Dialog_Show(playerid, eventSkin2, DIALOG_STYLE_INPUT, "Skin Team 2", "Masukkan id skin:", "Set", "Back");
			case 2: 
			{
				if(!eventData[eventSkin][0] || !eventData[eventSkin][1])
					return Dialog_Show(playerid, eventSkin, DIALOG_STYLE_LIST, "Skin can't 0", "Team 1: %d\nTeam 2: %d\nNext", "Set", "Back", eventData[eventSkin][0], eventData[eventSkin][1]);

				Dialog_Show(playerid, eventHealth, DIALOG_STYLE_INPUT, "Event "RED"Health", "Masukkan value darah yang akan di berikan:", "Set", "Back");
			}
		}
	}
	else Dialog_Show(playerid, eventTarget, DIALOG_STYLE_INPUT, "Target Score", "How much target:", "Set", "Back");
	return 1;
}

Dialog:eventSkin1(playerid, response, listitem, inputtext[])
{
	if(response) {
		if(strval(inputtext) < 1 || strval(inputtext) > 311)
			return Dialog_Show(playerid, eventSkin1, DIALOG_STYLE_INPUT, "Skin Team 1", "Id skin tidak sesuai\n\nMasukkan id skin:", "Set", "Back");

		eventData[eventSkin][0] = strval(inputtext);
		Dialog_Show(playerid, eventSkin, DIALOG_STYLE_LIST, "Skin Event", "Team 1: %d\nTeam 2: %d\nNext", "Set", "Back", eventData[eventSkin][0], eventData[eventSkin][1]);	
	}
	else Dialog_Show(playerid, eventSkin, DIALOG_STYLE_LIST, "Skin Event", "Team 1: %d\nTeam 2: %d\nNext", "Set", "Back", eventData[eventSkin][0], eventData[eventSkin][1]);
	return 1;
}

Dialog:eventSkin2(playerid, response, listitem, inputtext[])
{
	if(response) {
		if(strval(inputtext) < 1 || strval(inputtext) > 311)
			return Dialog_Show(playerid, eventSkin2, DIALOG_STYLE_INPUT, "Skin Team 2", "Id skin tidak sesuai\n\nMasukkan id skin:", "Set", "Back");

		eventData[eventSkin][1] = strval(inputtext);
		Dialog_Show(playerid, eventSkin, DIALOG_STYLE_LIST, "Skin Event", "Team 1: %d\nTeam 2: %d\nNext", "Set", "Back", eventData[eventSkin][0], eventData[eventSkin][1]);	
	}
	else Dialog_Show(playerid, eventSkin, DIALOG_STYLE_LIST, "Skin Event", "Team 1: %d\nTeam 2: %d\nNext", "Set", "Back", eventData[eventSkin][0], eventData[eventSkin][1]);
	return 1;
}

Dialog:eventHealth(playerid, response, listitem, inputtext[])
{
	if(response) {
		if(strval(inputtext) < 1 || strval(inputtext) > 100)
			return Dialog_Show(playerid, eventHealth, DIALOG_STYLE_INPUT, "Event "RED"Health", "Health must between 0 - 100\n\nMasukkan value darah yang akan di berikan:", "Set", "Back");

		eventData[eventHealth] = floatstr(inputtext);
		Dialog_Show(playerid, eventArmor, DIALOG_STYLE_INPUT, "Event "WHITE"Armor", "Masukkan value darah putih:", "Set", "Back");

	}
	else Dialog_Show(playerid, eventSkin, DIALOG_STYLE_LIST, "Skin Event", "Team 1: %d\nTeam 2: %d\nNext", "Set", "Back", eventData[eventSkin][0], eventData[eventSkin][1]);
	return 1;
}

Dialog:eventArmor(playerid, response, listitem, inputtext[])
{
	if(response) {
		if(strval(inputtext) < 1 || strval(inputtext) > 100)
			return Dialog_Show(playerid, eventArmor, DIALOG_STYLE_INPUT, "Event "WHITE"Armor", "Darah putih harus berada di antara 0 - 100\n\nMasukkan value darah putih:", "Set", "Back");

		eventData[eventArmor] = floatstr(inputtext);
		Dialog_Show(playerid, eventBonus, DIALOG_STYLE_INPUT, "Event {00FF00}Bonus", "Masukkan berapa bonus yang akan di berikan:", "Set", "Back");
	}
	else Dialog_Show(playerid, eventHealth, DIALOG_STYLE_LIST, "Event "RED"Health", "Masukkan value darah yang akan di berikan:", "Set", "Back");
	return 1;
}

Dialog:eventBonus(playerid, response, listitem, inputtext[])
{
	if(response) {
		if(strval(inputtext) < 100 || strval(inputtext) > 100000)
			return Dialog_Show(playerid, eventBonus, DIALOG_STYLE_INPUT, "Event {00FF00}Bonus", "Value bonus harus di antara 1,00 - 1,000.00\n\nMasukkan berapa bonus yang akan di berikan:", "Set", "Back");

		eventData[eventBonus] = strval(inputtext);

		if(eventData[eventType] == TYPE_TDM)
		{
			Dialog_Show(playerid, eventFinal, DIALOG_STYLE_LIST, "Event Information", "Score Target\t"YELLOW"%d"WHITE"\nSkin Team 1\t"YELLOW"%d"WHITE"\nSkin Team 2\t"YELLOW"%d"WHITE"\nHealth Spawn\t"YELLOW"%.1f"WHITE"\nArmor Spawn\t"YELLOW"%.1f\n"WHITE"Event Bonus\t{00FF00}%s", "Start", "Back", 
				eventData[eventTarget],
				eventData[eventSkin][0],
				eventData[eventSkin][1],
				eventData[eventHealth],
				eventData[eventArmor],
				FormatNumber(eventData[eventBonus])
			);
		}

		if(eventData[eventType] == TYPE_JETPACK)
			Dialog_Show(playerid, jetpackLoc, DIALOG_STYLE_LIST, "Jetpack Location", "Los Santos\nSan Fierro\nLas Venturas", "Select", "Back");
	}
	else 
	{
		if(eventData[eventType] == TYPE_TDM) Dialog_Show(playerid, eventHealth, DIALOG_STYLE_INPUT, "Event "RED"Health", "Masukkan value darah yang akan di berikan:", "Set", "Back");
		else Dialog_Show(playerid, eventType, DIALOG_STYLE_LIST, "Event Type", "TDM\nJetpack", "Select", "Close");
	}
	return 1;
}

Dialog:jetpackLoc(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0: SetPlayerPosEx(playerid,725.12,-1460.74,22.21); 
			case 1: SetPlayerPosEx(playerid, -1513.53,-397.74,7.07);
			case 2: SetPlayerPosEx(playerid, 1749.01, 2318.74, 22.82);
		}
		eventData[eventInt] = GetPlayerInterior(playerid);
		eventData[eventInt] = GetPlayerVirtualWorld(playerid);

		SetPlayerInterior(playerid, eventData[eventInt]);
		SetPlayerVirtualWorld(playerid, eventData[eventWorld]);

		eventData[eventJetpackType] = (listitem+1);
		ShowPlayerFooter(playerid, "~b~[INFO]~n~~w~Kamu di tempatkan di spawn jetpack pertama.");

		new loc[13];

		switch(eventData[eventJetpackType])
		{
			case 1: loc = "Los Santos";
			case 2: loc = "San Fierro";
			case 3: loc = "Las Venturas";
		}

		Dialog_Show(playerid, eventFinal, DIALOG_STYLE_LIST, "Event Information", "Event Type\t"YELLOW"Jetpack"WHITE"\nEvent Location\t"YELLOW"%s"WHITE"\nEvent Bonus\t{00FF00}%s", "Start", "Back", 
			loc,
			FormatNumber(eventData[eventBonus])
		);
	}
	else Dialog_Show(playerid, eventBonus, DIALOG_STYLE_INPUT, "Event {00FF00}Bonus", ""COL_GREEN"Pada event jetpack, bonus hanya untuk partisipasi, bonus pemenang di beri admin secara manual\n\n"WHITE"Masukkan berapa bonus yang akan di berikan:", "Set", "Back");
	return 1;
}

Dialog:eventFinal(playerid, response, listitem, inputtext[])
{
	if(response) {
		eventData[eventCreated] = 1;
		eventData[eventWorld] = GetPlayerVirtualWorld(playerid);
		eventData[eventInt] = GetPlayerInterior(playerid);

		SendServerMessage(playerid, "You've create the event, /event open to open the event.");
	}
	else Dialog_Show(playerid, eventBonus, DIALOG_STYLE_INPUT, "Event {00FF00}Bonus", "Masukkan berapa bonus yang akan di berikan:", "Set", "Back");
	return 1;
}


hook OnPlayerEnterRaceCP(playerid)
{
	if(IsPlayerInEvent(playerid) && eventData[eventType] == TYPE_JETPACK)
	{
		eventCheckpoint[playerid]++;

		if(eventCheckpoint[playerid] < (eventData[eventJetpackType]*16))
		{
			SetPlayerRaceCheckpoint(playerid, 4, arrJetEvent[eventCheckpoint[playerid]][jX], arrJetEvent[eventCheckpoint[playerid]][jY], 
				arrJetEvent[eventCheckpoint[playerid]][jZ], arrJetEvent[eventCheckpoint[playerid]+1][jX], arrJetEvent[eventCheckpoint[playerid]+1][jY], 
				arrJetEvent[eventCheckpoint[playerid]+1][jZ], 3
			);
		}
		
		if(eventCheckpoint[playerid] == (eventData[eventJetpackType]*16)-1)
		{
			SetPlayerRaceCheckpoint(playerid, 1, arrJetEvent[eventCheckpoint[playerid]][jX], arrJetEvent[eventCheckpoint[playerid]][jY], 
				arrJetEvent[eventCheckpoint[playerid]][jZ], 0.0, 0.0, 0.0, 3
			);
		}
		
		if(eventCheckpoint[playerid] == (eventData[eventJetpackType]*16)) 
		{
			eventData[eventWinner] = playerid;
			DisablePlayerRaceCheckpoint(playerid);

			SendEventMessageAll(COLOR_CLIENT, sprintf("EVENT: "WHITE"Event "RED"Jetpack "WHITE"telah selesai dan dimenangkan oleh "YELLOW"%s", ReturnName(playerid, 0)));
			SendAdminMessage(X11_TOMATO_1, "AdmWarn: Event Jetpack dimenangkan oleh %s", ReturnName(playerid, 0));

			foreach(new i : Player) if(IsPlayerInEvent(i))
			{
				if(eventData[eventWinner] == playerid) SendCustomMessage(playerid, "EVENT", "Kamu menang dalam event "RED"jetpack."), GiveMoney(playerid, eventData[eventBonus]), SendCustomMessage(playerid, "EVENT", "Kamu menang dan mendapat hadiah {00FF00}%s "WHITE"dari jetpack event.", FormatNumber(eventData[eventBonus]));
				else GiveMoney(playerid, 100), SendCustomMessage(playerid, "EVENT", "Kamu mendapat bonus {00FF00}%s "WHITE"dari partisipasi jetpack event.", FormatNumber(eventData[eventBonus]));

				eventLeave(i);
			}
			static const empty_player[E_EVENT];
		    eventData = empty_player;
		}

		printf("debug: %d", eventCheckpoint[playerid]);
	}
/*	#if defined event_OnPlayerEnterRaceCheckpoint
		return event_OnPlayerEnterRaceCheckpoint(playerid);
	#else
	#endif*/
	return 1;
}
/*#if defined _ALS_OnPlayerEnterRaceCheckpoint
	#undef OnPlayerEnterRaceCheckpoint
#else
	#define _ALS_OnPlayerEnterRaceCheckpoint
#endif

#define OnPlayerEnterRaceCheckpoint event_OnPlayerEnterRaceCheckpoint
#if defined event_OnPlayerEnterRaceCheckpoint
	forward event_OnPlayerEnterRaceCheckpoint(playerid);
#endif*/

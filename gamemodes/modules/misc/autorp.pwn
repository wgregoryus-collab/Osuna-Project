// Auto roleplay
new
	bool:PlayerConnected[MAX_PLAYERS],
	tempWeapon[MAX_PLAYERS];

static ShowAutoRoleplay(playerid) {
	new str[712], string[712];
	format(str, sizeof(str), "Auto Roleplay\tFungsi\n");
	strcat(string, str);
	format(str, sizeof(str), "/rp crash\tBerfungsi untuk Roleplay jika bertabrakan\n");
	strcat(string, str);
	format(str, sizeof(str), "/rp gun\tBerfungsi untuk Roleplay menggunakan senjata\n");
	strcat(string, str);
	format(str, sizeof(str), "/rp fish\tBerfungsi untuk Roleplay memancing\n");
	strcat(string, str);
	format(str, sizeof(str), "/rp punch\tBerfungsi untuk Roleplay memukul seseorang\n");
	strcat(string, str);
	format(str, sizeof(str), "/rp frisk\tBerfungsi untuk Roleplay menggeledah sesorang\n");
	strcat(string, str);
	format(str,sizeof(str), "/rp rob\tBerfungsi untuk Roleplay mengambil barang seseorang\n");
	strcat(string, str);
	format(str,sizeof(str), "/rp run\tBerfungsi untuk Roleplay melarikan diri\n");
	strcat(string, str);	
	format(str,sizeof(str), "/rp robbank\tBerfungsi untuk Roleplay merampok brankas bank\n");
	strcat(string, str);
	format(str,sizeof(str), "/rp savegun\tBerfungsi untuk Roleplay menyimpan senjata\n");
	strcat(string, str);
	format(str,sizeof(str), "/rp db\tBerfungsi untuk Roleplay DriveBy dari kendaraan\n");
	strcat(string, str);
	Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_TABLIST_HEADERS, "OwnPride - Auto RP", string, "Close", "");
}

#include <YSI\y_hooks>
hook OnPlayerConnect(playerid) {
	PlayerConnected[playerid] = false;
	tempWeapon[playerid] = 0;
	return 1;
}


hook OnPlayerSpawn(playerid) {
	PlayerConnected[playerid] = true;
	return 1;
}


hook OnPlayerDisconnectEx(playerid) {
	PlayerConnected[playerid] = false;
	tempWeapon[playerid] = 0;
	return 1;
}

Function:NextCrash(playerid) {
	new str[128];
	format(str, sizeof(str), "* %s mencoba membenarkan posisi dan menenangkan diri", ReturnName(playerid, 0, 1));
	SendNearbyMessage(playerid, 15.0, X11_PLUM, str);
}

CMD:autorplist(playerid, params[]) {
	ShowAutoRoleplay(playerid);
	return 1;
}

CMD:rp(playerid, params[]) {
	new rp[24];
	if (sscanf(params, "s[24]", rp))
		return SendSyntaxMessage(playerid, "/rp [crash/frisk/punch/fish/savegun/rob/robbank/run/db/gun]");

	new str[128];
	if(!strcmp(rp, "crash", true)) {
		format(str, sizeof(str), "* %s merasakan sakit karena bertabrakan dengan pengemudi lain", ReturnName(playerid, 0, 1));
		SendNearbyMessage(playerid, 15.0, X11_PLUM, str);
		SetTimerEx("NextCrash", 3000, false, "d", playerid);
	} else if(!strcmp(rp, "frisk", true)) {
		format(str, sizeof(str), "menggeledah tubuh orang didepan dari atas sampai bawah dengan kedua tangan");
		cmd_lme(playerid, str);
	} else if(!strcmp(rp, "punch", true)) {
		format(str, sizeof(str), "mengepalkan tangan dan siap memukul siapapun kapan saja");
		cmd_lme(playerid, str);
	} else if(!strcmp(rp, "fish", true)) {
		format(str, sizeof(str), "hook a bait and start to fishing");
		cmd_ame(playerid, str);
	} else if(!strcmp(rp, "savegun", true)) {
		if(GetPlayerWeapon(playerid) != 0) {
			new wepname[32];
			GetWeaponName(GetPlayerWeapon(playerid), wepname, sizeof(wepname));
			format(str, sizeof(str), "menyimpan kembali %s miliknya", wepname);
		}
		else {
			format(str, sizeof(str), "menyimpan kembali senjata miliknya");
		}
		cmd_ame(playerid, str);
	} else if(!strcmp(rp, "rob", true)) {
		format(str, sizeof(str), "mengambil barang bawaan milik orang didepan dengan bantuan tangan");
		cmd_lme(playerid, str);
	} else if(!strcmp(rp, "robbank", true)) {
		format(str, sizeof(str), "membuka brankas bank dengan alat dan bantuan kedua tangan - mengambil uang didalamnya");
		cmd_lme(playerid, str);
	} else if(!strcmp(rp, "run", true)) {
		format(str, sizeof(str), "lari dari tempat ini sejauh mungkin");
		cmd_lme(playerid, str);
	} else if(!strcmp(rp, "db", true)) {
		format(str, sizeof(str), "* %s mengambil senjata lalu siap untuk DriveBy dari kendaraan", ReturnName(playerid, 0, 1));
		SendNearbyMessage(playerid, 15.0, X11_PLUM, str);
	} else if(!strcmp(rp, "gun", true)) {
		if(GetPlayerWeapon(playerid) != 0) {
			new wepname[32];
			GetWeaponName(GetPlayerWeapon(playerid), wepname, sizeof(wepname));
			format(str, sizeof(str), "mengeluarkan %s dan siap untuk menembak kapan saja", wepname);
		}
		else {
			format(str, sizeof(str), "mengeluarkan senjata dan siap untuk menembak kapan saja");
		}
		cmd_ame(playerid, str);
	}
	return 1;
}
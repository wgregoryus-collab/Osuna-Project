SSCANF:GateMenu(string[]) 
{
	if(!strcmp(string,"create",true)) return 1;
 	else if(!strcmp(string,"delete",true)) return 2;
 	else if(!strcmp(string,"pos",true)) return 3;
 	else if(!strcmp(string,"move",true)) return 4;
 	else if(!strcmp(string,"password",true)) return 5;
 	else if(!strcmp(string,"radius",true)) return 6;
 	else if(!strcmp(string,"faction",true)) return 7;
 	else if(!strcmp(string,"linkid",true)) return 8;
 	else if(!strcmp(string,"removelinkid",true)) return 9;
	else if(!strcmp(string,"speed",true)) return 10;
	else if(!strcmp(string,"workshop",true)) return 11;
	else if(!strcmp(string,"vw",true)) return 12;
	else if(!strcmp(string,"int",true)) return 13;
	else if(!strcmp(string,"house",true)) return 14;
 	return 0;
}

/*CMD:gdl(playerid)
{
    if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);
        
    new gate_id = Iter_Free(Gates);
    if(PlayerData[playerid][pGdl] == 0)
    {
        new str[128];
		format(str, sizeof(str), "Gate ID: %d", gate_id);
		GateData[gate_id][gateText] = CreateDynamic3DTextLabel(str, COLOR_WHITE, GateData[gate_id][gatePosition][0], GateData[gate_id][gatePosition][1], GateData[gate_id][gatePosition][2], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
		PlayerData[playerid][pGdl] = 1;
		return 1;
	}
	if(PlayerData[playerid][pGdl] == 1)
	{
	    if(IsValidDynamic3DTextLabel(GateData[gate_id][gateText]))
            DestroyDynamic3DTextLabel(GateData[gate_id][gateText]);

        GateData[gate_id][gateText] = Text3D:INVALID_STREAMER_ID;
        PlayerData[playerid][pGdl] = 0;
		return 1;
	}
	return 1;
}*/

CMD:gate(playerid)
{
    new gate_id = Gate_Nearest(playerid);

	if(gate_id != -1)
	{
		new houseid = GetHouseByID(Gate_House(gate_id));

		if ((Gate_Faction(gate_id) != -1) && GetPlayerFactionID(playerid) != Gate_Faction(gate_id))
			return SendErrorMessage(playerid, "Your not a this faction, Acces Denied!");

		if ((Gate_Workshop(gate_id) != -1) && !Workshop_IsOwner(playerid, Gate_Workshop(gate_id)) && !Workshop_Employe(playerid, Gate_Workshop(gate_id)))
			return SendErrorMessage(playerid, "Your not a owned or employed this workshop, Acces Denied!");

		if ((houseid != -1) && !House_IsOwner(playerid, houseid))
			return SendErrorMessage(playerid, "Your not a owned this house, Acces Denied!");

    	if(!strcmp(GateData[gate_id][gatePassword], "none")) Gate_Operate(gate_id);
		else Dialog_Show(playerid, PasswordedGate, DIALOG_STYLE_PASSWORD, "Gate Password", "Masukkan password:", "Masukkan", "Batal");
	}
	return 1;
}

CMD:gatemenu(playerid, params[])
{
    if (CheckAdmin(playerid, 6))
        return PermissionError(playerid);

	new
		gate_id, action, nextParams[128]
	;

	if(sscanf(params, "k<GateMenu>S()[128]", action, nextParams))
		return SendSyntaxMessage(playerid, "/gatemenu [create/delete/pos/move/password/radius/faction/linkid/removelinkid/workshop/vw/int/house]");

	switch(action)
	{
		case 1: // Create
		{
			new modelId;

			if(sscanf(nextParams, "d", modelId))
				return SendSyntaxMessage(playerid, "/gatemenu create <model id>");

			new Float:x, Float:y, Float:z, Float:angle, vw, int;
			GetPlayerPos(playerid, z, z, z);
			GetPlayerFacingAngle(playerid, angle);
			GetXYInFrontOfPlayer(playerid, x, y, 3.0);
			vw = GetPlayerVirtualWorld(playerid);
			int = GetPlayerInterior(playerid);

			if((gate_id = Gate_Create(modelId, x, y, z, 0, 0, angle, vw, int)) != INVALID_ITERATOR_SLOT) {
				return SendServerMessage(playerid, "Sukses membuat gate dengan id: %d", gate_id);
			}

			SendErrorMessage(playerid, "Slot gate sudah mencapai batas maksimal (%d gate), hubungi scripter segera!.", MAX_DYNAMIC_GATE);
		}
		case 2: // Delete
		{
			new last_gate_id;

			if(sscanf(nextParams, "d", gate_id))
				return SendSyntaxMessage(playerid, "/gatemenu delete <gate id>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

			last_gate_id = GateData[gate_id][gateID];

			if(Gate_Delete(gate_id)) {
				foreach(new i : Gates) if(GateData[i][gateLinkID] == last_gate_id) {
	        		GateData[i][gateLinkID] = -1;
			        Gate_Save(i, SAVE_GATE_LINKID);
	        		break;
		        }
				SendServerMessage(playerid, "Gate id "RED"%d "WHITE"telah dihapus dari server!", gate_id);
			}
			else SendErrorMessage(playerid, "Id gate tidak terdaftar diserver.", gate_id);
		}
		case 3: // Position
		{
			if(sscanf(nextParams, "d", gate_id))
				return SendSyntaxMessage(playerid, "/gatemenu pos <gate id>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

			editGateID[playerid] = gate_id;
			editGateMode[playerid] = EDIT_GATE_POS;

			EditDynamicObject(playerid, Gate_ObjectID(gate_id));
		}
		case 4: // Move
		{
			if(sscanf(nextParams, "d", gate_id))
				return SendSyntaxMessage(playerid, "/gatemenu move <gate id>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

			editGateID[playerid] = gate_id;
			editGateMode[playerid] = EDIT_GATE_MOVE;

			EditDynamicObject(playerid, Gate_ObjectID(gate_id));
		}
		case 5: // Password
		{
			new gate_password[10];

			if(sscanf(nextParams, "ds[10]", gate_id, gate_password))
				return SendSyntaxMessage(playerid, "/gatemenu password <gate id> <password ('none' untuk menghapus)");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

			format(GateData[gate_id][gatePassword], 10, gate_password);
			Gate_Save(gate_id, SAVE_GATE_PASSWORD);

			SendServerMessage(playerid, "Sukses mengubah password gate menjadi: "YELLOW"%s.", gate_password);
		}
		case 6: // Radius
		{
			new gate_radius;

			if(sscanf(nextParams, "dd", gate_id, gate_radius))
				return SendSyntaxMessage(playerid, "/gatemenu radius <gate id> <radius (5 - 10)>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

			if(gate_radius < 3 || gate_radius > 10)
				return SendErrorMessage(playerid, "Radius hanya dibatasi antara 3 - 10.");

			GateData[gate_id][gateRadius] = gate_radius;
			Gate_Save(gate_id, SAVE_GATE_RADIUS);

			SendServerMessage(playerid, "Sukses mengubah radius gate menjadi: "YELLOW"%d.", gate_radius);
		}
		case 7: // Faction
		{
			new gate_faction;

			if(sscanf(nextParams, "dd", gate_id, gate_faction))
				return SendSyntaxMessage(playerid, "/gatemenu faction <gate id> <faction id (-1 to disable)>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

	        if((gate_faction < -1 || gate_faction >= MAX_FACTIONS) || (gate_faction != -1 && !FactionData[gate_faction][factionExists]))
	            return SendErrorMessage(playerid, "Faction id tidak terdaftar diserver.");

	        GateData[gate_id][gateFaction] = (gate_faction == -1) ? (-1) : (FactionData[gate_faction][factionID]);
	        Gate_Save(gate_id, SAVE_GATE_FACTION);

			SendServerMessage(playerid, "Gate id "YELLOW"%d "WHITE"telah dikhususkan untuk faction id: "YELLOW"%d.", gate_id, gate_faction);
		}
		case 8: // LinkID
		{
			new gate_link;

			if(sscanf(nextParams, "dd", gate_id, gate_link))
				return SendSyntaxMessage(playerid, "/gatemenu linkid <gate id> <gate id link>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

			if(!Gate_Exists(gate_link))
				return SendErrorMessage(playerid, "Indeks gate yang akan dilink tidak terdaftar!.");

	        GateData[gate_id][gateLinkID] = (gate_link == -1) ? (-1) : (GateData[gate_link][gateID]);
	        GateData[gate_link][gateLinkID] = (gate_link == -1) ? (-1) : (GateData[gate_id][gateID]);

	        Gate_Save(gate_id, SAVE_GATE_LINKID);
	        Gate_Save(gate_link, SAVE_GATE_LINKID);
			SendServerMessage(playerid, "Gate id "YELLOW"%d "WHITE"telah link dengan gate id: "YELLOW"%d.", gate_id, gate_link);
		}
		case 9: // Remove LinkID
		{
			if(sscanf(nextParams, "d", gate_id))
				return SendSyntaxMessage(playerid, "/gatemenu removelinkid <gate id>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

	        GateData[gate_id][gateLinkID] = -1;
	        Gate_Save(gate_id, SAVE_GATE_LINKID);

	        foreach(new i : Gates) if(GateData[i][gateLinkID] == GateData[gate_id][gateID]) {
        		GateData[i][gateLinkID] = -1;
		        Gate_Save(i, SAVE_GATE_LINKID);
        		break;
	        }
			SendServerMessage(playerid, "Gate id "YELLOW"%d "WHITE"telah dihilangkan dengan link gate lainnya.", gate_id);
		}
		case 10: // Speed
		{
			new Float:speed;
			if (sscanf(nextParams, "df", gate_id, speed))
				return SendSyntaxMessage(playerid, "/gatemenu speed <gate id> <speed>");

			GateData[gate_id][gateSpeed] = speed;
			Gate_Save(gate_id, SAVE_GATE_MOVE);

			SendServerMessage(playerid, "Sukses mengubah speed gate id "YELLOW"%d"WHITE", menjadi %.1f.", gate_id, speed);
		}
		case 11: { // Workshop
			new gate_workshop;

			if(sscanf(nextParams, "dd", gate_id, gate_workshop))
				return SendSyntaxMessage(playerid, "/gatemenu workshop <gate id> <workshop id (-1 to disable)>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

	        if (!Iter_Contains(Workshop, gate_workshop))
	            return SendErrorMessage(playerid, "Workshop id tidak terdaftar diserver.");

	        GateData[gate_id][gateWorkshop] = (gate_workshop == -1) ? (-1) : (gate_workshop);
	        Gate_Save(gate_id, SAVE_GATE_WORKSHOP);

			SendServerMessage(playerid, "Gate id "YELLOW"%d "WHITE"telah dibuat untuk workshop id: "YELLOW"%d.", gate_id, gate_workshop);
		}
		case 12: { // Vw
			new vw;
			if (sscanf(nextParams, "dd", gate_id, vw))
				return SendSyntaxMessage(playerid, "/gatemenu vw <gate id> <virtual world>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

			GateData[gate_id][gateWorld] = vw;
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, GateData[gate_id][gateObject], E_STREAMER_WORLD_ID, GateData[gate_id][gateWorld]);
			Streamer_Update(playerid);
			Gate_Save(gate_id, SAVE_GATE_WORLD);
			SendServerMessage(playerid, "Sukses mengubah vw gate id "YELLOW"%d"WHITE", menjadi %d.", gate_id, vw);
		}
		case 13: { // Int
			new int;
			if (sscanf(nextParams, "dd", gate_id, int))
				return SendSyntaxMessage(playerid, "/gatemenu int <gate id> <interior id>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

			GateData[gate_id][gateInterior] = int;
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, GateData[gate_id][gateObject], E_STREAMER_INTERIOR_ID, GateData[gate_id][gateInterior]);
			Streamer_Update(playerid);
			Gate_Save(gate_id, SAVE_GATE_INTERIOR);
			SendServerMessage(playerid, "Sukses mengubah interior gate id "YELLOW"%d"WHITE", menjadi %d.", gate_id, int);
		}
		case 14: { // House
			new house;
			if (sscanf(nextParams, "dd", gate_id, house))
				return SendSyntaxMessage(playerid, "/gatemenu house <gate id> <house id>");

			if(!Gate_Exists(gate_id))
				return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

			if (!Iter_Contains(Houses, house))
				return SendErrorMessage(playerid, "Invalid house id.");

			GateData[gate_id][gateHouse] = (house == -1) ? (-1) : (HouseData[house][houseID]);
			Gate_Save(gate_id, SAVE_GATE_HOUSE);
			SendServerMessage(playerid, "Gate id "YELLOW"%d "WHITE"telah dibuat untuk house id: "YELLOW"%d.", gate_id, house);
		}
		
		default: SendSyntaxMessage(playerid, "/gatemenu [create/delete/pos/move/password/radius/faction/linkid/removelinkid/speed/workshop/vw/int/house]");
	}
	return 1;
}

CMD:gotogate(playerid, params[])
{
	if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);

	new gate_id;

	if(sscanf(params, "d", gate_id))
		return SendSyntaxMessage(playerid, "/gotogate [gate id]");

	if(!Gate_Exists(gate_id))
		return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

	SetPlayerPos(playerid, GateData[gate_id][gatePosition][0], GateData[gate_id][gatePosition][1], GateData[gate_id][gatePosition][2]);
	SetPlayerFacingAngle(playerid, GateData[gate_id][gateRotation][2]);
	SetPlayerVirtualWorld(playerid, GateData[gate_id][gateWorld]);
	SetPlayerInterior(playerid, GateData[gate_id][gateInterior]);

	SendServerMessage(playerid, "Kamu telah teleportasi ke gate id: "YELLOW"%d", gate_id);
	return 1;
}

CMD:gdl(playerid, params[])
{
	if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);

	new gate_id = Gate_Nearest(playerid);
	SendServerMessage(playerid, "Gate ID: "YELLOW"%s", (gate_id == -1) ? ("none") : sprintf("%d", gate_id));
	return 1;
}

CMD:infogate(playerid, params[])
{
	if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);

    new gate_id;

	if(sscanf(params, "d", gate_id))
		return SendSyntaxMessage(playerid, "/infogate [gate id]");

	if(!Gate_Exists(gate_id))
		return SendErrorMessage(playerid, "Indeks gate tidak terdaftar!.");

    Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "Gate Info", WHITE"ID: %d\nPassword: %s\nRadius: %.1f\nFaction: %d\nLinkID: %d\nVirtual World: %d\nInterior: %d","Close","", gate_id, GateData[gate_id][gatePassword], GateData[gate_id][gateRadius], GetFactionByID(GateData[gate_id][gateFaction]), GateData[gate_id][gateLinkID], GateData[gate_id][gateWorld], GateData[gate_id][gateInterior]);
	return 1;
}

CMD:gatehelp(playerid, params[])
{
	if (CheckAdmin(playerid, 1))
        return PermissionError(playerid);

	SendServerMessage(playerid, "/gatemenu, /gotogate, /gdl, /infogate.");
	return 1;
}

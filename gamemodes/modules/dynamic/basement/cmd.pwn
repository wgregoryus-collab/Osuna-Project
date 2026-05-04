SSCANF:UndergroundMenu(string[]) 
{
 	if(!strcmp(string,"create",true)) return 1;
 	else if(!strcmp(string,"delete",true)) return 2;
 	else if(!strcmp(string,"enter",true)) return 3;
 	else if(!strcmp(string,"exit",true)) return 4;
    else if(!strcmp(string,"faction",true)) return 5;
 	return 0;
}

CMD:basement(playerid, params[])
{
	static
		index, action, nextParams[128];

	if (CheckAdmin(playerid, 9))
        return PermissionError(playerid);

	if(sscanf(params, "k<UndergroundMenu>S()[128]", action, nextParams))
		return SendSyntaxMessage(playerid, "/basement [create/delete/enter/exit/faction]");

	switch(action)
	{
		case 1: // Create
		{
			if((index = Underground_Create(playerid)) != -1) SendServerMessage(playerid, "Sukses membuat basement "YELLOW"id %d.", index);
			else SendErrorMessage(playerid, "Gagal membuat basement, sudah mencapai batas maksimal!");
		}
		case 2: // Delete
		{
			if(sscanf(nextParams, "d", index))
				return SendErrorMessage(playerid, "/basement delete [basement id]");

			if(!Underground_IsExists(index))
				return SendErrorMessage(playerid, "Basement tidak terdaftar!");

			Underground_Delete(index);
			SendServerMessage(playerid, "Sukses menghapus basement "YELLOW"id %d.", index);
		}
		case 3: // Enter
		{
			if(sscanf(nextParams, "d", index))
				return SendErrorMessage(playerid, "/basement enter [basement id]");

			if(!Underground_IsExists(index))
				return SendErrorMessage(playerid, "Basement tidak terdaftar!");

			GetPlayerPos(playerid, UndergroundData[index][underEnter][0], UndergroundData[index][underEnter][1], UndergroundData[index][underEnter][2]);
            UndergroundData[index][enterInt] = GetPlayerInterior(playerid);
            UndergroundData[index][enterVW] = GetPlayerVirtualWorld(playerid);

			Underground_Sync(index);
			Underground_Save(index);
			SendServerMessage(playerid, "Sukses mengubah posisi masuk basement "YELLOW"id %d.", index);
		}
		case 4: // Exit
		{

			if(sscanf(nextParams, "d", index))
				return SendErrorMessage(playerid, "/basement exit [basement id]");

			if(!Underground_IsExists(index))
				return SendErrorMessage(playerid, "Basement tidak terdaftar!");

			GetPlayerPos(playerid, UndergroundData[index][underExitSpawn][0], UndergroundData[index][underExitSpawn][1], UndergroundData[index][underExitSpawn][2]);
			GetPlayerFacingAngle(playerid, UndergroundData[index][underExitSpawn][3]);
            UndergroundData[index][exitInt] = GetPlayerInterior(playerid);
            UndergroundData[index][exitVW] = GetPlayerVirtualWorld(playerid);

			Underground_Sync(index);
			Underground_Save(index);
			SendServerMessage(playerid, "Sukses mengubah posisi keluar basement "YELLOW"id %d.", index);
		}

        case 5:
        {
            new factionid;

            if(sscanf(nextParams, "dd", index, factionid))
                return SendSyntaxMessage(playerid, "/basement faction [basement id] [faction id]");

            UndergroundData[index][underFaction] = factionid;

            Underground_Sync(index);
			Underground_Save(index);

            SendAdminMessage(X11_TOMATO_1, "AdmCmd: %s has adjusted the faction of entrance ID: %d to faction id %d.", ReturnName(playerid, 0), index, factionid);
        }
		default: SendSyntaxMessage(playerid, "/basement [create/delete/enter/exit/faction]");
	}
	return 1;
}
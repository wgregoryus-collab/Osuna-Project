#include <YSI\y_hooks>
hook OnPlayerConnect(playerid)
{
	editGateID[playerid] = -1;
	editGateMode[playerid] = 0;
	return 1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(((GetPlayerState(playerid) == PLAYER_STATE_DRIVER) && (newkeys & KEY_CROUCH)) || ((GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) && (newkeys & KEY_CTRL_BACK)))
    {
    	new gate_id = Gate_Nearest(playerid);

    	if(gate_id != -1) {
			new houseid = GetHouseByID(Gate_House(gate_id));

    		if ((Gate_Faction(gate_id) != -1) && GetPlayerFactionID(playerid) != Gate_Faction(gate_id))
    			return 0;

    		if ((Gate_Workshop(gate_id) != -1) && !Workshop_IsOwner(playerid, Gate_Workshop(gate_id)) && !Workshop_Employe(playerid, Gate_Workshop(gate_id)))
    			return 0;

			if ((houseid != -1) && !House_IsOwner(playerid, houseid))
				return 0;

	    	if(!strcmp(GateData[gate_id][gatePassword], "none")) Gate_Operate(gate_id);
			else Dialog_Show(playerid, PasswordedGate, DIALOG_STYLE_PASSWORD, "Gate Password", "Masukkan password:", "Masukkan", "Batal");
		}
	}
	return 1;
}


hook OnPlayerEditDynObj(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if (editGateID[playerid] != -1)
	{
		if(response == EDIT_RESPONSE_CANCEL)
    	{
			new gate_id = editGateID[playerid];

    		Gate_Sync(gate_id);

    		editGateID[playerid] = -1;
			editGateMode[playerid] = 0;

			SendServerMessage(playerid, "Gagal mengubah posisi gate.");
    	}

    	else if(response == EDIT_RESPONSE_FINAL)
    	{
			new gate_id = editGateID[playerid],
				edit_mode = editGateMode[playerid];

    		if(edit_mode == EDIT_GATE_POS) {
    			Gate_SetObjectPos(gate_id, x, y, z, rx, ry, rz);
    			
    			Gate_Sync(gate_id);
    			Gate_Save(gate_id, SAVE_GATE_POS);
    			SendServerMessage(playerid, "Posisi utama gate telah perbaharui.");
    		}

    		if(edit_mode == EDIT_GATE_MOVE) {
    			Gate_SetObjectMove(gate_id, x, y, z, rx, ry, rz);

    			Gate_Sync(gate_id);
    			Gate_Save(gate_id, SAVE_GATE_MOVE);
    			SendServerMessage(playerid, "Posisi perpindahan gate telah perbaharui.");
    		}
	    	editGateID[playerid] = -1;
			editGateMode[playerid] = 0;
    	}
	}
	return 1;
}

// Dialog response
Dialog:PasswordedGate(playerid, response, listitem, inputtext[]) 
{
    if (response)  {
		new gate_id = Gate_Nearest(playerid);

    	if(strlen(inputtext) > 10)
			return Dialog_Show(playerid, PasswordedGate, DIALOG_STYLE_PASSWORD, "Gate Password", "Password salah\n\nMasukkan password:", "Masukkan", "Batal");

		if(!strcmp(inputtext, GateData[gate_id][gatePassword])) Gate_Operate(gate_id);
		else Dialog_Show(playerid, PasswordedGate, DIALOG_STYLE_PASSWORD, "Gate Password", "Password salah\n\nMasukkan password:", "Masukkan", "Batal");
    }
    return 1;
}

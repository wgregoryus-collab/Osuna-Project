/*
	Vehicle object system
*/
// Defined

#define MAX_VEHICLE_OBJECT					5
#define MAX_COLOR_MATERIAL					5

#define OBJECT_TYPE_BODY						1
#define OBJECT_TYPE_TEXT						2
#define VEHICLE_OBJECT_PRICE				100
#define VEHICLE_OBJECT_EDIT_PRICE		10


// Variable



// Enum's

enum carObjects {
    object_id,
    object_vehicle,
    object_type,
    object_model,
    object_color[MAX_COLOR_MATERIAL],

    object_text[128],
    object_fonts[24],
    object_fontsize,
    object_fontcolor,

    object_streamer,

    bool:object_exists,
    object_toggle,

    Float:object_x,
    Float:object_y,
    Float:object_z,
    Float:object_rx,
    Float:object_ry,
    Float:object_rz
};

new VehicleObjects[MAX_DYNAMIC_VEHICLES][MAX_VEHICLE_OBJECT+5][carObjects];

Function:Vehicle_ObjectLoad(id)
{
	if(cache_num_rows())
	{
		for(new slot = 0; slot != cache_num_rows(); slot++) if(!VehicleObjects[id][slot][object_exists])
		{
			VehicleObjects[id][slot][object_exists] = true;

			new
				query[24]
			;
			cache_get_value(slot, "color", query, 24);
            sscanf(query, "p<|>ddddd", VehicleObjects[id][slot][object_color][0], VehicleObjects[id][slot][object_color][1], VehicleObjects[id][slot][object_color][2], VehicleObjects[id][slot][object_color][3], VehicleObjects[id][slot][object_color][4]);

			cache_get_value(slot, "text", VehicleObjects[id][slot][object_text], 128);
			cache_get_value(slot, "font", VehicleObjects[id][slot][object_fonts], 32);

			cache_get_value_int(slot, "id", VehicleObjects[id][slot][object_id]);
			cache_get_value_int(slot, "vehicle", VehicleObjects[id][slot][object_vehicle]);
			cache_get_value_int(slot, "type", VehicleObjects[id][slot][object_type]);
			cache_get_value_int(slot, "model", VehicleObjects[id][slot][object_model]);
			cache_get_value_int(slot, "fontcolor", VehicleObjects[id][slot][object_fontcolor]);
			cache_get_value_int(slot, "fontsize", VehicleObjects[id][slot][object_fontsize]);
			cache_get_value_int(slot, "toggle", VehicleObjects[id][slot][object_toggle]);

			cache_get_value_float(slot, "x", VehicleObjects[id][slot][object_x]);
			cache_get_value_float(slot, "y", VehicleObjects[id][slot][object_y]);
			cache_get_value_float(slot, "z", VehicleObjects[id][slot][object_z]);

			cache_get_value_float(slot, "rx", VehicleObjects[id][slot][object_rx]);
			cache_get_value_float(slot, "ry", VehicleObjects[id][slot][object_ry]);
			cache_get_value_float(slot, "rz", VehicleObjects[id][slot][object_rz]);

			Vehicle_ObjectUpdate(id, slot);
		}
	}
	return 1;
}

Vehicle_ObjectAdd(id, model, type)
{
	for(new slot = 0; slot != MAX_VEHICLE_OBJECT+5; slot++) if(VehicleObjects[id][slot][object_exists] == false)
	{
		VehicleObjects[id][slot][object_exists] = true;

		VehicleObjects[id][slot][object_type] = type;
		VehicleObjects[id][slot][object_vehicle] = VehicleData[id][cID];
		VehicleObjects[id][slot][object_model] = model;

		for(new mx = 0; mx != MAX_COLOR_MATERIAL; mx++) {
			VehicleObjects[id][slot][object_color][mx] = 1;
		}

		VehicleObjects[id][slot][object_toggle] = false;

		VehicleObjects[id][slot][object_x] = 0.0;
		VehicleObjects[id][slot][object_y] = 0.0;
		VehicleObjects[id][slot][object_z] = 0.0;

		VehicleObjects[id][slot][object_rx] = 0.0;
		VehicleObjects[id][slot][object_ry] = 0.0;
		VehicleObjects[id][slot][object_rz] = 0.0;

		if(VehicleObjects[id][slot][object_type] == OBJECT_TYPE_TEXT)
		{
			format(VehicleObjects[id][slot][object_text], 128, "Text Here");
			format(VehicleObjects[id][slot][object_fonts], 24, "Arial");
			VehicleObjects[id][slot][object_fontcolor] = 1;
			VehicleObjects[id][slot][object_fontsize] = 40;
		}

		Vehicle_ObjectUpdate(id, slot);

		mysql_tquery(g_iHandle, sprintf("INSERT INTO `vehicle_object` (`vehicle`) VALUES ('%d')", VehicleObjects[id][slot][object_vehicle]), "Vehicle_ObjectDB", "dd", id, slot);
		return 1;
	}
	return 0;
}

Vehicle_ObjectSave(id, slot)
{
	if(!VehicleObjects[id][slot][object_exists])
		return 0;

	new query[1500];

	format(query, sizeof(query), "UPDATE `vehicle_object` SET `model`='%d',`toggle`='%d', `color`='%d|%d|%d|%d|%d',`type`='%d',	`x`='%f',`y`='%f',`z`='%f', `rx`='%f',`ry`='%f',`rz`='%f'",
		 VehicleObjects[id][slot][object_model], VehicleObjects[id][slot][object_toggle], VehicleObjects[id][slot][object_color][0], VehicleObjects[id][slot][object_color][1],
		 VehicleObjects[id][slot][object_color][2], VehicleObjects[id][slot][object_color][3], VehicleObjects[id][slot][object_color][4], VehicleObjects[id][slot][object_type],
		 VehicleObjects[id][slot][object_x], VehicleObjects[id][slot][object_y], VehicleObjects[id][slot][object_z], VehicleObjects[id][slot][object_rx],
		 VehicleObjects[id][slot][object_ry], VehicleObjects[id][slot][object_rz]
	);

	format(query, sizeof(query), "%s, `text`='%s',`font`='%s', `fontsize`='%d',`fontcolor`='%d' WHERE `id`='%d' AND vehicle = %d",
		 query, SQL_ReturnEscaped(VehicleObjects[id][slot][object_text]), VehicleObjects[id][slot][object_fonts], VehicleObjects[id][slot][object_fontsize], VehicleObjects[id][slot][object_fontcolor], VehicleObjects[id][slot][object_id], VehicleData[id][cID]
	);

	mysql_tquery(g_iHandle, query);
	return 1;
}

Vehicle_ObjectUpdate(id, slot, sync = 1)
{
		if(!IsValidVehicle(VehicleData[id][cVehicle]))
				return 0;

		if (sync) {
			if (IsValidDynamicObject(VehicleObjects[id][slot][object_streamer]))
					DestroyDynamicObject(VehicleObjects[id][slot][object_streamer]);

			VehicleObjects[id][slot][object_streamer] = CreateDynamicObject(VehicleObjects[id][slot][object_model], VehicleObjects[id][slot][object_x], VehicleObjects[id][slot][object_y], VehicleObjects[id][slot][object_z], VehicleObjects[id][slot][object_rx], VehicleObjects[id][slot][object_ry], VehicleObjects[id][slot][object_rz]);
		}

		if(VehicleObjects[id][slot][object_type] == OBJECT_TYPE_BODY)
		{
			for(new mx = 0; mx != MAX_COLOR_MATERIAL; mx++) {
				SetDynamicObjectMaterial(VehicleObjects[id][slot][object_streamer], mx, VehicleObjects[id][slot][object_model], "none", "none", RGBAToARGB(ColorList[VehicleObjects[id][slot][object_color][mx]]));
			}
		}
		else SetDynamicObjectMaterialText(VehicleObjects[id][slot][object_streamer], 0, VehicleObjects[id][slot][object_text], OBJECT_MATERIAL_SIZE_512x512, VehicleObjects[id][slot][object_fonts], VehicleObjects[id][slot][object_fontsize], 1, RGBAToARGB(ColorList[VehicleObjects[id][slot][object_fontcolor]]), 0x00000000, OBJECT_MATERIAL_TEXT_ALIGN_CENTER);

		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, VehicleObjects[id][slot][object_streamer], E_STREAMER_DRAW_DISTANCE, 25);
		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, VehicleObjects[id][slot][object_streamer], E_STREAMER_STREAM_DISTANCE, 25);

		if (sync) {
			AttachDynamicObjectToVehicle(VehicleObjects[id][slot][object_streamer], VehicleData[id][cVehicle], VehicleObjects[id][slot][object_x], VehicleObjects[id][slot][object_y], VehicleObjects[id][slot][object_z], VehicleObjects[id][slot][object_rx], VehicleObjects[id][slot][object_ry], VehicleObjects[id][slot][object_rz]);
		}
    	return 1;
}

Vehicle_ObjectReset(id, slot, remove = 0)
{
    if(IsValidDynamicObject(VehicleObjects[id][slot][object_streamer]))
        DestroyDynamicObject(VehicleObjects[id][slot][object_streamer]);

    VehicleObjects[id][slot][object_streamer] = INVALID_STREAMER_ID;

    VehicleObjects[id][slot][object_model] = 0;
    VehicleObjects[id][slot][object_toggle] = false;
    VehicleObjects[id][slot][object_exists] = false;

    for(new mx = 0; mx != MAX_COLOR_MATERIAL; mx++) {
	    VehicleObjects[id][slot][object_color][mx] = 1;
	}

    VehicleObjects[id][slot][object_x] = VehicleObjects[id][slot][object_y] = VehicleObjects[id][slot][object_z] = 0.0;
    VehicleObjects[id][slot][object_rx] = VehicleObjects[id][slot][object_ry] = VehicleObjects[id][slot][object_rz] = 0.0;

    if(remove) mysql_tquery(g_iHandle, sprintf("DELETE FROM `vehicle_object` WHERE `id` = '%d'", VehicleObjects[id][slot][object_id]));

    VehicleObjects[id][slot][object_id] = 0;
    return 1;
}

Vehicle_ObjectEdit(playerid, id, slot)
{
	if(PlayerTemp[playerid][temp_pivot] != INVALID_STREAMER_ID)
	{
		DestroyDynamicObject(PlayerTemp[playerid][temp_pivot]);
		PlayerTemp[playerid][temp_pivot] = INVALID_STREAMER_ID;
	}

	GetVehiclePos(VehicleData[id][cVehicle], VehicleData[id][cPos][0], VehicleData[id][cPos][1], VehicleData[id][cPos][2]);

	new Float:pos[3];
	GetVehiclePos(VehicleData[id][cVehicle], VehicleData[id][cPos][0], VehicleData[id][cPos][1], VehicleData[id][cPos][2]);

	pos[0] = VehicleData[id][cPos][0] + VehicleObjects[id][slot][object_x];
	pos[1] = VehicleData[id][cPos][1] + VehicleObjects[id][slot][object_y];
	pos[2] = VehicleData[id][cPos][2] + VehicleObjects[id][slot][object_z];

	PlayerTemp[playerid][temp_voldpos][0] = VehicleObjects[id][slot][object_x];
	PlayerTemp[playerid][temp_voldpos][1] = VehicleObjects[id][slot][object_y];
	PlayerTemp[playerid][temp_voldpos][2] = VehicleObjects[id][slot][object_z];
	PlayerTemp[playerid][temp_voldpos][3] = VehicleObjects[id][slot][object_rx];
	PlayerTemp[playerid][temp_voldpos][4] = VehicleObjects[id][slot][object_ry];
	PlayerTemp[playerid][temp_voldpos][5] = VehicleObjects[id][slot][object_rz];

	DestroyDynamicObject(VehicleObjects[id][slot][object_streamer]);

	PlayerTemp[playerid][temp_pivot] = CreateDynamicObject(VehicleObjects[id][slot][object_model], pos[0], pos[1], pos[2], VehicleObjects[id][slot][object_rx], VehicleObjects[id][slot][object_ry], VehicleObjects[id][slot][object_rz]);
	if(VehicleObjects[id][slot][object_type] == OBJECT_TYPE_BODY)
	{
		for(new mx = 0; mx != MAX_COLOR_MATERIAL; mx++) {
			SetDynamicObjectMaterial(PlayerTemp[playerid][temp_pivot], mx, VehicleObjects[id][slot][object_model], "none", "none", RGBAToARGB(ColorList[VehicleObjects[id][slot][object_color][mx]]));
		}
	}
	else SetDynamicObjectMaterialText(PlayerTemp[playerid][temp_pivot], 0, VehicleObjects[id][slot][object_text], OBJECT_MATERIAL_SIZE_512x512, VehicleObjects[id][slot][object_fonts], VehicleObjects[id][slot][object_fontsize], 1, RGBAToARGB(ColorList[VehicleObjects[id][slot][object_fontcolor]]), 0x00000000, OBJECT_MATERIAL_TEXT_ALIGN_CENTER);

	Streamer_Update(playerid);
	PlayerData[playerid][pEditingMode] = VEHICLE;
	EditDynamicObject(playerid, PlayerTemp[playerid][temp_pivot]);
	return 1;
}

Vehicle_ObjectColor(playerid, id, slot)
{
	new color[155];
    for(new mx = 0; mx != MAX_COLOR_MATERIAL; mx++)  {
        strcat(color, sprintf("{%06x}Color #%d %s\n", ColorList[VehicleObjects[id][slot][object_color][mx]] >>> 8, mx+1, (VehicleObjects[id][slot][object_color][mx] == 1) ? ("(original)") : ("")));
    }
    Dialog_Show(playerid, v_object_color, DIALOG_STYLE_LIST, "Select Index", color, "Select", "Close");
    return 1;
}

#include <YSI\y_hooks>
hook OnPlayerDisconnectEx(playerid) {
	if (PlayerData[playerid][pVObject] != -1 && PlayerData[playerid][pEditingMode] == VEHICLE) {
		if(PlayerTemp[playerid][temp_pivot] != INVALID_STREAMER_ID)
		{
			DestroyDynamicObject(PlayerTemp[playerid][temp_pivot]);
			PlayerTemp[playerid][temp_pivot] = INVALID_STREAMER_ID;
		}
	}
	return 1;
}


hook OnPlayerEditDynObj(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if (PlayerData[playerid][pVObject] != -1 && PlayerData[playerid][pEditingMode] == VEHICLE) {
		switch(response)
		{
			case EDIT_RESPONSE_CANCEL:
			{
				new id = PlayerData[playerid][pVObject],
					slot = PlayerData[playerid][pVObjectList];

				if(PlayerTemp[playerid][temp_pivot] != INVALID_STREAMER_ID)
				{
					DestroyDynamicObject(PlayerTemp[playerid][temp_pivot]);
					PlayerTemp[playerid][temp_pivot] = INVALID_STREAMER_ID;
				}
				VehicleObjects[id][slot][object_x] = PlayerTemp[playerid][temp_voldpos][0];
				VehicleObjects[id][slot][object_y] = PlayerTemp[playerid][temp_voldpos][1];
				VehicleObjects[id][slot][object_z] = PlayerTemp[playerid][temp_voldpos][2];
				VehicleObjects[id][slot][object_rx] = PlayerTemp[playerid][temp_voldpos][3];
				VehicleObjects[id][slot][object_ry] = PlayerTemp[playerid][temp_voldpos][4];
				VehicleObjects[id][slot][object_rz] = PlayerTemp[playerid][temp_voldpos][5];
				Vehicle_ObjectUpdate(id, slot);
				Streamer_Update(playerid);
				PlayerData[playerid][pEditingMode] = NOTHING;
				SendCustomMessage(playerid, "MODSHOP", "You've been canceled editing modification.");
				Dialog_Show(playerid, VACCSE, DIALOG_STYLE_LIST, "Vehicle Accesories > Edit", "%s\nEdit Position\nRemove From Vehicle", "Select", "Back", VehicleObjects[id][slot][object_type] == OBJECT_TYPE_BODY ? ("Set Color") : ("Edit Text"));
			}
			case EDIT_RESPONSE_FINAL:
			{
				new id = PlayerData[playerid][pVObject],
					slot = PlayerData[playerid][pVObjectList];

				if(PlayerTemp[playerid][temp_pivot] != INVALID_STREAMER_ID)
				{
					DestroyDynamicObject(PlayerTemp[playerid][temp_pivot]);
					PlayerTemp[playerid][temp_pivot] = INVALID_STREAMER_ID;
				}

				new Float:v_size[3];
				GetVehicleModelInfo(VehicleData[id][cModel], VEHICLE_MODEL_INFO_SIZE, v_size[0], v_size[1], v_size[2]);

				if	((VehicleObjects[id][slot][object_x] >= v_size[0] || -v_size[0] >= VehicleObjects[id][slot][object_x]) || (VehicleObjects[id][slot][object_y] >= v_size[1] || -v_size[1] >= VehicleObjects[id][slot][object_y]) || (VehicleObjects[id][slot][object_z] >= v_size[2] || -v_size[2] >= VehicleObjects[id][slot][object_z])) {
					SendErrorMessage(playerid, "Posisi object terlalu jauh dari body kendaraan.");
					VehicleObjects[id][slot][object_x] = PlayerTemp[playerid][temp_voldpos][0];
					VehicleObjects[id][slot][object_y] = PlayerTemp[playerid][temp_voldpos][1];
					VehicleObjects[id][slot][object_z] = PlayerTemp[playerid][temp_voldpos][2];
					VehicleObjects[id][slot][object_rx] = PlayerTemp[playerid][temp_voldpos][3];
					VehicleObjects[id][slot][object_ry] = PlayerTemp[playerid][temp_voldpos][4];
					VehicleObjects[id][slot][object_rz] = PlayerTemp[playerid][temp_voldpos][5];
					Vehicle_ObjectUpdate(id, slot);
					Streamer_Update(playerid);
					PlayerData[playerid][pEditingMode] = NOTHING;
					Dialog_Show(playerid, VACCSE, DIALOG_STYLE_LIST, "Vehicle Accesories > Edit", "%s\nEdit Position\nRemove From Vehicle", "Select", "Back", VehicleObjects[id][slot][object_type] == OBJECT_TYPE_BODY ? ("Set Color") : ("Edit Text"));
					return 1;
				}
				GiveMoney(playerid, -VEHICLE_OBJECT_EDIT_PRICE);
				new
	                Float:vx,
	                Float:vy,
	                Float:vz,
	                Float:va,
	                Float:real_x,
	                Float:real_y,
	                Float:real_z,
	                Float:real_a
	            ;
				GetVehiclePos(VehicleData[id][cVehicle], vx, vy, vz);

				real_x = x - vx;
	            real_y = y - vy;
	            real_z = z - vz;
	            real_a = rz - va;

				VehicleObjects[id][slot][object_x] = real_x;
				VehicleObjects[id][slot][object_y] = real_y;
				VehicleObjects[id][slot][object_z] = real_z;
				VehicleObjects[id][slot][object_rx] = rx;
				VehicleObjects[id][slot][object_ry] = ry;
				VehicleObjects[id][slot][object_rz] = real_a;

				Vehicle_ObjectUpdate(id, slot);
				Vehicle_ObjectSave(id, slot);
				//Streamer_UpdateEx(playerid, VehicleObjects[id][slot][object_x], VehicleObjects[id][slot][object_y], VehicleObjects[id][slot][object_z]);
				AttachDynamicObjectToVehicle(VehicleObjects[id][slot][object_streamer], VehicleData[id][cVehicle], real_x, real_y, real_z, rx, ry, real_a);
				Streamer_Update(playerid);
				PlayerData[playerid][pEditingMode] = NOTHING;
				SendCustomMessage(playerid, "MODSHOP", "Your vehicle modification has been saved.");
				Dialog_Show(playerid, VACCSE, DIALOG_STYLE_LIST, "Vehicle Accesories > Edit", "%s\nEdit Position\nRemove From Vehicle", "Select", "Back", VehicleObjects[id][slot][object_type] == OBJECT_TYPE_BODY ? ("Set Color") : ("Edit Text"));
			}
		}
	}
	return 1;
}
Function:Vehicle_ObjectDB(id, slot)
{
	if(VehicleObjects[id][slot][object_exists] == false)
		return 0;

	VehicleObjects[id][slot][object_id] = cache_insert_id();

	Vehicle_ObjectSave(id, slot);
	return 1;
}

CMD:addvacc(playerid, params[])
{
	if(CheckAdmin(playerid, 6))
        return PermissionError(playerid);


    static
        vehicle,
        model,
        id = -1;

    if(sscanf(params,"dd", vehicle, model))
        return SendSyntaxMessage(playerid, "/addvacc [vehicleid] [model]");

    if((id = Vehicle_GetID(vehicle)) != -1 && VehicleData[id][cOwner])
    {
    	if(Vehicle_ObjectAdd(id, model, OBJECT_TYPE_BODY)) SendServerMessage(playerid, "Sukses membuat objek kendaraan baru.");
    	else SendServerMessage(playerid, "Tidak ada slot untuk kendaraan ini lagi.");
    	return 1;
    }
    else SendErrorMessage(playerid, "Invalid vehicle id.");

    return 1;
}

CMD:addvacctext(playerid, params[])
{
	if(CheckAdmin(playerid, 5))
        return PermissionError(playerid);

    static
        vehicle,
        id = -1;

    if(sscanf(params,"d", vehicle))
        return SendSyntaxMessage(playerid, "/addvacc [vehicleid]");

    if((id = Vehicle_GetID(vehicle)) != -1 && VehicleData[id][cOwner])
    {
    	if(Vehicle_ObjectAdd(id, 18664, OBJECT_TYPE_TEXT)) SendServerMessage(playerid, "Sukses membuat objek kendaraan baru.");
    	else SendServerMessage(playerid, "Tidak ada slot untuk kendaraan ini lagi.");
    	return 1;
    }
    else SendErrorMessage(playerid, "Invalid vehicle id.");

    return 1;
}

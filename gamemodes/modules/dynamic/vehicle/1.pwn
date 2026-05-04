forward EnterBusVehicle(playerid, vehicleid);
forward EnterTrashmasterVehicle(playerid, vehicleid);
forward EnterSweeperVehicle(playerid, vehicleid);
forward EnterMoneytransVehicle(playerid, vehicleid);
forward EnterBoxvilleVehicle(playerid, vehicleid);

timer VehicleMod_ApplySideskirt[1000](vehicleid, componentid)
{
	switch (componentid)
	{
		case 1007, 1017: // Sideskirt Transfender
		{
			AddVehicleComponent(vehicleid, 1007); // Right
			AddVehicleComponent(vehicleid, 1017); // Left
		}
		case 1026, 1027: // Alien Sideskirt for Sultan
		{
			AddVehicleComponent(vehicleid, 1026); // Right
			AddVehicleComponent(vehicleid, 1027); // Left
		}
		case 1036, 1040: // Alien Sideskirt for Elegy
		{
			AddVehicleComponent(vehicleid, 1036); // Right
			AddVehicleComponent(vehicleid, 1040); // Left
		}
		case 1039, 1041: // X-Flow Sideskirt for Elegy
		{
			AddVehicleComponent(vehicleid, 1039); // Right
			AddVehicleComponent(vehicleid, 1041); // Left
		}
		case 1042, 1099: // Chrome Sideskirt for Broadway
		{
			AddVehicleComponent(vehicleid, 1042); // Right
			AddVehicleComponent(vehicleid, 1099); // Left
		}
		case 1047, 1051: // Alien Sideskirt for Flash
		{
			AddVehicleComponent(vehicleid, 1047); // Right
			AddVehicleComponent(vehicleid, 1051); // Left
		}
		case 1048, 1052: // X-Flow Sideskirt for Flash
		{
			AddVehicleComponent(vehicleid, 1048); // Right
			AddVehicleComponent(vehicleid, 1052); // Left
		}
		case 1056, 1062:  // Alien Sideskirt for Stratum
		{
			AddVehicleComponent(vehicleid, 1056); // Right
			AddVehicleComponent(vehicleid, 1062); // Left
		}
		case 1057, 1063: // X-Flow Sideskirt for Stratum
		{
			AddVehicleComponent(vehicleid, 1057); // Right
			AddVehicleComponent(vehicleid, 1063); // Left
		}
		case 1069, 1071: // Alien Sideskirt for Jester
		{
			AddVehicleComponent(vehicleid, 1069); // Right
			AddVehicleComponent(vehicleid, 1071); // Left
		}
		case 1070, 1072: // X-Flow Sideskirt for Jester
		{
			AddVehicleComponent(vehicleid, 1070); // Right
			AddVehicleComponent(vehicleid, 1072); // Left
		}
		case 1090, 1094: // Alien Sideskirt for Uranus
		{
			AddVehicleComponent(vehicleid, 1090); // Right
			AddVehicleComponent(vehicleid, 1094); // Left
		}
		case 1093, 1095: // X-Flow Sideskirt for Uranus
		{
			AddVehicleComponent(vehicleid, 1093); // Right
			AddVehicleComponent(vehicleid, 1095); // Left
		}
		case 1101, 1122: // 'Chrome Flames' Sideskirt for Remington
		{
			AddVehicleComponent(vehicleid, 1101); // Right
			AddVehicleComponent(vehicleid, 1122); // Left
		}
		case 1102, 1133: // 'Chrome Strip' Sideskirt for Savanna
		{
			AddVehicleComponent(vehicleid, 1102); // Left
			AddVehicleComponent(vehicleid, 1133); // Right
		}
		case 1106, 1124: // 'Chrome Arches' Sideskirt for Remington
		{
			AddVehicleComponent(vehicleid, 1106); // Right
			AddVehicleComponent(vehicleid, 1124); // Left
		}
		case 1107, 1108: // 'Chrome Strip' Sideskirt for Blade
		{
			AddVehicleComponent(vehicleid, 1107); // Right
			AddVehicleComponent(vehicleid, 1108); // Left
		}
		case 1118, 1120: // 'Chrome Trim' Sideskirt for Slamvan
		{
			AddVehicleComponent(vehicleid, 1118); // Right
			AddVehicleComponent(vehicleid, 1120); // Left
		}
		case 1119, 1121: // 'Wheelcovers' Sideskirt for Slamvan
		{
			AddVehicleComponent(vehicleid, 1119); // Right
			AddVehicleComponent(vehicleid, 1121); // Left
		}
		case 1134, 1137: // 'Chrome Strip' Sideskirt for Tornado
		{
			AddVehicleComponent(vehicleid, 1134); // Right
			AddVehicleComponent(vehicleid, 1137); // Left
		}
	}

	return 1;
}

Vehicle_GetInstalledMod(vehicleid, list[], length = sizeof(list))
{
	new
		count = 0,
		section_name[32]
	;

	format(list, length, "");

	if (!IsValidVehicle(vehicleid))
	{
		return 1;
	}

	for(new index = 0; index < MAX_VEHICLE_MOD_SECTIONS; index++)
	{
		VehicleMod_GetSectionName(index, section_name);

		if (VehicleData[vehicleid][vehMod][index] < 1000)
		{
			continue;
		}

		if (count == 0)
		{
			format(list, length, "Section ID\tSection Name\n%d\t%s\n", index, section_name);
		}
		else
		{
			format(list, length, "%s%d\t%s\n", list, index, section_name);
		}

		count++;
	}

	return 1;
}

Vehicle_HasInstalledMod(vehicleid, section)
{
	new veh_index = Vehicle_ReturnID(vehicleid);

	if (veh_index < 0)
	{
		return 0;
	}

	if (section < 0 || section > MAX_VEHICLE_MOD_SECTIONS)
	{
		return 0;
	}

	return (VehicleData[veh_index][vehMod][section] >= 1000 && VehicleData[veh_index][vehMod][section] <= MAX_VEHICLE_MOD_ID) == true ? 1 : 0;
}

Vehicle_CountInstalledMod(vehicleid)
{
	new
		count = 0,
		veh_index = Vehicle_ReturnID(vehicleid)
	;

	if (veh_index < 0) {
		return count;
	}

	if (!IsValidVehicle(vehicleid))
	{
		return count;
	}

	for(new index = 0; index < MAX_VEHICLE_MOD_SECTIONS; index++)
	{
		if (VehicleData[veh_index][vehMod][index] < 1000)
		{
			continue;
		}

		count++;
	}

	return count;
}

forward VehicleCreated(vehicleid);
public VehicleCreated(vehicleid)


forward VehicleLoaded();
public VehicleLoaded()


public OldVehicleLoaded(playerid)


forward VehicleWeaponLoaded(index);

forward VehicleInventoryLoaded(index);
public VehicleInventoryLoaded(index)


Vehicle_FactionDelete(factionid)
{
	static Iterator:vehicles<MAX_VEHICLES>;
	Iter_Init(vehicles);

	foreach(new vehicleid : Vehicle)
	{
		if(Vehicle_GetType(vehicleid) == VEHICLE_TYPE_FACTION && Vehicle_GetExtraID(vehicleid) == factionid)
		{
			if(IsValidVehicle(VehicleData[vehicleid][vehVehicleID]))
			{
				Iter_Add(vehicles, VehicleData[vehicleid][vehVehicleID]);
			}

			// Cargo on vehicle remove
			mysql_tquery(g_iHandle, sprintf("DELETE FROM `vehicle_cargo` WHERE `vehicle_id`='%d';", VehicleData[vehicleid][vehIndex]));

			// Vehicle database
			mysql_tquery(g_iHandle, sprintf("DELETE FROM `server_vehicles` WHERE `id` = '%d';", VehicleData[vehicleid][vehIndex]));

			Vehicle_ResetVariable(vehicleid);
		}
	}

	foreach (new vehicleid : vehicles)
	{
		DestroyVehicle(vehicleid);
	}

	return 1;
}

Vehicle_ExecuteInt(vehicleid, const column[], value)
{
	if(Vehicle_IsExists(vehicleid))
		return mysql_tquery(g_iHandle, sprintf("UPDATE `server_vehicles` SET `%s` = '%d' WHERE id='%d';", column, value, VehicleData[vehicleid][vehIndex]));

	return 0;
}
Vehicle_TogNeon(playerid, vehicleid)
{
	new index;
	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && VehicleData[index][vehNeonColor] > 0)
	{
		if(VehicleData[index][vehTogNeon] == 0)
		{
			VehicleData[index][vehTogNeon] = 1;
			SendClientMessage(playerid, COLOR_WHITE, ""RED"[VEHICLE] "WHITE"Kamu telah "RED" mematikan "WHITE" neon kendaraan");
			Vehicle_DeleteNeon(VehicleData[index][vehVehicleID]);
		}
		else
		{
			VehicleData[index][vehTogNeon] = 0;
			SendClientMessage(playerid, COLOR_WHITE, ""RED"[VEHICLE] "WHITE"Kamu telah "GREEN" menghidupkan "WHITE" neon kendaraan");
			Vehicle_CreateNeon(VehicleData[index][vehVehicleID], VehicleData[index][vehNeonColor]);
		}
	}
    return 1;
}
Vehicle_Save(vehicleid, save_mode = VEHICLE_SAVE_ALL)
{
	if (Vehicle_GetType(vehicleid) == VEHICLE_TYPE_NONE)
	{
		return 0;
	}

	if(Vehicle_IsExists(vehicleid))
	{
		switch(save_mode)
		{
			case VEHICLE_SAVE_ALL: 
			{
				new query[1250];
				mysql_format(g_iHandle, query, sizeof(query), "UPDATE `server_vehicles` SET `model`='%d',`extraid`='%d',`posX`='%.4f',`posY`='%.4f',`posZ`='%.4f',`posRZ`='%.4f',`renttime`='%d',`health`='%.2f',`plate`='%s',`fuel`='%.2f', `neoncolor` = '%d', `togneon` = '%d'",
					VehicleData[vehicleid][cModel],
					VehicleData[vehicleid][vehExtraID],
					VehicleData[vehicleid][vehPosX],
					VehicleData[vehicleid][vehPosY],
					VehicleData[vehicleid][vehPosZ],
					VehicleData[vehicleid][vehPosRZ],
					VehicleData[vehicleid][vehRentTime],
					VehicleData[vehicleid][cHealth],
					SQL_ReturnEscaped(VehicleData[vehicleid][vehPlate]),
					VehicleData[vehicleid][vehFuel],
					VehicleData[vehicleid][vehNeonColor],
					VehicleData[vehicleid][vehTogNeon]
				);

				mysql_format(g_iHandle, query, sizeof(query), "%s, `vehwoods` = '%d', `vehcomponent` = '%d', `parking` = '%d', `house_parking` = '%d', `doorstatus` = '%d', `enginestatus` = '%d'",
					query,
					VehicleData[vehicleid][vehComponent],
					VehicleData[vehicleid][vehWoods],
					VehicleData[vehicleid][vehParking],
					VehicleData[vehicleid][vehHouseParking],
					VehicleData[vehicleid][vehDoorStatus],
					VehicleData[vehicleid][vehEngineStatus]
				);

				mysql_format(g_iHandle, query, sizeof(query), "%s, `vehlocktire` = '%d', `vehhandbrake` = '%d'",
					query,
					VehicleData[vehicleid][vehLockTire],
					VehicleData[vehicleid][vehHandBrake]					
				);

				mysql_format(g_iHandle, query, sizeof(query), "%s,`type`='%d',`color1`='%d',`color2`='%d',`damage1`='%d',`damage2`='%d',`damage3`='%d',`damage4`='%d',`paintjob`='%d',`state`='%d',`siren`='%d',`engineup`='%d',`bodyup`='%d',`gasup`='%d',`bodyrepair`='%.3f', `turbo`='%d', `accumulated_mileage` = '%.4f', `current_mileage` = '%.4f', `durability_mileage` = '%.4f' WHERE `id`='%d';",
					query,
					VehicleData[vehicleid][vehType],
					VehicleData[vehicleid][cColor1],
					VehicleData[vehicleid][cColor2],
					VehicleData[vehicleid][vehPanel],
					VehicleData[vehicleid][vehDoor],
					VehicleData[vehicleid][vehLight],
					VehicleData[vehicleid][vehTires],
					VehicleData[vehicleid][cPaintjob],
					VehicleData[vehicleid][vehState],
					VehicleData[vehicleid][vehSiren],
					VehicleData[vehicleid][vehEngineUpgrade],
					VehicleData[vehicleid][vehBodyUpgrade],
					VehicleData[vehicleid][vehGasUpgrade],
					VehicleData[vehicleid][vehBodyRepair],
					VehicleData[vehicleid][vehTurbo],
					VehicleData[vehicleid][accumulatedMileage],
					VehicleData[vehicleid][currentMileage],
					VehicleData[vehicleid][durabilityMileage],
					VehicleData[vehicleid][vehIndex]
				);
				mysql_tquery(g_iHandle, query);
			}
			case VEHICLE_SAVE_COLOR:
			{
				mysql_tquery(g_iHandle, sprintf("UPDATE `server_vehicles` SET `color1`='%d', `color2`='%d', `paintjob`='%d' WHERE `id`='%d';",
					VehicleData[vehicleid][cColor1],
					VehicleData[vehicleid][cColor2],
					VehicleData[vehicleid][cPaintjob],
					VehicleData[vehicleid][vehIndex]
				));
			}
			case VEHICLE_SAVE_POSITION:
			{
				new query[500];
				mysql_format(g_iHandle, query, sizeof(query), "UPDATE `server_vehicles` SET `posX`='%.4f',`posY`='%.4f',`posZ`='%.4f',`posRZ`='%.4f',`interior`='%d',`world`='%d',`doorstatus`='%d',`enginestatus`='%d' WHERE `id`='%d';",
					VehicleData[vehicleid][vehPosX],
					VehicleData[vehicleid][vehPosY],
					VehicleData[vehicleid][vehPosZ],
					VehicleData[vehicleid][vehPosRZ],
					VehicleData[vehicleid][vehInterior],
					VehicleData[vehicleid][vehVirtual],
					VehicleData[vehicleid][vehDoorStatus],
					VehicleData[vehicleid][vehEngineStatus],
					VehicleData[vehicleid][vehIndex]
				);
				mysql_tquery(g_iHandle, query);
			}
			case VEHICLE_SAVE_DAMAGES:
			{
				new query[500];
				mysql_format(g_iHandle, query, sizeof(query), "UPDATE `server_vehicles` SET `damage1`='%d', `damage2`='%d', `damage3`='%d', `damage4`='%d', `health`='%.2f', `fuel`='%.2f' WHERE `id`='%d';",
					VehicleData[vehicleid][vehPanel],
					VehicleData[vehicleid][vehDoor],
					VehicleData[vehicleid][vehLight],
					VehicleData[vehicleid][vehTires],
					VehicleData[vehicleid][cHealth],
					VehicleData[vehicleid][vehFuel],
					VehicleData[vehicleid][vehIndex]
				);
				mysql_tquery(g_iHandle, query);
			}
			case VEHICLE_SAVE_MISC:
			{
				mysql_tquery(g_iHandle, sprintf("UPDATE `server_vehicles` SET `plate`='%s', `renttime`='%d', `state`='%d', `insurance`='%d', `engineup` ='%d', `bodyup` ='%d', `gasup`='%d', `bodyrepair`='%.3f', `neoncolor`='%d', `togneon`='%d', `vehwoods` = '%d', `vehcomponent` = '%d', `turbo` = '%d', `parking` = '%d', `house_parking` = '%d', `accumulated_mileage` = '%.4f', `current_mileage` = '%.4f', `durability_mileage` = '%.4f' WHERE `id`='%d';",
					SQL_ReturnEscaped(VehicleData[vehicleid][vehPlate]),
					VehicleData[vehicleid][vehRentTime],
					VehicleData[vehicleid][vehState],
					VehicleData[vehicleid][vehInsurance],
					VehicleData[vehicleid][vehEngineUpgrade],
					VehicleData[vehicleid][vehBodyUpgrade],
					VehicleData[vehicleid][vehGasUpgrade],
					VehicleData[vehicleid][vehBodyRepair],
					VehicleData[vehicleid][vehNeonColor],
					VehicleData[vehicleid][vehTogNeon],
					VehicleData[vehicleid][vehWoods],
					VehicleData[vehicleid][vehComponent],
					VehicleData[vehicleid][vehTurbo],
					VehicleData[vehicleid][vehParking],
					VehicleData[vehicleid][vehHouseParking],
					VehicleData[vehicleid][accumulatedMileage],
					VehicleData[vehicleid][currentMileage],
					VehicleData[vehicleid][durabilityMileage],
					VehicleData[vehicleid][vehIndex]
				));
			}
			case VEHICLE_SAVE_COMPONENT:
			{
				new query[500];
				mysql_format(g_iHandle, query, sizeof query, "INSERT INTO `vehicle_mod` VALUES ('%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d') ON DUPLICATE KEY UPDATE ", 
					VehicleData[vehicleid][vehIndex],
					VehicleData[vehicleid][vehMod][0],
					VehicleData[vehicleid][vehMod][1],
					VehicleData[vehicleid][vehMod][2],
					VehicleData[vehicleid][vehMod][3],
					VehicleData[vehicleid][vehMod][4],
					VehicleData[vehicleid][vehMod][5],
					VehicleData[vehicleid][vehMod][6],
					VehicleData[vehicleid][vehMod][7],
					VehicleData[vehicleid][vehMod][8],
					VehicleData[vehicleid][vehMod][9],
					VehicleData[vehicleid][vehMod][10],
					VehicleData[vehicleid][vehMod][11],
					VehicleData[vehicleid][vehMod][12],
					VehicleData[vehicleid][vehMod][13],
					VehicleData[vehicleid][vehMod][14],
					VehicleData[vehicleid][vehMod][15],
					VehicleData[vehicleid][vehMod][16]
				);
				mysql_format(g_iHandle, query, sizeof query, "%smod0=%d,mod1=%d,mod2=%d,mod3=%d,mod4=%d,mod5=%d,mod6=%d,mod7=%d,mod8=%d,mod9=%d,mod10=%d,mod11=%d,mod12=%d,mod13=%d,mod14=%d,mod15=%d,mod16=%d;",
					query,
					VehicleData[vehicleid][vehMod][0],
					VehicleData[vehicleid][vehMod][1],
					VehicleData[vehicleid][vehMod][2],
					VehicleData[vehicleid][vehMod][3],
					VehicleData[vehicleid][vehMod][4],
					VehicleData[vehicleid][vehMod][5],
					VehicleData[vehicleid][vehMod][6],
					VehicleData[vehicleid][vehMod][7],
					VehicleData[vehicleid][vehMod][8],
					VehicleData[vehicleid][vehMod][9],
					VehicleData[vehicleid][vehMod][10],
					VehicleData[vehicleid][vehMod][11],
					VehicleData[vehicleid][vehMod][12],
					VehicleData[vehicleid][vehMod][13],
					VehicleData[vehicleid][vehMod][14],
					VehicleData[vehicleid][vehMod][15],
					VehicleData[vehicleid][vehMod][16]
				);
				mysql_tquery(g_iHandle, query);
			}
		}
		return 1;
	}
	return 0;
}

Vehicle_TemporaryDelete()
{
	static Iterator:vehicles<MAX_VEHICLES>;
	Iter_Init(vehicles);

	foreach(new i : Vehicle)
	{
		if(Vehicle_GetType(i) == VEHICLE_TYPE_NONE)
		{
			if(IsValidVehicle(VehicleData[i][vehVehicleID]))
			{
				Iter_Add(vehicles, i);
			}

			Vehicle_ResetVariable(i);
			VehicleData[i][vehVehicleID] = INVALID_VEHICLE_ID;
		}
	}

	foreach (new i : vehicles)
	{
		DestroyVehicle(i);
	}
	return 1;
}
RemovePlayerFromRV(playerid)
{
	foreach(new i : Player)
	{
		new vw = GetPlayerVirtualWorld(i);
		new vehicleidext = (vw - 1000000);
		new playervehid = (vw + vehicleidext);
		new Float:x, Float:y, Float:z;
		if(vw > MIN_VIRTUAL_WORLD && vw < MAX_VIRTUAL_WORLD && playervehid == vw)
		{
			GetVehiclePos(vehicleidext, x, y, z);
			GetXYInFrontOfVehicle(vehicleidext, x, y, 2.0);
			SetPlayerPos(i, x, y, z);
			SetPlayerVirtualWorld(i, 0);

			SetPlayerPos(playerid, x, y, z);
			SetPlayerVirtualWorld(playerid, 0);
		}
	}
	return 1;
}
Vehicle_PlayerUnload(playerid) //Tambahing untuk destroy.
{
	foreach(new i : OwnedVehicles<playerid>)
	{
		if(VehicleData[i][cModel] == 508)
		{
			RemovePlayerFromRV(playerid);
		}	
		Vehicle_SaveData(i);
		
		Vehicle_Save(i, VEHICLE_SAVE_POSITION);
		Vehicle_Save(i, VEHICLE_SAVE_DAMAGES);
		Vehicle_Save(i, VEHICLE_SAVE_MISC);

		Vehicle_ObjectDestroy(VehicleData[i][vehVehicleID]);
		Vehicle_DeleteNeon(VehicleData[i][vehVehicleID]);
		Vehicle_StopLockTire(VehicleData[i][vehVehicleID]);
		Vehicle_StopHandbrake(VehicleData[i][vehVehicleID]);

		printf("Resetting owned vehicle id: %d (%d) (%s)", VehicleData[i][vehVehicleID], i, ReturnName(playerid, 1));

		if(IsValidDynamic3DTextLabel(VehicleData[i][vehLockTireText]))
			DestroyDynamic3DTextLabel(VehicleData[i][vehLockTireText]);

        VehicleData[i][vehLockTireText] = Text3D:INVALID_STREAMER_ID;

		if (IsValidVehicle(VehicleData[i][vehVehicleID]))
		{
			DestroyVehicle(VehicleData[i][vehVehicleID]);
		}

		printf("Owned unload: %d", i);
		Vehicle_ResetVariable(i);

		new current = i;
		Iter_SafeRemove(OwnedVehicles<playerid>, current, i);

	}

	return 1;
}

Vehicle_RentalUnload(playerid)
{
	foreach(new i : RentedVehicles<playerid>)
	{
		Vehicle_SaveData(i);

		Vehicle_Save(i, VEHICLE_SAVE_ALL);
		Vehicle_Save(i, VEHICLE_SAVE_POSITION);
		Vehicle_Save(i, VEHICLE_SAVE_DAMAGES);
		Vehicle_Save(i, VEHICLE_SAVE_MISC);

		printf("Resetting rental vehicle id: %d (%d) (%s)", VehicleData[i][vehVehicleID], i, ReturnName(playerid, 1));

		if(IsValidDynamic3DTextLabel(VehicleData[i][vehLockTireText]))
			DestroyDynamic3DTextLabel(VehicleData[i][vehLockTireText]);

        VehicleData[i][vehLockTireText] = Text3D:INVALID_STREAMER_ID;

		if(IsValidVehicle(VehicleData[i][vehVehicleID]))
			DestroyVehicle(VehicleData[i][vehVehicleID]);

		Vehicle_ResetVariable(i);

		new
			current = i;
		Iter_SafeRemove(RentedVehicles<playerid>, current, i);
	}

	foreach(new i : RentedVehicles<playerid>)
		printf("Rental unload: %d", i);

	return 1;
}

Vehicle_IsExists(vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid))
		return 1;

	return 0;
}

Vehicle_ExtraID(vehicleid, index = 0)
{
	if(Iter_Contains(Vehicle, vehicleid)) {
		VehicleData[vehicleid][vehExtraID] = index;
		return 1;
	}

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_GetExtraID(vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid))
		return VehicleData[vehicleid][vehExtraID];

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_SetKillerID(vehicleid, killerid)
{
	if(Iter_Contains(Vehicle, vehicleid)){
		VehicleData[vehicleid][vehKillerID] = killerid;
		return 1;
	}

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_GetKillerID(vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid))
		return VehicleData[vehicleid][vehKillerID];

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_SetOwner(playerid, vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid)) {
		Vehicle_SetType(vehicleid, VEHICLE_TYPE_PLAYER);
		Vehicle_ExtraID(vehicleid, GetPlayerSQLID(playerid));
		Iter_Add(OwnedVehicles<playerid>, vehicleid);
		return 1;
	}

	return RETURN_INVALID_VEHICLE_ID;
}

stock Vehicle_RemoveOwner(playerid, vehicleid)
{
	if(Iter_Contains(OwnedVehicles<playerid>, vehicleid)) {
		Vehicle_SetType(vehicleid, VEHICLE_TYPE_NONE);
		Vehicle_ExtraID(vehicleid);
		Iter_Remove(OwnedVehicles<playerid>, vehicleid);
		return 1;
	}

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_SetRentalOwned(playerid, vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid)) {
		Vehicle_SetType(vehicleid, VEHICLE_TYPE_RENTAL);
		Vehicle_ExtraID(vehicleid, GetPlayerSQLID(playerid));
		Iter_Add(RentedVehicles<playerid>, vehicleid);

		return 1;
	}

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_RemoveRented(playerid, vehicleid)
{
	if(Iter_Contains(RentedVehicles<playerid>, vehicleid)) {
		Vehicle_SetType(vehicleid, VEHICLE_TYPE_NONE);
		Vehicle_ExtraID(vehicleid);
		Iter_Remove(RentedVehicles<playerid>, vehicleid);
		return 1;
	}

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_RentedCount(playerid)
{
	if(Iter_Count(RentedVehicles<playerid>))
		return Iter_Count(RentedVehicles<playerid>);

	return 0;
}

Vehicle_SetFaction(factionid, vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid)) {
		Vehicle_SetType(vehicleid, VEHICLE_TYPE_FACTION);
		Vehicle_ExtraID(vehicleid, factionid);
		return 1;
	}

	return RETURN_INVALID_VEHICLE_ID;
}
Vehicle_IsSharedToPlayer(playerid, vehicleid)
{
	for(new i; i < PLAYER_MAX_VEHICLE_SHARE_KEYS; i++) 
	if(Vehicle_GetType(vehicleid) != VEHICLE_TYPE_NONE && VehicleKeyData[playerid][i][vehicleID] == VehicleData[vehicleid][vehIndex])
		return 1;

	return 0;
}
Vehicle_IsOwned(playerid, vehicleid)
{
	if(Iter_Contains(OwnedVehicles<playerid>, vehicleid))
		return 1;

	return 0;
}

Vehicle_IsRented(playerid, vehicleid)
{
	if(Iter_Contains(RentedVehicles<playerid>, vehicleid))
		return 1;

	return 0;
}

stock Vehicle_PlayerList(playerid)
{
	if(!Vehicle_PlayerCount(playerid))
		return SendErrorMessage(playerid, "Kamu tidak memiliki satupun kendaraan!");

	new vehicle_list[128];
	foreach(new vehicleid : OwnedVehicles<playerid>)
		strcat(vehicle_list, sprintf("%s\n", GetVehicleNameByModel(VehicleData[vehicleid][cModel])));

	Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_LIST, "All Vehicle(s)", vehicle_list, "Close", "");
	return 1;
}

Vehicle_PlayerCount(playerid)
{
	if(Iter_Count(OwnedVehicles<playerid>))
		return Iter_Count(OwnedVehicles<playerid>);

	return 0;
}

Vehicle_PlayerTotalCount(playerid)
{
	new Cache:execute, total = 0;

	execute = mysql_query(g_iHandle, sprintf("SELECT `id` FROM `server_vehicles` WHERE `extraid`='%d' AND `type`='%d';", GetPlayerSQLID(playerid), VEHICLE_TYPE_PLAYER));

	if(cache_num_rows())
		total = cache_num_rows();

	cache_delete(execute);
	return total;
}

Vehicle_CargoCount(vehicleid)
{
	new Cache:execute, total = 0;

	execute = mysql_query(g_iHandle, sprintf("SELECT `id` FROM `vehicle_cargo` WHERE `vehicle_id`='%d';", VehicleData[vehicleid][vehIndex]));

	if(cache_num_rows())
		total = cache_num_rows();

	cache_delete(execute);
	return total;
}

Vehicle_ReturnID(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return RETURN_INVALID_VEHICLE_ID;

	foreach(new index : Vehicle) if(VehicleData[index][vehVehicleID] == vehicleid)
		return index;

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_SaveData(vehicleid, bool:pos = false)
{
	if(Iter_Contains(Vehicle, vehicleid))
	{
		if(IsValidVehicle(VehicleData[vehicleid][vehVehicleID]))
		{
			VehicleData[vehicleid][vehVirtual] = GetVehicleVirtualWorld(VehicleData[vehicleid][vehVehicleID]);
			
			VehicleData[vehicleid][vehDoorStatus] = (GetDoorStatus(vehicleid)) ? 1 : 0;
			VehicleData[vehicleid][vehEngineStatus] = (GetEngineStatus(vehicleid)) ? 1 : 0;

			GetVehiclePos(VehicleData[vehicleid][vehVehicleID], VehicleData[vehicleid][vehPosX], VehicleData[vehicleid][vehPosY], VehicleData[vehicleid][vehPosZ]);
			GetVehicleZAngle(VehicleData[vehicleid][vehVehicleID], VehicleData[vehicleid][vehPosRZ]);

			if(!pos) 
			{
				GetVehicleHealth(VehicleData[vehicleid][vehVehicleID], VehicleData[vehicleid][cHealth]);
				GetVehicleDamageStatus(VehicleData[vehicleid][vehVehicleID], VehicleData[vehicleid][vehPanel], VehicleData[vehicleid][vehDoor], VehicleData[vehicleid][vehLight], VehicleData[vehicleid][vehTires]);
			}
		}
		return 1;
	}
	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_Respawn(vehicleid, bool:plate_sync = false)
{
	if(Iter_Contains(Vehicle, vehicleid))
	{
		new
			vid = INVALID_VEHICLE_ID;

		if((vid = VehicleData[vehicleid][vehVehicleID]) != INVALID_VEHICLE_ID)
		{
			if(plate_sync)
			{
				SetVehicleNumberPlate(vid, VehicleData[vehicleid][vehPlate]);
				SetVehicleToRespawn(vid);

				//====temp
				for(new i = 0; i != 14; i++) if(VehicleData[vehicleid][vehMod][i]) {
			    	AddVehicleComponent(VehicleData[vehicleid][vehVehicleID], VehicleData[vehicleid][vehMod][i]);
		    	}
			}

			SetEngineStatus(vid, false);
			SetLightStatus(vid, false);
			if(Vehicle_GetType(vehicleid) == VEHICLE_TYPE_DRIVING_SCHOOL || Vehicle_GetType(vehicleid) == VEHICLE_TYPE_SIDEJOB)
			{
				SetDoorStatus(vid, false);
			}

			if(IsValidDynamicObject(Vehicle_RadarObjectID[vehicleid]))
			{
				DestroyDynamicObject(Vehicle_RadarObjectID[vehicleid]);
				Vehicle_RadarObjectID[vehicleid] = INVALID_STREAMER_ID;
			}
			if(Vehicle_RadarToggle[vehicleid])
			{
				stop Vehicle_CheckingSpeed[vehicleid];
				Vehicle_RadarToggle[vehicleid] = false;
				foreach(new i : Player)
				{
					if (IsPlayerInVehicle (i, vehicleid))
					{
						DisableSpeedRadar(i);
					}
				}
			}

			for(new i = 0; i < MAX_GUNRACK_SLOT; i++)
			{
				Vehicle_ResetGunrack(vehicleid, i);
			}

			SetVehiclePos(vid, VehicleData[vehicleid][vehPosX], VehicleData[vehicleid][vehPosY], VehicleData[vehicleid][vehPosZ]);
			SetVehicleZAngle(vid, VehicleData[vehicleid][vehPosRZ]);

			SetVehicleHealth(vid, VehicleData[vehicleid][cHealth]);
			
			LinkVehicleToInterior(vid, VehicleData[vehicleid][vehInterior]);
			SetVehicleVirtualWorld(vid, VehicleData[vehicleid][vehVirtual]);

			ChangeVehiclePaintjob(vid, VehicleData[vehicleid][cPaintjob]);
			ChangeVehicleColor(vid, VehicleData[vehicleid][cColor1], VehicleData[vehicleid][cColor2]);

			UpdateVehicleDamageStatus(vid, VehicleData[vehicleid][vehPanel], VehicleData[vehicleid][vehDoor], VehicleData[vehicleid][vehLight], VehicleData[vehicleid][vehTires]);

			printf("Respawning vehicle id %d", vid);
		}
		return 1;
	}
	return RETURN_INVALID_VEHICLE_ID;
}

//Untuk ngerespawn object si neon
Vehicle_ReplaceNeon(vehicleid, neoncolor)
{
	static index = -1;
	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(index) != VEHICLE_TYPE_NONE)
	{
		VehicleData[index][vehNeonColor] = neoncolor;
		VehicleData[index][vehTogNeon] = 0;

		if(IsValidDynamicObject(VehicleData[index][vehNeonL]))
			DestroyDynamicObject(VehicleData[index][vehNeonL]);
		
		if(IsValidDynamicObject(VehicleData[index][vehNeonR]))
			DestroyDynamicObject(VehicleData[index][vehNeonR]);

		VehicleData[index][vehNeonL] = INVALID_STREAMER_ID;
		VehicleData[index][vehNeonR] = INVALID_STREAMER_ID;

		VehicleData[index][vehNeonL] = CreateDynamicObject(neoncolor,0,0,0,0,0,0);
		VehicleData[index][vehNeonR] = CreateDynamicObject(neoncolor,0,0,0,0,0,0);

		AttachDynamicObjectToVehicle(VehicleData[index][vehNeonR], VehicleData[index][vehVehicleID], 0.8, 0.0, -0.50, 0.0, 0.0, 0.0);
		AttachDynamicObjectToVehicle(VehicleData[index][vehNeonL], VehicleData[index][vehVehicleID], -0.8, 0.0, -0.50, 0.0, 0.0, 0.0);
		Vehicle_Save(index, VEHICLE_SAVE_MISC);
	}
	return 1;
}

//Untuk ngedelete object si neon
Vehicle_DeleteNeon(vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid))
	{
		if(IsValidDynamicObject(VehicleData[vehicleid][vehNeonL]))
			DestroyDynamicObject(VehicleData[vehicleid][vehNeonL]);

		if(IsValidDynamicObject(VehicleData[vehicleid][vehNeonR]))
			DestroyDynamicObject(VehicleData[vehicleid][vehNeonR]);

		VehicleData[vehicleid][vehNeonL] = INVALID_STREAMER_ID;
		VehicleData[vehicleid][vehNeonR] = INVALID_STREAMER_ID;
	}
	return 1;
}
Vehicle_UninstallNeon(vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid))
	{
		if(IsValidDynamicObject(VehicleData[vehicleid][vehNeonL]))
			DestroyDynamicObject(VehicleData[vehicleid][vehNeonL]);

		if(IsValidDynamicObject(VehicleData[vehicleid][vehNeonR]))
			DestroyDynamicObject(VehicleData[vehicleid][vehNeonR]);
		
		VehicleData[vehicleid][vehNeonL] = INVALID_STREAMER_ID;
		VehicleData[vehicleid][vehNeonR] = INVALID_STREAMER_ID;

		VehicleData[vehicleid][vehNeonColor] = 0;
	}
	return 1;
}
//Untuk ngecreate object si neon.
Vehicle_CreateNeon(vehicleid, neoncolor)
{
	static index = -1;
	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(index) != VEHICLE_TYPE_NONE)
	{
		VehicleData[index][vehNeonColor] = neoncolor;
		VehicleData[index][vehTogNeon] = 0;

		if(IsValidDynamicObject(VehicleData[index][vehNeonL]))
			DestroyDynamicObject(VehicleData[index][vehNeonL]);
		
		if(IsValidDynamicObject(VehicleData[index][vehNeonR]))
			DestroyDynamicObject(VehicleData[index][vehNeonR]);

		VehicleData[index][vehNeonL] = INVALID_STREAMER_ID;
		VehicleData[index][vehNeonR] = INVALID_STREAMER_ID;

		VehicleData[index][vehNeonL] = CreateDynamicObject(neoncolor,0,0,0,0,0,0);
		VehicleData[index][vehNeonR] = CreateDynamicObject(neoncolor,0,0,0,0,0,0);

		AttachDynamicObjectToVehicle(VehicleData[index][vehNeonR], VehicleData[index][vehVehicleID], 0.8, 0.0, -0.50, 0.0, 0.0, 0.0);
		AttachDynamicObjectToVehicle(VehicleData[index][vehNeonL], VehicleData[index][vehVehicleID], -0.8, 0.0, -0.50, 0.0, 0.0, 0.0);
		Vehicle_Save(index, VEHICLE_SAVE_MISC);
	}
	return 1;
}

Vehicle_SetColor(vehicleid, color1 = -1, color2 = -1)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(index) != VEHICLE_TYPE_NONE)
	{
		VehicleData[index][cColor1] = ((color1 == -1) ? random(255) : color1);
		VehicleData[index][cColor2] = ((color1 == -1) ? random(255) : color2);
		Vehicle_Save(index, VEHICLE_SAVE_COLOR);
	}

	ChangeVehicleColor(vehicleid, (color1 == -1) ? random(255) : color1, (color1 == -1) ? random(255) : color2);
	return 1;
}

Vehicle_AddComponent(vehicleid, componentid)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(index) != VEHICLE_TYPE_NONE)
	{
		new section = VehicleMod_GetComponentSection(componentid);

		if (section >= 0 && section < MAX_VEHICLE_MOD_SECTIONS)
		{
			VehicleData[index][vehMod][section] = componentid;
			Vehicle_Save(index, VEHICLE_SAVE_COMPONENT);
		}
	}

	AddVehicleComponent(vehicleid, componentid);
	return 1;
}

Vehicle_RemoveComponent(vehicleid, componentid)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(index) != VEHICLE_TYPE_NONE)
	{
		new section = VehicleMod_GetComponentSection(componentid);

		if (section >= 0 && section < MAX_VEHICLE_MOD_SECTIONS)
		{
			VehicleData[index][vehMod][section] = 0;
			Vehicle_Save(index, VEHICLE_SAVE_COMPONENT);
		}
	}

	RemoveVehicleComponent(vehicleid, componentid);
	return 1;
}

Vehicle_AddUpgrade(vehicleid, type)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(index) != VEHICLE_TYPE_NONE)
	{
		if(type == 1)
		{
			VehicleData[index][vehEngineUpgrade] = type; //1 Engine untuk ke DB
			VehicleData[vehicleid][vehEngineUpgrade] = type; // 1 Engine untuk VehID Ingame
			Vehicle_Save(index, VEHICLE_SAVE_MISC);
		}
		else if(type == 2)
		{
			 VehicleData[index][vehGasUpgrade] = type;
			 VehicleData[vehicleid][vehGasUpgrade] = type;
			 Vehicle_Save(index, VEHICLE_SAVE_MISC);
		}
		else if(type == 3)
		{
			VehicleData[index][vehBodyUpgrade] = type; // 3 Body untuk ke DB
			VehicleData[vehicleid][vehBodyUpgrade] = type; // 3 Body untuk ingame
			Vehicle_Save(index, VEHICLE_SAVE_MISC);
		}
	}
	return 1;
}
Vehicle_SetPaintjob(vehicleid, paintjobid)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(index) != VEHICLE_TYPE_NONE)
	{
		VehicleData[index][cPaintjob] = paintjobid;
		Vehicle_Save(index, VEHICLE_SAVE_COLOR);
	}
	ChangeVehiclePaintjob(vehicleid, paintjobid);
	return 1;
}

Vehicle_SetType(vehicleid, type = VEHICLE_TYPE_NONE)
{
	if(Iter_Contains(Vehicle, vehicleid)) {
		VehicleData[vehicleid][vehType] = type;
		return 1;
	}

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_GetType(vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid))
		return VehicleData[vehicleid][vehType];

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_SetState(vehicleid, states = VEHICLE_STATE_SPAWNED)
{
	if(Iter_Contains(Vehicle, vehicleid))
		return VehicleData[vehicleid][vehState] = states;

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_GetState(vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid))
		return VehicleData[vehicleid][vehState];

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_PlayerLoad(playerid)
{
	mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `parking`='0' AND `house_parking`='-1' AND `extraid`='%d' AND `type`='%d' AND `state`='%d' ORDER BY `id` ASC LIMIT %d;", GetPlayerSQLID(playerid), VEHICLE_TYPE_PLAYER, VEHICLE_STATE_SPAWNED, MAX_OWNED_VEHICLES), "VehicleLoaded", "");
	mysql_tquery(g_iHandle, sprintf("SELECT * FROM `player_vehicles` WHERE `owner`='%d';", GetPlayerSQLID(playerid)), "OldVehicleLoaded", "d", playerid);
	return 1;
}

Vehicle_RentalLoad(playerid)
{
	mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `extraid`='%d' AND `type`='%d' ORDER BY `id` ASC LIMIT %d;", GetPlayerSQLID(playerid), VEHICLE_TYPE_RENTAL, MAX_RENTED_VEHICLES), "VehicleLoaded", "d", INVALID_PLAYER_ID);
	return 1;
}

Vehicle_FactionLoad(factionid)
{
	// mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `health` = '2000.0' WHERE `engineup` = '1' AND `extraid`='%d' AND `type`='%d' ORDER BY `id` ASC;", factionid, VEHICLE_TYPE_FACTION), "VehicleLoaded", "d", INVALID_PLAYER_ID);
	mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `extraid`='%d' AND `type`='%d' ORDER BY `id` ASC;", factionid, VEHICLE_TYPE_FACTION), "VehicleLoaded", "d", INVALID_PLAYER_ID);
	return 1;
}

Vehicle_SidejobLoad()
{
	mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `type`='%d' ORDER BY `id` ASC;", VEHICLE_TYPE_SIDEJOB), "VehicleLoaded", "d", INVALID_PLAYER_ID);
	return 1;
}

Vehicle_DMVLoad()
{
	mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `type`='%d' ORDER BY `id` ASC;", VEHICLE_TYPE_DRIVING_SCHOOL), "VehicleLoaded", "d", INVALID_PLAYER_ID);
	return 1;
}

Vehicle_Nearest(playerid, Float:range = 5.0)
{
	new id = -1, Float: playerdist, Float: tempdist = 9999.0, Float:x, Float:y, Float:z;
	
	foreach(new i : Vehicle) 
	{
		GetVehiclePos(i, x, y, z);
        playerdist = GetPlayerDistanceFromPoint(playerid, x, y, z);
        
        if(playerdist > range) continue;

	    if(playerdist <= tempdist) {
	        tempdist = playerdist;
	        id = i;
	    }
	}
	return id;
}

IsBusVehicle(vehicleid)
{
	new vehicle_id;
	if((vehicle_id = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(vehicle_id) == VEHICLE_TYPE_SIDEJOB && Vehicle_GetExtraID(vehicle_id) == VEHICLE_SIDEJOB_BUS)
		return 1;

	return 0;
}

/*IsSweeperVehicle(vehicleid)
{
	new vehicle_id;
	if((vehicle_id = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(vehicle_id) == VEHICLE_TYPE_SIDEJOB && Vehicle_GetExtraID(vehicle_id) == VEHICLE_SIDEJOB_SWEEPER)
		return 1;

	return 0;
}

IsTrashmasterVehicle(vehicleid)
{
	new vehicle_id;
	if((vehicle_id = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID && Vehicle_GetType(vehicle_id) == VEHICLE_TYPE_SIDEJOB && Vehicle_GetExtraID(vehicle_id) == VEHICLE_SIDEJOB_TRASHMASTER)
		return 1;

	return 0;
}*/

Vehicle_SetRentTime(vehicleid, value)
{
	if(Iter_Contains(Vehicle, vehicleid)) {
		VehicleData[vehicleid][vehRentTime] = value;
		return 1;
	}

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_GetRentTime(vehicleid)
{
	if(Iter_Contains(Vehicle, vehicleid))
		return VehicleData[vehicleid][vehRentTime];

	return RETURN_INVALID_VEHICLE_ID;
}

Vehicle_RentInfo(playerid)
{
	if(!Iter_Count(RentedVehicles<playerid>))
		return Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_LIST, "Vehicle Rental(s)", "Kamu tidak memiliki kendaraan sewaan", "Close", "");

	new output[256];

	strcat(output, "Model\tDurasi\n");

	foreach(new i : RentedVehicles<playerid>)
	{
		new times[3];
		GetElapsedTime(Vehicle_GetRentTime(i), times[0], times[1], times[2]);

		strcat(output, sprintf(""LIGHTBLUE"%s\t"YELLOW"%d jam %d menit %d detik\n", GetVehicleNameByModel(VehicleData[i][cModel]), times[0], times[1], times[2]));
	}
	Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_TABLIST_HEADERS, "Vehicle Rental(s)", output, "Close", "");
	return 1;
}

stock Vehicle_ShowWeapon(playerid, vehicleid)
{
	if(!Iter_Contains(Vehicle, vehicleid))
		return 0;

	new output[255];

    strcat(output, "Weapon\tAmmo\tDurability\n");
	for(new i = 0; i != MAX_VEHICLE_STORAGE; i++)
	{
		if(22 <= VehicleData[vehicleid][vehWeapon][i] <= 38) strcat(output, sprintf("%s\t%d\t%d\n", ReturnWeaponName(VehicleData[vehicleid][vehWeapon][i]), VehicleData[vehicleid][vehAmmo][i], VehicleData[vehicleid][vehDurability][i]));
        else strcat(output, sprintf("{%s}%s\t \t \n", (VehicleData[vehicleid][vehWeapon][i]) ? ("C0C0C0") : ("FFFFFF"), (VehicleData[vehicleid][vehWeapon][i]) ? (ReturnWeaponName(VehicleData[vehicleid][vehWeapon][i])) : (""WHITE"Empty Slot")));
	}
    Dialog_Show(playerid, OperateWeapon, DIALOG_STYLE_TABLIST_HEADERS, "Car Trunk", output, "Select", "Cancel");
	return 1;
}

Vehicle_FactionRespawn(factionid)
{
	foreach(new vehicle_index : Vehicle) if(GetVehicleDriver(VehicleData[vehicle_index][vehVehicleID]) == INVALID_PLAYER_ID)
	{
		if(Vehicle_GetType(vehicle_index) == VEHICLE_TYPE_FACTION && Vehicle_GetExtraID(vehicle_index) == factionid)
		{
			SetEngineStatus(VehicleData[vehicle_index][vehVehicleID], false);
			SetLightStatus(VehicleData[vehicle_index][vehVehicleID], false);
			Vehicle_Respawn(vehicle_index);
		}
	}
	return 1;
}

Vehicle_ShowTrunk(playerid, vehicleid)
{
	new output[300];

	strcat(output, "Item\tAmmo/Quantity\tDurability\n");
	for(new i = 0; i != MAX_VEHICLE_STORAGE; i++)
	{
		switch(_:VehicleData[vehicleid][vehTrunkType][i])
		{
			case e_TRUNK_WEAPON:
			{
				strcat(output, sprintf(RED"%s\t%d\t%d\n", ReturnWeaponName(VehicleData[vehicleid][vehWeapon][i]), VehicleData[vehicleid][vehAmmo][i], VehicleData[vehicleid][vehDurability][i]));
			}
			case e_TRUNK_INVENTORY:
			{
				strcat(output, sprintf(LIGHTBLUE"%s\t%d\t \n", VehicleStorageData[vehicleid][i][vehInvName], VehicleStorageData[vehicleid][i][vehInvQuantity]));
			}
			default: strcat(output, "Empty\t \t \n");
		}
	}

	Dialog_Show(playerid, VehicleTrunk, DIALOG_STYLE_TABLIST_HEADERS, "Vehicle Trunk", output, "Select", "Close");
	return 1;
}// Player virtualworld - 1000000

Vehicle_AddItem(playerid, index, slot, items[], model)
{
	if(!Inventory_HasItem(playerid, items))
	{
		Dialog_Show(playerid, VehicleTrunkOption, DIALOG_STYLE_LIST, "Your item(s)", "Store Weapon\nStore Drugs\nStore Seeds\nStore Foods", "Select", "<<");
		return SendErrorMessage(playerid, "Kamu tidak memiliki item "YELLOW"%s", items);
	}

	new quantity = Inventory_Count(playerid, items),
		nearest_vehicle = GetPVarInt(playerid, "CarStorage");

	if(Vehicle_Nearest(playerid) != nearest_vehicle)
		return SendErrorMessage(playerid, "Terlalu jauh dari posisi kendaraan yang kamu operasikan, gagal meletakkan item!"), SetTrunkStatus(nearest_vehicle, false);

    VehicleData[index][vehTrunkType][slot] = e_TRUNK_INVENTORY;

    format(VehicleStorageData[index][slot][vehInvName], 32, items);
    VehicleStorageData[index][slot][vehInvModel] = model; 
    VehicleStorageData[index][slot][vehInvQuantity] = quantity;

    new query[400];
    mysql_format(g_iHandle, query, sizeof(query), "INSERT INTO `carstorage` (`itemVehicle`,`itemName`,`itemModel`,`itemQuantity`) VALUES('%d', '%s', '%d', '%d');", VehicleData[index][vehIndex], items, model, quantity);
    mysql_tquery(g_iHandle, query, "VehicleInventoryCreated", "dd", index, slot);

	SetTrunkStatus(nearest_vehicle, false);
    SendServerMessage(playerid, "Sukses meletakkan "YELLOW"%s "WHITE"kedalam bagasi!", items);
	Log_Save(E_LOG_VEHICLE_STORAGE, sprintf("[%s] %s store a \"%s\" (%d) from the trunk vehicle %s (dbid: %d).", ReturnDate(), ReturnName(playerid, 0), items, quantity, GetVehicleNameByVehicle(nearest_vehicle), VehicleData[index][vehIndex]));

	Inventory_Remove(playerid, items, quantity);
	return 1;
}

// Fuel Function
Vehicle_AddFuel(vehicleid, Float:value)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID) {
		VehicleData[index][vehFuel] += value;
		return 1;
	}

	return 0;
}

Vehicle_SetFuel(vehicleid, Float:value)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID) {
		VehicleData[index][vehFuel] = value;
		return 1;
	}

	return 0;
}

Vehicle_GetFuel(vehicleid)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID)
		return floatround(VehicleData[index][vehFuel]);

	return 0;
}

/**
 * ============================
 * Mileage
 * ============================
 */

// Accumulated Mileage

Vehicle_GetAccumulatedMileage(vehicleid)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID)
		return floatround(VehicleData[index][accumulatedMileage], floatround_ceil);

	return 0;
}

Vehicle_SetAccumulatedMileage(vehicleid, Float:value)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID) {
		VehicleData[index][accumulatedMileage] = value;
		return 1;
	}

	return 0;
}

// Current Mileage

Vehicle_GetCurrentMileage(vehicleid)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID)
		return floatround(VehicleData[index][currentMileage], floatround_ceil);

	return 0;
}

Vehicle_SetCurrentMileage(vehicleid, Float:value)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID) {
		VehicleData[index][currentMileage] = value;
		return 1;
	}

	return 0;
}

Vehicle_AddCurrentMileage(vehicleid, Float:value)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID) {
		VehicleData[index][currentMileage] += value;
		return 1;
	}

	return 0;
}

Vehicle_ReduceCurrentMileage(vehicleid, Float:value)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID) {
		VehicleData[index][currentMileage] -= value;
		return 1;
	}

	return 0;
}

// Durability Mileage

Vehicle_GetDurabilityMileage(vehicleid)
{
	static index;

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID)
		return floatround(VehicleData[index][durabilityMileage], floatround_ceil);

	return 0;
}

Vehicle_SetDurabilityMileage(vehicleid, Float:value)
{
	static index;

	if (value < SAFE_MILEAGE)
	{
		return 0;
	}

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID) {
		VehicleData[index][durabilityMileage] = value;
		return 1;
	}

	return 0;
}

Vehicle_AddDurabilityMileage(vehicleid, Float:value)
{
	static index;

	if (value < SAFE_MILEAGE)
	{
		return 0;
	}

	if((index = Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID) {
		VehicleData[index][durabilityMileage] += value;
		return 1;
	}

	return 0;
}

// Other Mileage Functions

bool:Vehicle_IsMileageOverused(vehicleid)
{
	if((Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID) {
		return (Vehicle_GetCurrentMileage(vehicleid) > Vehicle_GetDurabilityMileage(vehicleid));
	}

	return false;
}

Vehicle_GetOverusedMileage(vehicleid, &value)
{
	value = 0;

	if((Vehicle_ReturnID(vehicleid)) != RETURN_INVALID_VEHICLE_ID)
	{
		if (Vehicle_IsMileageOverused(vehicleid))
		{
			value  = Vehicle_GetCurrentMileage(vehicleid);
			value -= SAFE_MILEAGE;

			return 1;
		}
	}

	return 0;
}

/** Timer turn on engine
*
*/
timer TurnEngineOn[1500](playerid, vehicleid) 
{
	if(!PlayerData[playerid][pInjured] && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && vehicleid != INVALID_VEHICLE_ID)
	{

		new
			index = Vehicle_ReturnID(vehicleid),
			// bool:can_start_engine = true,
			overused_mileage
		;

		if(index == -1)
		{
			return SendErrorMessage(playerid, "Kendaraan tidak valid!");
		}

		Vehicle_GetOverusedMileage(vehicleid, overused_mileage);

		
        if(VehicleData[index][vehHandBrake])
        {
			Vehicle_StopHandbrake(index);
			SendServerMessage(playerid, "Vehicle Handbrake di non aktifkan");
        }

		// new rand = random(100);

		// if (overused_mileage >= 50)
		// {
		// 	can_start_engine = (rand % 10 == 0) ? true : false;
		// }
		// else if (overused_mileage >= 60)
		// {
		// 	can_start_engine = (rand == 1 || rand == 33 || rand == 54 || rand == 78 || rand == 83) ? true : false;
		// }

		// if (can_start_engine)
		// {
		// 	SetEngineStatus(vehicleid, true);
		// 	SetLightStatus(vehicleid, true);

		// 	VehicleData[index][vehEngineStatus] = 1;
		// 	ShowPlayerFooter(playerid, "Mesin kendaraan telah aktif.");
		// }
		// else
		// {
		// 	ShowPlayerFooter(playerid, "~r~Gagal ~w~mengaktifkan kendaraan.");
		// }
		SetEngineStatus(vehicleid, true);
		SetLightStatus(vehicleid, true);

		VehicleData[index][vehEngineStatus] = 1;
		ShowPlayerFooter(playerid, "Mesin kendaraan telah aktif.");

	}
	else
	{
		ShowPlayerFooter(playerid, "~r~ERROR: ~w~Gagal mengaktifkan kendaraan dikarenakan turun atau terluka.");
	}

	DeletePVar(playerid, "VehicleEngine");
	return 1;
}


/** Timer turn on engine
*
*/
Dialog:LockVehicle(playerid, response, listitem, inputtext[]) 
{
    if (response)
    {
    	new vehicleid = g_selected_vehicle[playerid][listitem];

    	if(Vehicle_IsExists(vehicleid))
    	{
    		new Float:x, Float:y, Float:z;

    		GetVehiclePos(VehicleData[vehicleid][vehVehicleID], x, y, z);

			if(GetPlayerDistanceFromPoint(playerid, x, y, z) < 5)
			{
	    		new vid = VehicleData[vehicleid][vehVehicleID];
				SetDoorStatus(vid, ((GetDoorStatus(vid)) ? false : true));
				VehicleData[vehicleid][vehDoorStatus] = (GetDoorStatus(vid) ? 1 : 0);
				GameTextForPlayer(playerid, sprintf("~w~VEHICLE %s", ((GetDoorStatus(vid)) ? ("~r~Locked") : ("~g~Unlocked"))), 3000, 6);
			}
			else SendErrorMessage(playerid, "Kendaraan terlalu jauh dari posisimu.");
	    }
    }
    return 1;
}

Dialog:PlayerCars(playerid, response, listitem, inputtext[]) 
{
    if (response)
    {
    	new vehicleid = g_selected_vehicle[playerid][listitem];

    	if(Vehicle_IsExists(vehicleid))
    	{
    		new Float:x, Float:y, Float:z,
    			vid = VehicleData[vehicleid][vehVehicleID];

    		GetVehiclePos(vid, x, y, z);
	        SetPlayerPos(playerid, x, y, (z + 3.0));
	        SendCustomMessage(playerid, "TELEPORT", "Sukses melakukan teleportasi pada kendaraan "CYAN"%s (%d)!", GetVehicleNameByVehicle(vid), vid);
	    }
    }
    return 1;
}

Dialog:TrackVehicle(playerid, response, listitem, inputtext[]) 
{
    if (response)
    {
    	new vehicleid = g_selected_vehicle[playerid][listitem];

    	if(Vehicle_IsExists(vehicleid))
    	{
    		new Float:x, Float:y, Float:z,
    			vid = VehicleData[vehicleid][vehVehicleID];

    		GetVehiclePos(vid, x, y, z);

	        SetPlayerWaypoint(playerid, sprintf("%s", GetVehicleNameByVehicle(vid)), x, y, z);
	        SendCustomMessage(playerid, "TRACKING", "Checkpoint menunjukkan posisi kendaraan "CYAN"%s "WHITE"mu!", GetVehicleNameByVehicle(vid));
	    }
    }
    return 1;
}

Dialog:BuyInsurance(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new vehicleid = g_selected_vehicle[playerid][listitem];

		if(Vehicle_IsExists(vehicleid))
		{
			if(GetMoney(playerid) < Vehicle_InsurancePrice(Model_GetCategory(VehicleData[vehicleid][cModel])))
				return SendErrorMessage(playerid, "Kamu butuh (%s) untuk menambah asuransi kendaraan.", FormatNumber(Vehicle_InsurancePrice(Model_GetCategory(VehicleData[vehicleid][cModel]))));

			if(VehicleData[vehicleid][vehInsurance] >= 3)
				return SendErrorMessage(playerid, "Kendaraan ini sudah mencapai batas maksimal asuransi.");

			VehicleData[vehicleid][vehInsurance] ++;
			GiveMoney(playerid, -Vehicle_InsurancePrice(Model_GetCategory(VehicleData[vehicleid][cModel])), ECONOMY_ADD_SUPPLY, "bought vehicle insurance");
			SendServerMessage(playerid, "Kamu menambahkan asuransi kendaraan "CYAN"%s "WHITE"menjadi "YELLOW"%d.", GetVehicleNameByModel(VehicleData[vehicleid][cModel]), VehicleData[vehicleid][vehInsurance]);
		}
		else SendErrorMessage(playerid, "Kendaraan tidak terdaftar!");
	}
	return 1;
}

Dialog:ClaimInsurance(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new
			index = random(sizeof(insurancePosition)),
			id = g_selected_vehicle[playerid][listitem],
			claim_time = g_selected_vehicle_time[playerid][listitem],
			claim_model = g_selected_vehicle_price[playerid][listitem];

		if(gettime() < claim_time)
			return SendErrorMessage(playerid, "Kendaraan ini belum bisa diambil!");

		mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `state` = '%d', `vehhandbrake` = '0', `health` = '2000.0', `damage1` = '0', `damage2` = '0', `damage3` = '0', `damage4` = '0', `insurancetime` = 0, `interior` = 0, `world` = 0 WHERE `id` = '%d' AND `engineup` = '1';", VEHICLE_STATE_SPAWNED, id));
		
		mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `state` = '%d', `vehhandbrake` = '0', `health` = '1000.0', `damage1` = '0', `damage2` = '0', `damage3` = '0', `damage4` = '0', `insurancetime` = 0, `interior` = 0, `world` = 0 WHERE `id` = '%d' AND `engineup` = '0';", VEHICLE_STATE_SPAWNED, id));


		if(Model_GetCategory(claim_model) == CATEGORY_BOAT) mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `posX`='725.09',`posY`='-1935.05',`posZ`='-0.1206',`posRZ`='179.0585' WHERE `id`='%d';", id));
		else mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `posX`='%.2f',`posY`='%.2f',`posZ`='%.2f',`posRZ`='%.2f' WHERE `id`='%d';", insurancePosition[index][0], insurancePosition[index][1], insurancePosition[index][2], insurancePosition[index][3], id));
		
		mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `id`='%d';", id), "VehicleLoaded", "d", playerid);

		SendServerMessage(playerid, "Kamu telah mengeluarkan "CYAN"%s "WHITE"dari "YELLOW"insurance center.", inputtext);
	}
	return 1;
}

Dialog:ForceInsurance(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new
			targetid = GetPVarInt(playerid, "ForceInsurancePlayer"),
			index = random(sizeof(insurancePosition)),
			id = g_selected_vehicle[playerid][listitem],
			claim_model = g_selected_vehicle_price[playerid][listitem];
		//Untuk yang upgrade
		mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `state` = '%d', `vehhandbrake` = '0', `health` = '2000.0', `damage1` = '0', `damage2` = '0', `damage3` = '0', `damage4` = '0', `insurancetime` = 0, `interior` = 0, `world` = 0 WHERE `id` = '%d' AND `engineup` = '1';", VEHICLE_STATE_SPAWNED, id));
		//Untuk yang tidak upgrade
		mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `state` = '%d', `vehhandbrake` = '0', `health` = '1000.0', `damage1` = '0', `damage2` = '0', `damage3` = '0', `damage4` = '0', `insurancetime` = 0, `interior` = 0, `world` = 0 WHERE `id` = '%d' AND `engineup` = '0';", VEHICLE_STATE_SPAWNED, id));

		if(Model_GetCategory(claim_model) == CATEGORY_BOAT) mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `posX`='725.09',`posY`='-1935.05',`posZ`='-0.1206',`posRZ`='179.0585' WHERE `id`='%d';", id));
		else mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `posX`='%.2f',`posY`='%.2f',`posZ`='%.2f',`posRZ`='%.2f' WHERE `id`='%d';", insurancePosition[index][0], insurancePosition[index][1], insurancePosition[index][2], insurancePosition[index][3], id));

		mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `id`='%d';", id), "VehicleLoaded", "d", targetid);

		SendServerMessage(playerid, "Kamu telah mengeluarkan "CYAN"%s "WHITE"dari "YELLOW"insurance center.", inputtext);
		SendServerMessage(targetid, "Admin "RED"%s "WHITE"telah mengeluarkan "CYAN"%s "WHITE"dari "YELLOW"insurance center.", ReturnAdminName(playerid), inputtext);

		DeletePVar(playerid, "ForceInsurancePlayer");
	}
	return 1;
}

Dialog:ForceVehicleSpawn(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new
			targetid = GetPVarInt(playerid, "ForceSpawnVehicle"),
			id = g_selected_vehicle[playerid][listitem]
		;

		mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET state=%d,`house_parking`='-1',insurancetime=0,interior=0,world=0 WHERE `id`='%d';", VEHICLE_STATE_SPAWNED, id));

		mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `id`='%d' LIMIT 1;", id), "VehicleLoaded", "d", targetid);

		SendServerMessage(playerid, "Kamu telah mengeluarkan "CYAN"%s "WHITE"dari "YELLOW"house parking.", inputtext);
		DeletePVar(playerid, "ForceSpawnVehicle");
	}
	return 1;
}



Dialog:ForceDeath(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new
			targetid = GetPVarInt(playerid, "ForceDeathPlayer"),
			index = random(sizeof(insurancePosition)),
			id = g_selected_vehicle[playerid][listitem],
			claim_model = g_selected_vehicle_price[playerid][listitem];

		mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET state=%d,`health`='1000.0',insurancetime=0,interior=0,world=0 WHERE `id`='%d';", VEHICLE_STATE_SPAWNED, id));

		if(Model_GetCategory(claim_model) == CATEGORY_BOAT) mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `posX`='725.09',`posY`='-1935.05',`posZ`='-0.1206',`posRZ`='179.0585' WHERE `id`='%d';", id));
		else mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET `posX`='%.2f',`posY`='%.2f',`posZ`='%.2f',`posRZ`='%.2f' WHERE `id`='%d';", insurancePosition[index][0], insurancePosition[index][1], insurancePosition[index][2], insurancePosition[index][3], id));

		mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `id`='%d' LIMIT 1;", id), "VehicleLoaded", "d", targetid);

		SendServerMessage(playerid, "Kamu telah mengeluarkan "CYAN"%s "WHITE"dari "YELLOW"death list.", inputtext);
		DeletePVar(playerid, "ForceDeathPlayer");
	}
	return 1;
}

Dialog:VehicleDeath(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new Cache:execute, output[600], name[MAX_PLAYER_NAME], issued[MAX_PLAYER_NAME];
		SetPVarInt(playerid, "VehicleDeleteList", GetPVarInt(playerid, "VehicleDeleteList") + 1);

		execute = mysql_query(g_iHandle, sprintf("SELECT * FROM `cardestroy` ORDER BY `destroyTime` DESC LIMIT %d, 10", GetPVarInt(playerid, "VehicleDeleteList") * 10));

		if(cache_num_rows())
		{
			strcat(output, sprintf("Model\tOwner\tDestroyer\tDate record\n"));
			for(new i = 0; i != cache_num_rows(); i++)
			{
	        	cache_get_field_content(i, "destroyOwner", name, MAX_PLAYER_NAME);
	        	cache_get_field_content(i, "destroyBy", issued, MAX_PLAYER_NAME);

				strcat(output, sprintf("%s\t%s\t%s\t%s\n", GetVehicleNameByModel(cache_get_field_int(i, "destroyModel")), name, issued, ConvertTimestamp(Timestamp:cache_get_field_int(i, "destroyTime"))));
			}
			Dialog_Show(playerid, VehicleDeath, DIALOG_STYLE_TABLIST_HEADERS, "Vehicle Death List", output, "Next", "Close");
		}
		else SendErrorMessage(playerid, "Tidak ada data yang dimuat");

		cache_delete(execute);
	}
	else DeletePVar(playerid, "VehicleDeleteList");
	return 1;
}

Dialog:RefuelVehicle(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        new vehicle_index,
        	pump_index = PlayerData[playerid][pGasPump],
        	biz_index = PumpData[pump_index][pumpBusiness],
        	payment = (strval(inputtext) * BusinessData[biz_index][bizPrices][5]);

        if(!(0 < strval(inputtext) <= 125))
        	return Dialog_Show(playerid, RefuelVehicle, DIALOG_STYLE_INPUT, "Refuel Vehicle", ""WHITE"(error): inputan dibatasi hanya 0 sampai 125!\n\nToko ini menjual "GREEN"%s"YELLOW"/liter "WHITE"nya\n\nBerapa persen literan yang mau kamu beli?", "Beli", "Gagalkan", FormatNumber(BusinessData[biz_index][bizPrices][5]));

        if(PumpData[pump_index][pumpFuel] < strval(inputtext))
        	return Dialog_Show(playerid, RefuelVehicle, DIALOG_STYLE_INPUT, "Refuel Vehicle", ""WHITE"(error): kapasitas pompa bahan bakar tidak mencukupi, hanya tersisa "YELLOW"%d!\n\n"WHITE"Toko ini menjual "GREEN"%s"YELLOW"/liter "WHITE"nya\n\nBerapa persen literan yang mau kamu beli?", "Beli", "Gagalkan", PumpData[pump_index][pumpFuel], FormatNumber(BusinessData[biz_index][bizPrices][5]));

    	if(GetMoney(playerid) < payment)
    		return Dialog_Show(playerid, RefuelVehicle, DIALOG_STYLE_INPUT, "Refuel Vehicle", ""WHITE"(error): uang tidak cukup mengisi sebanyak itu "GREEN"(%s)!\n\n"WHITE"Toko ini menjual "GREEN"%s"YELLOW"/liter "WHITE"nya\n\nBerapa persen literan yang mau kamu beli?", "Beli", "Gagalkan", FormatNumber(payment), FormatNumber(BusinessData[biz_index][bizPrices][5]));

		if((vehicle_index = Vehicle_ReturnID(GetPlayerVehicleID(playerid))) != RETURN_INVALID_VEHICLE_ID)
		{
			if(VehicleData[vehicle_index][vehGasUpgrade] != 2 && (VehicleData[vehicle_index][vehFuel] + strval(inputtext)) > 100)
	        	return Dialog_Show(playerid, RefuelVehicle, DIALOG_STYLE_INPUT, "Refuel Vehicle", ""WHITE"(error): jumlah yang kamu masukkan terlalu banyak, masukkan "YELLOW"(%.0f)"WHITE"!\n\nToko ini menjual "GREEN"%s"YELLOW"/liter "WHITE"nya\n\nBerapa persen literan yang mau kamu beli?", "Beli", "Gagalkan", (100 - VehicleData[vehicle_index][vehFuel]), FormatNumber(BusinessData[biz_index][bizPrices][5]));
			
			if(VehicleData[vehicle_index][vehGasUpgrade] == 2 && (VehicleData[vehicle_index][vehFuel] + strval(inputtext)) > 125)
	        	return Dialog_Show(playerid, RefuelVehicle, DIALOG_STYLE_INPUT, "Refuel Vehicle", ""WHITE"(error): jumlah yang kamu masukkan terlalu banyak, masukkan "YELLOW"(%.0f)"WHITE"!\n\nToko ini menjual "GREEN"%s"YELLOW"/liter "WHITE"nya\n\nBerapa persen literan yang mau kamu beli?", "Beli", "Gagalkan", (125 - VehicleData[vehicle_index][vehFuel]), FormatNumber(BusinessData[biz_index][bizPrices][5]));


	        VehicleData[vehicle_index][vehFuel] += float(strval(inputtext));
	        PumpData[pump_index][pumpFuel] -= strval(inputtext);
	        BusinessData[biz_index][bizVault] += payment;

	        if(VehicleData[vehicle_index][vehGasUpgrade] != 2 && VehicleData[vehicle_index][vehFuel] > 100)
	        {
				VehicleData[vehicle_index][vehFuel] = 100;
			}
			else if(VehicleData[vehicle_index][vehGasUpgrade] == 2 && VehicleData[vehicle_index][vehFuel] > 125)
			{
				VehicleData[vehicle_index][vehFuel] = 125;
			}
		
	        Pump_Sync(pump_index);
	        Pump_Save(pump_index, false);
	        GiveMoney(playerid, -payment, ECONOMY_ADD_SUPPLY, "bought vehicle gas");
	        SendServerMessage(playerid, "Sukses mengisi bahan bakar sebanyak "YELLOW"%d liter "WHITE" dengan bayaran "GREEN"%s.", strval(inputtext), FormatNumber(payment));
		}
    }
    return 1;
}

Dialog:ClaimImpound(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new
			id = g_selected_vehicle[playerid][listitem],
			claim_time = g_selected_vehicle_time[playerid][listitem],
			claim_price = g_selected_vehicle_price[playerid][listitem];

		if(gettime() < claim_time)
			return SendErrorMessage(playerid, "Kendaraan ini belum waktunya dilepas (%s)!", ConvertTimestamp(Timestamp:claim_time));

		if(GetMoney(playerid) < claim_price)
			return SendErrorMessage(playerid, "Uang tidak cukup, kamu butuh %s!", FormatNumber(claim_price));

		mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET state=%d,impoundtime=0,impoundprice=0,interior=0,world=0 WHERE `id`='%d';", VEHICLE_STATE_SPAWNED, id));
		mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `id`='%d';", id), "VehicleLoaded", "d", playerid);

		SendServerMessage(playerid, "Kamu telah mengeluarkan "CYAN"%s "WHITE"dari "YELLOW"impound center.", inputtext);
	}
	return 1;
}

Dialog:ForceRelease(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new
			targetid = GetPVarInt(playerid, "ForceRelease"),
			id = g_selected_vehicle[playerid][listitem];

		mysql_tquery(g_iHandle, sprintf("UPDATE server_vehicles SET state=%d,impoundtime=0,impoundprice=0,interior=0,world=0 WHERE `id`='%d';", VEHICLE_STATE_SPAWNED, id));
		mysql_tquery(g_iHandle, sprintf("SELECT * FROM `server_vehicles` WHERE `id`='%d';", id), "VehicleLoaded", "d", targetid);

		SendServerMessage(playerid, "Kamu telah mengeluarkan "CYAN"%s "WHITE"dari "YELLOW"impound center.", inputtext);
		SendServerMessage(targetid, "Admin "RED"%s "WHITE"telah mengeluarkan "CYAN"%s "WHITE"dari "YELLOW"impound center.", ReturnAdminName(playerid), inputtext);

		DeletePVar(playerid, "ForceRelease");
	}
	return 1;
}


// Trunk options
Dialog:VehicleTrunk(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new vehicleid = GetPVarInt(playerid, "CarStorageIndex"),
			nearest_vehicle = GetPVarInt(playerid, "CarStorage");

		if(!Vehicle_IsOwned(playerid, vehicleid) && GetAdminLevel(playerid) < 8) {
			SetTrunkStatus(nearest_vehicle, false);
	    	return SendServerMessage(playerid, "Hanya dapat melihat isi bagasi, tidak dapat mengoperasikan isi didalamnya!");
		}

		if(listitem >= MAX_VEHICLE_STORAGE)
			return SendErrorMessage(playerid, "Invalid list-item");

		SetPVarInt(playerid, "VehicleTrunkList", listitem);

		switch(_:VehicleData[vehicleid][vehTrunkType][listitem])
		{
			case e_TRUNK_WEAPON:
			{
				if(IsPlayerDuty(playerid)) 
					return SendErrorMessage(playerid, "Off duty untuk mengambil senjata!.");

				if(PlayerHasWeaponInSlot(playerid, VehicleData[vehicleid][vehWeapon][listitem]))
					return SendErrorMessage(playerid, "Kamu telah memiliki senjata pada slot yang sama!."), SetTrunkStatus(nearest_vehicle, false);

				if(Vehicle_Nearest(playerid) != nearest_vehicle)
					return SendErrorMessage(playerid, "Terlalu jauh dari posisi kendaraan yang kamu operasikan, gagal meletakkan senjata!"), SetTrunkStatus(nearest_vehicle, false);

				if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
					return SendErrorMessage(playerid, "Kamu tidak bisa mengambil senjata saat di dalam mobil");

				mysql_tquery(g_iHandle, sprintf("DELETE FROM `weapon_vehicles` WHERE `vehicleid` = '%d' AND `ammo`='%d' AND `weaponid`='%d' AND `durability`='%d' LIMIT 1;", VehicleData[vehicleid][vehIndex], VehicleData[vehicleid][vehAmmo][listitem], VehicleData[vehicleid][vehWeapon][listitem], VehicleData[vehicleid][vehDurability][listitem]));

				new serial[128];
				valstr(serial, VehicleData[vehicleid][vehSerial][listitem]);

				GivePlayerWeaponEx(playerid, VehicleData[vehicleid][vehWeapon][listitem], VehicleData[vehicleid][vehAmmo][listitem], VehicleData[vehicleid][vehDurability][listitem], serial);
				
				SetTrunkStatus(nearest_vehicle, false);
				SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s takes a %s from the trunk.", ReturnName(playerid, 0, 1), ReturnWeaponName(VehicleData[vehicleid][vehWeapon][listitem]));
				Log_Save(E_LOG_VEHICLE_STORAGE, sprintf("[%s] %s takes a \"%s\" from the trunk vehicle %s (dbid: %d).", ReturnDate(), ReturnName(playerid, 0), ReturnWeaponName(VehicleData[vehicleid][vehWeapon][listitem]), GetVehicleNameByVehicle(nearest_vehicle), VehicleData[vehicleid][vehIndex]));

				VehicleData[vehicleid][vehTrunkType][listitem] = e_TRUNK_NOTHING;
				VehicleData[vehicleid][vehWeapon][listitem] = VehicleData[vehicleid][vehAmmo][listitem] = VehicleData[vehicleid][vehDurability][listitem] = VehicleData[vehicleid][vehSerial][listitem] = 0;
			}
			case e_TRUNK_INVENTORY:
			{
				if(!VehicleStorageData[vehicleid][listitem][vehInvModel])
					return SendErrorMessage(playerid, "Tidak ada item dilist ini!");

				if(Vehicle_Nearest(playerid) != nearest_vehicle)
					return SendErrorMessage(playerid, "Terlalu jauh dari posisi kendaraan yang kamu operasikan, gagal meletakkan item!"), SetTrunkStatus(nearest_vehicle, false);

				if(Inventory_Add(playerid, VehicleStorageData[vehicleid][listitem][vehInvName], VehicleStorageData[vehicleid][listitem][vehInvModel], VehicleStorageData[vehicleid][listitem][vehInvQuantity]) == -1)
					return 1;

				mysql_tquery(g_iHandle, sprintf("DELETE FROM `carstorage` WHERE `itemID`='%d';", VehicleStorageData[vehicleid][listitem][vehInvIndex]));

                SetTrunkStatus(nearest_vehicle, false);

				SendServerMessage(playerid, "Sukses mengambil "YELLOW"%s "GREEN"(%d) "WHITE"dari dalam bagasi!", VehicleStorageData[vehicleid][listitem][vehInvName], VehicleStorageData[vehicleid][listitem][vehInvQuantity]);
            	Log_Save(E_LOG_VEHICLE_STORAGE, sprintf("[%s] %s takes a \"%s\" (%d) from the trunk vehicle %s (dbid: %d).", ReturnDate(), ReturnName(playerid, 0), VehicleStorageData[vehicleid][listitem][vehInvName], VehicleStorageData[vehicleid][listitem][vehInvQuantity], GetVehicleNameByVehicle(nearest_vehicle), VehicleData[vehicleid][vehIndex]));

                VehicleData[vehicleid][vehTrunkType][listitem] = e_TRUNK_NOTHING;
				VehicleStorageData[vehicleid][listitem][vehInvName][0] = EOS;
				VehicleStorageData[vehicleid][listitem][vehInvIndex] = VehicleStorageData[vehicleid][listitem][vehInvModel] = VehicleStorageData[vehicleid][listitem][vehInvQuantity] = 0;
			}
			default: Dialog_Show(playerid, VehicleTrunkOption, DIALOG_STYLE_LIST, "Your item(s)", "Store Weapon\nStore Drugs\nStore Seeds\nStore Foods\nStore Items", "Select", "<<");
		}
	}
	else SetTrunkStatus(GetPVarInt(playerid, "CarStorage"), false);
	return 1;
}

Dialog:VehicleTrunkOption(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new 
			slot = GetPVarInt(playerid, "VehicleTrunkList"),
			index = GetPVarInt(playerid, "CarStorageIndex"),
			nearest_vehicle = GetPVarInt(playerid, "CarStorage");

		switch(listitem)
		{
			case 0:
			{
                static weaponid = 0;

				if(IsPlayerDuty(playerid)) 
		            return SendErrorMessage(playerid, "Off duty untuk meletakkan senjata!."), SetTrunkStatus(nearest_vehicle, false);

                if((weaponid = GetWeapon(playerid)) == 0) 
                    return SendErrorMessage(playerid, "Kamu tidak memegang senjata."), SetTrunkStatus(nearest_vehicle, false);
               
                if(PlayerHasTazer(playerid)) 
                    return SendErrorMessage(playerid, "Tazer tidak diperbolehkan disimpan."), SetTrunkStatus(nearest_vehicle, false);

                if(Vehicle_Nearest(playerid) != nearest_vehicle)
					return SendErrorMessage(playerid, "Terlalu jauh dari posisi kendaraan yang kamu operasikan, gagal meletakkan senjata!"), SetTrunkStatus(nearest_vehicle, false);
                
                VehicleData[index][vehTrunkType][slot] 		= e_TRUNK_WEAPON;
                VehicleData[index][vehWeapon][slot]      	= weaponid;
                VehicleData[index][vehAmmo][slot]         	= ReturnWeaponAmmo(playerid, weaponid);
                VehicleData[index][vehDurability][slot]   	= ReturnWeaponDurability(playerid, weaponid);
				VehicleData[index][vehSerial][slot]			= ReturnWeaponSerial(playerid, weaponid);

                mysql_tquery(g_iHandle, sprintf("INSERT INTO `weapon_vehicles`(`vehicleid`, `weaponid`, `ammo`, `durability`, `serial`) VALUES ('%d','%d','%d','%d', '%d');", VehicleData[index][vehIndex], VehicleData[index][vehWeapon][slot], VehicleData[index][vehAmmo][slot], VehicleData[index][vehDurability][slot], VehicleData[index][vehSerial][slot]));

                SetTrunkStatus(nearest_vehicle, false);
                ResetWeaponID(playerid, VehicleData[index][vehWeapon][slot]);
                SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s stored a %s into the trunk.", ReturnName(playerid, 0, 1), ReturnWeaponName(VehicleData[index][vehWeapon][slot]));

            	Log_Save(E_LOG_VEHICLE_STORAGE, sprintf("[%s] %s stored a \"%s\" into the trunk vehicle %s (dbid: %d).", ReturnDate(), ReturnName(playerid, 0), ReturnWeaponName(VehicleData[index][vehWeapon][slot]), GetVehicleNameByVehicle(nearest_vehicle), VehicleData[index][vehIndex]));
			}
			case 1: Dialog_Show(playerid, VehicleTrunkDrugs, DIALOG_STYLE_LIST, "Select Drugs", "Marijuana\nCocaine\nHeroin\nSteroids\nLSD\nEcstasy", "Store", "<<");
			case 2: Dialog_Show(playerid, VehicleTrunkSeeds, DIALOG_STYLE_LIST, "Select Seeds", "Marijuana Seeds\nCocaine Seeds\nHeroin Opium Seeds", "Store", "<<");
			case 3: Dialog_Show(playerid, VehicleTrunkFoods, DIALOG_STYLE_LIST, "Select Foods", "Snack\nCooked Burger\nCooked Pizza\nFrozen Burger\nFrozen Pizza\nWater", "Store", "<<");
			case 4: Dialog_Show(playerid, VehicleTrunkItems, DIALOG_STYLE_LIST, "Select Items", "Materials\nComponent", "Store", "<<");

		}
	}
	else cmd_vehicle(playerid, "trunk");

	return 1;
}

Dialog:VehicleTrunkDrugs(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new 
			slot = GetPVarInt(playerid, "VehicleTrunkList"),
			index = GetPVarInt(playerid, "CarStorageIndex");

		switch(listitem)
		{
			case 0: Vehicle_AddItem(playerid, index, slot, "Marijuana", 1578);
			case 1: Vehicle_AddItem(playerid, index, slot, "Cocaine", 1575);
			case 2: Vehicle_AddItem(playerid, index, slot, "Heroin", 1577);
			case 3: Vehicle_AddItem(playerid, index, slot, "Steroids", 1241);
			case 4: Vehicle_AddItem(playerid, index, slot, "LSD", 1578);
			case 5: Vehicle_AddItem(playerid, index, slot, "Ecstasy", 1575);
		}
	}
	return 1;
}

Dialog:VehicleTrunkSeeds(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new 
			slot = GetPVarInt(playerid, "VehicleTrunkList"),
			index = GetPVarInt(playerid, "CarStorageIndex");

		switch(listitem)
		{
			case 0: Vehicle_AddItem(playerid, index, slot, "Marijuana Seeds", 1578);
			case 1: Vehicle_AddItem(playerid, index, slot, "Cocaine Seeds", 1575);
			case 2: Vehicle_AddItem(playerid, index, slot, "Heroin Opium Seeds", 1577);
		}
	}
	return 1;
}
Dialog:VehicleTrunkItems(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new 
			slot = GetPVarInt(playerid, "VehicleTrunkList"),
			index = GetPVarInt(playerid, "CarStorageIndex");

		switch(listitem)
		{
			case 0: Vehicle_AddItem(playerid, index, slot, "Materials", 11746);
			case 1: Vehicle_AddItem(playerid, index, slot, "Component", 18633);
		}
	}
	return 1;
}
Dialog:VehicleTrunkFoods(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new 
			slot = GetPVarInt(playerid, "VehicleTrunkList"),
			index = GetPVarInt(playerid, "CarStorageIndex");

		switch(listitem)
		{
			case 0: Vehicle_AddItem(playerid, index, slot, "Snack", 2768);
			case 1: Vehicle_AddItem(playerid, index, slot, "Cooked Burger", 2703);
			case 2: Vehicle_AddItem(playerid, index, slot, "Cooked Pizza", 2702);
			case 3: Vehicle_AddItem(playerid, index, slot, "Frozen Burger", 2768);
			case 4: Vehicle_AddItem(playerid, index, slot, "Frozen Pizza", 2814);
			case 5: Vehicle_AddItem(playerid, index, slot, "Water", 1484);
		}
	}
	return 1;
}


//Vehicle Operation
Dialog:VehicleOperation(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0: cmd_v(playerid, "engine");
			case 1: cmd_v(playerid, "lock");
			case 2: cmd_v(playerid, "lights");
			case 3: cmd_v(playerid, "hood");
			case 4: cmd_v(playerid, "trunk");
			case 5: cmd_v(playerid, "speedometer");
			case 6: cmd_togneon(playerid, "");
		}
	}
	return 1;
}
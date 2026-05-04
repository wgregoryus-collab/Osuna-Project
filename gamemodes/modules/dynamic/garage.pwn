#define MAX_GARAGE	2000
#define GARAGE_INTERIOR	4

#include <YSI\y_hooks>

/*Variable List*/
new const Float:garageInterior[][4] = {
	{1990.0426,-2640.0649,13.1878,358.4085}
};

/*Enums List*/
enum garageData
{
	garageOwner[MAX_PLAYER_NAME],
	Float:garageLoc[4],
	Float:garageLocInt[4],

	garageID,
	garageOwnerId,
	garagePrice,
	garagePublic,
	garageType,
	garageLock,
	garageHouseLink,

	bool:garageExists,
	Text3D:garageLabel,
	garageInside,
	garagePickup,
	garageLastVisited
};
new GarageData[MAX_GARAGE][garageData];

/*Function:List*/

Function:Garage_Load()
{
	if(!cache_num_rows()) return printf("[Dynamic Garage] There are no one garage loaded to the server.");

	for(new id = 0; id != cache_num_rows(); id++) if (id < MAX_GARAGE && !GarageData[id][garageExists])
	{
		new part[64];

		GarageData[id][garageExists] = true;

		cache_get_value(id, "Owner", GarageData[id][garageOwner], MAX_PLAYER_NAME);

		cache_get_value(id, "Location", part, sizeof(part));
		sscanf(part, "p<|>ffff", GarageData[id][garageLoc][0], GarageData[id][garageLoc][1], GarageData[id][garageLoc][2], GarageData[id][garageLoc][3]);

		cache_get_value(id, "LocationInt", part, sizeof(part));
		sscanf(part, "p<|>ffff", GarageData[id][garageLocInt][0], GarageData[id][garageLocInt][1], GarageData[id][garageLocInt][2], GarageData[id][garageLocInt][3]);

		cache_get_value_int(id, "ID", GarageData[id][garageID]);
		cache_get_value_int(id, "OwnerID", GarageData[id][garageOwnerId]);
		cache_get_value_int(id, "Price", GarageData[id][garagePrice]);
		cache_get_value_int(id, "Type", GarageData[id][garageType]);
		cache_get_value_int(id, "Public", GarageData[id][garagePublic]);
		cache_get_value_int(id, "Lock", GarageData[id][garageLock]);
		cache_get_value_int(id, "Inside", GarageData[id][garageInside]);
		cache_get_value_int(id, "HouseLink", GarageData[id][garageHouseLink]);
		cache_get_value_int(id, "LastVisited", GarageData[id][garageLastVisited]);

		Garage_Sync(id);
	}
	return 1;
}

stock Garage_Save(id)
{
	new query[512];

	format(query, sizeof(query), "UPDATE `garage` SET `Owner`='%s', `Location`='%.02f|%.02f|%.02f|%.02f', `OwnerID`='%d', `Inside`='%d', `HouseLink`='%d', `LastVisited` = '%d'",
		GarageData[id][garageOwner],
		GarageData[id][garageLoc][0],
		GarageData[id][garageLoc][1],
		GarageData[id][garageLoc][2],
		GarageData[id][garageLoc][3],
		GarageData[id][garageOwnerId],
		GarageData[id][garageInside],
		GarageData[id][garageHouseLink],
		GarageData[id][garageLastVisited]
	);
	format(query, sizeof(query), "%s, `Price`='%d', `Type`='%d', `Public`='%d', `Lock`='%d', `LocationInt`='%.02f|%.02f|%.02f|%.02f' WHERE `ID` = '%d'",
		query,
		GarageData[id][garagePrice],
		GarageData[id][garageType],
		GarageData[id][garagePublic],
		GarageData[id][garageLock],
		GarageData[id][garageLocInt][0],
		GarageData[id][garageLocInt][1],
		GarageData[id][garageLocInt][2],
		GarageData[id][garageLocInt][3],
		GarageData[id][garageID]
	);
	return mysql_tquery(g_iHandle, query);
}

stock SwitchVehicleInGarage(playerid, listitem, newvehicleid) {
	new takevehicle = ListedVehicles[playerid][listitem];

	if (ApartGarage_Nearest(playerid) != -1) {
		VehicleData[takevehicle][cGarageApart] = 0;
		VehicleData[newvehicleid][cGarageApart] = ApartData[ApartGarage_Nearest(playerid)][aID];
	}
	
	if (Garage_Nearest(playerid) != -1) {
		VehicleData[takevehicle][cGarage] = 0;
		VehicleData[newvehicleid][cGarage] = GarageData[Garage_Nearest(playerid)][garageID];
	}

	if (Flat_NearestGarage(playerid) != -1) {
		VehicleData[takevehicle][cGarageFlat] = 0;
		VehicleData[newvehicleid][cGarageFlat] = FlatData[Flat_NearestGarage(playerid)][flatID];
	}
				
	GetVehiclePos(VehicleData[newvehicleid][cVehicle], VehicleData[newvehicleid][cPos][0], VehicleData[newvehicleid][cPos][1], VehicleData[newvehicleid][cPos][2]);
	if (VehicleData[newvehicleid][cNeon]) VehicleData[newvehicleid][cNeonToggle] = 0;
	ReloadVehicleNeon(newvehicleid);

	for (new slot = 0; slot < MAX_VEHICLE_OBJECT+5; slot ++) if (VehicleObjects[newvehicleid][slot][object_exists]) {
		if(IsValidDynamicObject(VehicleObjects[newvehicleid][slot][object_streamer]))
			DestroyDynamicObject(VehicleObjects[newvehicleid][slot][object_streamer]);

		VehicleObjects[newvehicleid][slot][object_streamer] = INVALID_STREAMER_ID;
	}

	Vehicle_Save(newvehicleid);

	if (IsValidVehicle(VehicleData[newvehicleid][cVehicle]))
		DestroyVehicle(VehicleData[newvehicleid][cVehicle]);

	VehicleData[newvehicleid][cVehicle] = INVALID_VEHICLE_ID;

	Vehicle_Spawn(takevehicle);

	SetVehiclePos(VehicleData[takevehicle][cVehicle], VehicleData[takevehicle][cPos][0], VehicleData[takevehicle][cPos][1], VehicleData[takevehicle][cPos][2]);
	LinkVehicleToInterior(VehicleData[takevehicle][cVehicle], 0);
	SetVehicleVirtualWorld(VehicleData[takevehicle][cVehicle], 0);
	CoreVehicles[VehicleData[takevehicle][cVehicle]][vehFuel] = VehicleData[takevehicle][cFuel];

	PutPlayerInVehicleEx(playerid, VehicleData[takevehicle][cVehicle], 0);
	Vehicle_Save(takevehicle);
	return 1;
}

stock TakeVehicleFromGarage(playerid, listitem) {
	new vehicleid = ListedVehicles[playerid][listitem];

	if (ApartGarage_Nearest(playerid) != -1) {
		VehicleData[vehicleid][cGarageApart] = 0;
	}
	
	if (Garage_Nearest(playerid) != -1) {
		VehicleData[vehicleid][cGarage] = 0;
	}

	if (Flat_NearestGarage(playerid) != -1) {
		VehicleData[vehicleid][cGarageFlat] = 0;
	}

	Vehicle_Spawn(vehicleid);

	SetVehiclePos(VehicleData[vehicleid][cVehicle], VehicleData[vehicleid][cPos][0], VehicleData[vehicleid][cPos][1], VehicleData[vehicleid][cPos][2]);
	LinkVehicleToInterior(VehicleData[vehicleid][cVehicle], 0);
	SetVehicleVirtualWorld(VehicleData[vehicleid][cVehicle], 0);
	CoreVehicles[VehicleData[vehicleid][cVehicle]][vehFuel] = VehicleData[vehicleid][cFuel];

	PutPlayerInVehicleEx(playerid, VehicleData[vehicleid][cVehicle], 0);
	Vehicle_Save(vehicleid);
	return 1;
}

stock Garage_Sync(id)
{
	if (GarageData[id][garageExists]) 
	{
		new str[200];

		if(IsValidDynamicPickup(GarageData[id][garagePickup]))
			DestroyDynamicPickup(GarageData[id][garagePickup]);

		if(IsValidDynamic3DTextLabel(GarageData[id][garageLabel]))
			DestroyDynamic3DTextLabel(GarageData[id][garageLabel]);
			
        if(GarageData[id][garagePublic]) {
			format(str, sizeof(str), ""CYAN"[PARK ID:%d]\n"WHITE"Location: "YELLOW"%s\n"WHITE"Type '"YELLOW"/parkveh"WHITE"' to park veh\n"WHITE"Type '"YELLOW"/pickupveh"WHITE"' to pickup veh", id, GetLocation(GarageData[id][garageLoc][0], GarageData[id][garageLoc][1], GarageData[id][garageLoc][2]));
		}
		else {
			if(GarageData[id][garageOwnerId]) {
				format(str, sizeof(str), "[Garage:%d]\n"WHITE"Owner: "YELLOW"%s\n"WHITE"Vehicle Inside: "YELLOW"%d"WHITE"/"YELLOW"%d\n"WHITE"Type '"YELLOW"/garage"WHITE"' to use access this garage", id, GarageData[id][garageOwner], GarageData[id][garageInside], GarageData[id][garageType]);
			}
			else {
				format(str, sizeof(str), "[Garage:%d]\n"WHITE"Price: "GREEN"%s\n"WHITE"Vehicle Limit: "YELLOW"%d\n"WHITE"Type '"YELLOW"/garage buy"WHITE"' to buy this garage", id, FormatNumber(GarageData[id][garagePrice]), GarageData[id][garageType]);
			}
		}
		if (!GarageData[id][garageHouseLink]) {
			GarageData[id][garageLabel] = CreateDynamic3DTextLabel(str, COLOR_CLIENT, GarageData[id][garageLoc][0], GarageData[id][garageLoc][1], GarageData[id][garageLoc][2]+0.5, 7);
			if(!GarageData[id][garagePublic]) GarageData[id][garagePickup] = CreateDynamicPickup(1239, 23, GarageData[id][garageLoc][0], GarageData[id][garageLoc][1], GarageData[id][garageLoc][2], -1, -1, -1, 10);
			else if(GarageData[id][garagePublic]) GarageData[id][garagePickup] = CreateDynamicPickup(19134, 23, GarageData[id][garageLoc][0], GarageData[id][garageLoc][1], GarageData[id][garageLoc][2], -1, -1, -1, 10);
		}

		Garage_Save(id);
	}
	return 1;
}

stock Garage_FreeID()
{
	for(new id = 0; id != MAX_GARAGE; id++) if(!GarageData[id][garageExists]) {
		return id;
	}
	return -1;
}

stock Garage_Nearest(playerid)
{
	for(new id = 0; id != MAX_GARAGE; id++) if(GarageData[id][garageExists] && IsPlayerInRangeOfPoint(playerid, 4.0, GarageData[id][garageLoc][0], GarageData[id][garageLoc][1], GarageData[id][garageLoc][2])) {
		return id;
	}
	return -1;
}

stock Garage_Inside(playerid)
{
    if(PlayerData[playerid][pGarage] != -1)
    {
        for (new i = 0; i != MAX_GARAGE; i ++) if(GarageData[i][garageExists] && GarageData[i][garageID] == PlayerData[playerid][pGarage]) {
            return i;
        }
    }
    return -1;
}

stock Garage_IsOwner(playerid, id)
{
    if(!PlayerData[playerid][pLogged] || PlayerData[playerid][pID] == -1)
        return 0;

    if((GarageData[id][garageExists] && GarageData[id][garageOwnerId] != 0) && GarageData[id][garageOwnerId] == PlayerData[playerid][pID])
        return 1;

    return 0;
}

stock Garage_SQLID(id)
{
    for (new i = 0; i != MAX_GARAGE; i ++) if(GarageData[i][garageExists] && GarageData[i][garageID] == id) {
        return i;
    }

    return 0;
}


stock Garage_GetCount(playerid)
{
    new count = 0;
    for (new i = 0; i != MAX_GARAGE; i ++) if(GarageData[i][garageExists] && !GarageData[i][garageHouseLink] && Garage_IsOwner(playerid, i)) {
        count++;
    }
    return count;
}

stock Garage_GetType(id) {
	new type[24];
	switch (GarageData[id][garageType]) {
		case 0: format(type,sizeof(type),"Not available");
		case 1: format(type,sizeof(type),"Low");
		case 2: format(type,sizeof(type),"Medium");
		case 3: format(type,sizeof(type),"High");
		case 4: format(type,sizeof(type),"Super High");
		case 5: format(type,sizeof(type),"Big High");
	}
	return type;
}

stock Garage_Destroy(id)
{
	mysql_tquery(g_iHandle, sprintf("DELETE FROM `garage` WHERE `ID`='%d'", GarageData[id][garageID]));
	mysql_tquery(g_iHandle, sprintf("DELETE FROM `player_vehicles` WHERE Garage='%d'", GarageData[id][garageID]));

	// for(new i = 0; i != MAX_DYNAMIC_CARS; i++) if(VehicleData[i][cExists] && VehicleData[i][cOwner] != 0 && VehicleData[i][cGarage] == GarageData[id][garageID])
	// {
	// 	VehicleData[i][cGarage] =  VehicleData[i][cVw] = 0;
	// 	VehicleData[i][cPos][0] = GarageData[id][garageLoc][0];
    //     VehicleData[i][cPos][1] = GarageData[id][garageLoc][1];
    //     VehicleData[i][cPos][2] = GarageData[id][garageLoc][2];
    //     VehicleData[i][cPos][3] = GarageData[id][garageLoc][3];

    //     Vehicle_Spawn(i);
	// }

	Garage_Reset(id);
	return 1;
}

stock Garage_Reset(id)
{
	if(!GarageData[id][garageExists])
		return 0;

	if(IsValidDynamicPickup(GarageData[id][garagePickup]))
		DestroyDynamicPickup(GarageData[id][garagePickup]);

	if(IsValidDynamic3DTextLabel(GarageData[id][garageLabel]))
		DestroyDynamic3DTextLabel(GarageData[id][garageLabel]);

	GarageData[id][garageOwner] = EOS;

	GarageData[id][garageExists] = false;
	GarageData[id][garageID] = 0;
	GarageData[id][garageType] = 0;
	GarageData[id][garagePublic] = 0;
	GarageData[id][garagePrice] = 0;
	GarageData[id][garageInside] = 0;
	GarageData[id][garageOwnerId] = 0;
	GarageData[id][garageLock] = 1;
	GarageData[id][garageHouseLink] = 0;

	return 1;
}

stock Garage_Create(playerid, price, type, status)
{
	static
		id = -1;

	if((id = Garage_FreeID()) != -1) 
	{
		GetPlayerPos(playerid, GarageData[id][garageLoc][0], GarageData[id][garageLoc][1], GarageData[id][garageLoc][2]);
		GetPlayerFacingAngle(playerid, GarageData[id][garageLoc][3]);

		GarageData[id][garageLocInt][0] = garageInterior[0][0];
		GarageData[id][garageLocInt][1] = garageInterior[0][1];
		GarageData[id][garageLocInt][2] = garageInterior[0][2];
		GarageData[id][garageLocInt][3] = garageInterior[0][3];

		GarageData[id][garageExists] = true;
		GarageData[id][garageType] = type;
		GarageData[id][garagePublic] = status;
		GarageData[id][garagePrice] = price;
		GarageData[id][garageInside] = 0;
		GarageData[id][garageOwnerId] = 0;
		GarageData[id][garageOwner] = EOS;
		GarageData[id][garageLock] = 1;
		GarageData[id][garageHouseLink] = 0;

		mysql_tquery(g_iHandle, sprintf("INSERT INTO `garage` (`Price`) VALUES (%d)", GarageData[id][garagePrice]), "Garage_Created", "d", id);

		return id;
	} 
	return 1;
}

/*Function:other List*/
Function:Garage_Created(id)
{
	GarageData[id][garageID] = cache_insert_id();

	Garage_Sync(id);
	Garage_Save(id);
	return 1;
}

/*Command List Admin*/
CMD:creategarage(playerid, params[])
{
   	if(CheckAdmin(playerid, 5))
        return PermissionError(playerid);

	static
		price, type, id;

	if(sscanf(params, "dd", price, type)) return SendSyntaxMessage(playerid, "/creategarage [price] [type 1-5]");
	if(type < 1 || type > 5) return SendErrorMessage(playerid, "Invalid type id.");
	if(price < 1) return SendErrorMessage(playerid, "Price minimum is zero.");

	id = Garage_Create(playerid, price, type, 0);

	if(id == -1)
		return SendErrorMessage(playerid, "The server has reached the limit for garage.");

    SendServerMessage(playerid, "You have successfully created garage ID: %d.", id);
	return 1;
}

CMD:parkveh(playerid, params[])
{
	static id = -1;
	if((id = Garage_Nearest(playerid)) == -1) return SendErrorMessage(playerid, "You're not in nearest any park.");
	if(IsPlayerInAnyVehicle(playerid))
	{
		static
			vehicleid = -1;

		if((vehicleid = Vehicle_GetID(GetPlayerVehicleID(playerid))) != -1)
		{
		    if(!GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You're not in nearest any park.");
			if(!Vehicle_IsOwner(playerid, vehicleid)) return SendErrorMessage(playerid, "This is not your vehicle.");
			if(IsAPlane(GetPlayerVehicleID(playerid)) || IsAHelicopter(GetPlayerVehicleID(playerid))) return SendErrorMessage(playerid, "Can't loaded this vehicle.");

			VehicleData[vehicleid][cGarage] = GarageData[id][garageID];

			GetVehiclePos(VehicleData[vehicleid][cVehicle], VehicleData[vehicleid][cPos][0], VehicleData[vehicleid][cPos][1], VehicleData[vehicleid][cPos][2]);
			if (VehicleData[vehicleid][cNeon]) VehicleData[vehicleid][cNeonToggle] = 0;
			ReloadVehicleNeon(vehicleid);

			for (new slot = 0; slot < MAX_VEHICLE_OBJECT+5; slot ++) if (VehicleObjects[vehicleid][slot][object_exists]) {
                if(IsValidDynamicObject(VehicleObjects[vehicleid][slot][object_streamer]))
                    DestroyDynamicObject(VehicleObjects[vehicleid][slot][object_streamer]);

                VehicleObjects[vehicleid][slot][object_streamer] = INVALID_STREAMER_ID;
            }

			Vehicle_Save(vehicleid);

			if (IsValidVehicle(VehicleData[vehicleid][cVehicle]))
				DestroyVehicle(VehicleData[vehicleid][cVehicle]);

			VehicleData[vehicleid][cVehicle] = INVALID_VEHICLE_ID;
			Garage_Sync(id);
		}
		else SendErrorMessage(playerid, "This vehicle not owned by you, can't put to this garage.");
	}
	return 1;
}

CMD:pickupveh(playerid, params[])
{
	static id = -1;
	id = Garage_Nearest(playerid);

	if(id == -1) {
		SendErrorMessage(playerid, "You're not in nearest any park.");
	} else {
        if(!GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You're not in nearest any park.");

		if (IsPlayerInAnyVehicle(playerid))
			return SendErrorMessage(playerid, "You need to be on foot to use this command!");

		if (PlayerData[playerid][pVipTime] > 0 && PlayerData[playerid][pVip] == 3) {
			if(Vehicle_GetCount(playerid) >= MAX_PLAYER_VEHICLE+1)
				return SendErrorMessage(playerid, "You vehicle slot is full!");
		} else if (PlayerData[playerid][pVipTime] > 0 && PlayerData[playerid][pVip] == 4) {
			if(Vehicle_GetCount(playerid) >= MAX_PLAYER_VEHICLE+2)
				return SendErrorMessage(playerid, "You vehicle slot is full!");
		} else {
			if(Vehicle_GetCount(playerid) >= MAX_PLAYER_VEHICLE)
				return SendErrorMessage(playerid, "You vehicle slot is full!");
		}

		new text[300], count = 0;

		format(text,sizeof(text),"Model\tInsurance\n");
		foreach (new vehicleid : DynamicVehicles) if (VehicleData[vehicleid][cGarage] == GarageData[id][garageID] && Vehicle_IsOwner(playerid, vehicleid)) {
			format(text,sizeof(text),"%s%s\t%d\n",text,GetVehicleNameByModel(VehicleData[vehicleid][cModel]),VehicleData[vehicleid][cInsurance]);
			ListedVehicles[playerid][count++] = vehicleid;
		}
		if (count) Dialog_Show(playerid, TakeVeh, DIALOG_STYLE_TABLIST_HEADERS, "Take Veh", text, "Take", "Cancel");
		else SendErrorMessage(playerid, "There are nothing vehicle in here.");
	}
	return 1;
}

CMD:createpark(playerid, params[])
{
   	if(CheckAdmin(playerid, 5))
        return PermissionError(playerid);

	static
		id;

	id = Garage_Create(playerid, 1, 5, 1);

	if(id == -1)
		return SendErrorMessage(playerid, "The server has reached the limit for garage.");

    SendServerMessage(playerid, "You have successfully created park public ID: %d.", id);
	return 1;
}

CMD:destroypark(playerid, params[])
{
   	if(CheckAdmin(playerid, 5))
        return PermissionError(playerid);

	static
		id;

	if(sscanf(params, "d", id)) return SendErrorMessage(playerid, "/destroygarage [id]");
	if(!GarageData[id][garageExists]) return SendErrorMessage(playerid, "Invalid garage id.");
	if(!GarageData[id][garagePublic]) return SendErrorMessage(playerid, "Invalid garage id.");

	SendServerMessage(playerid, "You have successfully destroy garage ID: %d.", id);
	Garage_Destroy(id);
	return 1;
}

CMD:destroygarage(playerid, params[])
{
   	if(CheckAdmin(playerid, 5))
        return PermissionError(playerid);

	static
		id;

	if(sscanf(params, "d", id)) return SendErrorMessage(playerid, "/destroygarage [id]");
	if(!GarageData[id][garageExists]) return SendErrorMessage(playerid, "Invalid garage id.");
	if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "Invalid garage id.");

	SendServerMessage(playerid, "You have successfully destroy garage ID: %d.", id);
	Garage_Destroy(id);
	return 1;
}

CMD:setlocation(playerid, params[])
{
   	if(CheckAdmin(playerid, 5))
        return PermissionError(playerid);

	new
		id;

	if(sscanf(params, "d", id)) return SendSyntaxMessage(playerid, "/setlocation [id]");
	if(!GarageData[id][garageExists]) return SendErrorMessage(playerid, "Invalid garage id.");
	if(!GarageData[id][garagePublic]) return SendErrorMessage(playerid, "Invalid garage id.");

	GetPlayerPos(playerid, GarageData[id][garageLoc][0], GarageData[id][garageLoc][1], GarageData[id][garageLoc][2]);
	GetPlayerFacingAngle(playerid, GarageData[id][garageLoc][3]);

	Garage_Sync(id);

	SendServerMessage(playerid, "You have successfully edit location of park id %d", id);
	return 1;
}

CMD:editgarage(playerid, params[])
{
   	if(CheckAdmin(playerid, 5))
        return PermissionError(playerid);

	new 
		string[128],
		id,
		category[10];

	if(sscanf(params, "ds[10]S()[128]", id, category, string)) return SendSyntaxMessage(playerid, "/editgarage [id] [location/price/type/lock/sell/houselink]");
	if(!GarageData[id][garageExists]) return SendErrorMessage(playerid, "Invalid garage id.");
	if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "Invalid garage id.");

	if(!strcmp(category, "location"))
	{
		GetPlayerPos(playerid, GarageData[id][garageLoc][0], GarageData[id][garageLoc][1], GarageData[id][garageLoc][2]);
		GetPlayerFacingAngle(playerid, GarageData[id][garageLoc][3]);

		Garage_Sync(id);

		SendServerMessage(playerid, "You have successfully edit location of garage id %d", id);
	}
	else if(!strcmp(category, "price"))
	{
		new price;

		if(sscanf(string, "d", price)) return SendSyntaxMessage(playerid, "/editgarage id price [value]");
		if(price < 1) return SendErrorMessage(playerid, "Price minimum is zero.");
		
		if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You can't setting a price for Public Garage.");

		GarageData[id][garagePrice] = price;
		Garage_Sync(id);

		SendServerMessage(playerid, "You have successfully edit price of garage id %d to %s", id, FormatNumber(price));
	}
	else if(!strcmp(category, "type"))
	{
		new type;

		if(sscanf(string, "d", type)) return SendSyntaxMessage(playerid, "/editgarage id type [1-5]");
		if(type < 1 || type > 5) return SendErrorMessage(playerid, "Invalid type id.");
		
		if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You can't setting a type for Public Garage.");

		GarageData[id][garageType] = type;

		foreach (new i : DynamicVehicles) if (VehicleData[i][cOwner] && VehicleData[i][cGarage] == GarageData[id][garageID])
		{
			VehicleData[i][cGarage] = 0;
			VehicleData[i][cInt] = 0;
			VehicleData[i][cVw] = 0;
			VehicleData[i][cPos][0] = GarageData[id][garageLoc][0];
	        VehicleData[i][cPos][1] = GarageData[id][garageLoc][1];
	        VehicleData[i][cPos][2] = GarageData[id][garageLoc][2];
	        VehicleData[i][cPos][3] = GarageData[id][garageLoc][3];

	        Vehicle_Spawn(i);
		}
		Garage_Sync(id);

		SendServerMessage(playerid, "You have successfully edit type of garage id %d to %d", id, type);
	}
	else if(!strcmp(category, "lock"))
	{
		new lock;

		if(sscanf(string, "d", lock)) return SendSyntaxMessage(playerid, "/editgarage id lock [0/1]");
		if(lock < 0 || lock > 1) return SendErrorMessage(playerid, "Only 0 (unlock) or 1 (lock).");

		GarageData[id][garageLock] = lock;
		Garage_Sync(id);

		SendServerMessage(playerid, "You have successfully %s of garage id %d.", GarageData[id][garageLock] ? ("Lock") : ("Unlock"), id);
	}
	else if(!strcmp(category, "houselink"))
	{
		new houseid;

		if(sscanf(string, "d", houseid)) return SendSyntaxMessage(playerid, "/editgarage id houselink [houseid]");
		if(!Iter_Contains(Houses, houseid)) return SendErrorMessage(playerid, "Invalid house id.");
		
		if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You can't setting a house link for Public Garage.");

		GarageData[id][garageHouseLink] = HouseData[houseid][houseID];
		if(HouseData[houseid][houseOwner]) {
			GarageData[id][garageOwnerId] = HouseData[houseid][houseOwner];
			format(GarageData[id][garageOwner], MAX_PLAYER_NAME, HouseData[houseid][houseOwnerName]);
		}

		Garage_Sync(id);
		House_Refresh(houseid);

		SendServerMessage(playerid, "You have successfully linked this garage to house id %d.", houseid);
	}
	else if(!strcmp(category, "sell"))
	{
	    if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You can't sell a Public Garage.");
		if (!GarageData[id][garageOwnerId]) return SendErrorMessage(playerid, "This garage is for sale!.");
		if (GarageData[id][garageHouseLink]) return SendErrorMessage(playerid, "This garage linked to houseid!.");

		mysql_tquery(g_iHandle, sprintf("UPDATE `player_vehicles` SET `Garage`= 0, Pos1 = '%.01f', Pos2 = '%.01f', Pos3 = '%.01f', Pos4 = '%.01f' WHERE Garage='%d'", 
			GarageData[id][garageLoc][0],  GarageData[id][garageLoc][1], GarageData[id][garageLoc][2], GarageData[id][garageLoc][3], 
			GarageData[id][garageID])
		);

		GarageData[id][garageOwnerId] = 0;
		GarageData[id][garageOwner] = EOS;
		GarageData[id][garageLock] = 1;
		GarageData[id][garageInside] = 0;

		foreach (new i : DynamicVehicles) if (VehicleData[i][cOwner] && VehicleData[i][cGarage] == GarageData[id][garageID])
		{
			VehicleData[i][cGarage] = 0;
			VehicleData[i][cInt] = 0;
			VehicleData[i][cVw] = 0;
			VehicleData[i][cPos][0] = GarageData[id][garageLoc][0];
	        VehicleData[i][cPos][1] = GarageData[id][garageLoc][1];
	        VehicleData[i][cPos][2] = GarageData[id][garageLoc][2];
	        VehicleData[i][cPos][3] = GarageData[id][garageLoc][3];

	        Vehicle_Spawn(i);
		}
		Garage_Sync(id);
	}
	Garage_Save(id);
	return 1;
}

/*Command List Player*/
CMD:garage(playerid, params[])
{
	static 
		string[128],
		id = -1,
		category[64];

	if(sscanf(params, "s[64]S()[128]", category, string)) return SendSyntaxMessage(playerid, "/garage [buy/storecar/takecar/lock/sell/approve/abandon/switchcar]");

	if(!strcmp(category, "buy"))
	{
		if (!PlayerData[playerid][pStory]) return SendErrorMessage(playerid, "You must have accepted character story to buying any property");
		if((id = Garage_Nearest(playerid)) == -1) return SendErrorMessage(playerid, "You're not in nearest any garage.");
		if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You can't buy a Public Garage.");
		if(GarageData[id][garageOwnerId]) return SendErrorMessage(playerid, "This garage owned by someone.");
		if (PlayerData[playerid][pVip] >= 2 && PlayerData[playerid][pVipTime] > 0) {
			if(Garage_GetCount(playerid) >= MAX_OWNABLE_GARAGE+1) return SendErrorMessage(playerid, "You garage slot is not available.");
		} else {
			if(Garage_GetCount(playerid) >= MAX_OWNABLE_GARAGE) return SendErrorMessage(playerid, "You garage slot is not available.");
		}
		if(GetMoney(playerid) < GarageData[id][garagePrice]) return SendErrorMessage(playerid, "You dont have enough money to buy this garage.");
		if(GarageData[id][garageHouseLink]) return SendErrorMessage(playerid, "This garage linked to the house, buy house near this garage to owned this garage.");

		GarageData[id][garageOwnerId] = PlayerData[playerid][pID];
		GarageData[id][garageLastVisited] = gettime();
		format(GarageData[id][garageOwner], MAX_PLAYER_NAME, "%s", ReturnName(playerid));
		GiveMoney(playerid, -GarageData[id][garagePrice]);

		SendServerMessage(playerid, "You've bough this garage.");

		Garage_Sync(id);
	}
	else if(!strcmp(category, "storecar"))
	{
		if((id = Garage_Nearest(playerid)) == -1) return SendErrorMessage(playerid, "You're not in nearest any garage.");
		if(GarageData[id][garageLock]) return GameTextForPlayer(playerid, "~r~Locked", 1500, 1);
		if(IsPlayerInAnyVehicle(playerid))
		{
			static 
				vehicleid = -1;

			if((vehicleid = Vehicle_GetID(GetPlayerVehicleID(playerid))) != -1)
			{
			    if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You're not in nearest any garage.");
				if(!Vehicle_IsOwner(playerid, vehicleid)) return SendErrorMessage(playerid, "This is not your vehicle.");
				if(!Garage_IsOwner(playerid, id)) return SendErrorMessage(playerid, "This garage isn't owned by you.");
				if(IsAPlane(GetPlayerVehicleID(playerid)) || IsAHelicopter(GetPlayerVehicleID(playerid))) return SendErrorMessage(playerid, "Can't loaded this vehicle.");
				if(GarageData[id][garageInside] >= GarageData[id][garageType]) return SendErrorMessage(playerid, "Can't put more vehicle to this garage.");
				
				VehicleData[vehicleid][cGarage] = GarageData[id][garageID];
				
				GetVehiclePos(VehicleData[vehicleid][cVehicle], VehicleData[vehicleid][cPos][0], VehicleData[vehicleid][cPos][1], VehicleData[vehicleid][cPos][2]);
				if (VehicleData[vehicleid][cNeon]) VehicleData[vehicleid][cNeonToggle] = 0;
				ReloadVehicleNeon(vehicleid);

				for (new slot = 0; slot < MAX_VEHICLE_OBJECT+5; slot ++) if (VehicleObjects[vehicleid][slot][object_exists]) {
                    if(IsValidDynamicObject(VehicleObjects[vehicleid][slot][object_streamer]))
                        DestroyDynamicObject(VehicleObjects[vehicleid][slot][object_streamer]);

                    VehicleObjects[vehicleid][slot][object_streamer] = INVALID_STREAMER_ID;
                }

				Vehicle_Save(vehicleid);

				GarageData[id][garageInside]++;

				if (IsValidVehicle(VehicleData[vehicleid][cVehicle]))
					DestroyVehicle(VehicleData[vehicleid][cVehicle]);

				VehicleData[vehicleid][cVehicle] = INVALID_VEHICLE_ID;
				Garage_Sync(id);
			}
			else SendErrorMessage(playerid, "This vehicle not owned by you, can't put to this garage.");
		}
	}
	else if(!strcmp(category, "sell"))
	{
		if((id = Garage_Nearest(playerid)) == -1) return SendErrorMessage(playerid, "You're not in nearest any garage.");
		if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You can't sell a Public Garage.");
		if(!Garage_IsOwner(playerid, id)) return SendErrorMessage(playerid, "This garage isn't owned by you.");

		new 
			userid,
			price;

		if(GarageData[id][garageHouseLink]) 
			return SendErrorMessage(playerid, "This garage can't sell by yourself, sell your house to sell this garage too.");
		
		if(GarageData[id][garageInside]) 
			return SendErrorMessage(playerid, "Take out all vehicle from this garage.");
		
		if(sscanf(string, "dd", userid, price)) 
			return SendSyntaxMessage(playerid, "/garage sell [userid] [price]");
		
		if(userid == playerid) 
			return SendErrorMessage(playerid, "This garage owned by you!.");
		
		if(userid == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, userid, 5.0)) 
			return SendErrorMessage(playerid, "That player is disconnected or not near you.");

		if (!PlayerData[userid][pStory])
			return SendErrorMessage(playerid, "That player must have accepted character story to buying any property");
		
		if (PlayerData[userid][pVip] >= 2 && PlayerData[playerid][pVipTime] > 0) {
			if(Garage_GetCount(userid) >= MAX_OWNABLE_GARAGE+1) 
				return SendErrorMessage(playerid, "That player not have garage slot.");
		} else {
			if(Garage_GetCount(userid) >= MAX_OWNABLE_GARAGE) 
				return SendErrorMessage(playerid, "That player not have garage slot.");
		}
		
		if(price < 0) 
			return SendErrorMessage(playerid, "Price can't under 0.");

		PlayerData[userid][pGarageSeller] = playerid;
        PlayerData[userid][pGarageOffered] = id;
        PlayerData[userid][pGarageValue] = price;

        SendServerMessage(playerid, "You have requested %s to purchase your garage (%s).", ReturnName(userid, 0), FormatNumber(price));
        SendServerMessage(userid, "%s has offered you their garage for %s (type \"/garage approve\" to accept).", ReturnName(playerid, 0), FormatNumber(price));
	}
	else if(!strcmp(category, "abandon"))
	{
		if((id = Garage_Nearest(playerid)) == -1) return SendErrorMessage(playerid, "You're not in nearest any garage.");
		if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You can't abandon a Public Garage.");
		if(!Garage_IsOwner(playerid, id)) return SendErrorMessage(playerid, "This garage isn't owned by you.");
		if(GarageData[id][garageHouseLink]) return SendErrorMessage(playerid, "Can't abandon this garage, this garage linked to other house id.");

		new 
			confirm[8];

		if(GarageData[id][garageInside]) return SendErrorMessage(playerid, "Take out all vehicle from this garage.");
		if(sscanf(string, "s[8]", confirm)) return SendSyntaxMessage(playerid, "/garage abandon 'confirm'");

		if (GarageData[id][garageInside])
            return SendErrorMessage(playerid, "Please take out all vehicle from this garage");

        GarageData[id][garageOwnerId] = 0;
        GarageData[id][garageInside] = 0;
		Garage_Sync(id);
        Garage_Save(id);

		SendServerMessage(playerid, "You have abandoned your garage.");
        Log_Write("logs/garage_log.txt", "[%s] %s has abandoned garage ID: %d.", ReturnDate(), ReturnName(playerid), id);
	}
	else if(!strcmp(category, "approve"))
	{
		if(PlayerData[playerid][pGarageSeller] == INVALID_PLAYER_ID) return SendErrorMessage(playerid, "No one sell garage for you.");

		new
			sellerid = PlayerData[playerid][pGarageSeller],
			garageid = PlayerData[playerid][pGarageOffered],
			price = PlayerData[playerid][pGarageValue];

		if(!IsPlayerNearPlayer(playerid, sellerid, 6.0)) return SendErrorMessage(playerid, "You are not near that player.");
		if(GetMoney(playerid) < price) return SendErrorMessage(playerid, "You have insufficient funds to purchase this garage.");
		if(Garage_Nearest(playerid) != garageid) return SendErrorMessage(playerid, "You must be near the garage to purchase it.");
		if(!Garage_IsOwner(sellerid, garageid)) return SendErrorMessage(playerid, "This garage offer is no longer valid.");

		SendServerMessage(playerid, "You have successfully purchased %s's garage for %s.", ReturnName(sellerid, 0), FormatNumber(price));
		SendServerMessage(sellerid, "%s has successfully purchased your garage for %s.", ReturnName(playerid, 0), FormatNumber(price));

		format(GarageData[garageid][garageOwner], MAX_PLAYER_NAME, ReturnName(playerid));
		GarageData[garageid][garageOwnerId] = GetPlayerSQLID(playerid);
		GarageData[garageid][garageLastVisited] = gettime();
		
		Garage_Sync(garageid);
		GiveMoney(playerid, -price);
		GiveMoney(sellerid, price);

		Log_Write("logs/offer_log.txt", "[%s] %s (%s) has sold a garage to %s (%s) for %s.", ReturnDate(), ReturnName(playerid, 0), AccountData[playerid][pIP], ReturnName(sellerid, 0), AccountData[sellerid][pIP], FormatNumber(price));

		PlayerData[playerid][pGarageSeller] = INVALID_PLAYER_ID;
		PlayerData[playerid][pGarageOffered] = -1;
		PlayerData[playerid][pGarageValue] = 0;
	}
	else if(!strcmp(category, "lock"))
	{
		if((id = (Garage_Inside(playerid) == -1) ? (Garage_Nearest(playerid)) : (Garage_Inside(playerid))) != -1 && Garage_IsOwner(playerid, id))
		{
			if(!GarageData[id][garageLock]) GarageData[id][garageLock] = true;
			else GarageData[id][garageLock] = false;

			SendServerMessage(playerid, "You have %s this garage.", GarageData[id][garageLock] ? ("Lock") : ("Unlock"));
			Garage_Sync(id);
			return 1;
		}
		SendErrorMessage(playerid, "You're not outside your garage.");
	}
	else if(!strcmp(category, "takecar"))
	{
		id = Garage_Nearest(playerid);

		if(id == -1) {
			SendErrorMessage(playerid, "You're not in nearest any garage.");
		} else {
            if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You're not in nearest any garage.");
			if(!Garage_IsOwner(playerid, id)) return SendErrorMessage(playerid, "This garage isn't owned by you.");

			if (IsPlayerInAnyVehicle(playerid))
				return SendErrorMessage(playerid, "You need to be on foot to use this command!");

			if (PlayerData[playerid][pVipTime] > 0 && PlayerData[playerid][pVip] == 3) {
				if(Vehicle_GetCount(playerid) >= MAX_PLAYER_VEHICLE+1)
					return SendErrorMessage(playerid, "You vehicle slot is full!");
			} else if (PlayerData[playerid][pVipTime] > 0 && PlayerData[playerid][pVip] == 4) {
				if(Vehicle_GetCount(playerid) >= MAX_PLAYER_VEHICLE+2)
					return SendErrorMessage(playerid, "You vehicle slot is full!");
			} else {
				if(Vehicle_GetCount(playerid) >= MAX_PLAYER_VEHICLE)
					return SendErrorMessage(playerid, "You vehicle slot is full!");
			}

			new text[300], count = 0;

			format(text,sizeof(text),"Model\tInsurance\n");
			foreach (new vehicleid : DynamicVehicles) if (VehicleData[vehicleid][cGarage] == GarageData[id][garageID] && Vehicle_IsOwner(playerid, vehicleid)) {
				format(text,sizeof(text),"%s%s\t%d\n",text,GetVehicleNameByModel(VehicleData[vehicleid][cModel]),VehicleData[vehicleid][cInsurance]);
				ListedVehicles[playerid][count++] = vehicleid;
			}
			if (count) Dialog_Show(playerid, TakeVeh, DIALOG_STYLE_TABLIST_HEADERS, "Take Veh", text, "Take", "Cancel");
			else SendErrorMessage(playerid, "There are nothing vehicle in here.");
		}
	} else if (!strcmp(category, "switchcar", true)) {
		id = Garage_Nearest(playerid);

		if(id == -1) {
			SendErrorMessage(playerid, "You're not in nearest any garage.");
		} else {
		    if(GarageData[id][garagePublic]) return SendErrorMessage(playerid, "You're not in nearest any garage.");
			if(!Garage_IsOwner(playerid, id))
				return SendErrorMessage(playerid, "This garage isn't owned by you.");

			if (!IsPlayerInAnyVehicle(playerid))
				return SendErrorMessage(playerid, "You need to be in any vehicle to use this command!");
			
			
			new text[300], count = 0;

			format(text,sizeof(text),"Model\tInsurance\n");
			foreach (new vehicleid : DynamicVehicles) if (VehicleData[vehicleid][cGarage] == GarageData[id][garageID] && Vehicle_IsOwner(playerid, vehicleid)) {
				format(text,sizeof(text),"%s%s\t%d\n",text,GetVehicleNameByModel(VehicleData[vehicleid][cModel]),VehicleData[vehicleid][cInsurance]);
				ListedVehicles[playerid][count++] = vehicleid;
			}
			if (count) Dialog_Show(playerid, SwitchVeh, DIALOG_STYLE_TABLIST_HEADERS, "Switch Car", text, "Switch", "Cancel");
			else SendErrorMessage(playerid, "There are nothing vehicle in here.");
		}
	}
	return 1;
}

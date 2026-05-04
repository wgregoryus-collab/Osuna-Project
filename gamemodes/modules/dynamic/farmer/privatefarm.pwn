// Private Farm System
// Created by Lukman on 26 August 2021
#define MAX_PRIVATE_FARM (50)
#define MAX_PLANTS_STORAGE (5000)

enum pFarm {
  farmID,
  farmOwner,
  farmOwnerName[MAX_PLAYER_NAME],
  farmName[32],
  farmPrice,
  Float:farmPos[3],
  farmPlant[4],
  farmSeeds[4],
  farmLastVisited,
  farmMoney,
  farmSeal,
  farmPickup,
  Text3D:farmLabel
};
new FarmData[MAX_PRIVATE_FARM][pFarm],
    Iterator:Farms<MAX_PRIVATE_FARM>;

new pvFarmZone[MAX_PRIVATE_FARM];

// Private Farmer Zone
new Float:farmzone_0[] = {
	-334.0, -1026.0, -364.0, -1027.0, -387.0, -1031.0, -384.0, -1060.0, -374.0, -1063.0, -362.0, -1070.0, -342.0, -1070.0, -334.0, -1026.0
};

new Float:farmzone_1[] = {
	-815.0, -1414.0, -860.0, -1407.0, -857.0, -1441.0, -808.0, -1444.0, -815.0, -1414.0
};

new Float:farmzone_2[] = {
	-415.0, -1507.0, -444.0, -1510.0, -445.0, -1473.0, -401.0, -1479.0, -415.0, -1507.0
};

new Float:farmzone_3[] = {
	6.0,36.0,18.0,68.0,34.0,63.0,80.0,26.0,72.0,-48.0,6.0,36.0
};

new Float:farmzone_4[] = {
	-342.0,-940.0,-296.0,-893.0,-230.0,-951.0,-278.0,-1002.0,-342.0,-940.0
};

new Float:farmzone_5[] = {
	-1001.0,-1063.0,-1002.0,-907.0,-1161.0,-906.0,-1200.0,-931.0,-1200.0,-1067.0,-1001.0,-1063.0
};

new Float:farmzone_6[] = {
	1911.0,189.0,1994.0,169.0,2003.0,171.0,2003.0,236.0,1916.0,247.0,1909.0,225.0,1911.0,189.0
}; //(AREA) farm6
new Float:farmzone_7[] = {
	-1071.0,-1238.0,-1073.0,-1204.0,-1081.0,-1203.0,-1087.0,-1195.0,-1089.0,-1180.0,-1091.0,-1170.0,-1101.0,-1155.0,-1153.0,-1157.0,-1152.0,-1215.0,-1122.0,-1215.0,
	-1121.0,-1238.0,-1071.0,-1238.0
}; //(AREA) farm7
new Float:farmzone_8[] = {
	-1092.0,-2492.0,-1068.0,-2455.0,-1023.0,-2451.0,-992.0,-2471.0,-971.0,-2484.0,-970.0,-2515.0,-976.0,-2541.0,-1005.0,-2575.0,-1048.0,-2587.0,-1073.0,-2587.0,
	-1099.0,-2524.0,-1092.0,-2492.0
}; //(AREA) farm_8
new Float:farmzone_9[] = {
	-713.0,-84.0,-704.0,-137.0,-810.0,-165.0,-819.0,-125.0,-713.0,-84.0
}; //(AREA) farmzone_9
new Float:farmzone_10[] = {
	272.0,1120.0,268.0,1163.0,217.0,1162.0,214.0,1118.0,272.0,1120.0
}; //(AREA) farmzone_10
new Float:farmzone_11[] = {
	-1237.0,-1469.0,-1207.0,-1458.0,-1180.0,-1462.0,-1148.0,-1458.0,-1159.0,-1364.0,-1180.0,-1362.0,-1201.0,-1364.0,-1214.0,-1360.0,-1249.0,-1368.0,-1249.0,-1441.0,
	-1237.0,-1469.0
}; //(AREA) farmzone_11
new Float:farmzone_12[] = {
	2532.0,-892.0,2564.0,-902.0,2593.0,-903.0,2616.0,-886.0,2614.0,-870.0,2612.0,-858.0,2527.0,-800.0,2474.0,-800.0,2452.0,-817.0,2422.0,-828.0,
	2406.0,-854.0,2438.0,-900.0,2532.0,-892.0
}; //(AREA) farmzone_12
new Float:farmzone_13[] = {
	283.0,1032.0,236.0,1033.0,236.0,1101.0,283.0,1101.0,283.0,1032.0
}; //(AREA) farmzone_13
new Float:farmzone_14[] = {
	486.0,1075.0,440.0,1070.0,439.0,1129.0,482.0,1128.0,486.0,1075.0
}; //(AREA) farmzone_14
new Float:farmzone_15[] = {
	-1080.0,-1640.0,-987.0,-1640.0,-967.0,-1618.0,-941.0,-1601.0,-928.0,-1585.0,-937.0,-1572.0,-1080.0,-1575.0,-1080.0,-1640.0
}; //(AREA) farmzone_15
new Float:farmzone_16[] = {
	-404.0,-1099.0,-496.0,-1102.0,-494.0,-1185.0,-406.0,-1184.0,-404.0,-1099.0
}; //(AREA) farmzone_16
new Float:farmzone_17[] = {
	1514.0,-29.0,1413.0,-33.0,1406.0,-63.0,1519.0,-70.0,1514.0,-29.0
}; //(AREA) farmzone_18
new Float:farmzone_18[] = {
	1090.0,264.0,1078.0,300.0,934.0,332.0,906.0,318.0,885.0,295.0,884.0,272.0,916.0,258.0,1001.0,239.0,1041.0,241.0,1076.0,233.0,1086.0,243.0,1090.0,264.0
}; //(AREA) farmzone_19
new Float:farmzone_19[] = {
	999.0,-289.0,901.0,-301.0,852.0,-259.0,851.0,-226.0,764.0,-227.0,744.0,-244.0,742.0,-261.0,777.0,-272.0,917.0,-371.0,1001.0,-391.0,999.0,-289.0
}; //(AREA) farmzone_20
new Float:farmzone_20[] = {
	-915.0,-491.0,-945.0,-486.0,-960.0,-488.0,-968.0,-515.0,-967.0,-543.0,-912.0,-545.0,-905.0,-501.0,-915.0,-491.0
}; //(AREA) farmzone_21
new Float:farmzone_21[] = {
	-533.0,-1492.0,-541.0,-1553.0,-540.0,-1603.0,-530.0,-1611.0,-508.0,-1636.0,-486.0,-1591.0,-483.0,-1509.0,-480.0,-1479.0,-533.0,-1492.0
};
new Float:farmzone_22[] = {
	-342.0,-1264.0,-434.0,-1278.0,-467.0,-1287.0,-589.0,-1287.0,-591.0,-1409.0,-554.0,-1439.0,-530.0,-1422.0,-504.0,-1412.0,-400.0,-1400.0,-372.0,-1379.0,-342.0,-1264.0
};
new Float:farmzone_23[] = {
	-456.0,-1572.0,-468.0,-1603.0,-464.0,-1636.0,-437.0,-1669.0,-396.0,-1667.0,-381.0,-1633.0,-390.0,-1598.0,-419.0,-1567.0,-456.0,-1572.0
};
new Float:farmzone_24[] = {
	-1414.0,-966.0,-1412.0,-912.0,-1435.0,-911.0,-1441.0,-969.0,-1414.0,-966.0
};
new Float:farmzone_25[] = {
	-843.0,-491.0,-873.0,-503.0,-888.0,-520.0,-903.0,-573.0,-904.0,-597.0,-877.0,-615.0,-781.0,-618.0,-763.0,-611.0,-756.0,-593.0,-780.0,-557.0,-785.0,-530.0,
	-812.0,-503.0,-843.0,-491.0
};
new Float:farmzone_26[] = {
	1001.0,-413.0,898.0,-382.0,780.0,-296.0,777.0,-446.0,1006.0,-443.0,1001.0,-413.0
};
new Float:farmzone_27[] = {
	-77.0,-1531.0,-135.0,-1487.0,-156.0,-1510.0,-116.0,-1570.0,-77.0,-1531.0
};
new Float:farmzone_28[] = {
	1755.0,240.0,1755.0,216.0,1878.0,196.0,1877.0,241.0,1755.0,240.0
};
new Float:farmzone_29[] = {
	-555.0,-2665.0,-538.0,-2644.0,-527.0,-2639.0,-522.0,-2629.0,-525.0,-2601.0,-540.0,-2574.0,-564.0,-2568.0,-597.0,-2583.0,-610.0,-2603.0,-612.0,-2629.0,
	-598.0,-2644.0,-576.0,-2661.0,-555.0,-2665.0
};
new Float:farmzone_30[] = {
	1273.0,136.0,1270.0,23.0,1290.0,3.0,1304.0,-41.0,1366.0,31.0,1407.0,51.0,1487.0,116.0,1433.0,149.0,1405.0,151.0,1331.0,189.0,1312.0,129.0,1293.0,127.0,1273.0,136.0
};
new Float:farmzone_31[] = {
	738.0,-90.0,688.0,-89.0,588.0,-100.0,586.0,-117.0,626.0,-120.0,737.0,-120.0,738.0,-90.0
};
new Float:farmzone_32[] = {
	-446.0,-2673.0,-457.0,-2671.0,-425.0,-2650.0,-337.0,-2555.0,-340.0,-2518.0,-350.0,-2495.0,-373.0,-2491.0,-402.0,-2495.0,-424.0,-2520.0,-438.0,-2631.0,-466.0,-2673.0
};
new Float:farmzone_33[] = {
	1709.0,347.0,1723.0,314.0,1760.0,298.0,1817.0,298.0,1884.0,315.0,1863.0,345.0,1739.0,371.0,1709.0,347.0
};
new Float:farmzone_34[] = {
	131.0,1039.0,142.0,1104.0,127.0,1105.0,124.0,1115.0,98.0,1112.0,99.0,1098.0,96.0,1093.0,81.0,1093.0,87.0,1040.0,131.0,1039.0
};

#include <YSI\y_hooks>
hook OnGameModeInitEx() {
  mysql_tquery(g_iHandle, "SELECT * FROM `farms`", "Farm_Load", "");
  pvFarmZone[0] = CreateDynamicPolygon(farmzone_0, _, _, _, 0, 0);
  pvFarmZone[1] = CreateDynamicPolygon(farmzone_1, _, _, _, 0, 0);
  pvFarmZone[2] = CreateDynamicPolygon(farmzone_2, _, _, _, 0, 0);
  pvFarmZone[3] = CreateDynamicPolygon(farmzone_3, _, _, _, 0, 0);
  pvFarmZone[4] = CreateDynamicPolygon(farmzone_4, _, _, _, 0, 0);
  pvFarmZone[5] = CreateDynamicPolygon(farmzone_5, _, _, _, 0, 0);
  pvFarmZone[6] = CreateDynamicPolygon(farmzone_6, _, _, _, 0, 0);
  pvFarmZone[7] = CreateDynamicPolygon(farmzone_7, _, _, _, 0, 0);
  pvFarmZone[8] = CreateDynamicPolygon(farmzone_8, _, _, _, 0, 0);
  pvFarmZone[9] = CreateDynamicPolygon(farmzone_9, _, _, _, 0, 0);
  pvFarmZone[10] = CreateDynamicPolygon(farmzone_10, _, _, _, 0, 0);
  pvFarmZone[11] = CreateDynamicPolygon(farmzone_11, _, _, _, 0, 0);
  pvFarmZone[12] = CreateDynamicPolygon(farmzone_12, _, _, _, 0, 0);
  pvFarmZone[13] = CreateDynamicPolygon(farmzone_13, _, _, _, 0, 0);
  pvFarmZone[14] = CreateDynamicPolygon(farmzone_14, _, _, _, 0, 0);
  pvFarmZone[15] = CreateDynamicPolygon(farmzone_15, _, _, _, 0, 0);
  pvFarmZone[16] = CreateDynamicPolygon(farmzone_16, _, _, _, 0, 0);
  pvFarmZone[17] = CreateDynamicPolygon(farmzone_17, _, _, _, 0, 0);
  pvFarmZone[18] = CreateDynamicPolygon(farmzone_18, _, _, _, 0, 0);
  pvFarmZone[19] = CreateDynamicPolygon(farmzone_19, _, _, _, 0, 0);
  pvFarmZone[20] = CreateDynamicPolygon(farmzone_20, _, _, _, 0, 0);
  pvFarmZone[21] = CreateDynamicPolygon(farmzone_21, _, _, _, 0, 0);
  pvFarmZone[22] = CreateDynamicPolygon(farmzone_22, _, _, _, 0, 0);
  pvFarmZone[23] = CreateDynamicPolygon(farmzone_23, _, _, _, 0, 0);
  pvFarmZone[24] = CreateDynamicPolygon(farmzone_24, _, _, _, 0, 0);
  pvFarmZone[25] = CreateDynamicPolygon(farmzone_25, _, _, _, 0, 0);
  pvFarmZone[26] = CreateDynamicPolygon(farmzone_26, _, _, _, 0, 0);
  pvFarmZone[27] = CreateDynamicPolygon(farmzone_27, _, _, _, 0, 0);
  pvFarmZone[28] = CreateDynamicPolygon(farmzone_28, _, _, _, 0, 0);
  pvFarmZone[29] = CreateDynamicPolygon(farmzone_29, _, _, _, 0, 0);
  pvFarmZone[30] = CreateDynamicPolygon(farmzone_30, _, _, _, 0, 0);
  pvFarmZone[31] = CreateDynamicPolygon(farmzone_31, _, _, _, 0, 0);
  pvFarmZone[32] = CreateDynamicPolygon(farmzone_32, _, _, _, 0, 0);
  pvFarmZone[33] = CreateDynamicPolygon(farmzone_33, _, _, _, 0, 0);
  pvFarmZone[34] = CreateDynamicPolygon(farmzone_34, _, _, _, 0, 0);
  return 1;
}


hook OnGameModeExit() {
  foreach (new i : Farms) {
    Farm_Save(i);
  }
  return 1;
}

Function:Farm_Load() {
  new rows = cache_num_rows();

  for (new i = 0; i < rows; i ++) {
    cache_get_value_int(i, "ID", FarmData[i][farmID]);
    cache_get_value_int(i, "Owner", FarmData[i][farmOwner]);
    cache_get_value(i, "OwnerName", FarmData[i][farmOwnerName], MAX_PLAYER_NAME);
    cache_get_value(i, "Name", FarmData[i][farmName], 32);
    cache_get_value_int(i, "Price", FarmData[i][farmPrice]);
    cache_get_value_int(i, "LastVisited", FarmData[i][farmLastVisited]);
    cache_get_value_int(i, "Seal", FarmData[i][farmSeal]);

    cache_get_value_float(i, "Pos0", FarmData[i][farmPos][0]);
    cache_get_value_float(i, "Pos1", FarmData[i][farmPos][1]);
    cache_get_value_float(i, "Pos2", FarmData[i][farmPos][2]);
    
    cache_get_value_int(i, "Plant0", FarmData[i][farmPlant][0]);
    cache_get_value_int(i, "Plant1", FarmData[i][farmPlant][1]);
    cache_get_value_int(i, "Plant2", FarmData[i][farmPlant][2]);
    cache_get_value_int(i, "Plant3", FarmData[i][farmPlant][3]);
    
    cache_get_value_int(i, "Seed0", FarmData[i][farmSeeds][0]);
    cache_get_value_int(i, "Seed1", FarmData[i][farmSeeds][1]);
    cache_get_value_int(i, "Seed2", FarmData[i][farmSeeds][2]);
    cache_get_value_int(i, "Seed3", FarmData[i][farmSeeds][3]);

    cache_get_value_int(i, "Money", FarmData[i][farmMoney]);

    Iter_Add(Farms, i);
    Farm_Refresh(i);
  }
  printf("*** [GarudaPride Database: Loaded] private farm data loaded (%d count)", rows);
  return 1;
}

Function:OnFarmCreated(farmid) {
  if (!Iter_Contains(Farms, farmid))
    return 0;

  FarmData[farmid][farmID] = cache_insert_id();
  Farm_Save(farmid);
  return 1;
}

Farm_Save(id) {
  if (Iter_Contains(Farms, id)) {
    new query[1500];
    format(query,sizeof(query),"UPDATE `farms` SET `Owner`='%d', `Name`='%s', `OwnerName`='%s', `Price`='%d', `LastVisited`='%d', `Seal`='%d', `Pos0`='%.2f', `Pos1`='%.2f', `Pos2`='%.2f', `Plant0`='%d', `Plant1`='%d', `Plant2`='%d', `Plant3`='%d', `Seed0`='%d', `Seed1`='%d', `Seed2`='%d', `Seed3`='%d', `Money`='%d' WHERE `ID`='%d'",
    FarmData[id][farmOwner],
    SQL_ReturnEscaped(FarmData[id][farmName]),
    SQL_ReturnEscaped(FarmData[id][farmOwnerName]),
    FarmData[id][farmPrice],
    FarmData[id][farmLastVisited],
    FarmData[id][farmSeal],
    FarmData[id][farmPos][0],
    FarmData[id][farmPos][1],
    FarmData[id][farmPos][2],
    FarmData[id][farmPlant][0],
    FarmData[id][farmPlant][1],
    FarmData[id][farmPlant][2],
    FarmData[id][farmPlant][3],
    FarmData[id][farmSeeds][0],
    FarmData[id][farmSeeds][1],
    FarmData[id][farmSeeds][2],
    FarmData[id][farmSeeds][3],
    FarmData[id][farmMoney],
    FarmData[id][farmID]
    );
    return mysql_tquery(g_iHandle, query);
  }
  return 1;
}

Farm_Delete(id) {
  if (IsValidDynamicPickup(FarmData[id][farmPickup]))
    DestroyDynamicPickup(FarmData[id][farmPickup]);

  if (IsValidDynamic3DTextLabel(FarmData[id][farmLabel]))
    DestroyDynamic3DTextLabel(FarmData[id][farmLabel]);

  mysql_tquery(g_iHandle, sprintf("DELETE FROM `farms` WHERE `ID` = '%d'", FarmData[id][farmID]));
  FarmData[id][farmPickup] = INVALID_STREAMER_ID;
  FarmData[id][farmLabel] = Text3D:INVALID_3DTEXT_ID;
  FarmData[id][farmMoney] = 0;
  FarmData[id][farmID] = 0;
  Iter_Remove(Farms, id);
  return 1;
}

Farm_Create(price, Float:x, Float:y, Float:z) {
  new slot = cellmin;
  if ((slot = Iter_Free(Farms)) != cellmin) {
    FarmData[slot][farmOwner] = 0;
    format(FarmData[slot][farmOwnerName], MAX_PLAYER_NAME, "None");
    format(FarmData[slot][farmName], 32, "Private Farm");
    FarmData[slot][farmPrice] = price;
    FarmData[slot][farmPos][0] = x;
    FarmData[slot][farmPos][1] = y;
    FarmData[slot][farmPos][2] = z;
    FarmData[slot][farmPlant][0] = 0;
    FarmData[slot][farmPlant][1] = 0;
    FarmData[slot][farmPlant][2] = 0;
    FarmData[slot][farmPlant][3] = 0;
    FarmData[slot][farmSeeds][0] = 0;
    FarmData[slot][farmSeeds][1] = 0;
    FarmData[slot][farmSeeds][2] = 0;
    FarmData[slot][farmSeeds][3] = 0;
    FarmData[slot][farmMoney] = 0;
    Farm_RemoveAllEmployees(slot);

    Iter_Add(Farms, slot);
    Farm_Refresh(slot);

    mysql_tquery(g_iHandle, sprintf("INSERT INTO `farms` (`Owner`) VALUES ('%d')", FarmData[slot][farmOwner]), "OnFarmCreated", "d", slot);

    return slot;
  }
  return cellmin;
}

Farm_Refresh(id) {
  new label[512];
  if (IsValidDynamicPickup(FarmData[id][farmPickup]))
    DestroyDynamicPickup(FarmData[id][farmPickup]);

  if (IsValidDynamic3DTextLabel(FarmData[id][farmLabel]))
    DestroyDynamic3DTextLabel(FarmData[id][farmLabel]);

  FarmData[id][farmPickup] = CreateDynamicPickup(1239, 23, FarmData[id][farmPos][0], FarmData[id][farmPos][1], FarmData[id][farmPos][2], 0, 0, -1, 10);

  if (FarmData[id][farmOwner] > 0) {
    if (FarmData[id][farmSeal]) {
      format(label, sizeof(label), "[PF:%d]\n"GREEN"%s\n"YELLOW"Owner: "WHITE"%s\nThis farm is sealed by "RED"authority", id, FarmData[id][farmName], FarmData[id][farmOwnerName]);
    } else {
      format(label, sizeof(label), "[PF:%d]\n"GREEN"%s\n"YELLOW"Owner: "WHITE"%s", id, FarmData[id][farmName], FarmData[id][farmOwnerName]);
    }
  } else {
    format(label, sizeof(label), "[PF:%d]\n"GREEN"This farm is for sale\n"YELLOW"Price: "GREEN"%s\n"GREY"Type /buy to purchase it", id, FormatNumber(FarmData[id][farmPrice]));
  }

  FarmData[id][farmLabel] = CreateDynamic3DTextLabel(label, COLOR_CLIENT, FarmData[id][farmPos][0], FarmData[id][farmPos][1], FarmData[id][farmPos][2]+0.5, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);
  return 1;
}

Farm_Nearest(playerid, Float:range = 3.0) {
	foreach(new id : Farms) if(Iter_Contains(Farms, id) && IsPlayerInRangeOfPoint(playerid, range, FarmData[id][farmPos][0], FarmData[id][farmPos][1], FarmData[id][farmPos][2])) {
		return id;
	}
	return -1;
}

Farm_GetCount(playerid)
{
	new
		count = 0;

	foreach(new id : Farms) if (Iter_Contains(Farms, id) && Farm_IsOwner(playerid, id)) {
		count++;
	}
	return count;
}

Farm_GetID(playerid) {
  foreach (new i : Farms) if (Iter_Contains(Farms, i) && (Farm_IsOwner(playerid, i) || Farm_IsEmployee(playerid, i))) {
    return i;
  }

  return -1;
}

Farm_IsOwner(playerid, id) {
	if (Iter_Contains(Farms, id) && FarmData[id][farmOwner] == GetPlayerSQLID(playerid)) {
		return 1;
	}
	return 0;
}

Farm_IsEmployee(playerid, farmid) {
	new str[128], Cache: cache;
	format(str, sizeof(str), "SELECT * FROM `farm_employe` WHERE `Name`='%s' AND `Farm`='%d'", NormalName(playerid), FarmData[farmid][farmID]);
	cache = mysql_query(g_iHandle, str);
	new result = cache_num_rows();
	cache_delete(cache);
	return result;
}

Farm_AddEmployee(playerid, farmid) {
	new str[128];
	format(str, sizeof(str), "INSERT INTO `farm_employe` SET `Name`='%s', `Farm`='%d', `Time`=UNIX_TIMESTAMP()", NormalName(playerid), FarmData[farmid][farmID]);
	mysql_tquery(g_iHandle, str);
	return 1;
}

Farm_RemoveEmployee(id)
{
	new query[200];
	format(query,sizeof(query),"DELETE FROM `farm_employe` WHERE `ID`='%d'", id);
	mysql_tquery(g_iHandle, query);
	return 1;
}

Farm_RemoveAllEmployees(id)
{
	new query[200];
	format(query,sizeof(query),"DELETE FROM `farm_employe` WHERE `Farm`='%d'", FarmData[id][farmID]);
	mysql_tquery(g_iHandle, query);
	return 1;
}

Farm_EmployeeCount(farmid)
{
	new query[144], Cache: check, count;
	mysql_format(g_iHandle, query, sizeof(query), "SELECT * FROM `farm_employe` WHERE `Farm` = '%d'", FarmData[farmid][farmID]);
	check = mysql_query(g_iHandle, query);
	new result = cache_num_rows();
	if(result) {
		for(new i; i != result; i++) {
			count++;
		}
	}
	cache_delete(check);
	return count;
}

Farm_ShowEmployees(playerid, id, type = 0)
{
	new query[255], Cache: cache;
	format(query, sizeof(query), "SELECT * FROM `farm_employe` WHERE `Farm`='%d'", FarmData[id][farmID]);
	cache = mysql_query(g_iHandle, query);

	if(!cache_num_rows()) return SendErrorMessage(playerid, "There are no one employee for this farm.");
	
	format(query, sizeof(query), "#\tName\tDate Added\n");
	for(new i; i < cache_num_rows(); i++) {
		new
      farm,
      time,
      name[24];

        cache_get_value_int(i, "ID", farm);
        cache_get_value_int(i, "Time", time);
        cache_get_value(i, "Name", name, sizeof(name));
        format(query, sizeof(query), "%s%d\t%s\t%s\n", query, farm, name, ConvertTimestamp(Time:time));
	}
	if (!type)
		Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_TABLIST_HEADERS, "Farm Employees", query, "Close", "");
	else
		Dialog_Show(playerid, FarmRemoveEmployee, DIALOG_STYLE_TABLIST_HEADERS, "Remove Employees", query, "Remove", "Close");

	cache_delete(cache);
	return 1;
}

Plant_GetName(index) {
  static
    name[24];

  switch (index) {
    case 0: format(name,sizeof(name),"Pumpkin");
    case 1: format(name,sizeof(name),"Mushroom");
    case 2: format(name,sizeof(name),"Cucumber");
    case 3: format(name,sizeof(name),"Egg Plant");
  }

  return name;
}

Seed_GetName(index) {
  static
    name[24];

  switch (index) {
    case 0: format(name,sizeof(name),"Pumpkin Seeds");
    case 1: format(name,sizeof(name),"Mushroom Seeds");
    case 2: format(name,sizeof(name),"Cucumber Seeds");
    case 3: format(name,sizeof(name),"Egg Plant Seeds");
  }

  return name;
}

SSCANF:FarmMenu(string[]) {
  if (!strcmp(string, "create", true)) return 1;
  else if (!strcmp(string, "delete", true)) return 2;
  else if (!strcmp(string, "price", true)) return 3;
  else if (!strcmp(string, "sell", true)) return 4;
  else if (!strcmp(string, "location", true)) return 5;
  else if (!strcmp(string, "goto", true)) return 6;
  return 0;
}

SSCANF:FarmStorage(string[]) {
  if (!strcmp(string, "ps", true)) return 1;
  else if (!strcmp(string, "ms", true)) return 2;
  else if (!strcmp(string, "cs", true)) return 3;
  else if (!strcmp(string, "es", true)) return 4;
  else if (!strcmp(string, "p", true)) return 5;
  else if (!strcmp(string, "m", true)) return 6;
  else if (!strcmp(string, "c", true)) return 7;
  else if (!strcmp(string, "e", true)) return 8;
  return 0;
}

CMD:stfarm(playerid, params[]) {
  if (CheckAdmin(playerid, 5))
    return PermissionError(playerid);

  new opt, value[64];
  if (sscanf(params, "k<FarmStorage>S()[64]", opt, value))
    return SendSyntaxMessage(playerid, "/stfarm [ps/ms/cs/es/Space/p/m/c/e]");

  switch (opt) {
    case 1: {
      new farmid, ps;

      if (sscanf(value, "dd", farmid, ps))
        return SendSyntaxMessage(playerid, "/stfarm ps [farm id] [amount]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmSeeds][0] = ps;
      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been set the Pumpkin Seeds of private farm id: "YELLOW"%d "WHITE"to "RED"%d", farmid, ps);
    }
    case 2: {
      new farmid, ms;

      if (sscanf(value, "dd", farmid, ms))
        return SendSyntaxMessage(playerid, "/stfarm ms [farm id] [amount]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmSeeds][1] = ms;
      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been set the Mushroom Seeds of private farm id: "YELLOW"%d "WHITE"to "RED"%d", farmid, ms);
    }
    case 3: {
      new farmid, cs;

      if (sscanf(value, "dd", farmid, cs))
        return SendSyntaxMessage(playerid, "/stfarm cs [farm id] [amount]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmSeeds][2] = cs;
      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been set the Cocaine Seeds of private farm id: "YELLOW"%d "WHITE"to "RED"%d", farmid, cs);
    }
    case 4: {
      new farmid, es;

      if (sscanf(value, "dd", farmid, es))
        return SendSyntaxMessage(playerid, "/stfarm es [farm id] [amount]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmSeeds][3] = es;
      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been set the Eggplant Seeds of private farm id: "YELLOW"%d "WHITE"to "RED"%d", farmid, es);
    }
    case 5: {
      new farmid, p;

      if (sscanf(value, "dd", farmid, p))
        return SendSyntaxMessage(playerid, "/stfarm p [farm id] [amount]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmPlant][0] = p;
      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been set the Pumpkin of private farm id: "YELLOW"%d "WHITE"to "RED"%d", farmid, p);
    }
    case 6: {
      new farmid, m;

      if (sscanf(value, "dd", farmid, m))
        return SendSyntaxMessage(playerid, "/stfarm m [farm id] [amount]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmPlant][1] = m;
      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been set the Mushroom of private farm id: "YELLOW"%d "WHITE"to "RED"%d", farmid, m);
    }
    case 7: {
      new farmid, c;

      if (sscanf(value, "dd", farmid, c))
        return SendSyntaxMessage(playerid, "/stfarm c [farm id] [amount]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmPlant][2] = c;
      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been set the Cocaine of private farm id: "YELLOW"%d "WHITE"to "RED"%d", farmid, c);
    }
    case 8: {
      new farmid, e;

      if (sscanf(value, "dd", farmid, e))
        return SendSyntaxMessage(playerid, "/stfarm e [farm id] [amount]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmPlant][3] = e;
      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been set the Eggplant of private farm id: "YELLOW"%d "WHITE"to "RED"%d", farmid, e);
    }
    default: SendSyntaxMessage(playerid, "/farm [create/delete/price/sell/location/goto]");
  }
  return 1;
}

CMD:farm(playerid, params[]) {
  if (CheckAdmin(playerid, 10))
    return PermissionError(playerid);

  new opt, value[64];
  if (sscanf(params, "k<FarmMenu>S()[64]", opt, value))
    return SendSyntaxMessage(playerid, "/farm [create/delete/price/sell/location/goto]");

  switch (opt) {
    case 1: {
      new farmid = cellmin, Float:x, Float:y, Float:z, price;

      if (sscanf(value, "d", price))
        return SendSyntaxMessage(playerid, "/farm create [price]");
      
      GetPlayerPos(playerid, x, y, z);
      farmid = Farm_Create(price, x, y, z);

      SendCustomMessage(playerid, "FARM", "You've been successfully created private farm id: "YELLOW"%d", farmid);
    }
    case 2: {
      new farmid;

      if (sscanf(value, "d", farmid))
        return SendSyntaxMessage(playerid, "/farm delete [farm id]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      Farm_Delete(farmid);
      SendCustomMessage(playerid, "FARM", "You've been deleted private farm id: "YELLOW"%d", farmid);
    }
    case 3: {
      new farmid, newprice;

      if (sscanf(value, "dd", farmid, newprice))
        return SendSyntaxMessage(playerid, "/farm price [farm id] [new price]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmPrice] = newprice;
      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been changed the price of private farm id: "YELLOW"%d "WHITE"to "GREEN"%s", farmid, FormatNumber(newprice));
    }
    case 4: {
      new farmid;

      if (sscanf(value, "d", farmid))
        return SendSyntaxMessage(playerid, "/farm sell [farm id]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      FarmData[farmid][farmOwner] = 0;
      format(FarmData[farmid][farmOwnerName], MAX_PLAYER_NAME, "None");
      format(FarmData[farmid][farmName], 32, "Private Farm");
      FarmData[farmid][farmPlant][0] = 0;
      FarmData[farmid][farmPlant][1] = 0;
      FarmData[farmid][farmPlant][2] = 0;
      FarmData[farmid][farmPlant][3] = 0;
      FarmData[farmid][farmSeeds][0] = 0;
      FarmData[farmid][farmSeeds][1] = 0;
      FarmData[farmid][farmSeeds][2] = 0;
      FarmData[farmid][farmSeeds][3] = 0;

      Farm_RemoveAllEmployees(farmid);

      Farm_Refresh(farmid);
      Farm_Save(farmid);

      SendCustomMessage(playerid, "FARM", "You've been sold the private farm id: "YELLOW"%d", farmid);
    }
    case 5: {
      new farmid;

      if (sscanf(value, "d", farmid))
        return SendSyntaxMessage(playerid, "/farm location [farm id]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      new Float:x, Float:y, Float:z;
      GetPlayerPos(playerid, x, y, z);
      FarmData[farmid][farmPos][0] = x;
      FarmData[farmid][farmPos][1] = y;
      FarmData[farmid][farmPos][2] = z;
      Farm_Refresh(farmid);
      Farm_Save(farmid);
      SendCustomMessage(playerid, "FARM", "You've been changed location of farm id: "YELLOW"%d", farmid);
    }
    case 6: {
      new farmid;

      if (sscanf(value, "d", farmid))
        return SendSyntaxMessage(playerid, "/farm goto [farm id]");

      if (!Iter_Contains(Farms, farmid))
        return SendErrorMessage(playerid, "Invalid private farm ID!");

      SetPlayerPos(playerid, FarmData[farmid][farmPos][0],FarmData[farmid][farmPos][1],FarmData[farmid][farmPos][2]);
      SetPlayerVirtualWorld(playerid, 0);
      SetPlayerInterior(playerid, 0);
      SendCustomMessage(playerid, "FARM", "You've been teleported to farm id: "YELLOW"%d", farmid);
    }
    default: SendSyntaxMessage(playerid, "/farm [create/delete/price/sell/location/goto]");
  }
  return 1;
}

CMD:farmmenu(playerid) {
  new id = -1;
  if ((id = Farm_Nearest(playerid)) != -1) {
    if (!Farm_IsOwner(playerid, id) && !Farm_IsEmployee(playerid, id))
      return SendErrorMessage(playerid, "This is not your farm or you're not employee members of this farm!");

    if (FarmData[id][farmSeal])
      return SendErrorMessage(playerid, "This farm is sealed by authority.");

    if (Farm_IsOwner(playerid, id)) Dialog_Show(playerid, FarmMenu, DIALOG_STYLE_LIST, sprintf("%s", FarmData[id][farmName]), "Plants\nSeeds\nGive\nEmployees\nChange Name\nVault", "Select", "Close"), SetPVarInt(playerid, "holdingFarmID", id);
    else Dialog_Show(playerid, FarmMenu, DIALOG_STYLE_LIST, sprintf("%s", FarmData[id][farmName]), "Plants\nSeeds\nVault", "Select", "Close"), SetPVarInt(playerid, "holdingFarmID", id);
  } else SendErrorMessage(playerid, "You're not nearest in any private farm or inside any private farm");
  return 1;
}
CMD:fm(playerid)
  return cmd_farmmenu(playerid);

Dialog:FarmMenu(playerid, response, listitem, inputtext[]) {
  if (response) {
    new id = GetPVarInt(playerid, "holdingFarmID");
    switch (listitem) {
      case 0: {
        new string[512];
        strcat(string, "Plant\tAmount\n");
        strcat(string, sprintf("Pumpkin\t%d gram(s)\n", FarmData[id][farmPlant][0]));
        strcat(string, sprintf("Mushroom\t%d gram(s)\n", FarmData[id][farmPlant][1]));
        strcat(string, sprintf("Cucumber\t%d gram(s)\n", FarmData[id][farmPlant][2]));
        strcat(string, sprintf("Egg Plant\t%d gram(s)", FarmData[id][farmPlant][3]));
        Dialog_Show(playerid, FarmPlant, DIALOG_STYLE_TABLIST_HEADERS, "Farm Plants", string, "Select", "Back");
      }
      case 1: {
        new string[512];
        strcat(string, "Seed\tAmount\n");
        strcat(string, sprintf("Pumpkin Seed\t%d gram(s)\n", FarmData[id][farmSeeds][0]));
        strcat(string, sprintf("Mushroom Seed\t%d gram(s)\n", FarmData[id][farmSeeds][1]));
        strcat(string, sprintf("Cucumber Seed\t%d gram(s)\n", FarmData[id][farmSeeds][2]));
        strcat(string, sprintf("Egg Plant Seed\t%d gram(s)", FarmData[id][farmSeeds][3]));
        Dialog_Show(playerid, FarmSeeds, DIALOG_STYLE_TABLIST_HEADERS, "Farm Seeds", string, "Select", "Back");
      }
      case 2: {
        if (Farm_IsOwner(playerid, id)) Dialog_Show(playerid, FarmGive, DIALOG_STYLE_INPUT, "Farm Transfer Ownership", "Please input the playerid or name to giving your private farm: "GREEN"(input below)", "Give", "Back");
        else Dialog_Show(playerid, FarmVault, DIALOG_STYLE_LIST, "Farm Vault", "Deposit", "Select", "Back");
      }
      case 3: {
        Dialog_Show(playerid, FarmShowEmployees, DIALOG_STYLE_LIST, "Employees Management", "Add Employee\nRemove Employee\nRemove All Employees\nEmployee Members", "Select", "Back");
      }
      case 4: {
        Dialog_Show(playerid, FarmChangeName, DIALOG_STYLE_INPUT, "Farm Change Name", "Please input the new your farmer name: "GREEN"(input below)", "Change", "Back");
      }
      case 5: {
        Dialog_Show(playerid, FarmVault, DIALOG_STYLE_LIST, "Farm Vault", "Deposit\nWithdraw", "Select", "Back");
      }
    }
  } else DeletePVar(playerid, "holdingFarmID");
  return 1;
}

Dialog:FarmPlant(playerid, response, listitem, inputtext[]) {
  if (!response)
    return cmd_farmmenu(playerid);

  SetPVarInt(playerid, "holdingPlantIndex", listitem);
  Dialog_Show(playerid, FarmPlantOption, DIALOG_STYLE_LIST, "Plant Option", "Store Plant\nTake Plant", "Select", "Close");
  return 1;
}

Dialog:FarmSeeds(playerid, response, listitem, inputtext[]) {
  if (!response)
    return cmd_farmmenu(playerid);

  SetPVarInt(playerid, "holdingSeedIndex", listitem);
  Dialog_Show(playerid, FarmSeedsOption, DIALOG_STYLE_LIST, "Seed Option", "Store Seed\nTake Seed", "Select", "Close");
  return 1;
}

Dialog:FarmSeedsOption(playerid, response, listitem, inputtext[]) {
  if (!response) DeletePVar(playerid, "holdingFarmID"), DeletePVar(playerid, "holdingSeedIndex");
  else {
    new id = GetPVarInt(playerid, "holdingFarmID"), plantIndex = GetPVarInt(playerid, "holdingSeedIndex"), plantName[24];
    format(plantName,sizeof(plantName),"%s",Seed_GetName(plantIndex));
    switch (listitem) {
      case 0: {
        if (!Inventory_Count(playerid, plantName))
          return SendErrorMessage(playerid, "You don't have any %s", plantName);

        if (FarmData[id][farmSeeds][plantIndex] >= MAX_PLANTS_STORAGE)
          return SendErrorMessage(playerid, "This farm is already have a maximum of "YELLOW"%s"WHITE", the maximum seeds is "YELLOW"%d grams", plantName, MAX_PLANTS_STORAGE);

        Dialog_Show(playerid, StoreSeedFarm, DIALOG_STYLE_INPUT, "Store Seeds", "Please input the amount of %s wish you store on farm, you have %d gram(s) of %s: "GREEN"(input below)", "Store", "Close", plantName, Inventory_Count(playerid, plantName), plantName);
      }
      case 1: {
        if (!FarmData[id][farmSeeds][plantIndex])
          return SendErrorMessage(playerid, "Your farm doesn't have any %s", plantName);

        Dialog_Show(playerid, TakeSeedFarm, DIALOG_STYLE_INPUT, "Take Plant", "Please input the amount of %s wish you want to take, your farm have %d gram(s) of %s: "GREEN"(input below)", "Take", "Close", plantName, FarmData[id][farmSeeds][plantIndex], plantName);
      }
    }
  }
  return 1;
}

Dialog:StoreSeedFarm(playerid, response, listitem, inputtext[]) {
  if (!response) DeletePVar(playerid, "holdingFarmID"), DeletePVar(playerid, "holdingSeedIndex");
  else {
    new id = GetPVarInt(playerid, "holdingFarmID"), plantIndex = GetPVarInt(playerid, "holdingSeedIndex"), plantName[24];
    format(plantName,sizeof(plantName),"%s",Seed_GetName(plantIndex));

    if (isnull(inputtext))
      return Dialog_Show(playerid, StoreSeedFarm, DIALOG_STYLE_INPUT, "Store Seeds", "Please input the amount of %s wish you store on farm, you have %d gram(s) of %s: "GREEN"(input below)", "Store", "Close", plantName, Inventory_Count(playerid, plantName), plantName);

    new amount = strval(inputtext), plantCount = Inventory_Count(playerid, plantName);
    
    if (amount < 1 || amount > plantCount)
      return Dialog_Show(playerid, StoreSeedFarm, DIALOG_STYLE_INPUT, "Store Seeds", "Please input the amount of %s wish you store on farm, you have %d gram(s) of %s: "GREEN"(input below)", "Store", "Close", plantName, Inventory_Count(playerid, plantName), plantName), SendErrorMessage(playerid, "You don't have that much!");

    FarmData[id][farmSeeds][plantIndex] += amount;
    Inventory_Remove(playerid, plantName, amount);
    SendCustomMessage(playerid, "FARM", "You've been stored "YELLOW"%d gram(s) "WHITE"of "GREEN"%s "WHITE"to your farm storage", amount, plantName);
  }
  return 1;
}

Dialog:TakeSeedFarm(playerid, response, listitem, inputtext[]) {
  if (!response) DeletePVar(playerid, "holdingFarmID"), DeletePVar(playerid, "holdingSeedIndex");
  else {
    new id = GetPVarInt(playerid, "holdingFarmID"), plantIndex = GetPVarInt(playerid, "holdingSeedIndex"), plantName[24];
    format(plantName,sizeof(plantName),"%s",Seed_GetName(plantIndex));

    if (isnull(inputtext))
      return Dialog_Show(playerid, TakeSeedFarm, DIALOG_STYLE_INPUT, "Take Seeds", "Please input the amount of %s wish you want to take, your farm have %d gram(s) of %s: "GREEN"(input below)", "Take", "Close", plantName, FarmData[id][farmSeeds][plantIndex], plantName);

    new amount = strval(inputtext), plantCount = FarmData[id][farmSeeds][plantIndex];
    
    if (amount < 1 || amount > plantCount)
      return Dialog_Show(playerid, TakeSeedFarm, DIALOG_STYLE_INPUT, "Take Seeds", "Please input the amount of %s wish you want to take, your farm have %d gram(s) of %s: "GREEN"(input below)", "Take", "Close", plantName, FarmData[id][farmSeeds][plantIndex], plantName), SendErrorMessage(playerid, "Your farm don't have that much");

    new itemid = Inventory_Add(playerid, plantName, 19320, amount);

    if(itemid == -1)
        return SendErrorMessage(playerid, "You don't have any room in your inventory.");

    FarmData[id][farmSeeds][plantIndex] -= amount;

    SendCustomMessage(playerid, "FARM", "You've been taken "YELLOW"%d gram(s) "WHITE"of "GREEN"%s "WHITE"from your farm storage", amount, plantName);
  }
  return 1;
}

Dialog:FarmPlantOption(playerid, response, listitem, inputtext[]) {
  if (!response) DeletePVar(playerid, "holdingFarmID"), DeletePVar(playerid, "holdingPlantIndex");
  else {
    new id = GetPVarInt(playerid, "holdingFarmID"), plantIndex = GetPVarInt(playerid, "holdingPlantIndex"), plantName[24];
    format(plantName,sizeof(plantName),"%s",Plant_GetName(plantIndex));
    switch (listitem) {
      case 0: {
        if (!Inventory_Count(playerid, plantName))
          return SendErrorMessage(playerid, "You don't have any %s", plantName);

        if (FarmData[id][farmPlant][plantIndex] >= MAX_PLANTS_STORAGE)
          return SendErrorMessage(playerid, "This farm is already have a maximum of "YELLOW"%s"WHITE", the maximum plants is "YELLOW"%d grams", plantName, MAX_PLANTS_STORAGE);

        Dialog_Show(playerid, StorePlantFarm, DIALOG_STYLE_INPUT, "Store Plant", "Please input the amount of %s wish you store on farm, you have %d gram(s) of %s: "GREEN"(input below)", "Store", "Close", plantName, Inventory_Count(playerid, plantName), plantName);
      }
      case 1: {
        if (!FarmData[id][farmPlant][plantIndex])
          return SendErrorMessage(playerid, "Your farm doesn't have any %s", plantName);

        Dialog_Show(playerid, TakePlantFarm, DIALOG_STYLE_INPUT, "Take Plant", "Please input the amount of %s wish you want to take, your farm have %d gram(s) of %s: "GREEN"(input below)", "Take", "Close", plantName, FarmData[id][farmPlant][plantIndex], plantName);
      }
    }
  }
  return 1;
}

Dialog:StorePlantFarm(playerid, response, listitem, inputtext[]) {
  if (!response) DeletePVar(playerid, "holdingFarmID"), DeletePVar(playerid, "holdingPlantIndex");
  else {
    new id = GetPVarInt(playerid, "holdingFarmID"), plantIndex = GetPVarInt(playerid, "holdingPlantIndex"), plantName[24];
    format(plantName,sizeof(plantName),"%s",Plant_GetName(plantIndex));

    if (isnull(inputtext))
      return Dialog_Show(playerid, StorePlantFarm, DIALOG_STYLE_INPUT, "Store Plant", "Please input the amount of %s wish you store on farm, you have %d gram(s) of %s: "GREEN"(input below)", "Store", "Close", plantName, Inventory_Count(playerid, plantName), plantName);

    new amount = strval(inputtext), plantCount = Inventory_Count(playerid, plantName);
    
    if (amount < 1 || amount > plantCount)
      return Dialog_Show(playerid, StorePlantFarm, DIALOG_STYLE_INPUT, "Store Plant", "Please input the amount of %s wish you store on farm, you have %d gram(s) of %s: "GREEN"(input below)", "Store", "Close", plantName, Inventory_Count(playerid, plantName), plantName), SendErrorMessage(playerid, "You don't have that much!");

    FarmData[id][farmPlant][plantIndex] += amount;
    Inventory_Remove(playerid, plantName, amount);
    SendCustomMessage(playerid, "FARM", "You've been stored "YELLOW"%d gram(s) "WHITE"of "GREEN"%s "WHITE"to your farm storage", amount, plantName);
  }
  return 1;
}

Dialog:TakePlantFarm(playerid, response, listitem, inputtext[]) {
  if (!response) DeletePVar(playerid, "holdingFarmID"), DeletePVar(playerid, "holdingPlantIndex");
  else {
    new id = GetPVarInt(playerid, "holdingFarmID"), plantIndex = GetPVarInt(playerid, "holdingPlantIndex"), plantName[24];
    format(plantName,sizeof(plantName),"%s",Plant_GetName(plantIndex));

    if (isnull(inputtext))
      return Dialog_Show(playerid, TakePlantFarm, DIALOG_STYLE_INPUT, "Take Plant", "Please input the amount of %s wish you want to take, your farm have %d gram(s) of %s: "GREEN"(input below)", "Take", "Close", plantName, FarmData[id][farmPlant][plantIndex], plantName);

    new amount = strval(inputtext), plantCount = FarmData[id][farmPlant][plantIndex];
    
    if (amount < 1 || amount > plantCount)
      return Dialog_Show(playerid, TakePlantFarm, DIALOG_STYLE_INPUT, "Take Plant", "Please input the amount of %s wish you want to take, your farm have %d gram(s) of %s: "GREEN"(input below)", "Take", "Close", plantName, FarmData[id][farmPlant][plantIndex], plantName), SendErrorMessage(playerid, "Your farm doesn't have that much");

    new itemid = Inventory_Add(playerid, plantName, 19320, amount);

    if(itemid == -1)
        return SendErrorMessage(playerid, "You don't have any room in your inventory.");

    FarmData[id][farmPlant][plantIndex] -= amount;

    SendCustomMessage(playerid, "FARM", "You've been taken "YELLOW"%d gram(s) "WHITE"of "GREEN"%s "WHITE"from your farm storage", amount, plantName);
  }
  return 1;
}

Dialog:FarmGive(playerid, response, listitem, inputtext[]) {
  if (!response)
    return cmd_farmmenu(playerid);

  new userid;
  if (sscanf(inputtext, "u", userid))
    return Dialog_Show(playerid, FarmGive, DIALOG_STYLE_INPUT, "Farm Transfer Ownership", "Please input the playerid or name to giving your private farm: "GREEN"(input below)", "Give", "Back");

  if (userid == INVALID_PLAYER_ID)
    return SendErrorMessage(playerid, "Invalid playerid or name!");

  if (userid == playerid)
    return SendErrorMessage(playerid, "You can't giving your farm to yourself!");

  if (!IsPlayerNearPlayer(playerid, userid, 3.0))
    return SendErrorMessage(playerid, "You are not nearest with that player!");
  
  if(!PlayerData[userid][pFarmLicenseExpired])
    return SendErrorMessage(playerid, "That player don't have farm licenses.");
  
  SetPVarInt(playerid, "holdingUserID", userid);
  Dialog_Show(playerid, FarmGiveConfirm, DIALOG_STYLE_MSGBOX, "Giving Confirmation", "Are you sure want to transfer your farm ownership to "YELLOW"%s?", "Sure", "Close", NormalName(userid));
  return 1;
}

Dialog:FarmGiveConfirm(playerid, response, listitem, inputtext[]) {
  if (response) {
    new id = GetPVarInt(playerid, "holdingFarmID"), userid = GetPVarInt(playerid, "holdingUserID");

    if (!PlayerData[userid][pStory])
      return SendErrorMessage(playerid, "That player must have accepted character story to owning any property");

    if (Farm_GetCount(userid))
      return SendErrorMessage(playerid, "That player has already have private farm!");

    FarmData[id][farmOwner] = PlayerData[userid][pID];
    format(FarmData[id][farmOwnerName], MAX_PLAYER_NAME, "%s", NormalName(userid));

    Farm_RemoveAllEmployees(id);

    Farm_Refresh(id);
    Farm_Save(id);
    SendCustomMessage(playerid, "FARM", "You've been transfered your private farm to "YELLOW"%s", NormalName(userid));
    SendCustomMessage(userid, "FARM", YELLOW"%s "WHITE"has transfered their private farm to you", NormalName(playerid));
  }
  return 1;
}

Dialog:FarmShowEmployees(playerid, response, listitem, inputtext[]) {
  if (!response)
    return cmd_farmmenu(playerid);

  new id = GetPVarInt(playerid, "holdingFarmID");
  switch (listitem) {
    case 0: {
      Dialog_Show(playerid, FarmAddEmployee, DIALOG_STYLE_INPUT, "Farm Add Employee", "Please input playerid or name whis you want hired as your employee: "GREEN"(input below)", "Hire", "Close");
    }
    case 1: {
      Farm_ShowEmployees(playerid, id, 1);
    }
    case 2: {
      Farm_RemoveAllEmployees(id);
      SendCustomMessage(playerid, "FARM", "You've been fired all your employees");
    }
    case 3: {
      Farm_ShowEmployees(playerid, id, 0);
    }
  }
  return 1;
}

Dialog:FarmAddEmployee(playerid, response, listitem, inputtext[]) {
  if (response) {
    new userid, id = GetPVarInt(playerid, "holdingFarmID");

    if (Farm_EmployeeCount(id) >= 10)
      return SendErrorMessage(playerid, "This Farm is limited 10 employees.");

    if (sscanf(inputtext, "u", userid))
      return Dialog_Show(playerid, FarmAddEmployee, DIALOG_STYLE_INPUT, "Farm Add Employee", "Please input playerid or name whis you want hired as your employee: "GREEN"(input below)", "Hire", "Close");

    if (userid == INVALID_PLAYER_ID)
      return Dialog_Show(playerid, FarmAddEmployee, DIALOG_STYLE_INPUT, "Farm Add Employee", "Please input playerid or name whis you want hired as your employee: "GREEN"(input below)", "Hire", "Close"), SendErrorMessage(playerid, "Invalid playerid or name!");

    if (userid == playerid)
      return Dialog_Show(playerid, FarmAddEmployee, DIALOG_STYLE_INPUT, "Farm Add Employee", "Please input playerid or name whis you want hired as your employee: "GREEN"(input below)", "Hire", "Close"), SendErrorMessage(playerid, "You doesn't hire yourself");

    if (Farm_IsEmployee(userid, id))
      return Dialog_Show(playerid, FarmAddEmployee, DIALOG_STYLE_INPUT, "Farm Add Employee", "Please input playerid or name whis you want hired as your employee: "GREEN"(input below)", "Hire", "Close"), SendErrorMessage(playerid, "That player is already employee of your farm");

    Farm_AddEmployee(userid, id);
    SendCustomMessage(playerid, "FARM", "You've been hired "YELLOW"%s "WHITE"as your farm employee", NormalName(userid));
    SendCustomMessage(userid, "FARM", YELLOW"%s "WHITE"has hired you as employee of his farm", NormalName(playerid));
  }
  return 1;
}

Dialog:FarmRemoveEmployee(playerid, response, listitem, inputtext[]) {
  if (response) {
    Farm_RemoveEmployee(strval(inputtext));
    SendCustomMessage(playerid,"FARM","You've remove list employe number #%d from your farm.", strval(inputtext));
  }
  return 1;
}

Dialog:FarmChangeName(playerid, response, listitem, inputtext[]) {
  if (response) {
    new id = GetPVarInt(playerid, "holdingFarmID");

    if (isnull(inputtext))
      return Dialog_Show(playerid, FarmChangeName, DIALOG_STYLE_INPUT, "Farm Change Name", "Please input the new your farmer name: "GREEN"(input below)", "Change", "Back");

    if (strlen(inputtext) > 32)
      return Dialog_Show(playerid, FarmChangeName, DIALOG_STYLE_INPUT, "Farm Change Name", "Please input the new your farmer name: "GREEN"(input below)", "Change", "Back"), SendErrorMessage(playerid, "Max farm name is 24 characters");

    format(FarmData[id][farmName], 32, "%s", ColouredText(inputtext));
    Farm_Refresh(id);
    Farm_Save(id);

    SendCustomMessage(playerid, "FARM", "You've been changed your farm name to "YELLOW"%s", FarmData[id][farmName]);
  }
  return 1;
}

Dialog:FarmVault(playerid, response, listitem, inputtext[]) {
  if (!response)
    return cmd_farmmenu(playerid), DeletePVar(playerid, "holdingFarmID");

  new id = GetPVarInt(playerid, "holdingFarmID");
  switch (listitem) {
    case 0: {
      Dialog_Show(playerid, FarmDeposit, DIALOG_STYLE_INPUT, "Farm Deposit Vault", "Please input the money wish you want to deposit to vault: "GREEN"(input below)\n"WHITE"Current balance: "GREEN"%s", "Deposit", "Back", FormatNumber(FarmData[id][farmMoney]));
    }
    case 1: {
      if (!Farm_IsOwner(playerid, id))
        return SendErrorMessage(playerid, "You don't have permission to access this option.");
      
      Dialog_Show(playerid, FarmWithdraw, DIALOG_STYLE_INPUT, "Farm Withdraw Vault", "Please input the money wish you want to withdraw from vault: "GREEN"(input below)\n"WHITE"Current balance: "GREEN"%s", "Withdraw", "Back", FormatNumber(FarmData[id][farmMoney]));
    }
  }
  return 1;
}

Dialog:FarmDeposit(playerid, response, listitem, inputtext[]) {
  if (response) {
    new id = GetPVarInt(playerid, "holdingFarmID"), money;

    if (isnull(inputtext))
      return Dialog_Show(playerid, FarmDeposit, DIALOG_STYLE_INPUT, "Farm Deposit Vault", "Please input the money wish you want to deposit to vault: "GREEN"(input below)", "Deposit", "Back");

    if (sscanf(inputtext, "d", money))
      return Dialog_Show(playerid, FarmDeposit, DIALOG_STYLE_INPUT, "Farm Deposit Vault", "Please input the money wish you want to deposit to vault: "GREEN"(input below)", "Deposit", "Back");
      
    new
		totalcash[25];
	format(totalcash, sizeof(totalcash), "%d00", money);
    
    if (strval(totalcash) < 1)
      return Dialog_Show(playerid, FarmDeposit, DIALOG_STYLE_INPUT, "Farm Deposit Vault", "Please input the money wish you want to deposit to vault: "GREEN"(input below)", "Deposit", "Back"), SendErrorMessage(playerid, "You can't deposit less than $1.00");
    
    if (GetMoney(playerid) < strval(totalcash))
      return Dialog_Show(playerid, FarmDeposit, DIALOG_STYLE_INPUT, "Farm Deposit Vault", "Please input the money wish you want to deposit to vault: "GREEN"(input below)", "Deposit", "Back"), SendErrorMessage(playerid, "You don't have enough money");
    
    FarmData[id][farmMoney] += strval(totalcash);
    GiveMoney(playerid, -strval(totalcash));
    Farm_Save(id);
    SendCustomMessage(playerid, "FARM", "You've deposited "GREEN"$%s "WHITE"to your farm vault, current balance: "GREEN"$%s", FormatNumber(strval(totalcash)), FormatNumber(FarmData[id][farmMoney]));
  } else DeletePVar(playerid, "holdingFarmID"), cmd_farmmenu(playerid);
  return 1;
}

Dialog:FarmWithdraw(playerid, response, listitem, inputtext[]) {
  if (response) {
    new id = GetPVarInt(playerid, "holdingFarmID"), money;

    if (isnull(inputtext))
      return Dialog_Show(playerid, FarmWithdraw, DIALOG_STYLE_INPUT, "Farm Withdraw Vault", "Please input the money wish you want to withdraw from vault: "GREEN"(input below)", "Withdraw", "Back");
    
    if (sscanf(inputtext, "d", money))
      return Dialog_Show(playerid, FarmWithdraw, DIALOG_STYLE_INPUT, "Farm Withdraw Vault", "Please input the money wish you want to withdraw from vault: "GREEN"(input below)", "Withdraw", "Back");
      
    new
		totalcash[25];
	format(totalcash, sizeof(totalcash), "%d00", money);
    
    if (strval(totalcash) < 1)
      return Dialog_Show(playerid, FarmWithdraw, DIALOG_STYLE_INPUT, "Farm Withdraw Vault", "Please input the money wish you want to withdraw from vault: "GREEN"(input below)", "Withdraw", "Back"), SendErrorMessage(playerid, "You can't withdraw less than 1$");
    
    if (FarmData[id][farmMoney] < strval(totalcash))
      return Dialog_Show(playerid, FarmWithdraw, DIALOG_STYLE_INPUT, "Farm Withdraw Vault", "Please input the money wish you want to withdraw from vault: "GREEN"(input below)", "Withdraw", "Back"), SendErrorMessage(playerid, "You don't have enough money in your farm vault");
    
    FarmData[id][farmMoney] -= strval(totalcash);
    GiveMoney(playerid, strval(totalcash));
    Farm_Save(id);
    SendCustomMessage(playerid, "FARM", "You've withdrawed "GREEN"$%s "WHITE"from your farm vault, current balance: "GREEN"$%s", FormatNumber(strval(totalcash)), FormatNumber(FarmData[id][farmMoney]));
  } else DeletePVar(playerid, "holdingFarmID"), cmd_farmmenu(playerid);
  return 1;
}

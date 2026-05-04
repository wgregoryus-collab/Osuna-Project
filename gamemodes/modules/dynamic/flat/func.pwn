Function:Flat_Load() {
  new str[128];

  Iter_Init(Flat);
  if (cache_num_rows()) {
    for (new i = 0; i < cache_num_rows(); i ++) {
      Iter_Add(Flat, i);
      cache_get_value_int(i, "ID", FlatData[i][flatID]);
      cache_get_value(i, "Name", FlatData[i][flatName]);
      cache_get_value_int(i, "Type", FlatData[i][flatType]);
      cache_get_value_int(i, "World", FlatData[i][flatWorld]);
      cache_get_value_int(i, "Interior", FlatData[i][flatInterior]);
      cache_get_value_int(i, "IntWorld", FlatData[i][flatIntWorld]);
      cache_get_value_int(i, "IntInterior", FlatData[i][flatIntInterior]);

      cache_get_value(i, "Position", str);
      sscanf(str, "p<|>fff", FlatData[i][flatPos][0], FlatData[i][flatPos][1], FlatData[i][flatPos][2]);

      cache_get_value(i, "IntPosition", str);
      sscanf(str, "p<|>fff", FlatData[i][flatIntPos][0], FlatData[i][flatIntPos][1], FlatData[i][flatIntPos][2]);

      cache_get_value(i, "GaragePos", str);
      sscanf(str, "p<|>fff", FlatData[i][flatGaragePos][0], FlatData[i][flatGaragePos][1], FlatData[i][flatGaragePos][2]);

      Flat_Refresh(i);
    }
  }
  printf("*** [GarudaPride Database: Loaded] flat data loaded (%d count)", cache_num_rows());
  return 1;
}

Function:FlatRoom_Load() {
  new str[128];

  Iter_Init(FlatRooms);
  if (cache_num_rows()) {
    for (new i = 0; i < cache_num_rows(); i ++) {
      Iter_Add(FlatRooms, i);

      cache_get_value_int(i, "ID", FlatRoom[i][flatRoomID]);
      cache_get_value_int(i, "FlatID", FlatRoom[i][flatID]);
      cache_get_value_int(i, "Owner", FlatRoom[i][flatRoomOwner]);
      cache_get_value_int(i, "Locked", FlatRoom[i][flatRoomLocked]);
      cache_get_value_int(i, "Price", FlatRoom[i][flatRoomPrice]);
      cache_get_value_int(i, "World", FlatRoom[i][flatRoomWorld]);
      cache_get_value_int(i, "Interior", FlatRoom[i][flatRoomInterior]);
      cache_get_value_int(i, "Seal", FlatRoom[i][flatRoomSeal]);
      cache_get_value_int(i, "Money", FlatRoom[i][flatRoomMoney]);
      cache_get_value_int(i, "LastVisited", FlatRoom[i][flatRoomLastVisited]);
      
      cache_get_value(i, "Builder", str);
      sscanf(str, "p<|>dd", FlatRoom[i][flatRoomBuilder], FlatRoom[i][flatRoomBuilderTime]);

      cache_get_value(i, "Position", str);
      sscanf(str, "p<|>fff", FlatRoom[i][flatRoomPos][0], FlatRoom[i][flatRoomPos][1], FlatRoom[i][flatRoomPos][2]);

      cache_get_value(i, "AreaPos", str);
      sscanf(str, "p<|>fffff", FlatRoom[i][flatRoomAreaPos][0], FlatRoom[i][flatRoomAreaPos][1], FlatRoom[i][flatRoomAreaPos][2], FlatRoom[i][flatRoomAreaPos][3], FlatRoom[i][flatRoomAreaPos][4]);

      FlatRoom_Refresh(i);
    }

    foreach (new flatroom : FlatRooms) {
      mysql_tquery(g_iHandle, sprintf("SELECT * FROM `flat_weapon` WHERE `flatroomid` = '%d' ORDER BY `id` DESC LIMIT 3;", FlatRoom[flatroom][flatRoomID]), "OnFlatLoadWeapon", "d", flatroom);
  
      mysql_tquery(g_iHandle, sprintf("SELECT * FROM `flat_storage` WHERE `ID` = '%d';", FlatRoom[flatroom][flatRoomID]), "OnLoadFlatStorage", "d", flatroom);

      mysql_tquery(g_iHandle, sprintf("SELECT * FROM `flat_furniture` WHERE `Flatid` = '%d';", FlatRoom[flatroom][flatRoomID]), "OnLoadFlatFurniture", "d", flatroom);
      
      mysql_tquery(g_iHandle, sprintf("SELECT * FROM `flat_structure` WHERE `Flatid` = '%d' AND `Static`='1';", FlatRoom[flatroom][flatRoomID]), "OnLoadStaticStructure", "d", flatroom);

      mysql_tquery(g_iHandle, sprintf("SELECT * FROM `flat_structure` WHERE `Flatid` = '%d' AND `Static`='0';", FlatRoom[flatroom][flatRoomID]), "OnLoadFlatStructure", "d", flatroom);
    }
  }
  printf("*** [GarudaPride Database: Loaded] flat room data loaded (%d count)", cache_num_rows());
  return 1;
}

Flat_GetType(flatid, dest[], len = sizeof(dest)) {
  if (Iter_Contains(Flat, flatid)) {
    switch (FlatData[flatid][flatType]) {
      case FLAT_TYPE_NONE: format(dest,len,"Unknown");
      case FLAT_TYPE_LOW: format(dest,len,"Low");
      case FLAT_TYPE_MEDIUM: format(dest,len,"Medium");
      case FLAT_TYPE_HIGH: format(dest,len,"High");
    }
  }
}

Flat_GetType2(type, dest[], len = sizeof(dest)) {
  switch (type) {
    case FLAT_TYPE_NONE: format(dest,len,"Unknown");
    case FLAT_TYPE_LOW: format(dest,len,"Low");
    case FLAT_TYPE_MEDIUM: format(dest,len,"Medium");
    case FLAT_TYPE_HIGH: format(dest,len,"High");
  }
}

Flat_Refresh(flatid) {
  if (!Iter_Contains(Flat, flatid))
    return 0;
  
  new Float:PosX = FlatData[flatid][flatPos][0],
    Float:PosY = FlatData[flatid][flatPos][1],
    Float:PosZ = FlatData[flatid][flatPos][2],
    World = FlatData[flatid][flatWorld],
    Interior = FlatData[flatid][flatInterior];
  
  new Float:IntPosX = FlatData[flatid][flatIntPos][0],
    Float:IntPosY = FlatData[flatid][flatIntPos][1],
    Float:IntPosZ = FlatData[flatid][flatIntPos][2],
    IntWorld = FlatData[flatid][flatIntWorld],
    IntInterior = FlatData[flatid][flatIntInterior];
  
  new Float:garagePosX = FlatData[flatid][flatGaragePos][0],
    Float:garagePosY = FlatData[flatid][flatGaragePos][1],
    Float:garagePosZ = FlatData[flatid][flatGaragePos][2];
  
  new type[12];

  if (IsValidDynamicPickup(FlatData[flatid][flatGaragePickup])) {
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatGaragePickup], E_STREAMER_X, garagePosX);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatGaragePickup], E_STREAMER_Y, garagePosY);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatGaragePickup], E_STREAMER_Z, garagePosZ);
    Streamer_SetIntData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatGaragePickup], E_STREAMER_WORLD_ID, World);
    Streamer_SetIntData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatGaragePickup], E_STREAMER_INTERIOR_ID, Interior);
  } else {
    FlatData[flatid][flatGaragePickup] = CreateDynamicPickup(1239, 23, garagePosX, garagePosY, garagePosZ, World, Interior, -1, 10);
  }

  if (IsValidDynamic3DTextLabel(FlatData[flatid][flatGarageText])) {
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatGarageText], E_STREAMER_X, garagePosX);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatGarageText], E_STREAMER_Y, garagePosY);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatGarageText], E_STREAMER_Z, garagePosZ+0.5);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatGarageText], E_STREAMER_DRAW_DISTANCE, 10.0);
    Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatGarageText], E_STREAMER_TEST_LOS, 1);
    Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatGarageText], E_STREAMER_WORLD_ID, World);
    Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatGarageText], E_STREAMER_INTERIOR_ID, Interior);

    UpdateDynamic3DTextLabelText(FlatData[flatid][flatGarageText], X11_LIGHTBLUE, sprintf("[Flat Garage:%d]\n"YELLOW"%s",flatid,FlatData[flatid][flatName]));
  } else {
    FlatData[flatid][flatGarageText] = CreateDynamic3DTextLabel(sprintf("[Flat Garage:%d]\n"YELLOW"%s",flatid,FlatData[flatid][flatName]), X11_LIGHTBLUE, garagePosX, garagePosY, garagePosZ+0.5, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, World, Interior);
  }

  if (IsValidDynamicPickup(FlatData[flatid][flatPickup])) {
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatPickup], E_STREAMER_X, PosX);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatPickup], E_STREAMER_Y, PosY);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatPickup], E_STREAMER_Z, PosZ);
    Streamer_SetIntData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatPickup], E_STREAMER_WORLD_ID, World);
    Streamer_SetIntData(STREAMER_TYPE_PICKUP, FlatData[flatid][flatPickup], E_STREAMER_INTERIOR_ID, Interior);
  } else {
    FlatData[flatid][flatPickup] = CreateDynamicPickup(19130, 23, PosX, PosY, PosZ, World, Interior, -1, 10);
  }

  if (IsValidDynamicCP(FlatData[flatid][flatCPExt])) {
    Streamer_SetFloatData(STREAMER_TYPE_CP, FlatData[flatid][flatCPExt], E_STREAMER_X, PosX);
    Streamer_SetFloatData(STREAMER_TYPE_CP, FlatData[flatid][flatCPExt], E_STREAMER_Y, PosY);
    Streamer_SetFloatData(STREAMER_TYPE_CP, FlatData[flatid][flatCPExt], E_STREAMER_Z, PosZ);
    Streamer_SetFloatData(STREAMER_TYPE_CP, FlatData[flatid][flatCPExt], E_STREAMER_SIZE, 1.5);
    Streamer_SetIntData(STREAMER_TYPE_CP, FlatData[flatid][flatCPExt], E_STREAMER_WORLD_ID, World);
    Streamer_SetIntData(STREAMER_TYPE_CP, FlatData[flatid][flatCPExt], E_STREAMER_INTERIOR_ID, Interior);
  } else {
    FlatData[flatid][flatCPExt] = CreateDynamicCP(PosX, PosY, PosZ, 1.5, World, Interior, -1, 5.0);
  }

  if (IsValidDynamicCP(FlatData[flatid][flatCPInt])) {
    Streamer_SetFloatData(STREAMER_TYPE_CP, FlatData[flatid][flatCPInt], E_STREAMER_X, IntPosX);
    Streamer_SetFloatData(STREAMER_TYPE_CP, FlatData[flatid][flatCPInt], E_STREAMER_Y, IntPosY);
    Streamer_SetFloatData(STREAMER_TYPE_CP, FlatData[flatid][flatCPInt], E_STREAMER_Z, IntPosZ);
    Streamer_SetFloatData(STREAMER_TYPE_CP, FlatData[flatid][flatCPInt], E_STREAMER_SIZE, 1.5);
    Streamer_SetIntData(STREAMER_TYPE_CP, FlatData[flatid][flatCPInt], E_STREAMER_WORLD_ID, IntWorld);
    Streamer_SetIntData(STREAMER_TYPE_CP, FlatData[flatid][flatCPInt], E_STREAMER_INTERIOR_ID, IntInterior);
  } else {
    FlatData[flatid][flatCPInt] = CreateDynamicCP(IntPosX, IntPosY, IntPosZ, 1.5, IntWorld, IntInterior, -1, 5.0);
  }

  if (IsValidDynamic3DTextLabel(FlatData[flatid][flatText])) {
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatText], E_STREAMER_X, PosX);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatText], E_STREAMER_Y, PosY);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatText], E_STREAMER_Z, PosZ+0.5);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatText], E_STREAMER_DRAW_DISTANCE, 10.0);
    Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatText], E_STREAMER_TEST_LOS, 1);
    Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatText], E_STREAMER_WORLD_ID, World);
    Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, FlatData[flatid][flatText], E_STREAMER_INTERIOR_ID, Interior);

    Flat_GetType(flatid, type);
    UpdateDynamic3DTextLabelText(FlatData[flatid][flatText], COLOR_CLIENT, sprintf("[FB:%d]\n"YELLOW"%s\n"WHITE"Type: "YELLOW"%s\n"WHITE"Press '"RED"H"WHITE"' to enter/exit",flatid,FlatData[flatid][flatName],type));
  } else {
    Flat_GetType(flatid, type);

    FlatData[flatid][flatText] = CreateDynamic3DTextLabel(sprintf("[FB:%d]\n"YELLOW"%s\n"WHITE"Type: "YELLOW"%s\n"WHITE"Press '"RED"H"WHITE"' to enter/exit",flatid,FlatData[flatid][flatName],type), COLOR_CLIENT, PosX, PosY, PosZ+0.5, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, World, Interior);
  }
  return 1;
}

Flat_Save(flatid) {
  if (!Iter_Contains(Flat, flatid))
    return 0;
  
  new query[1024];
  format(query,sizeof(query),"UPDATE `flat` SET `Name`='%s', `Type`='%d', `World`='%d', `Interior`='%d', `IntWorld`='%d', `IntInterior`='%d', `Position`='%.2f|%.2f|%.2f', `IntPosition`='%.2f|%.2f|%.2f', `GaragePos`='%.2f|%.2f|%.2f' WHERE `ID`='%d'",
    SQL_ReturnEscaped(FlatData[flatid][flatName]),
    FlatData[flatid][flatType],
    FlatData[flatid][flatWorld],
    FlatData[flatid][flatInterior],
    FlatData[flatid][flatIntWorld],
    FlatData[flatid][flatIntInterior],
    FlatData[flatid][flatPos][0],
    FlatData[flatid][flatPos][1],
    FlatData[flatid][flatPos][2],
    FlatData[flatid][flatIntPos][0],
    FlatData[flatid][flatIntPos][1],
    FlatData[flatid][flatIntPos][2],
    FlatData[flatid][flatGaragePos][0],
    FlatData[flatid][flatGaragePos][1],
    FlatData[flatid][flatGaragePos][2],
    FlatData[flatid][flatID]
  );

  return mysql_tquery(g_iHandle, query);
}

Function:OnFlatCreated(flatid) {
  if (!Iter_Contains(Flat, flatid))
    return 0;
  
  FlatData[flatid][flatID] = cache_insert_id();
  Flat_Refresh(flatid);
  Flat_Save(flatid);
  return 1;
}

Flat_Create(name[], type, Float:x, Float:y, Float:z, world = 0, interior = 0) {
  new flatid = cellmin;

  if ((flatid = Iter_Free(Flat)) != cellmin) {
    Iter_Add(Flat, flatid);

    format(FlatData[flatid][flatName], 32, name);
    FlatData[flatid][flatType] = type;
    FlatData[flatid][flatWorld] = world;
    FlatData[flatid][flatInterior] = interior;
    FlatData[flatid][flatPos][0] = x;
    FlatData[flatid][flatPos][1] = y;
    FlatData[flatid][flatPos][2] = z;
    FlatData[flatid][flatIntPos][0] = FlatData[flatid][flatIntPos][1] = FlatData[flatid][flatIntPos][2] = 0.0;
    FlatData[flatid][flatIntWorld] = FlatData[flatid][flatIntInterior] = 0;

    mysql_tquery(g_iHandle, sprintf("INSERT INTO `flat` (`Type`) VALUES ('%d');", FlatData[flatid][flatType]), "OnFlatCreated", "d", flatid);
    return flatid;
  }
  return cellmin;
}

Flat_Delete(flatid){
  if (!Iter_Contains(Flat, flatid))
    return 0;
  
  if (IsValidDynamicPickup(FlatData[flatid][flatPickup]))
    DestroyDynamicPickup(FlatData[flatid][flatPickup]);

  if (IsValidDynamicPickup(FlatData[flatid][flatGaragePickup]))
    DestroyDynamicPickup(FlatData[flatid][flatGaragePickup]);
  
  if (IsValidDynamic3DTextLabel(FlatData[flatid][flatText]))
    DestroyDynamic3DTextLabel(FlatData[flatid][flatText]);

  if (IsValidDynamic3DTextLabel(FlatData[flatid][flatGarageText]))
    DestroyDynamic3DTextLabel(FlatData[flatid][flatGarageText]);
  
  if (IsValidDynamicCP(FlatData[flatid][flatCPExt]))
    DestroyDynamicCP(FlatData[flatid][flatCPExt]);
  
  if (IsValidDynamicCP(FlatData[flatid][flatCPInt]))
    DestroyDynamicCP(FlatData[flatid][flatCPInt]);
  
  FlatData[flatid][flatPickup] = FlatData[flatid][flatCPExt] = FlatData[flatid][flatCPInt] = FlatData[flatid][flatGaragePickup] = INVALID_STREAMER_ID;
  FlatData[flatid][flatText] = FlatData[flatid][flatGarageText] = Text3D:INVALID_STREAMER_ID;

  mysql_tquery(g_iHandle, sprintf("DELETE FROM `flat` WHERE `ID`='%d';",FlatData[flatid][flatID]));
  
  new tmp_FlatData[flatData];
  FlatData[flatid] = tmp_FlatData;

  Iter_Remove(Flat, flatid);
  return 1;
}

Flat_Inside(playerid) {
  if (PlayerData[playerid][pApartment] != -1){
    foreach (new flatid : Flat) if (FlatData[flatid][flatID] == PlayerData[playerid][pApartment] && GetPlayerInterior(playerid) == FlatData[flatid][flatIntInterior] && GetPlayerVirtualWorld(playerid) == FlatData[flatid][flatIntWorld]) {
      return flatid;
    }
  }
  return -1;
}

Flat_Nearest(playerid) {
  foreach (new flatid : Flat) if (IsPlayerInRangeOfPoint(playerid,3.0,FlatData[flatid][flatPos][0],FlatData[flatid][flatPos][1],FlatData[flatid][flatPos][2]) && GetPlayerVirtualWorld(playerid) == FlatData[flatid][flatWorld] && GetPlayerInterior(playerid) == FlatData[flatid][flatInterior]) {
    return flatid;
  }
  return -1;
}

Flat_NearestGarage(playerid) {
  foreach (new flatid : Flat) if(FlatData[flatid][flatGaragePos][0] != 0.0 && IsPlayerInRangeOfPoint(playerid, 5.0, FlatData[flatid][flatGaragePos][0], FlatData[flatid][flatGaragePos][1], FlatData[flatid][flatGaragePos][2])) {
    return flatid;
  }
  return -1;
}

Flat_ReturnID(roomid) {
  foreach (new i : Flat) if (FlatData[i][flatID] == FlatRoom[roomid][flatID]) {
    return i;
  }
  return -1;
}

FlatRoom_IsOwnerByFlat(playerid, flatBase) {
  foreach (new i : FlatRooms) if (FlatRoom_IsOwner(playerid, i)) {
    if (FlatRoom[i][flatID] == FlatData[flatBase][flatID]) {
      return 1;
    }
  }

  return 0;
}

FlatRoom_GetCount(playerid) {
  new count = 0;
  foreach (new i : FlatRooms) if (FlatRoom_IsOwner(playerid, i)) {
    count++;
  }
  return count;
}

FlatRoom_GetMaxCount(playerid) {
  new count = (PlayerData[playerid][pVip] > 1 && PlayerData[playerid][pVipTime]) ? (2) : (1);
  return count;
}

FlatRoom_GetAddress(flatroom, address[], len = sizeof(address)) {
  new flatid = Flat_ReturnID(flatroom);
  if (flatid != -1) {
    format(address, len, "%s", FlatData[flatid][flatName]);
  }
}

FlatRoom_GetLocation(flatroom, location[], len = sizeof(location)) {
  new flatid = Flat_ReturnID(flatroom);
  if (flatid != -1) {
    format(location, len, "%s", GetLocation(FlatData[flatid][flatPos][0], FlatData[flatid][flatPos][1], FlatData[flatid][flatPos][2]));
  }
}

FlatRoom_CreateDoor(flatroom, bool:locked = false) {
  new modelid = (locked) ? (1536) : (1502);

  foreach (new i : FlatStaticStructs[flatroom]) if (IsValidDynamicObject(FlatStaticStruct[flatroom][i][structObject])) {
    new curModel = Streamer_GetIntData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_MODEL_ID);

    if (curModel == 1536 || curModel == 1502) {
      FlatStaticStruct[flatroom][i][structModel] = modelid;
      Streamer_SetIntData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_MODEL_ID, modelid);

      Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_X, FlatStaticStruct[flatroom][i][structPos][0]);
      Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_Y, FlatStaticStruct[flatroom][i][structPos][1]);
      Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_Z, FlatStaticStruct[flatroom][i][structPos][2]);
      Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_R_X, FlatStaticStruct[flatroom][i][structRot][0]);
      Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_R_Y, FlatStaticStruct[flatroom][i][structRot][1]);
      Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_R_Z, FlatStaticStruct[flatroom][i][structRot][2]);
      Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_STREAM_DISTANCE, 100.00);
      Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_DRAW_DISTANCE, 100.00);
      Streamer_SetIntData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_WORLD_ID, FlatRoom[flatroom][flatRoomWorld]);
      Streamer_SetIntData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_INTERIOR_ID, FlatRoom[flatroom][flatRoomInterior]);

      if (FlatStaticStruct[flatroom][i][structMaterial] > 0) {
        SetDynamicObjectMaterial(FlatStaticStruct[flatroom][i][structObject], (FlatStaticStruct[flatroom][i][structModel] == 1502) ? (1) : (0), GetTModel(FlatStaticStruct[flatroom][i][structMaterial]), GetTXDName(FlatStaticStruct[flatroom][i][structMaterial]), GetTextureName(FlatStaticStruct[flatroom][i][structMaterial]), FlatStaticStruct[flatroom][i][structColor]);
      }

      FlatStructure_Save(flatroom, i, false, SAVE_STRUCTURE_MODEL);
    }
  }

  return 1;
}

FlatRoom_Refresh(flatroom) {
  if (!Iter_Contains(FlatRooms, flatroom))
    return 0;
  
  new Float:areaMinX = FlatRoom[flatroom][flatRoomAreaPos][0],
    Float:areaMinY = FlatRoom[flatroom][flatRoomAreaPos][1],
    Float:areaMaxX = FlatRoom[flatroom][flatRoomAreaPos][2],
    Float:areaMaxY = FlatRoom[flatroom][flatRoomAreaPos][3],
    Float:areaZ = FlatRoom[flatroom][flatRoomAreaPos][4],
    World = FlatRoom[flatroom][flatRoomWorld],
    Interior = FlatRoom[flatroom][flatRoomInterior],
    Float:PosX = FlatRoom[flatroom][flatRoomPos][0],
    Float:PosY = FlatRoom[flatroom][flatRoomPos][1],
    Float:PosZ = FlatRoom[flatroom][flatRoomPos][2];
  
  if (IsValidDynamicArea(FlatRoom[flatroom][flatRoomArea])) {
    Streamer_SetFloatData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_MIN_X, areaMinX);
    Streamer_SetFloatData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_MIN_Y, areaMinY);
    Streamer_SetFloatData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_MAX_X, areaMaxX);
    Streamer_SetFloatData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_MAX_Y, areaMaxY);

    Streamer_SetFloatData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_MIN_Z, areaZ - 1.2);
    Streamer_SetFloatData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_MAX_Z, areaZ + 4.0);
    Streamer_SetIntData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_WORLD_ID, World);
    Streamer_SetIntData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_INTERIOR_ID, Interior);

    new info[2];
    info[0] = FLAT_AREA_INDEX;
    info[1] = flatroom;
    Streamer_SetArrayData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_EXTRA_ID, info);
  } else {
    FlatRoom[flatroom][flatRoomArea] = CreateDynamicCuboid(areaMinX, areaMinY, areaZ - 1.5, areaMaxX, areaMaxY, areaZ + 4.0, World, Interior);

    new info[2];
    info[0] = FLAT_AREA_INDEX;
    info[1] = flatroom;
    Streamer_SetArrayData(STREAMER_TYPE_AREA, FlatRoom[flatroom][flatRoomArea], E_STREAMER_EXTRA_ID, info);
  }

  if (!FlatRoom[flatroom][flatRoomOwner]) {
    if (IsValidDynamicPickup(FlatRoom[flatroom][flatRoomPickup])) {
      Streamer_SetFloatData(STREAMER_TYPE_PICKUP, FlatRoom[flatroom][flatRoomPickup], E_STREAMER_X, PosX);
      Streamer_SetFloatData(STREAMER_TYPE_PICKUP, FlatRoom[flatroom][flatRoomPickup], E_STREAMER_Y, PosY);
      Streamer_SetFloatData(STREAMER_TYPE_PICKUP, FlatRoom[flatroom][flatRoomPickup], E_STREAMER_Z, PosZ);
      Streamer_SetIntData(STREAMER_TYPE_PICKUP, FlatRoom[flatroom][flatRoomPickup], E_STREAMER_WORLD_ID, World);
      Streamer_SetIntData(STREAMER_TYPE_PICKUP, FlatRoom[flatroom][flatRoomPickup], E_STREAMER_INTERIOR_ID, Interior);
    } else {
      FlatRoom[flatroom][flatRoomPickup] = CreateDynamicPickup(1273, 23, PosX, PosY, PosZ, World, Interior, -1, 10);
    }

    if (IsValidDynamic3DTextLabel(FlatRoom[flatroom][flatRoomText])) {
      Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatRoom[flatroom][flatRoomText], E_STREAMER_X, PosX);
      Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatRoom[flatroom][flatRoomText], E_STREAMER_Y, PosY);
      Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatRoom[flatroom][flatRoomText], E_STREAMER_Z, PosZ);
      Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, FlatRoom[flatroom][flatRoomText], E_STREAMER_DRAW_DISTANCE, 10.0);
      Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, FlatRoom[flatroom][flatRoomText], E_STREAMER_TEST_LOS, 1);
      Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, FlatRoom[flatroom][flatRoomText], E_STREAMER_WORLD_ID, World);
      Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, FlatRoom[flatroom][flatRoomText], E_STREAMER_INTERIOR_ID, Interior);

      UpdateDynamic3DTextLabelText(FlatRoom[flatroom][flatRoomText], COLOR_CLIENT, sprintf("[Flat:%d]\n"WHITE"Price: "GREEN"%s",flatroom,FormatNumber(FlatRoom[flatroom][flatRoomPrice])));
    } else {
      FlatRoom[flatroom][flatRoomText] = CreateDynamic3DTextLabel(sprintf("[Flat:%d]\n"WHITE"Price: "GREEN"%s",flatroom,FormatNumber(FlatRoom[flatroom][flatRoomPrice])), COLOR_CLIENT, PosX, PosY, PosZ, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, World, Interior);
    }
    
    FlatRoom_CreateDoor(flatroom);
  } else {
    if (FlatRoom[flatroom][flatRoomSeal]) {
      FlatRoom_CreateDoor(flatroom, true);

      if (IsValidDynamic3DTextLabel(FlatRoom[flatroom][flatRoomText])){
        UpdateDynamic3DTextLabelText(FlatRoom[flatroom][flatRoomText], COLOR_CLIENT, sprintf("[Flat:%d]\n"WHITE"This flat is sealed by "RED"authority",flatroom,FlatRoom[flatroom][flatRoomOwner]));
      } else {
        FlatRoom[flatroom][flatRoomText] = CreateDynamic3DTextLabel(sprintf("[Flat:%d]\n"WHITE"This flat is sealed by "RED"authority"), COLOR_CLIENT, PosX, PosY, PosZ, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, World, Interior);
      }
    } else {
      if (IsValidDynamicPickup(FlatRoom[flatroom][flatRoomPickup]))
        DestroyDynamicPickup(FlatRoom[flatroom][flatRoomPickup]), FlatRoom[flatroom][flatRoomPickup] = INVALID_STREAMER_ID;
    
      if (IsValidDynamic3DTextLabel(FlatRoom[flatroom][flatRoomText]))
        DestroyDynamic3DTextLabel(FlatRoom[flatroom][flatRoomText]), FlatRoom[flatroom][flatRoomText] = Text3D:INVALID_STREAMER_ID;
    }
    if (FlatRoom[flatroom][flatRoomLocked]) {
      FlatRoom_CreateDoor(flatroom, true);
    } else {
      FlatRoom_CreateDoor(flatroom);
    }
  }
  return 1;
}

FlatRoom_Save(flatroom) {
  if (!Iter_Contains(FlatRooms, flatroom))
    return 0;
  
  new query[2000];
  format(query,sizeof(query),"UPDATE `flatroom` SET `FlatID`='%d', `Owner`='%d', `Locked`='%d', `Price`='%d', `World`='%d', `Interior`='%d', `Seal`='%d', `Money`='%d', `Position`='%.2f|%.2f|%.2f', `AreaPos`='%.2f|%.2f|%.2f|%.2f|%.2f', `Builder`='%d|%d', `LastVisited`='%d' WHERE `ID`='%d'",
    FlatRoom[flatroom][flatID],
    FlatRoom[flatroom][flatRoomOwner],
    FlatRoom[flatroom][flatRoomLocked],
    FlatRoom[flatroom][flatRoomPrice],
    FlatRoom[flatroom][flatRoomWorld],
    FlatRoom[flatroom][flatRoomInterior],
    FlatRoom[flatroom][flatRoomSeal],
    FlatRoom[flatroom][flatRoomMoney],
    FlatRoom[flatroom][flatRoomPos][0],
    FlatRoom[flatroom][flatRoomPos][1],
    FlatRoom[flatroom][flatRoomPos][2],
    FlatRoom[flatroom][flatRoomAreaPos][0],
    FlatRoom[flatroom][flatRoomAreaPos][1],
    FlatRoom[flatroom][flatRoomAreaPos][2],
    FlatRoom[flatroom][flatRoomAreaPos][3],
    FlatRoom[flatroom][flatRoomAreaPos][4],
    FlatRoom[flatroom][flatRoomBuilder],
    FlatRoom[flatroom][flatRoomBuilderTime],
    FlatRoom[flatroom][flatRoomLastVisited],
    FlatRoom[flatroom][flatRoomID]
  );

  return mysql_tquery(g_iHandle, query);
}

Function:OnFlatRoomCreated(flatroom) {
  if (!Iter_Contains(FlatRooms, flatroom))
    return 0;
  
  FlatRoom[flatroom][flatRoomID] = cache_insert_id();
  FlatRoom_Refresh(flatroom);
  FlatRoom_Save(flatroom);
  return 1;
}

FlatRoom_Create(price, Float:x, Float:y, Float:z, world, interior, flatid) {
  new flatroom = cellmin;

  if ((flatroom = Iter_Free(FlatRooms)) != cellmin) {
    Iter_Add(FlatRooms, flatroom);

    FlatRoom[flatroom][flatID] = FlatData[flatid][flatID];
    FlatRoom[flatroom][flatRoomPrice] = price;
    FlatRoom[flatroom][flatRoomOwner] = 0;
    FlatRoom[flatroom][flatRoomSeal] = 0;
    FlatRoom[flatroom][flatRoomBuilder] = 0;
    FlatRoom[flatroom][flatRoomBuilderTime] = 0;
    FlatRoom[flatroom][flatRoomLastVisited] = gettime();
    FlatRoom[flatroom][flatRoomPos][0] = x;
    FlatRoom[flatroom][flatRoomPos][1] = y;
    FlatRoom[flatroom][flatRoomPos][2] = z;
    FlatRoom[flatroom][flatRoomWorld] = world;
    FlatRoom[flatroom][flatRoomInterior] = interior;
    FlatRoom[flatroom][flatRoomAreaPos][0] = x;
    FlatRoom[flatroom][flatRoomAreaPos][1] = y;
    FlatRoom[flatroom][flatRoomAreaPos][2] = x;
    FlatRoom[flatroom][flatRoomAreaPos][3] = y;
    FlatRoom[flatroom][flatRoomAreaPos][4] = z;

    FlatStructure_Create(flatroom, 1502, x, y, z, 0.0, 0.0, 0.0, false);

    mysql_tquery(g_iHandle, sprintf("INSERT INTO `flatroom` (`Owner`) VALUES ('%d');", FlatRoom[flatroom][flatRoomOwner]), "OnFlatRoomCreated", "d", flatroom);

    return flatroom;
  }
  return cellmin;
}

FlatRoom_Delete(flatroom) {
  if(!Iter_Contains(FlatRooms, flatroom))
    return 0;
  
  if (IsValidDynamicArea(FlatRoom[flatroom][flatRoomArea]))
    DestroyDynamicArea(FlatRoom[flatroom][flatRoomArea]);

  if (IsValidDynamicPickup(FlatRoom[flatroom][flatRoomPickup]))
    DestroyDynamicPickup(FlatRoom[flatroom][flatRoomPickup]);
  
  if (IsValidDynamic3DTextLabel(FlatRoom[flatroom][flatRoomText]))
    DestroyDynamic3DTextLabel(FlatRoom[flatroom][flatRoomText]);
  
  FlatRoom[flatroom][flatRoomArea] = FlatRoom[flatroom][flatRoomPickup] = INVALID_STREAMER_ID;
  FlatRoom[flatroom][flatRoomText] = Text3D:INVALID_STREAMER_ID;
  Flat_RemoveAllItems(flatroom);
  mysql_tquery(g_iHandle, sprintf("DELETE FROM `flatroom` WHERE `ID`='%d';",FlatRoom[flatroom][flatRoomID]));

  FlatStructure_DeleteAll(flatroom, false);
  FlatStructure_DeleteAll(flatroom, true);
  FlatFurniture_DeleteAll(flatroom);

  new tmp_FlatRoom[flatRoom];
  FlatRoom[flatroom] = tmp_FlatRoom;
  Iter_Remove(FlatRooms, flatroom);
  return 1;
}

FlatRoom_Inside(playerid) {
  foreach (new flatroom : FlatRooms) if (IsPlayerInDynamicArea(playerid, FlatRoom[flatroom][flatRoomArea]) && GetPlayerVirtualWorld(playerid) == FlatRoom[flatroom][flatRoomWorld] && GetPlayerInterior(playerid) == FlatRoom[flatroom][flatRoomInterior]) {
    return flatroom;
  }
  return -1;
}

FlatRoom_Nearest(playerid) {
  foreach (new flatroom : FlatRooms) if (IsPlayerInRangeOfPoint(playerid,3.0,FlatRoom[flatroom][flatRoomPos][0],FlatRoom[flatroom][flatRoomPos][1],FlatRoom[flatroom][flatRoomPos][2]) && GetPlayerVirtualWorld(playerid) == FlatRoom[flatroom][flatRoomWorld] && GetPlayerInterior(playerid) == FlatRoom[flatroom][flatRoomInterior]) {
    return flatroom;
  }
  return -1;
}

FlatRoom_IsOwner(playerid, flatroom) {
  if (!Iter_Contains(FlatRooms, flatroom))
    return 0;
  
  if(!PlayerData[playerid][pLogged] || PlayerData[playerid][pID] == -1)
    return 0;
  
  if (FlatRoom[flatroom][flatRoomOwner] != 0 && FlatRoom[flatroom][flatRoomOwner] == PlayerData[playerid][pID])
    return 1;
  
  return 0;
}

FlatRoom_IsBuilder(playerid, flatroom) {
  if (!Iter_Contains(FlatRooms, flatroom))
    return 0;
  
  if(!PlayerData[playerid][pLogged] || PlayerData[playerid][pID] == -1)
    return 0;
  
  if (FlatRoom[flatroom][flatRoomBuilder] != 0 && FlatRoom[flatroom][flatRoomBuilder] == PlayerData[playerid][pID])
    return 1;
  
  return 0;
}

FlatRoom_GetItemsMax(flatroom) {
  new flatBase = Flat_ReturnID(flatroom), maxItems = 0;

  switch (FlatData[flatBase][flatType]) {
    case FLAT_TYPE_NONE: maxItems = 0;
    case FLAT_TYPE_LOW: maxItems = 50;
    case FLAT_TYPE_MEDIUM: maxItems = 80;
    case FLAT_TYPE_HIGH: maxItems = 100;
  }

  return maxItems;
}

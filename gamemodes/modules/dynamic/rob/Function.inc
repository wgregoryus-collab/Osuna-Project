Function:RobPoint_Load() {
  new rows = cache_num_rows();

  for (new i = 0; i < rows; i ++) {
    cache_get_value_int(i, "ID", RobPoint[i][robID]);
    cache_get_value_float(i, "PosX", RobPoint[i][robPos][0]);
    cache_get_value_float(i, "PosY", RobPoint[i][robPos][1]);
    cache_get_value_float(i, "PosZ", RobPoint[i][robPos][2]);
    cache_get_value_int(i, "Money", RobPoint[i][robAmountMoney]);
    cache_get_value_int(i, "World", RobPoint[i][robWorld]);
    cache_get_value_int(i, "Interior", RobPoint[i][robInt]);

    RobPoint_Refresh(i);

    Iter_Add(Rob, i);
  }
  printf("*** [GarudaPride Database: Loaded] rob points data (%d count)", rows);
  return 1;
}

Function:OnRobPointCreated(i) {
  if (!Iter_Contains(Rob, i))
    return false;

  RobPoint[i][robID] = cache_insert_id();

  RobPoint_Save(i);
  return 1;
}

RobPoint_Refresh(i) {
  new string[128];

  if (IsValidDynamicPickup(RobPoint[i][rob]))
    DestroyDynamicPickup(RobPoint[i][rob]);

  if (IsValidDynamic3DTextLabel(RobPoint[i][robLabel]))
    DestroyDynamic3DTextLabel(RobPoint[i][robLabel]);

  RobPoint[i][rob] = CreateDynamicPickup(1239, 23, RobPoint[i][robPos][0], RobPoint[i][robPos][1], RobPoint[i][robPos][2], RobPoint[i][robWorld], RobPoint[i][robInt]);
  format(string,sizeof(string),GREEN"[Rob Point ID: %d]\n"WHITE"Use '"YELLOW"/rob"WHITE"' to rob this safe.\nMoney: "GREEN"%s", i, FormatNumber(RobPoint[i][robAmountMoney]));
  RobPoint[i][robLabel] = CreateDynamic3DTextLabel(string, COLOR_CLIENT, RobPoint[i][robPos][0], RobPoint[i][robPos][1], RobPoint[i][robPos][2], 15.0, INVALID_VEHICLE_ID, INVALID_PLAYER_ID, 1, RobPoint[i][robWorld], RobPoint[i][robInt]);
  return 1;
}

RobPoint_Save(id) {
  new str[512];

  format(str,sizeof(str),"UPDATE `robpoint` SET `PosX` = '%f', `PosY` = '%f', `PosZ` = '%f', `Money` = '%d', `World` = '%d', `Interior` = '%d' WHERE `ID` = '%d'",
  RobPoint[id][robPos][0],
  RobPoint[id][robPos][1],
  RobPoint[id][robPos][2],
  RobPoint[id][robAmountMoney],
  RobPoint[id][robWorld],
  RobPoint[id][robInt],
  RobPoint[id][robID]
  );
  mysql_tquery(g_iHandle, str);
  return 1;
}

RobPoint_Create(playerid, Float:x, Float:y, Float:z) {
  for (new i = 0; i < MAX_ROB_POINTS; i ++) if (!Iter_Contains(Rob, i)) {
    RobPoint[i][robPos][0] = x;
    RobPoint[i][robPos][1] = y;
    RobPoint[i][robPos][2] = z;
    RobPoint[i][robWorld] = GetPlayerVirtualWorld(playerid);
    RobPoint[i][robInt] = GetPlayerInterior(playerid);
    RobPoint[i][robAmountMoney] = 5000;
    RobPoint[i][robRobbed] = 0;

    RobPoint_Refresh(i);
    Iter_Add(Rob, i);

    mysql_tquery(g_iHandle, sprintf("INSERT INTO `robpoint` (`World`) VALUES ('%d')", GetPlayerVirtualWorld(playerid)), "OnRobPointCreated", "d", i);

    return i;
  }
  return -1;
}

RobPoint_Delete(id) {
  if (!Iter_Contains(Rob, id))
    return 0;

  DestroyDynamicPickup(RobPoint[id][rob]);
  DestroyDynamic3DTextLabel(RobPoint[id][robLabel]);
  mysql_tquery(g_iHandle, sprintf("DELETE FROM `robpoint` WHERE `ID` = '%d'", RobPoint[id][robID]));
  Iter_Remove(Rob, id);
  RobPoint[id][robID] = RobPoint[id][rob] = INVALID_STREAMER_ID;
  RobPoint[id][robLabel] = Text3D:INVALID_3DTEXT_ID;
  return 1;
}

RobPoint_Nearest(playerid) {
  foreach(new i : Rob) if (Iter_Contains(Rob, i) && IsPlayerInRangeOfPoint(playerid, 3.5, RobPoint[i][robPos][0], RobPoint[i][robPos][1], RobPoint[i][robPos][2]) && GetPlayerInterior(playerid) == RobPoint[i][robInt] && GetPlayerVirtualWorld(playerid) == RobPoint[i][robWorld]) {
    return i;
  }
  return -1;
}

SendWarning(repeat) {
  new count = 0;
  if (repeat) {
    SendClientMessageToAllEx(X11_TOMATO_1, "BANK ALARM: "WHITE"Terdengar suara alarm Rodeo Bank berbunyi");
    SendClientMessageToAllEx(X11_TOMATO_1, "BREAKING NEWS: "WHITE"Rodeo Bank sedang dirampok !!!");
    SendClientMessageToAllEx(X11_TOMATO_1, "BREAKING NEWS: "WHITE"Harap warga kota San Andreas untuk tidak bertransaksi di Rodeo Bank terlebih dahulu !!!");
  } else {
    count++;
    if (count >= 3) Warn = 0;
    if (!Warn) {
      SendClientMessageToAllEx(X11_TOMATO_1, "BANK ALARM: "WHITE"Terdengar suara alarm Rodeo Bank berbunyi");
      SendClientMessageToAllEx(X11_TOMATO_1, "BREAKING NEWS: "WHITE"Rodeo Bank sedang dirampok !!!");
      SendClientMessageToAllEx(X11_TOMATO_1, "BREAKING NEWS: "WHITE"Harap warga kota San Andreas untuk tidak bertransaksi di Rodeo Bank terlebih dahulu !!!");
      Warn = 1;
    } else return 0;
  }
  return 1;
}
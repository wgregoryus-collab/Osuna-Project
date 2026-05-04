// Admin Commands
new testZone[MAX_FLAT_ROOM] = {-1, ...},
  editDoorFlat[MAX_PLAYERS] = {-1, ...};

static GetFreeZone() {
  for (new i = 0; i < MAX_FLAT_ROOM; i++) {
    if (testZone[i] == -1) {
      return i;
    }
  }
  return -1;
}

SSCANF:FlatMenu(string[]) {
  if (!strcmp(string, "create", true)) return 1;
  else if (!strcmp(string, "type", true)) return 2;
  else if (!strcmp(string, "name", true)) return 3;
  else if (!strcmp(string, "location", true)) return 4;
  else if (!strcmp(string, "interior", true)) return 5;
  else if (!strcmp(string, "goto", true)) return 6;
  else if (!strcmp(string, "garagepos", true)) return 7;
  else if (!strcmp(string, "delete", true)) return 8;
  return 0;
}

CMD:flat(playerid, params[]) {
  if (CheckAdmin(playerid, 8))
    return PermissionError(playerid);

  new menus, extendstr[128];
  if (sscanf(params, "k<FlatMenu>S()[128]", menus, extendstr)) {
    SendSyntaxMessage(playerid, "/flat [menu]");
    SendClientMessage(playerid, X11_YELLOW_2, "[MENUS]: "WHITE"create, delete, type, name, location, interior, goto, garagepos");
    return 1;
  }

  switch (menus) {
    case 1: { // Create
      new name[32], type;
      if (sscanf(extendstr, "ds[32]", type, name))
        return SendSyntaxMessage(playerid, "/flat create [type] [name]");
      
      new Float:position[3];
      GetPlayerPos(playerid, position[0], position[1], position[2]);

      new flatid = Flat_Create(name, type, position[0], position[1], position[2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
      
      if (flatid == cellmin)
        return SendErrorMessage(playerid, "Cannot create more flat!");
      
      SendCustomMessage(playerid, "FLAT","You've created flat ID: "YELLOW"%d", flatid);
    }
    case 2: { // Type
      new flatid, type;
      if (sscanf(extendstr, "dd", flatid, type))
        return SendSyntaxMessage(playerid, "/flat type [flat id] [type]"), SendClientMessage(playerid, X11_YELLOW_2, "[TYPES]: "WHITE"1 = low, 2 = medium, 3 = high");
      
      if (!Iter_Contains(Flat, flatid))
        return SendErrorMessage(playerid, "Invalid flat ID");
      
      new typeName[12];
      FlatData[flatid][flatType] = type;
      Flat_GetType(flatid, typeName);
      Flat_Refresh(flatid);
      Flat_Save(flatid);

      SendCustomMessage(playerid, "FLAT", "You've changed type of flat ID: "YELLOW"%d "WHITE"to "YELLOW"%s", flatid, typeName);
    }
    case 3: { // Name
      new flatid, name[32];
      if (sscanf(extendstr, "ds[32]", flatid, name))
        return SendSyntaxMessage(playerid, "/flat name [flat id] [flat name]");
      
      if (!Iter_Contains(Flat, flatid))
        return SendErrorMessage(playerid, "Invalid flat ID");
      
      if (strlen(name) > 32)
        return SendErrorMessage(playerid, "Maximum character name is 32 characters");
      
      format(FlatData[flatid][flatName], 32, name);
      Flat_Refresh(flatid);
      Flat_Save(flatid);

      SendCustomMessage(playerid, "FLAT","You've changed name of flat ID: "YELLOW"%d "WHITE"to "YELLOW"%s", flatid, FlatData[flatid][flatName]);
    }
    case 4: { // location
      new flatid;
      if (sscanf(extendstr, "d", flatid))
        return SendSyntaxMessage(playerid, "/flat location [flat id]");
      
      if (!Iter_Contains(Flat, flatid))
        return SendErrorMessage(playerid, "Invalid flat ID");
      
      new Float:playerPos[3];
      GetPlayerPos(playerid, playerPos[0], playerPos[1], playerPos[2]);

      FlatData[flatid][flatPos][0] = playerPos[0];
      FlatData[flatid][flatPos][1] = playerPos[1];
      FlatData[flatid][flatPos][2] = playerPos[2];
      FlatData[flatid][flatWorld] = GetPlayerVirtualWorld(playerid);
      FlatData[flatid][flatInterior] = GetPlayerInterior(playerid);
      Flat_Refresh(flatid);
      Flat_Save(flatid);

      SendCustomMessage(playerid, "FLAT", "You've changed location of flat ID: "YELLOW"%d "WHITE"to your current location", flatid);
    }
    case 5: { // interior
      new flatid;
      if (sscanf(extendstr, "d", flatid))
        return SendSyntaxMessage(playerid, "/flat interior [flat id]");
      
      if (!Iter_Contains(Flat, flatid))
        return SendErrorMessage(playerid, "Invalid flat ID");
      
      new Float:playerPos[3];
      GetPlayerPos(playerid, playerPos[0], playerPos[1], playerPos[2]);

      FlatData[flatid][flatIntPos][0] = playerPos[0];
      FlatData[flatid][flatIntPos][1] = playerPos[1];
      FlatData[flatid][flatIntPos][2] = playerPos[2];
      FlatData[flatid][flatIntWorld] = GetPlayerVirtualWorld(playerid);
      FlatData[flatid][flatIntInterior] = GetPlayerInterior(playerid);
      Flat_Refresh(flatid);
      Flat_Save(flatid);

      SendCustomMessage(playerid, "FLAT", "You've changed interior of flat ID: "YELLOW"%d "WHITE"to your current interior", flatid);
    }
    case 6: { // goto
      new flatid;
      if (sscanf(extendstr, "d", flatid))
        return SendSyntaxMessage(playerid, "/flat goto [flat id]");
      
      if (!Iter_Contains(Flat, flatid))
        return SendErrorMessage(playerid, "Invalid flat ID");
      
      SetPlayerPosEx(playerid, FlatData[flatid][flatPos][0],FlatData[flatid][flatPos][1],FlatData[flatid][flatPos][2]);
      SetPlayerVirtualWorld(playerid, FlatData[flatid][flatWorld]);
      SetPlayerInterior(playerid, FlatData[flatid][flatInterior]);

      SendCustomMessage(playerid, "FLAT", "You've been teleported to flat ID: "YELLOW"%d", flatid);
    }
    case 7: { // garagepos
      new flatid;
      if (sscanf(extendstr, "d", flatid))
        return SendSyntaxMessage(playerid, "/flat garagepos [flat id]");
      
      if (!Iter_Contains(Flat, flatid))
        return SendErrorMessage(playerid, "Invalid flat ID");
      
      new Float:gPos[3];
      GetPlayerPos(playerid, gPos[0], gPos[1], gPos[2]);
      FlatData[flatid][flatGaragePos][0] = gPos[0];
      FlatData[flatid][flatGaragePos][1] = gPos[1];
      FlatData[flatid][flatGaragePos][2] = gPos[2];
      Flat_Refresh(flatid);
      Flat_Save(flatid);

      SendCustomMessage(playerid, "FLAT", "You've changed garage position of flat ID: "YELLOW"%d", flatid);
    }
    case 8: { // delete
      new flatid;
      if (sscanf(extendstr, "d", flatid))
        return SendSyntaxMessage(playerid, "/flat delete [flat id]");
      
      if (!Iter_Contains(Flat, flatid))
        return SendErrorMessage(playerid, "Invalid flat ID");
      
      if (Flat_Delete(flatid)){
        foreach (new flatroom : FlatRooms) if (FlatRoom[flatroom][flatID] == FlatData[flatid][flatID]) {
          FlatRoom_Delete(flatroom);
        }
        SendCustomMessage(playerid, "FLAT","You've deleted flat ID: "YELLOW"%d", flatid);
      } else return SendErrorMessage(playerid, "Unable to delete flat ID: "YELLOW"%d", flatid);
    }
    default: {
      SendSyntaxMessage(playerid, "/flat [menu]");
      SendClientMessage(playerid, X11_YELLOW_2, "[MENUS]: "WHITE"create, delete, type, name, location, interior, goto, garagepos");
      return 1;
    }
  }
  return 1;
}

SSCANF:FlatRoomMenu(string[]) {
  if (!strcmp(string,"create",true)) return 1;
  else if (!strcmp(string,"delete",true)) return 2;
  else if (!strcmp(string,"editdoor",true)) return 3;
  else if (!strcmp(string,"areapos",true)) return 4;
  else if (!strcmp(string,"price",true)) return 5;
  else if (!strcmp(string,"location",true)) return 6;
  else if (!strcmp(string,"resetowner",true)) return 7;
  else if (!strcmp(string,"gangzone",true)) return 8;
  else if (!strcmp(string,"structure",true)) return 9;
  else if (!strcmp(string,"editstructure",true)) return 10;
  else if (!strcmp(string,"createinterior",true)) return 11;
  return 0;
}

CMD:flatroommenu(playerid, params[]) {
  if (CheckAdmin(playerid, 8))
    return PermissionError(playerid);
  
  new menus, extendstr[128];
  if (sscanf(params,"k<FlatRoomMenu>S()[128]",menus,extendstr)) {
    SendSyntaxMessage(playerid, "/flatroommenu [menu]");
    SendClientMessage(playerid, X11_YELLOW_2, "[MENUS]: "WHITE"create, delete, editdoor, areapos, price, location, resetowner, structure, editstructure, createinterior");
    return 1;
  }

  switch (menus) {
    case 1: { // create
      new price, flatid = Flat_Inside(playerid);
      if (sscanf(extendstr,"d",price))
        return SendSyntaxMessage(playerid, "/flatroommenu create [price]");
      
      if (price < 1)
        return SendErrorMessage(playerid, "Price cannot go below 1");
      
      if (flatid == -1)
        return SendErrorMessage(playerid, "You're not on inside flat");
      
      new Float:pos[3];
      GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

      new flatroom = FlatRoom_Create(price, pos[0], pos[1], pos[2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), flatid);

      if (flatroom == cellmin)
        return SendErrorMessage(playerid, "Cannot create more flat room");
      
      SendCustomMessage(playerid,"FLATROOM","You've created flat room ID: "YELLOW"%d", flatroom);
    }
    case 2: { // delete
      new flatroom;
      if (sscanf(extendstr, "d", flatroom))
        return SendSyntaxMessage(playerid, "/flatroommenu delete [flatroom id]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");
      
      if (FlatRoom_Delete(flatroom))
        SendCustomMessage(playerid,"FLATROOM","You've deleted flat room ID: "YELLOW"%d", flatroom);
      else
        return SendErrorMessage(playerid, "Unable to delete flat room");
    }
    case 3: { // editdoor
      new flatroom;
      if (sscanf(extendstr, "d", flatroom))
        return SendSyntaxMessage(playerid, "/flatroommenu editdoor [flatroom id]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");
      
      foreach (new i : FlatStaticStructs[flatroom]) if (IsValidDynamicObject(FlatStaticStruct[flatroom][i][structObject])) {
        new model = Streamer_GetIntData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_MODEL_ID);

        if (model == 1502 || model == 19430) {
          editDoorFlat[playerid] = flatroom;
          PlayerData[playerid][pEditStaticStructure] = i;
          EditDynamicObject(playerid, FlatStaticStruct[flatroom][i][structObject]);
          SendCustomMessage(playerid, "FLATROOM","You're now editing flat room door ID: "YELLOW"%d", flatroom);
          break;
        }
      }
    }
    case 4: { // areapos
      new flatroom, Float:minPos[2], Float:maxPos[2], Float:height;
      if (sscanf(extendstr, "dfffff", flatroom, minPos[0], minPos[1], maxPos[0], maxPos[1], height))
        return SendSyntaxMessage(playerid, "/flatroommenu areapos [flatroom id] [minx/barat] [miny/selatan] [maxx/timur] [maxy/utara] [z/tinggi]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");

      FlatRoom[flatroom][flatRoomAreaPos][0] = minPos[0];
      FlatRoom[flatroom][flatRoomAreaPos][1] = minPos[1];
      FlatRoom[flatroom][flatRoomAreaPos][2] = maxPos[0];
      FlatRoom[flatroom][flatRoomAreaPos][3] = maxPos[1];
      FlatRoom[flatroom][flatRoomAreaPos][4] = height;

      FlatRoom_Refresh(flatroom);
      FlatRoom_Save(flatroom);

      SendCustomMessage(playerid, "FLATROOM","You've set flat room ID: "YELLOW"%d"WHITE" area pos to: "YELLOW"%.2f, %.2f, %.2f, %.2f", flatroom, minPos[0], minPos[1], maxPos[0], maxPos[1]);
    }
    case 5: { // price
      new flatroom, price;
      if (sscanf(extendstr, "dd", flatroom, price))
        return SendSyntaxMessage(playerid, "/flatroommenu price [flatroom id] [price]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");
      
      if (price < 1)
        return SendErrorMessage(playerid, "Price cannot go below 1");
      
      FlatRoom[flatroom][flatRoomPrice] = price;
      FlatRoom_Refresh(flatroom);
      FlatRoom_Save(flatroom);

      SendCustomMessage(playerid,"FLATROOM","You've set new price of flat room ID: "YELLOW"%d "WHITE"to "GREEN"%s",flatroom,FormatNumber(FlatRoom[flatroom][flatRoomPrice]));
    }
    case 6: { // location
      new flatroom;
      if (sscanf(extendstr, "d", flatroom))
        return SendSyntaxMessage(playerid, "/flatroommenu location [flatroom id]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");
      
      new Float:fPos[3];
      GetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
      FlatRoom[flatroom][flatRoomPos][0] = fPos[0];
      FlatRoom[flatroom][flatRoomPos][1] = fPos[1];
      FlatRoom[flatroom][flatRoomPos][2] = fPos[2];
      FlatRoom[flatroom][flatRoomWorld] = GetPlayerVirtualWorld(playerid);
      FlatRoom[flatroom][flatRoomInterior] = GetPlayerInterior(playerid);

      foreach (new i : FlatStaticStructs[flatroom]) if (IsValidDynamicObject(FlatStaticStruct[flatroom][i][structObject])) {
        new curModel = Streamer_GetIntData(STREAMER_TYPE_OBJECT, FlatStaticStruct[flatroom][i][structObject], E_STREAMER_MODEL_ID);

        if (curModel == 1536 || curModel == 1502) {
          FlatStaticStruct[flatroom][i][structPos][0] = fPos[0];
          FlatStaticStruct[flatroom][i][structPos][1] = fPos[1];
          FlatStaticStruct[flatroom][i][structPos][2] = fPos[2];
          FlatStructure_Refresh(flatroom, i, false);
          FlatStructure_Save(flatroom, i, false, SAVE_STRUCTURE_POS);
        }
      }

      FlatRoom_Refresh(flatroom);
      FlatRoom_Save(flatroom);

      SendCustomMessage(playerid,"FLATROOM","You've changed location of flat room ID: "YELLOW"%d", flatroom);
    }
    case 7: { // resetowner
      new flatroom;
      if (sscanf(extendstr, "d", flatroom))
        return SendSyntaxMessage(playerid, "/flatroommenu resetowner [flatroom id]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");
      
      FlatRoom[flatroom][flatRoomOwner] = 0;
      FlatRoom_Refresh(flatroom);
      FlatRoom_Save(flatroom);

      SendCustomMessage(playerid,"FLATROOM","You've reset owner of flat room ID: "YELLOW"%d", flatroom);
    }
    case 8: { // gangzone
      new flatroom;
      if (sscanf(extendstr, "d", flatroom))
        return SendSyntaxMessage(playerid, "/flatroommenu gangzone [flatroom id]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");
      
      new gangID = GetFreeZone();
      if (gangID == -1)
        return SendErrorMessage(playerid, "No free gang zones available");
      
      testZone[gangID] = GangZoneCreate(FlatRoom[flatroom][flatRoomAreaPos][0], FlatRoom[flatroom][flatRoomAreaPos][1], FlatRoom[flatroom][flatRoomAreaPos][2], FlatRoom[flatroom][flatRoomAreaPos][3]);
      GangZoneShowForAll(testZone[gangID], 0xFF0000FF);
      GangZoneFlashForAll(testZone[gangID], 0xFF0000FF);

      SendCustomMessage(playerid,"FLATROOM","You've created gang zone ID: "YELLOW"%d"WHITE" for flat room ID: "YELLOW"%d", gangID, flatroom);
    }
    case 9: { // create Structure
      new flatroom, modelid;
      if (sscanf(extendstr, "dd", flatroom, modelid))
        return SendSyntaxMessage(playerid, "/flatroommenu structure [flatroom id] [modelid]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");
      
      static
        Float:x,
        Float:y,
        Float:z,
        Float:angle
      ;

      GetPlayerPos(playerid, z, z, z);
      GetXYInFrontOfPlayer(playerid, x, y, 3.0);
      GetPlayerFacingAngle(playerid, angle);

      new slot = FlatStructure_Create(flatroom, modelid, x, y, z, 0.0, 0.0, angle, false);

      if (slot == cellmin)
        return SendErrorMessage(playerid, "You can't create more structure in this flat");

      PlayerData[playerid][pEditStaticStructure] = slot;
      PlayerData[playerid][pEditFlatStructure] = flatroom;
      EditDynamicObject(playerid, FlatStaticStruct[flatroom][slot][structObject]);
    }
    case 10: { // edit Structure
      new flatroom;
      if (sscanf(extendstr, "d", flatroom))
        return SendSyntaxMessage(playerid, "/flatroommenu editstructure [flatroom id]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");
      
      new info[256], count = 0;

      strcat(info,"Model\tDistance\n");
      foreach (new i : FlatStaticStructs[flatroom]) if (IsValidDynamicObject(FlatStaticStruct[flatroom][i][structObject])) {
        strcat(info, sprintf("%d\t%.1f\n", FlatStaticStruct[flatroom][i][structModel], GetPlayerDistanceFromPoint(playerid, FlatStaticStruct[flatroom][i][structPos][0], FlatStaticStruct[flatroom][i][structPos][1], FlatStaticStruct[flatroom][i][structPos][2])));
        ListedFlatStructures[playerid][count++] = i;
      }

      if (count) Dialog_Show(playerid, Flat_EditStatic, DIALOG_STYLE_TABLIST_HEADERS, "Edit Static Structures", info, "Select", "Cancel");
      else SendErrorMessage(playerid, "There are no static structure on this flat");
    }
    case 11: { // Create Interior
      new flatroom, roomid;
      if (sscanf(extendstr, "dd", flatroom, roomid))
        return SendSyntaxMessage(playerid, "/flatroommenu createinterior [flatroom id] [room id]");
      
      if (!Iter_Contains(FlatRooms, flatroom))
        return SendErrorMessage(playerid, "Invalid flat room ID");
      
      if (roomid < 1)
        return SendErrorMessage(playerid, "Invalid Room ID!");
      
      new maxRoom, flatBase = Flat_ReturnID(flatroom);

      if (flatBase != -1) {
        switch (FlatData[flatBase][flatType]) {
          case FLAT_TYPE_LOW: maxRoom = 12;
          case FLAT_TYPE_MEDIUM: maxRoom = 16;
          case FLAT_TYPE_HIGH: maxRoom = 16;
        }

        if (roomid > maxRoom)
          return SendErrorMessage(playerid, "Invalid Room ID!");

        CreateFlatInterior(flatroom, roomid);
        SendCustomMessage(playerid, "FLAT", "You've been created flat interior for ID: "YELLOW"%d", flatroom);
      }
    }
    default: {
      SendSyntaxMessage(playerid, "/flatroommenu [menu]");
      SendClientMessage(playerid, X11_YELLOW_2, "[MENUS]: "WHITE"create, delete, editdoor, areapos, price, location, resetowner, structure, editstructure, createinterior");
      return 1;
    }
  }
  return 1;
}

// Player Commands
CMD:buyflat(playerid,params[]) {
  new flatroom = -1;
  if ((flatroom = FlatRoom_Nearest(playerid)) != -1) {
    if (!IsValidDynamicArea(FlatRoom[flatroom][flatRoomArea]))
      return SendErrorMessage(playerid, "This flat has no interior, please contact Head Admin");
    
    if (!PlayerData[playerid][pStory])
      return SendErrorMessage(playerid, "You must have accepted character story to buying any property");

    if (FlatRoom_GetCount(playerid) >= FlatRoom_GetMaxCount(playerid))
      return SendErrorMessage(playerid, "You have reached your flat limit of "YELLOW"%d", FlatRoom_GetMaxCount(playerid));
  
    if (FlatRoom[flatroom][flatRoomOwner])
      return SendErrorMessage(playerid, "This flat is already owned by other players");
    
    if (GetMoney(playerid) < FlatRoom[flatroom][flatRoomPrice])
      return SendErrorMessage(playerid,"You don't have enough money to buy this flat");
    
    FlatRoom[flatroom][flatRoomOwner] = GetPlayerSQLID(playerid);
    FlatRoom[flatroom][flatRoomSeal] = 0;
    FlatRoom[flatroom][flatRoomMoney] = 0;
    FlatRoom[flatroom][flatRoomLastVisited] = gettime();
    GiveMoney(playerid, -FlatRoom[flatroom][flatRoomPrice]);
    Flat_RemoveAllItems(flatroom);
    FlatFurniture_DeleteAll(flatroom);
    FlatStructure_DeleteAll(flatroom, true);

    FlatRoom_Refresh(flatroom);
    FlatRoom_Save(flatroom);
    return 1;
  }
  SendErrorMessage(playerid, "You're not in range of any flat");
  return 1;
}

CMD:flock(playerid) {
  new id = -1;
  if ((id = FlatRoom_Nearest(playerid)) != -1 || (id = FlatRoom_Inside(playerid)) != -1) {
    if (FlatRoom[id][flatRoomSeal])
      return SendErrorMessage(playerid, "This flat is sealed by the authority");

    if (!FlatRoom_IsOwner(playerid,id) && !FlatRoom_IsBuilder(playerid,id))
      return SendErrorMessage(playerid, "You're not the owner or builder of this flat");
    
    FlatRoom[id][flatRoomLocked] = FlatRoom[id][flatRoomLocked] ? 0 : 1;
    GameTextForPlayer(playerid, sprintf("~w~Flat %s", (FlatRoom[id][flatRoomLocked]) ? ("~r~Locked") : ("~g~Unlocked")), 1000, 3);
    FlatRoom_Refresh(id);
    FlatRoom_Save(id);
    return 1;
  }
  SendErrorMessage(playerid, "You're not in range of any flat");
  return 1;
}

CMD:flatmenu(playerid) {
  new id = -1;
  if ((id = FlatRoom_Inside(playerid)) != -1) {
    if (FlatRoom[id][flatRoomSeal])
      return SendErrorMessage(playerid, "This flat is sealed by the authority");

    if (!FlatRoom_IsOwner(playerid, id) && !FlatRoom_IsBuilder(playerid, id))
      return SendErrorMessage(playerid, "You're not the owner or builder of this flat");
    
    Dialog_Show(playerid, Dialog_FlatMenu, DIALOG_STYLE_LIST, "Flat Menu", sprintf("%s Flat\nFlat Storage\nFurnitures\nStructures\nAssign Builder", (FlatRoom[id][flatRoomLocked]) ? ("Unlock") : ("Lock")), "Select", "Cancel");
    return 1;
  }
  SendErrorMessage(playerid,"You're not in range of any flat");
  return 1;
}

CMD:getfreestruct(playerid, params[]) {
  if (CheckAdmin(playerid, 8))
    return PermissionError(playerid);
  
  new flatid, type[12];
  if (sscanf(params, "ds[12]", flatid, type))
    return SendSyntaxMessage(playerid, "/getfreestruct [flat id] [type]");
  
  if (!strcmp(type, "static", true)) {
    if (!Iter_Contains(FlatRooms, flatid))
      return SendErrorMessage(playerid, "Invalid flat room ID");
    
    new freeid;

    if ((freeid = Iter_Free(FlatStaticStructs[flatid])) != cellmin) {
      SendCustomMessage(playerid, "FREEID", "Available for Flat ID: "YELLOW"%d "WHITE"Static structure ID: "YELLOW"%d", flatid, freeid);
    } else {
      SendErrorMessage(playerid, "There are no free static structures for this flat");
    }
  } else if (!strcmp(type, "custom", true)) {
    if (!Iter_Contains(FlatRooms, flatid))
      return SendErrorMessage(playerid, "Invalid flat room ID");
    
    new freeid;

    if ((freeid = Iter_Free(FlatStructures[flatid])) != cellmin) {
      SendCustomMessage(playerid, "FREEID", "Available for Flat ID: "YELLOW"%d "WHITE"Custom structure ID: "YELLOW"%d", flatid, freeid);
    } else {
      SendErrorMessage(playerid, "There are no free custom structures for this flat");
    }
  }
  return 1;
}

Dialog:Dialog_FlatMenu(playerid,response,listitem,inputtext[]) {
  new flatid;

  if ((flatid = FlatRoom_Inside(playerid)) != -1 && (FlatRoom_IsOwner(playerid, flatid) || FlatRoom_IsBuilder(playerid, flatid))) {
    if (response) {
      switch (listitem) {
        case 0: {
          cmd_flock(playerid);
          cmd_flatmenu(playerid);
        }
        case 1: {
          if (FlatRoom_IsBuilder(playerid, flatid))
            return SendErrorMessage(playerid, "Access denied");

          Flat_OpenStorage(playerid, flatid);
        }
        case 2: {
          if (FlatRoom_IsBuilder(playerid, flatid))
            return SendErrorMessage(playerid, "Access denied");

          FlatFurniture_Show(playerid, flatid);
        }
        case 3: {
          if (GetPlayerJob(playerid, 0) != JOB_BUILDER && GetPlayerJob(playerid, 1) != JOB_BUILDER)
            return SendErrorMessage(playerid, "You're not a Builder");

          Dialog_Show(playerid, Flat_Structures, DIALOG_STYLE_LIST, "Select Flat Structure", "Add structure\nMove structure\nRetexture structure\nDestroy structure\nCopy structure\nDestroy all structure\nStructure list\nMove furniture\nDestroy furniture\nStore furniture\nFurniture list", "Select", "Back");
        }
        case 4: {
          if (FlatRoom_IsBuilder(playerid, flatid))
            return SendErrorMessage(playerid, "Access denied");

          if (!FlatRoom[flatid][flatRoomBuilder])
            Dialog_Show(playerid, Flat_AssignBuilder, DIALOG_STYLE_INPUT, "Assign Builder", "Enter player id or name to assign", "Assign", "Back");
          else
            Dialog_Show(playerid, Flat_UnassignBuilder, DIALOG_STYLE_MSGBOX, "Unassign Builder", WHITE"Your flat is already assigned a Builder the contract will be expire on "GREEN"%s"WHITE", do you want to fired them?", "Yes", "Back", ConvertTimestamp(Time:FlatRoom[flatid][flatRoomBuilderTime]));
        }
      }
    }
  }
  return 1;
}

Dialog:Flat_AssignBuilder(playerid,response,listitem,inputtext[]) {
  if (!response) cmd_flatmenu(playerid);
  else {
    new flatid;
    if ((flatid = FlatRoom_Inside(playerid)) != -1 && FlatRoom_IsOwner(playerid, flatid)) {
      new userid;
      if (isnull(inputtext))
        return Dialog_Show(playerid, Flat_AssignBuilder, DIALOG_STYLE_INPUT, "Assign Builder", "Enter player id or name to assign", "Assign", "Back"), SendErrorMessage(playerid, "Invalid input!");

      if (sscanf(inputtext, "u", userid))
        return Dialog_Show(playerid, Flat_AssignBuilder, DIALOG_STYLE_INPUT, "Assign Builder", "Enter player id or name to assign", "Assign", "Back"), SendErrorMessage(playerid, "Invalid input!");

      if (!IsPlayerConnected(userid))
        return SendErrorMessage(playerid, "Invalid playerid or name!");

      if (userid == playerid)
        return SendErrorMessage(playerid, "Cannot assign yourself");

      if (GetPlayerJob(userid, 0) != JOB_BUILDER && GetPlayerJob(userid, 1) != JOB_BUILDER)
        return SendErrorMessage(playerid, "That player are not a Bulder");

      FlatRoom[flatid][flatRoomBuilder] = PlayerData[userid][pID];
      FlatRoom[flatid][flatRoomBuilderTime] = (gettime()+((24*3600)*7));
      SendCustomMessage(playerid, "FLAT", "You've been assigned "YELLOW"%s "WHITE"as your flat builder, it will automatically fired for 7 days.", ReturnName(userid, 0));
      SendCustomMessage(userid, "FLAT", ""YELLOW"%s "WHITE"has assigned you as flat builder.", ReturnName(playerid, 0));
    }
  }
  return 1;
}

Dialog:Flat_UnassignBuilder(playerid,response,listitem,inputtext[]) {
  if (!response) cmd_flatmenu(playerid);
  else {
    new flatid;
    if ((flatid = FlatRoom_Inside(playerid)) != -1 && FlatRoom_IsOwner(playerid, flatid)) {
      FlatRoom[flatid][flatRoomBuilder] = 0;
      FlatRoom[flatid][flatRoomBuilderTime] = 0;
      SendCustomMessage(playerid, "FLAT", "You've been unassigned your flat builder");
    }
  }
  return 1;
}

Dialog:Flat_EditStatic(playerid,response,listitem,inputtext[]) {
  if (response) {
    new flatid;
    if ((flatid = FlatRoom_Inside(playerid)) != -1) {
      new slot = ListedFlatStructures[playerid][listitem],
        info[512];
      
      PlayerData[playerid][pEditFlatStructure] = flatid;
      PlayerData[playerid][pEditStaticStructure] = slot;

      strcat(info, sprintf("Model\t%d\n", FlatStaticStruct[flatid][slot][structModel]));
      strcat(info, sprintf("Pos X\t%.2f\n", FlatStaticStruct[flatid][slot][structPos][0]));
      strcat(info, sprintf("Pos Y\t%.2f\n", FlatStaticStruct[flatid][slot][structPos][1]));
      strcat(info, sprintf("Pos Z\t%.2f\n", FlatStaticStruct[flatid][slot][structPos][2]));
      strcat(info, sprintf("Rot X\t%.2f\n", FlatStaticStruct[flatid][slot][structRot][0]));
      strcat(info, sprintf("Rot Y\t%.2f\n", FlatStaticStruct[flatid][slot][structRot][1]));
      strcat(info, sprintf("Rot Z\t%.2f\n", FlatStaticStruct[flatid][slot][structRot][2]));
      strcat(info, sprintf("Open editor\t\n"));
      strcat(info, sprintf("Destroy\t"));
      Dialog_Show(playerid, Flat_EditPage, DIALOG_STYLE_TABLIST, "Edit Static Flat", info, "Edit", "Close");
    }
  }
  return 1;
}

Dialog:Flat_EditPage(playerid,response,listitem,inputtext[]) {
  if (response) {
    SetPVarInt(playerid, "StaticStructUpdate", listitem);

    switch (listitem) {
      case 0: {
        Dialog_Show(playerid, Flat_StructureUpdate, DIALOG_STYLE_INPUT, "Edit Model", "Input new model id: "GREEN"(input below)", "Update", "Close");
      }
      case 1: {
        Dialog_Show(playerid, Flat_StructureUpdate, DIALOG_STYLE_INPUT, "Edit Pos X", "Input new Pos X: "GREEN"(input below)", "Update", "Close");
      }
      case 2: {
        Dialog_Show(playerid, Flat_StructureUpdate, DIALOG_STYLE_INPUT, "Edit Pos Y", "Input new Pos Y: "GREEN"(input below)", "Update", "Close");
      }
      case 3: {
        Dialog_Show(playerid, Flat_StructureUpdate, DIALOG_STYLE_INPUT, "Edit Pos Z", "Input new Pos Z: "GREEN"(input below)", "Update", "Close");
      }
      case 4: {
        Dialog_Show(playerid, Flat_StructureUpdate, DIALOG_STYLE_INPUT, "Edit Rot X", "Input new Rot X: "GREEN"(input below)", "Update", "Close");
      }
      case 5: {
        Dialog_Show(playerid, Flat_StructureUpdate, DIALOG_STYLE_INPUT, "Edit Rot Y", "Input new Rot Y: "GREEN"(input below)", "Update", "Close");
      }
      case 6: {
        Dialog_Show(playerid, Flat_StructureUpdate, DIALOG_STYLE_INPUT, "Edit Rot z", "Input new Rot z: "GREEN"(input below)", "Update", "Close");
      }
      case 7: {
        new flatid = PlayerData[playerid][pEditFlatStructure],
          slot = PlayerData[playerid][pEditStaticStructure];
        
        EditDynamicObject(playerid, FlatStaticStruct[flatid][slot][structObject]);
        SendCustomMessage(playerid, "FLAT", "You're now editing static structure "YELLOW"%d "WHITE"for flat ID: "YELLOW"%d", slot, flatid);
      }
      case 8: {
        new flatid = PlayerData[playerid][pEditFlatStructure],
          slot = PlayerData[playerid][pEditStaticStructure];
        
        SendCustomMessage(playerid, "FLAT", "You've deleted static structure "YELLOW"%d "WHITE"flat ID: "YELLOW"%d", slot, flatid);
        FlatStructure_Delete(flatid, slot, false);
      }
    }
  }
  return 1;
}

Dialog:Flat_StructureUpdate(playerid,response,listitem,inputtext[]) {
  if (response) {
    new index = GetPVarInt(playerid, "StaticStructUpdate"),
      flatid = PlayerData[playerid][pEditFlatStructure],
      slot = PlayerData[playerid][pEditStaticStructure];
    
    if (!Iter_Contains(FlatStaticStructs[flatid], slot))
      return SendErrorMessage(playerid, "Invalid structure ID");

    switch (index) {
      case 0: {
        new model;
        if (sscanf(inputtext, "d", model))
          return SendErrorMessage(playerid, "Invalid input"), DeletePVar(playerid, "StaticStructUpdate");

        FlatStaticStruct[flatid][slot][structModel] = model;
        FlatStructure_Refresh(flatid, slot, false);
        FlatStructure_Save(flatid, slot, false, SAVE_STRUCTURE_MODEL);
        SendCustomMessage(playerid, "FLAT", "You've been changed model id of static structure ID: "YELLOW"%d "WHITE"to "YELLOW"%d", slot, model);
        DeletePVar(playerid, "StaticStructUpdate");
      }
      case 1: {
        new Float:pos;
        if (sscanf(inputtext, "f", pos))
          return SendErrorMessage(playerid, "Invalid input"), DeletePVar(playerid, "StaticStructUpdate");

        FlatStaticStruct[flatid][slot][structPos][0] = pos;
        FlatStructure_Refresh(flatid, slot, false);
        FlatStructure_Save(flatid, slot, false, SAVE_STRUCTURE_POS);
        SendCustomMessage(playerid, "FLAT", "You've been changed Pos X of static structure ID: "YELLOW"%d "WHITE"to "YELLOW"%.2f", slot, pos);
        DeletePVar(playerid, "StaticStructUpdate");
      }
      case 2: {
        new Float:pos;
        if (sscanf(inputtext, "f", pos))
          return SendErrorMessage(playerid, "Invalid input"), DeletePVar(playerid, "StaticStructUpdate");

        FlatStaticStruct[flatid][slot][structPos][1] = pos;
        FlatStructure_Refresh(flatid, slot, false);
        FlatStructure_Save(flatid, slot, false, SAVE_STRUCTURE_POS);
        SendCustomMessage(playerid, "FLAT", "You've been changed Pos Y of static structure ID: "YELLOW"%d "WHITE"to "YELLOW"%.2f", slot, pos);
        DeletePVar(playerid, "StaticStructUpdate");
      }
      case 3: {
        new Float:pos;
        if (sscanf(inputtext, "f", pos))
          return SendErrorMessage(playerid, "Invalid input"), DeletePVar(playerid, "StaticStructUpdate");

        FlatStaticStruct[flatid][slot][structPos][2] = pos;
        FlatStructure_Refresh(flatid, slot, false);
        FlatStructure_Save(flatid, slot, false, SAVE_STRUCTURE_POS);
        SendCustomMessage(playerid, "FLAT", "You've been changed Pos Z of static structure ID: "YELLOW"%d "WHITE"to "YELLOW"%.2f", slot, pos);
        DeletePVar(playerid, "StaticStructUpdate");
      }
      case 4: {
        new Float:pos;
        if (sscanf(inputtext, "f", pos))
          return SendErrorMessage(playerid, "Invalid input"), DeletePVar(playerid, "StaticStructUpdate");

        FlatStaticStruct[flatid][slot][structRot][0] = pos;
        FlatStructure_Refresh(flatid, slot, false);
        FlatStructure_Save(flatid, slot, false, SAVE_STRUCTURE_POS);
        SendCustomMessage(playerid, "FLAT", "You've been changed Rot X of static structure ID: "YELLOW"%d "WHITE"to "YELLOW"%.2f", slot, pos);
        DeletePVar(playerid, "StaticStructUpdate");
      }
      case 5: {
        new Float:pos;
        if (sscanf(inputtext, "f", pos))
          return SendErrorMessage(playerid, "Invalid input"), DeletePVar(playerid, "StaticStructUpdate");

        FlatStaticStruct[flatid][slot][structRot][1] = pos;
        FlatStructure_Refresh(flatid, slot, false);
        FlatStructure_Save(flatid, slot, false, SAVE_STRUCTURE_POS);
        SendCustomMessage(playerid, "FLAT", "You've been changed Rot Y of static structure ID: "YELLOW"%d "WHITE"to "YELLOW"%.2f", slot, pos);
        DeletePVar(playerid, "StaticStructUpdate");
      }
      case 6: {
        new Float:pos;
        if (sscanf(inputtext, "f", pos))
          return SendErrorMessage(playerid, "Invalid input"), DeletePVar(playerid, "StaticStructUpdate");

        FlatStaticStruct[flatid][slot][structRot][2] = pos;
        FlatStructure_Refresh(flatid, slot, false);
        FlatStructure_Save(flatid, slot, false, SAVE_STRUCTURE_POS);
        SendCustomMessage(playerid, "FLAT", "You've been changed Rot Z of static structure ID: "YELLOW"%d "WHITE"to "YELLOW"%.2f", slot, pos);
        DeletePVar(playerid, "StaticStructUpdate");
      }
    }
  }
  return 1;
}
#include <YSI\y_hooks>
hook OnGameModeInitEx() {
  mysql_tquery(g_iHandle, "SELECT * FROM `flat`", "Flat_Load", "");
  mysql_tquery(g_iHandle, "SELECT * FROM `flatroom`", "FlatRoom_Load", "");
  return 1;
}

#if defined DEVELOPMENT
  hook OnPlayerEnterDynArea(playerid, areaid) {
    new info[2];
    Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, info);

    if (info[0] == FLAT_AREA_INDEX) {
      new flatroom = info[1];
      
      SendClientMessageEx(playerid, -1, "[debug]: you've entered flatroom area ID: "YELLOW"%d", flatroom);
    }
    return 1;
  }
#endif


hook OnPlayerLeaveDynArea(playerid, areaid) {
  new info[2];
  Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, info);

  if (info[0] == FLAT_AREA_INDEX) {
    #if defined DEVELOPMENT
      new flatroom = info[1];
      SendClientMessageEx(playerid, -1, "[debug]: you've leaving from flatroom area ID: "YELLOW"%d", flatroom);
    #endif

    CancelEdit(playerid);
  }
  return 1;
}


hook OnPlayerEditDynObj(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
  if (editDoorFlat[playerid] != -1 && PlayerData[playerid][pEditStaticStructure] != -1) {
    switch (response) {
      case EDIT_RESPONSE_CANCEL: {
        new flatid = editDoorFlat[playerid],
          slot = PlayerData[playerid][pEditStaticStructure];

        FlatStructure_Refresh(flatid, slot, false);
        SendCustomMessage(playerid,"FLATROOM","You've canceled editing flat door");
        editDoorFlat[playerid] = -1;
        PlayerData[playerid][pEditStaticStructure] = -1;
      }
      case EDIT_RESPONSE_FINAL: {
        new flatid = editDoorFlat[playerid],
          slot = PlayerData[playerid][pEditStaticStructure];

        FlatStaticStruct[flatid][slot][structPos][0] = x;
        FlatStaticStruct[flatid][slot][structPos][1] = y;
        FlatStaticStruct[flatid][slot][structPos][2] = z;
        FlatStaticStruct[flatid][slot][structRot][0] = rx;
        FlatStaticStruct[flatid][slot][structRot][1] = ry;
        FlatStaticStruct[flatid][slot][structRot][2] = rz;
        
        SetDynamicObjectPos(objectid,x,y,z);
        SetDynamicObjectRot(objectid,rx,ry,rz);
        FlatStructure_Refresh(flatid, slot, false);
        FlatStructure_Save(flatid, slot, false, SAVE_STRUCTURE_POS);

        PlayerData[playerid][pEditStaticStructure] = -1;
        editDoorFlat[playerid] = -1;

        SendCustomMessage(playerid,"FLATROOM","Flat door position has been saved");
      }
    }
  }

  if (PlayerData[playerid][pEditFurniture] != -1 && PlayerData[playerid][pEditFurnFlat] != -1) {
    new flatid = PlayerData[playerid][pEditFurnFlat],
      slot = PlayerData[playerid][pEditFurniture];

    switch (response) {
      case EDIT_RESPONSE_FINAL: {
        if (flatid != -1 && (FlatRoom_IsOwner(playerid, flatid) || FlatRoom_IsBuilder(playerid, flatid))) {
          if (!IsPointInDynamicArea(FlatRoom[flatid][flatRoomArea], x, y, z))
            return SendErrorMessage(playerid, "You can't place furniture outside the flat area"), CancelEdit(playerid), FlatFurniture_Refresh(slot, flatid);

          FlatFurniture[flatid][slot][furnPos][0] = x;
          FlatFurniture[flatid][slot][furnPos][1] = y;
          FlatFurniture[flatid][slot][furnPos][2] = z;
          FlatFurniture[flatid][slot][furnRot][0] = rx;
          FlatFurniture[flatid][slot][furnRot][1] = ry;
          FlatFurniture[flatid][slot][furnRot][2] = rz;
          
          SetDynamicObjectPos(objectid,x,y,z);
          SetDynamicObjectRot(objectid,rx,ry,rz);
          FlatFurniture_Refresh(slot, flatid);
          FlatFurniture_Save(slot, flatid);

          SendCustomMessage(playerid, "FURNITURE", "You have edited the position of item \"%s"WHITE"\".", FlatFurniture[flatid][slot][furnName]);

          PlayerData[playerid][pEditFurniture] = -1;
          PlayerData[playerid][pEditFurnHouse] = -1;
        }
      }
      case EDIT_RESPONSE_CANCEL: {
        FlatFurniture_Refresh(slot, flatid);
        PlayerData[playerid][pEditFurniture] = -1;
        PlayerData[playerid][pEditFurnHouse] = -1;
      }
    }
  }

  if (PlayerData[playerid][pEditStaticStructure] != -1 && PlayerData[playerid][pEditFlatStructure] != -1) {
    new flatid = PlayerData[playerid][pEditFlatStructure],
      slot = PlayerData[playerid][pEditStaticStructure];
    
    switch (response) {
      case EDIT_RESPONSE_FINAL: {
        FlatStaticStruct[flatid][slot][structPos][0] = x;
        FlatStaticStruct[flatid][slot][structPos][1] = y;
        FlatStaticStruct[flatid][slot][structPos][2] = z;
        FlatStaticStruct[flatid][slot][structRot][0] = rx;
        FlatStaticStruct[flatid][slot][structRot][1] = ry;
        FlatStaticStruct[flatid][slot][structRot][2] = rz;
        
        SetDynamicObjectPos(objectid,x,y,z);
        SetDynamicObjectRot(objectid,rx,ry,rz);
        FlatStructure_Refresh(flatid, slot, false);
        FlatStructure_Save(flatid, slot, false, SAVE_STRUCTURE_POS);

        SendCustomMessage(playerid, "FLAT", "You have edited the static structure position");

        PlayerData[playerid][pEditStaticStructure] = -1;
        PlayerData[playerid][pEditFlatStructure] = -1;
      }
      case EDIT_RESPONSE_CANCEL: {
        FlatStructure_Refresh(flatid, slot, false);
        PlayerData[playerid][pEditStaticStructure] = -1;
        PlayerData[playerid][pEditFlatStructure] = -1;
      }
    }
  }

  if (PlayerData[playerid][pEditStructure] != -1 && PlayerData[playerid][pEditFlatStructure] != -1) {
    new flatid = PlayerData[playerid][pEditFlatStructure],
      slot = PlayerData[playerid][pEditStructure];
    
    switch (response) {
      case EDIT_RESPONSE_FINAL: {
        if (flatid != -1 && (FlatRoom_IsOwner(playerid, flatid) || FlatRoom_IsBuilder(playerid, flatid))) {
          if (!IsPointInDynamicArea(FlatRoom[flatid][flatRoomArea], x, y, z))
            return SendErrorMessage(playerid, "You can't place structure outside the flat area"), CancelEdit(playerid), FlatStructure_Refresh(flatid, slot);

          FlatStructure[flatid][slot][structPos][0] = x;
          FlatStructure[flatid][slot][structPos][1] = y;
          FlatStructure[flatid][slot][structPos][2] = z;
          FlatStructure[flatid][slot][structRot][0] = rx;
          FlatStructure[flatid][slot][structRot][1] = ry;
          FlatStructure[flatid][slot][structRot][2] = rz;
          
          SetDynamicObjectPos(objectid,x,y,z);
          SetDynamicObjectRot(objectid,rx,ry,rz);
          FlatStructure_Refresh(flatid, slot);
          FlatStructure_Save(flatid, slot, true, SAVE_STRUCTURE_POS);

          SendCustomMessage(playerid, "FLAT", "You have edited the structure position of \"%s"WHITE"\".", GetStructureNameByModel(FlatStructure[flatid][slot][structModel]));

          PlayerData[playerid][pEditStructure] = -1;
          PlayerData[playerid][pEditFlatStructure] = -1;
        }
      }
      case EDIT_RESPONSE_CANCEL: {
        FlatStructure_Refresh(flatid, slot);
        PlayerData[playerid][pEditStructure] = -1;
        PlayerData[playerid][pEditFlatStructure] = -1;
      }
    }
  }
  return 1;
}


hook OnPlayerSelectDynObj(playerid, objectid, modelid, Float:x, Float:y, Float:z) {
  if (PlayerData[playerid][pEditFlatStructure] != -1) {
    new flatid = PlayerData[playerid][pEditFlatStructure];

    switch (SelectStructureType[playerid]) {
      case STRUCTURE_SELECT_EDITOR: {
        foreach (new i : FlatStructures[flatid]) if (FlatStructure[flatid][i][structObject] == objectid) {
          PlayerData[playerid][pEditStructure] = i;
          PlayerData[playerid][pEditFlatStructure] = flatid;
          EditDynamicObject(playerid, objectid);
          SendCustomMessage(playerid, "FLAT", "You're now editing %s.", GetStructureNameByModel(FlatStructure[flatid][i][structModel]));
          break;
        }
      }
      case STRUCTURE_SELECT_RETEXTURE: {
        foreach (new i : FlatStructures[flatid]) if (FlatStructure[flatid][i][structObject] == objectid) {
          PlayerData[playerid][pEditStructure] = i;
          PlayerData[playerid][pEditFlatStructure] = flatid;
          CancelEdit(playerid);
          Dialog_Show(playerid, Dialog_FlatRetexture, DIALOG_STYLE_INPUT, "Retexture Flat Structure", "Please input the texture name below:\n"YELLOW"[model] [txdname] [texture] [opt: alpha] [opt: red] [opt: green] [opt: blue]", "Retexture", "Cancel");
          break;
        }

        foreach (new i : FlatStaticStructs[flatid]) if (FlatStaticStruct[flatid][i][structObject] == objectid) {
          PlayerData[playerid][pEditStructure] = i;
          PlayerData[playerid][pEditFlatStructure] = flatid;
          CancelEdit(playerid);
          Dialog_Show(playerid, Dialog_StaticRetexture, DIALOG_STYLE_INPUT, "Retexture Flat Structure", "Please input the texture name below:\n"YELLOW"[model] [txdname] [texture] [opt: alpha] [opt: red] [opt: green] [opt: blue]", "Retexture", "Cancel");
          break;
        }
      }
      case STRUCTURE_SELECT_DELETE: {
        foreach (new i : FlatStructures[flatid]) if (FlatStructure[flatid][i][structObject] == objectid) {
          SendCustomMessage(playerid, "FLAT", "You've deleted %s", GetStructureNameByModel(FlatStructure[flatid][i][structModel]));
          FlatStructure_Delete(flatid, i);
          break;
        }
      }
      case STRUCTURE_SELECT_COPY: {
        foreach (new i : FlatStructures[flatid]) if (FlatStructure[flatid][i][structObject] == objectid) {
          new price;

          for (new id = 0; id < sizeof(g_aHouseStructure); id ++) if (g_aHouseStructure[id][e_StructureModel] == FlatStructure[flatid][i][structModel]) {
            price = g_aHouseStructure[id][e_StructureCost];
          }

          if (Inventory_Count(playerid, "Component") < price)
            return SendErrorMessage(playerid, "You need %d Component(s) to copy this structure.", price);

          new copyId = FlatStructure_Copy(flatid, i);

          if (copyId == cellmin)
            return SendErrorMessage(playerid, "Your flat has reached maximum of structure");
          
          Inventory_Remove(playerid, "Component", price);
          PlayerData[playerid][pEditStructure] = copyId;
          PlayerData[playerid][pEditFlatStructure] = flatid;
          EditDynamicObject(playerid, FlatStructure[flatid][copyId][structObject]);
          SendCustomMessage(playerid, "BUILDER", "You have copied structure for "GREEN"%d component(s)", price);
          SendCustomMessage(playerid, "BUILDER", "You're now editing copied object of %s.", GetStructureNameByModel(FlatStructure[flatid][i][structModel]));
          break;
        }
      }
    }
  }

  if (PlayerData[playerid][pEditFurnFlat] != -1) {
    new flatid = PlayerData[playerid][pEditFurnFlat];

    foreach (new slot : FlatFurnitures[flatid]) if (objectid == FlatFurniture[flatid][slot][furnObject]) {
      switch (SelectFurnitureType[playerid]) {
        case FURNITURE_SELECT_MOVE: {
          PlayerData[playerid][pEditFurniture] = slot;
          PlayerData[playerid][pEditFurnFlat] = flatid;

          EditDynamicObject(playerid, FlatFurniture[flatid][slot][furnObject]);
          SendCustomMessage(playerid, "FURNITURE", "You are now editing the position of \"%s"WHITE"\".", FlatFurniture[flatid][slot][furnName]);
          break;
        }
        case FURNITURE_SELECT_DESTROY: {
          SendCustomMessage(playerid, "FURNITURE", "You have destroyed furniture \"%s"WHITE"\".", FlatFurniture[flatid][slot][furnName]);
          FlatFurniture_Delete(slot, flatid);

          CancelEdit(playerid);
          PlayerData[playerid][pEditFurniture] = -1;
          PlayerData[playerid][pEditFurnFlat] = -1;
          break;
        }
        case FURNITURE_SELECT_STORE: {
          if (FlatFurniture[flatid][slot][furnUnused])
            return SendErrorMessage(playerid, "This furniture already stored."), CancelEdit(playerid);
          
          FlatFurniture[flatid][slot][furnUnused] = 1;
          FlatFurniture_Refresh(slot, flatid);
          FlatFurniture_Save(slot, flatid);
          SendCustomMessage(playerid, "FURNITURE", "You have stored furniture \"%s"WHITE"\" into your flat.", FlatFurniture[flatid][slot][furnName]);
          break;
        }
      }
    }
  }
  return 1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
  if(newkeys & KEY_CTRL_BACK) {
    new id = -1;

    if ((id = Flat_Nearest(playerid)) != -1 && IsPlayerInDynamicCP(playerid, FlatData[id][flatCPExt])) {
      if (FlatData[id][flatIntPos][0] == 0.0 && FlatData[id][flatIntPos][1] == 0.0 && FlatData[id][flatIntPos][2] == 0.0)
        return SendErrorMessage(playerid, "Flat is not initialized");
      
      SetPlayerPosEx(playerid, FlatData[id][flatIntPos][0],FlatData[id][flatIntPos][1],FlatData[id][flatIntPos][2]);
      SetPlayerVirtualWorld(playerid, FlatData[id][flatIntWorld]);
      SetPlayerInterior(playerid, FlatData[id][flatIntInterior]);
      SetPlayerWeather(playerid, 1);
      SetPlayerTime(playerid, 12, 0);
      PlayerData[playerid][pApartment] = FlatData[id][flatID];
      return 1;
    }

    if ((id = Flat_Inside(playerid)) != -1 && IsPlayerInDynamicCP(playerid, FlatData[id][flatCPInt])) {
      SetPlayerPosEx(playerid, FlatData[id][flatPos][0],FlatData[id][flatPos][1],FlatData[id][flatPos][2]);
      SetPlayerWeather(playerid, current_weather);
      SetPlayerTime(playerid, current_hour, 0);
      SetPlayerVirtualWorld(playerid, FlatData[id][flatWorld]);
      SetPlayerInterior(playerid, FlatData[id][flatInterior]);
      PlayerData[playerid][pApartment] = -1;
      return 1;
    }
  }
  return 1;
}
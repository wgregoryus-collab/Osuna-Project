#define MAX_TOLL 50
#define PosArrTollGate{%0} TollGate[%0][tPos][0], TollGate[%0][tPos][1], TollGate[%0][tPos][2], TollGate[%0][tPos][3], TollGate[%0][tPos][4], TollGate[%0][tPos][5]
#define MoveArrTollGate{%0} TollGate[%0][tMove][0], TollGate[%0][tMove][1], TollGate[%0][tMove][2], 3.0, TollGate[%0][tMove][3], TollGate[%0][tMove][4], TollGate[%0][tMove][5]

enum tollGate {
  tID,
  tObj,
  tStatus,
  tModel,
  Float:tPos[6],
  Float:tMove[6]
};
new TollGate[MAX_TOLL][tollGate],
    Iterator:Tolls<MAX_TOLL>;

new TollGate_Timer[MAX_TOLL];

#include <YSI\y_hooks>
hook OnGameModeInitEx() {
  mysql_pquery(g_iHandle, "SELECT * FROM `tollgate`", "TollGate_Load", "");
  return 1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
  if ((GetPlayerState(playerid) == PLAYER_STATE_DRIVER) && (newkeys & KEY_CROUCH)) {
    new id = -1;

    if ((id = TollGate_Nearest(playerid)) != -1) {
      TollGate_Operate(playerid, id);
    }
  }
  return 1;
}

hook OnPlayerUpdate(playerid) {
    if ((TollGate_Nearest(playerid)) != -1) {
        if(IsPlayerInVehicle(playerid, GetPlayerVehicleID(playerid)) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        	GameTextForPlayer(playerid, "~p~TOLL GATE~n~~w~USE ~r~/PAYTOLL ~w~OR PRESS ~r~H~n~~w~TO PAY TOLL FEE", 1000, 4);
    }
    return 1;
}

hook OnPlayerEditDynObj(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
  if (GetPVarInt(playerid, "editTollGateID") != -1) {
    new id = GetPVarInt(playerid, "editTollGateID"),
        mode = GetPVarInt(playerid, "editTollGateMode");

    if (response == EDIT_RESPONSE_CANCEL) {
      TollGate_Refresh(id);

      SetPVarInt(playerid, "editTollGateID", -1);
      SetPVarInt(playerid, "editTollGateMode", -1);

      SendCustomMessage(playerid, "TOLLGATE", "You've canceled editing toll gate.");
    } else if (response == EDIT_RESPONSE_FINAL) {
      if (mode == 0) {
        TollGate_SetObjectPos(id, x, y, z, rx, ry, rz);

        TollGate_Refresh(id);
        TollGate_Save(id);
        SendCustomMessage(playerid, "TOLLGATE", "You've sucessfully editing toll gate position!");
      } 
      
      if (mode == 1) {
        TollGate_SetObjectMove(id, x, y, z, rx, ry, rz);

        TollGate_Refresh(id);
        TollGate_Save(id);
        SendCustomMessage(playerid, "TOLLGATE", "You've successfully editing toll gate move!");
      }
      SetPVarInt(playerid, "editTollGateID", -1);
      SetPVarInt(playerid, "editTollGateMode", -1);
    }
  }

  return 1;
}


hook OnPlayerConnect(playerid) {
  SetPVarInt(playerid, "editTollGateID", -1);
  SetPVarInt(playerid, "editTollGateMode", -1);
  return 1;
}

Function:TollGate_Load() {
  new rows = cache_num_rows();

  for (new i = 0; i < rows; i ++) {
    cache_get_value_int(i, "ID", TollGate[i][tID]);
    cache_get_value_int(i, "Model", TollGate[i][tModel]);
    TollGate[i][tStatus] = 0;
    cache_get_value_float(i, "PosX", TollGate[i][tPos][0]);
    cache_get_value_float(i, "PosY", TollGate[i][tPos][1]);
    cache_get_value_float(i, "PosZ", TollGate[i][tPos][2]);
    cache_get_value_float(i, "RotX", TollGate[i][tPos][3]);
    cache_get_value_float(i, "RotY", TollGate[i][tPos][4]);
    cache_get_value_float(i, "RotZ", TollGate[i][tPos][5]);
    cache_get_value_float(i, "MoveX", TollGate[i][tMove][0]);
    cache_get_value_float(i, "MoveY", TollGate[i][tMove][1]);
    cache_get_value_float(i, "MoveZ", TollGate[i][tMove][2]);
    cache_get_value_float(i, "MoveRotX", TollGate[i][tMove][3]);
    cache_get_value_float(i, "MoveRotY", TollGate[i][tMove][4]);
    cache_get_value_float(i, "MoveRotZ", TollGate[i][tMove][5]);

    Iter_Add(Tolls, i);

    TollGate_Refresh(i);
  }
  printf("*** [GarudaPride Database: Loaded] toll gate data (%d count)", rows);
  return 1;
}

TollGate_Create(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
  new id = INVALID_ITERATOR_SLOT;

  if ((id = Iter_Free(Tolls)) != INVALID_ITERATOR_SLOT) {
    Iter_Add(Tolls, id);
    
    TollGate[id][tModel] = modelid;
    TollGate[id][tStatus] = 0;
    TollGate[id][tPos][0] = x;
    TollGate[id][tPos][1] = y;
    TollGate[id][tPos][2] = z;
    TollGate[id][tPos][3] = rx;
    TollGate[id][tPos][4] = ry;
    TollGate[id][tPos][5] = rz;
    TollGate[id][tMove][0] = x;
    TollGate[id][tMove][1] = y;
    TollGate[id][tMove][2] = z;
    TollGate[id][tMove][3] = rx;
    TollGate[id][tMove][4] = ry;
    TollGate[id][tMove][5] = rz;

    mysql_tquery(g_iHandle, sprintf("INSERT INTO `tollgate` (`Model`) VALUES ('%d');", modelid), "OnTollGateCreated", "d", id);
    return id;
  }
  return INVALID_ITERATOR_SLOT;
}

Function:OnTollGateCreated(id) {
  if (Iter_Contains(Tolls, id)) {
    TollGate[id][tID] = cache_insert_id();

    TollGate_Refresh(id);
    TollGate_Save(id);
    return 1;
  }
  return 0;
}

TollGate_Save(id) {
  new query[650];

  format(query,sizeof(query),"UPDATE `tollgate` SET `Model` = '%d', `PosX` = '%f', `PosY` = '%f', `PosZ` = '%f', `RotX` = '%f', `RotY` = '%f', `RotZ` = '%f', `MoveX` = '%f', `MoveY` = '%f', `MoveZ` = '%f', `MoveRotX` = '%f', `MoveRotY` = '%f', `MoveRotZ` = '%f' WHERE `ID` = '%d'",
  TollGate[id][tModel],
  TollGate[id][tPos][0],
  TollGate[id][tPos][1],
  TollGate[id][tPos][2],
  TollGate[id][tPos][3],
  TollGate[id][tPos][4],
  TollGate[id][tPos][5],
  TollGate[id][tMove][0],
  TollGate[id][tMove][1],
  TollGate[id][tMove][2],
  TollGate[id][tMove][3],
  TollGate[id][tMove][4],
  TollGate[id][tMove][5],
  TollGate[id][tID]
  );
  return mysql_tquery(g_iHandle, query);
}

TollGate_Delete(id) {
  if (Iter_Contains(Tolls, id)) {
    Iter_Remove(Tolls, id);
    mysql_tquery(g_iHandle, sprintf("DELETE FROM `tollgate` WHERE `ID` = '%d'", TollGate[id][tID]));

    if (IsValidDynamicObject(TollGate[id][tObj]))
      DestroyDynamicObject(TollGate[id][tObj]);

    TollGate[id][tID] = 0;
    TollGate[id][tObj] = INVALID_STREAMER_ID;
    return 1;
  }
  return 0;
}

TollGate_Refresh(id) {
  if (!IsValidDynamicObject(TollGate[id][tObj])) TollGate[id][tObj] = CreateDynamicObject(TollGate[id][tModel], PosArrTollGate{id});

  TollGate_Sync(id);
  TollGate[id][tStatus] = 0;
  return 1;
}

TollGate_Sync(id) {
  Streamer_SetIntData(STREAMER_TYPE_OBJECT,TollGate[id][tObj],E_STREAMER_MODEL_ID,TollGate[id][tModel]);
  Streamer_SetFloatData(STREAMER_TYPE_OBJECT,TollGate[id][tObj],E_STREAMER_X,TollGate[id][tPos][0]);
  Streamer_SetFloatData(STREAMER_TYPE_OBJECT,TollGate[id][tObj],E_STREAMER_Y,TollGate[id][tPos][1]);
  Streamer_SetFloatData(STREAMER_TYPE_OBJECT,TollGate[id][tObj],E_STREAMER_Z,TollGate[id][tPos][2]);
  Streamer_SetFloatData(STREAMER_TYPE_OBJECT,TollGate[id][tObj],E_STREAMER_R_X,TollGate[id][tPos][3]);
  Streamer_SetFloatData(STREAMER_TYPE_OBJECT,TollGate[id][tObj],E_STREAMER_R_Y,TollGate[id][tPos][4]);
  Streamer_SetFloatData(STREAMER_TYPE_OBJECT,TollGate[id][tObj],E_STREAMER_R_Z,TollGate[id][tPos][5]);
  return 1;
}

TollGate_Nearest(playerid) {
  new id = -1, Float: playerdist, Float: tempdist = 9999.0;
	
  foreach (new i : Tolls)
  {
        playerdist = GetPlayerDistanceFromPoint(playerid, TollGate[i][tPos][0], TollGate[i][tPos][1], TollGate[i][tPos][2]);
        if(playerdist > 10.0) continue;
	    if(playerdist <= tempdist) {
	        tempdist = playerdist;
	        id = i;
	    }
	}
	
  
  return id;
}

TollGate_Operate(playerid, id) {
  if (TollGate[id][tStatus] == 0) {
    if (TollGate[id][tModel] == 968) {
      if(GetFactionType(playerid) == FACTION_FIRE && PlayerData[playerid][pOnDuty]) {
        SendCustomMessage(playerid, "TOLL", "You have successfully opened a toll road at the expense of the government.");
        TollGate_Timer[id] = 1;

        TollGate[id][tStatus] = 1;

      	RotateDynamicObject(TollGate[id][tObj], TollGate[id][tMove][3], TollGate[id][tMove][4], TollGate[id][tMove][5], 1);

      	SetTimerEx("TollGate_Closed", 5000, false, "d", id);
      } else if(GetFactionType(playerid) == FACTION_POLICE && PlayerData[playerid][pOnDuty]) {
        SendCustomMessage(playerid, "TOLL", "You have successfully opened a toll road at the expense of the government.");
        TollGate_Timer[id] = 1;

        TollGate[id][tStatus] = 1;

      	RotateDynamicObject(TollGate[id][tObj], TollGate[id][tMove][3], TollGate[id][tMove][4], TollGate[id][tMove][5], 1);

      	SetTimerEx("TollGate_Closed", 5000, false, "d", id);
      } else if(GetFactionType(playerid) == FACTION_SHERIFF && PlayerData[playerid][pOnDuty]) {
        SendCustomMessage(playerid, "TOLL", "You have successfully opened a toll road at the expense of the government.");
        TollGate_Timer[id] = 1;

        TollGate[id][tStatus] = 1;  

      }	else if (Inventory_Count(playerid, "Toll Card") > 0) {
        Inventory_Remove(playerid, "Toll Card", 1);
        SendCustomMessage(playerid, "TOLL", "You've pay the toll with 1 toll card.");
        TollGate_Timer[id] = 1;
        
        TollGate[id][tStatus] = 1;

      	RotateDynamicObject(TollGate[id][tObj], TollGate[id][tMove][3], TollGate[id][tMove][4], TollGate[id][tMove][5], 1);

      	SetTimerEx("TollGate_Closed", 5000, false, "d", id);
      } else {
        if(PlayerData[playerid][pMoney] < 100) return SendErrorMessage(playerid, "You don't have that much money.");
        GiveMoney(playerid, -100);
        SendCustomMessage(playerid, "TOLL", "You've pay the toll with $1.00.");
        TollGate_Timer[id] = 1;

        TollGate[id][tStatus] = 1;

      	RotateDynamicObject(TollGate[id][tObj], TollGate[id][tMove][3], TollGate[id][tMove][4], TollGate[id][tMove][5], 1);

      	SetTimerEx("TollGate_Closed", 5000, false, "d", id);
      }
    } else {
      if(GetFactionType(playerid) == FACTION_FIRE && PlayerData[playerid][pOnDuty]) {
        SendCustomMessage(playerid, "TOLL", "You have successfully opened a toll road at the expense of the government.");
        MoveDynamicObject(TollGate[id][tObj], MoveArrTollGate{id});

      	TollGate_Timer[id] = 1;

      	TollGate[id][tStatus] = 1;

      	SetTimerEx("TollGate_Closed", 5000, false, "d", id);
      } else if(GetFactionType(playerid) == FACTION_POLICE && PlayerData[playerid][pOnDuty]) {
        SendCustomMessage(playerid, "TOLL", "You have successfully opened a toll road at the expense of the government.");
        MoveDynamicObject(TollGate[id][tObj], MoveArrTollGate{id});

      	TollGate_Timer[id] = 1;

      	TollGate[id][tStatus] = 1;

      	SetTimerEx("TollGate_Closed", 5000, false, "d", id);
      } else if(GetFactionType(playerid) == FACTION_SHERIFF && PlayerData[playerid][pOnDuty]) {
        SendCustomMessage(playerid, "TOLL", "You have successfully opened a toll road at the expense of the government.");
        MoveDynamicObject(TollGate[id][tObj], MoveArrTollGate{id});

        TollGate_Timer[id] = 1;

        TollGate[id][tStatus] = 1;

        SetTimerEx("TollGate_Closed", 5000, false, "d", id);  

      } else if (Inventory_Count(playerid, "Toll Card") > 0) {
        Inventory_Remove(playerid, "Toll Card", 1);
        SendCustomMessage(playerid, "TOLL", "You've pay the toll with 1 toll card.");
        MoveDynamicObject(TollGate[id][tObj], MoveArrTollGate{id});

      	TollGate_Timer[id] = 1;
      	
      	TollGate[id][tStatus] = 1;

      	SetTimerEx("TollGate_Closed", 5000, false, "d", id);
      } else {
        if(PlayerData[playerid][pMoney] < 100) return SendErrorMessage(playerid, "You don't have that much money.");
        GiveMoney(playerid, -100);
        SendCustomMessage(playerid, "TOLL", "You've pay the toll with $1.00.");
        MoveDynamicObject(TollGate[id][tObj], MoveArrTollGate{id});

      	TollGate_Timer[id] = 1;
      	
      	TollGate[id][tStatus] = 1;

      	SetTimerEx("TollGate_Closed", 5000, false, "d", id);
      }
    }
  } else {
    if (TollGate_Timer[id]) {
      SendErrorMessage(playerid, "Please wait for five seconds until gate closed!");
    }
  }
  return 1;
}

Function:TollGate_Closed(id) {
  if (TollGate[id][tModel] == 968) {
    TollGate[id][tStatus] = 0;
    RotateDynamicObject(TollGate[id][tObj], TollGate[id][tPos][3], TollGate[id][tPos][4], TollGate[id][tPos][5], 1.0);
    TollGate_Timer[id] = 0;
  } else {
    TollGate[id][tStatus] = 0;
    MoveDynamicObject(TollGate[id][tObj], TollGate[id][tPos][0], TollGate[id][tPos][1], TollGate[id][tPos][2], 3.0, TollGate[id][tPos][3], TollGate[id][tPos][4], TollGate[id][tPos][5]);
    TollGate_Timer[id] = 0;
  }
  return 1;
}

TollGate_SetObjectPos(id, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
  if (Iter_Contains(Tolls, id)) {
    TollGate[id][tPos][0] = x;
    TollGate[id][tPos][1] = y;
    TollGate[id][tPos][2] = z;
    TollGate[id][tPos][3] = rx;
    TollGate[id][tPos][4] = ry;
    TollGate[id][tPos][5] = rz;
    return 1;
  }
  return 0;
}

TollGate_SetObjectMove(id, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
  if (Iter_Contains(Tolls, id)) {
    TollGate[id][tMove][0] = x;
    TollGate[id][tMove][1] = y;
    TollGate[id][tMove][2] = z;
    TollGate[id][tMove][3] = rx;
    TollGate[id][tMove][4] = ry;
    TollGate[id][tMove][5] = rz;
    return 1;
  }
  return 0;
}

RotateDynamicObject(objectid, Float:rotX, Float:rotY, Float:rotZ, Float:Speed)
{
	new Float:X, Float:Y, Float:Z;
	new Float:SpeedConverted = floatmul(Speed, 0.01);
	GetDynamicObjectPos(objectid, X, Y, Z);
	SetDynamicObjectPos(objectid, X, Y, floatadd(Z, 0.01));
	MoveDynamicObject(objectid, X, Y, Z, SpeedConverted, rotX, rotY, rotZ);
	return 1;
}

CMD:paytoll(playerid, params[]) {
  if (!IsPlayerConnected(playerid))
    return SendErrorMessage(playerid, "You are not logged in!");

  if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You must to be driver to use this command!");

  new id = -1;

  if ((id = TollGate_Nearest(playerid)) != -1) {
    TollGate_Operate(playerid, id);
  } else {
    SendErrorMessage(playerid, "You are not in any toll gate.");
  }
  return 1;
}

// Admin Commands
CMD:tollgate(playerid, params[]) {
  if (CheckAdmin(playerid, 5))
    return PermissionError(playerid);

  new option[24], str[32];
  if (sscanf(params, "s[24]S()[32]", option, str)) {
    SendSyntaxMessage(playerid, "/tollgate [option]");
    SendClientMessageEx(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"create, delete, position, move, near");
    return 1;
  }

  if (!strcmp(option, "create")) {
    new id, modelid, Float:playerPos[3], Float:rotate[3];
    if (sscanf(str, "d", modelid)) return SendSyntaxMessage(playerid, "/tollgate create [modelid]");

    GetPlayerPos(playerid, playerPos[0], playerPos[1], playerPos[2]);
    rotate[0] = 0.0;
    rotate[1] = 0.0;
    rotate[2] = 0.0;

    id = TollGate_Create(modelid, playerPos[0], playerPos[1], playerPos[2], rotate[0], rotate[1], rotate[2]);

    SendCustomMessage(playerid, "TOLLGATE", "You've successfully created toll gate id: "YELLOW"%d", id);
  } else if (!strcmp(option, "delete")) {
    new id;
    if (sscanf(str, "d", id)) return SendSyntaxMessage(playerid, "/tollgate delete [tollgate id]");

    if (!Iter_Contains(Tolls, id)) return SendErrorMessage(playerid, "Invalid toll gate ID!");

    TollGate_Delete(id);

    SendCustomMessage(playerid, "TOLLGATE", "You've successfully deleted toll gate id: "YELLOW"%d", id);
  } else if (!strcmp(option, "position")) {
    new id;
    if (sscanf(str, "d", id)) return SendSyntaxMessage(playerid, "/tollgate position [tollgate id]");

    if (!Iter_Contains(Tolls, id)) return SendErrorMessage(playerid, "Invalid toll gate ID!");

    SetPVarInt(playerid, "editTollGateID", id);
    SetPVarInt(playerid, "editTollGateMode", 0);

    EditDynamicObject(playerid, TollGate[id][tObj]);
  } else if (!strcmp(option, "move")) {
    new id;
    if (sscanf(str, "d", id)) return SendSyntaxMessage(playerid, "/tollgate move [tollgate id]");

    if (!Iter_Contains(Tolls, id)) return SendErrorMessage(playerid, "Invalid toll gate ID!");

    SetPVarInt(playerid, "editTollGateID", id);
    SetPVarInt(playerid, "editTollGateMode", 1);

    EditDynamicObject(playerid, TollGate[id][tObj]);
  } else if (!strcmp(option, "near")) {
    new id = -1;

    if ((id = TollGate_Nearest(playerid)) != -1) {
      SendCustomMessage(playerid, "TOLLGATE", "Nearest toll gate id: "YELLOW"%d", id);
    }
  }
  return 1;
}

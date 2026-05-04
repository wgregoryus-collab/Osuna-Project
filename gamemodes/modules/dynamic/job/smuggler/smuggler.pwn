#define SMUGGLER_SALARY 25000
#define SetSmugglerDelay(%0,%1) PlayerData[%0][pSmugglerDelay] = %1
#define GetSmugglerDelay(%0)    PlayerData[%0][pSmugglerDelay]
#define MAX_PACKET 5

new selectedLocation;
new packetStatus[MAX_PACKET];
new packetPlayerid[MAX_PACKET] = {INVALID_PLAYER_ID, ...};
new packetObject[MAX_PACKET], Text3D:packetLabel[MAX_PACKET];
new packetActive = 0;

new Float:pickPacket[][3] = {
  {-1633.02, -2239.38, 31.47},
  {-2057.39, -2464.50, 31.17},
  {-418.21, 2229.03, 42.42},
  {1550.20, -29.35, 21.33},
  {-36.12, 2350.08, 24.30}
};

new Float:storePacket[][3] = {
  {-534.31, -103.06, 63.29},
  {-1426.72, 2170.94, 50.62},
  {870.05, -25.43, 63.95},
  {-127.32, 2259.13, 28.43},
  {-391.05, 2487.62, 41.14}
};

SendSmugglerMessage(text[]) {
  foreach (new i : Player) if (GetPlayerJob(i, 0) == JOB_SMUGGLER || GetPlayerJob(i, 1) == JOB_SMUGGLER) {
    SendCustomMessage(i, "SMUGGLER", "%s", text);
  }
  return 1;
}

task PacketUpdate[300000]() {
  if (packetActive == 0) {
    selectedLocation = random(sizeof(pickPacket));
    if (packetStatus[selectedLocation] == 0) {
      packetStatus[selectedLocation] = 1;
      packetObject[selectedLocation] = CreateDynamicObject(1279, pickPacket[selectedLocation][0], pickPacket[selectedLocation][1], pickPacket[selectedLocation][2]-0.9, 0.0, 0.0, 0.0, 0, 0);
      packetActive = 1;
      SendSmugglerMessage("New packet available '"YELLOW"/findpacket"WHITE"' to find the packet.");
    }
  } else SendSmugglerMessage("Smuggler job is currently active, use '"YELLOW"/findpacket"WHITE"' to find the packet.");
}

CMD:findpacket(playerid, params[]) {
  if (GetPlayerJob(playerid, 0) != JOB_SMUGGLER && GetPlayerJob(playerid, 1) != JOB_SMUGGLER)
    return SendErrorMessage(playerid, "You don't have the appropriate job.");

  if (GetSmugglerDelay(playerid) > 0)
    return SendErrorMessage(playerid, "You can work again in %d minutes.", GetSmugglerDelay(playerid) / 60);

  if (PlayerData[playerid][pSmugglerPick])
    return SendErrorMessage(playerid, "Kamu tidak bisa mengambil packet yang lain, karena kamu sedang mengantarkan paket.");

  if (packetStatus[selectedLocation] == 1) {
    SetPlayerWaypoint(playerid, "Pickup Packet", pickPacket[selectedLocation][0], pickPacket[selectedLocation][1], pickPacket[selectedLocation][2]);
    PlayerData[playerid][pSmugglerFind] = 1;
    SetPVarInt(playerid, "sedangSmuggler", 1);
    SendCustomMessage(playerid, "SMUGGLER", "Please goto the marked location to pickup the packet.");
  } else if (packetStatus[selectedLocation] == 2) {
    new Float:pos[3], Float:oPos[3];
    GetPlayerPos(packetPlayerid[selectedLocation], pos[0], pos[1], pos[2]);
    DisableWaypoint(playerid);
    SetPlayerWaypoint(playerid, "Player picked packet", pos[0], pos[1], pos[2]);

    if (packetPlayerid[selectedLocation] == INVALID_PLAYER_ID) {
      GetDynamicObjectPos(packetObject[selectedLocation], oPos[0], oPos[1], oPos[2]);
      SetPlayerWaypoint(playerid, "Packet position", oPos[0], oPos[1], oPos[2]);
    }
    SetPVarInt(playerid, "sedangSmuggler", 1);
    SendCustomMessage(playerid, "SMUGGLER", "Please goto the marked location to pickup the packet.");
  } else {
    SendErrorMessage(playerid, "Tidak ada paket yang perlu dikirim.");
  }
  return 1;
}

CMD:pickpacket(playerid, params[]) {
  if (GetPlayerJob(playerid, 0) != JOB_SMUGGLER && GetPlayerJob(playerid, 1) != JOB_SMUGGLER)
    return SendErrorMessage(playerid, "You don't have the appropriate job.");

  if (GetSmugglerDelay(playerid) > 0)
    return SendErrorMessage(playerid, "You can work again in %d minutes.", GetSmugglerDelay(playerid) / 60);

  new Float:oPos[3];
  GetDynamicObjectPos(packetObject[selectedLocation], oPos[0], oPos[1], oPos[2]);

  if (!IsPlayerInRangeOfPoint(playerid, 3.0, oPos[0], oPos[1], oPos[2]))
    return SendErrorMessage(playerid, "You're not near any packet.");

  SetPVarInt(playerid, "sedangNganter", 1);
  SetPVarInt(playerid, "sedangSmuggler", 0);

  DestroyDynamicObject(packetObject[selectedLocation]);
  packetObject[selectedLocation] = INVALID_STREAMER_ID;
  DestroyDynamic3DTextLabel(packetLabel[selectedLocation]);
  packetLabel[selectedLocation] = Text3D:INVALID_3DTEXT_ID;
  PlayerData[playerid][pSmugglerPick] = 1;
  PlayerData[playerid][pSmugglerFind] = 0;
  packetPlayerid[selectedLocation] = playerid;
  packetStatus[selectedLocation] = 2;
  SetPlayerWaypoint(playerid, "Store Packet", storePacket[selectedLocation][0], storePacket[selectedLocation][1], storePacket[selectedLocation][2]);
  SendCustomMessage(playerid, "SMUGGLER", "You've pickup the packet, please go to marked location to store this packet!");
  return 1;
}

CMD:getpacket(playerid, params[]) {
  if (GetPlayerJob(playerid, 0) != JOB_SMUGGLER && GetPlayerJob(playerid, 1) != JOB_SMUGGLER)
    return SendErrorMessage(playerid, "You don't have the appropriate job.");

  if (GetSmugglerDelay(playerid) > 0)
    return SendErrorMessage(playerid, "You can work again in %d minutes.", GetSmugglerDelay(playerid) / 60);

  if (GetPVarInt(playerid, "sedangSmuggler") == 1) {
    if (IsPlayerInRangeOfPoint(playerid, 3.0, pickPacket[selectedLocation][0], pickPacket[selectedLocation][1], pickPacket[selectedLocation][2]) && PlayerData[playerid][pSmugglerFind]) {
      packetPlayerid[selectedLocation] = playerid;
      packetStatus[selectedLocation] = 2;
      foreach (new i : Player) if (GetPlayerJob(i, 0) == JOB_SMUGGLER || GetPlayerJob(i, 1) == JOB_SMUGGLER) {
        if (GetPVarInt(i, "sedangSmuggler") == 1) {
          DisableWaypoint(i);
        }
        SendCustomMessage(i, "SMUGGLER", "Someone has already pickup the packet, packet was moved!");
        SendCustomMessage(i, "SMUGGLER", "Type /findpacket again to know the packet location.");
      }
      PlayerData[playerid][pSmugglerPick] = 1;
      PlayerData[playerid][pSmugglerFind] = 0;
      SetPVarInt(playerid, "sedangNganter", 1);
      SetPVarInt(playerid, "sedangSmuggler", 0);
      DestroyDynamicObject(packetObject[selectedLocation]);
      packetObject[selectedLocation] = INVALID_STREAMER_ID;
      SetPlayerWaypoint(playerid, "Store Packet", storePacket[selectedLocation][0], storePacket[selectedLocation][1], storePacket[selectedLocation][2]);
      ApplyAnimation(playerid, "BSKTBALL", "BBALL_pickup", 4.0, 0, 1, 1, 0, 0, 1);
      SendCustomMessage(playerid, "SMUGGLER", "You've pickup the packet, please go to marked location to store this packet!");
    } else return SendErrorMessage(playerid, "Please go to the marked location, to pickup the packet.");
  }
  return 1;
}

CMD:storepacket(playerid, params[]) {
  if (GetPlayerJob(playerid, 0) != JOB_SMUGGLER && GetPlayerJob(playerid, 1) != JOB_SMUGGLER)
    return SendErrorMessage(playerid, "You don't have the appropriate job.");

  if (GetSmugglerDelay(playerid) > 0)
    return SendErrorMessage(playerid, "You can work again in %d minutes.", GetSmugglerDelay(playerid) / 60);

  if (PlayerData[playerid][pSmugglerPick]) {
    if (PlayerData[playerid][pSmugglerPick] && IsPlayerInRangeOfPoint(playerid, 3.0, storePacket[selectedLocation][0], storePacket[selectedLocation][1], storePacket[selectedLocation][2])) {
      ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0, 1);
      GiveMoney(playerid, SMUGGLER_SALARY);
      PlayerData[playerid][pSmugglerPick] = 0;
      PlayerData[playerid][pSmugglerFind] = 0;
      packetPlayerid[selectedLocation] = INVALID_PLAYER_ID;
      packetStatus[selectedLocation] = 0;
      SetSmugglerDelay(playerid, 1800);
      DeletePVar(playerid, "sedangSmuggler");
      DeletePVar(playerid, "sedangNganter");
      RemovePlayerAttachedObject(playerid, JOB_SLOT);
      packetActive = 0;
      foreach (new i : Player) if (GetPlayerJob(i, 0) == JOB_SMUGGLER || GetPlayerJob(i, 1) == JOB_SMUGGLER) {
        PlayerData[i][pSmugglerPick] = 0;
        PlayerData[i][pSmugglerFind] = 0;
        DeletePVar(i, "sedangSmuggler");
        DeletePVar(i, "sedangNganter");
      }
      SendCustomMessage(playerid, "SMUGGLER", "You've been stored the packet and you'll received "GREEN"$%s", FormatNumber(SMUGGLER_SALARY));
    } else return SendErrorMessage(playerid, "Please go to the marked location, to store the packet.");
  }
  return 1;
}

CMD:droppacket(playerid) {
  if (GetPlayerJob(playerid, 0) != JOB_SMUGGLER && GetPlayerJob(playerid, 1) != JOB_SMUGGLER)
    return SendErrorMessage(playerid, "You don't have the appropriate job.");

  if (PlayerData[playerid][pSmugglerPick] == 0 && GetPVarInt(playerid, "sedangNganter") == 0)
    return SendErrorMessage(playerid, "You are not being sending any packet.");

  new Float:pos[3];
  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
  packetPlayerid[selectedLocation] = INVALID_PLAYER_ID;
  packetObject[selectedLocation] = CreateDynamicObject(1279, pos[0], pos[1], pos[2]-0.9, 0.0, 0.0, 0.0, 0, 0);
  packetLabel[selectedLocation] = CreateDynamic3DTextLabel("[Packet]\n"WHITE"Type "YELLOW"/pickpacket"WHITE" to pick the packet.", COLOR_CLIENT, pos[0], pos[1], pos[2]+0.5, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1);
  PlayerData[playerid][pSmugglerPick] = 0;
  PlayerData[playerid][pSmugglerFind] = 0;
  DisablePlayerRaceCheckpoint(playerid);
  SendCustomMessage(playerid, "SMUGGLER", "You've dropped the packet..");
  DeletePVar(playerid, "sedangSmuggler");
  DeletePVar(playerid, "sedangNganter");
  return 1;
}

CMD:resetsmuggler(playerid, params[]) {
  if (CheckAdmin(playerid, 7))
    return PermissionError(playerid);

  packetActive = 0;
  packetPlayerid[selectedLocation] = INVALID_PLAYER_ID;
  packetStatus[selectedLocation] = 0;
  foreach (new i : Player) if (GetPlayerJob(i, 0) == JOB_SMUGGLER || GetPlayerJob(i, 1) == JOB_SMUGGLER) {
    PlayerData[i][pSmugglerPick] = 0;
    PlayerData[i][pSmugglerFind] = 0;
    DeletePVar(i, "sedangSmuggler");
    DeletePVar(i, "sedangNganter");
  }
  SendCustomMessage(playerid, "RESET", "You've reseted smuggler packet.");
  return 1;
}

#include <YSI\y_hooks>
hook OnPlayerEnterRaceCP(playerid)
{
  if (GetPlayerJob(playerid, 0) == JOB_SMUGGLER || GetPlayerJob(playerid, 1) == JOB_SMUGGLER) {
    if (GetPVarInt(playerid, "sedangSmuggler") == 1) {
      SendCustomMessage(playerid, "SMUGGLER", "Type /getpacket to pickup the packet.");
    } else if (GetPVarInt(playerid, "sedangNganter") == 1) {
      SendCustomMessage(playerid, "SMUGGLER", "Type /storepacket to store this packet.");
    }
  }
  return 1;
}
/*hook OnPlayerDeath(playerid) {
  if (GetPVarInt(playerid, "sedangNganter")) {
    if ((GetPlayerJob(playerid, 0) == JOB_SMUGGLER || GetPlayerJob(playerid, 1) == JOB_SMUGGLER) && PlayerData[playerid][pSmugglerPick]) {
      new Float:pos[3];
      GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
      packetObject[selectedLocation] = CreateDynamicObject(1279, pos[0], pos[1], pos[2]-0.9, 0.0, 0.0, 0.0, 0, 0);
      packetLabel[selectedLocation] = CreateDynamic3DTextLabel("[Packet]\n"WHITE"Type "YELLOW"/pickpacket"WHITE" to pick the packet.", COLOR_CLIENT, pos[0], pos[1], pos[2]+0.5, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1);
      packetPlayerid[selectedLocation] = INVALID_PLAYER_ID;
      PlayerData[playerid][pSmugglerPick] = 0;
      PlayerData[playerid][pSmugglerFind] = 0;
      DisablePlayerRaceCheckpoint(playerid);
      SendCustomMessage(playerid, "SMUGGLER", "You've failed store a packet.");
      SetSmugglerDelay(playerid, 300);
      DeletePVar(playerid, "sedangSmuggler");
      DeletePVar(playerid, "sedangNganter");
    }
  }
  return 1;
}


hook OnPlayerDisconnectExEx(playerid) {
  if (GetPVarInt(playerid, "sedangNganter")) {
    if ((GetPlayerJob(playerid, 0) == JOB_SMUGGLER || GetPlayerJob(playerid, 1) == JOB_SMUGGLER) && PlayerData[playerid][pSmugglerPick]) {
      new Float:pos[3];
      GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
      packetObject[selectedLocation] = CreateDynamicObject(1279, pos[0], pos[1], pos[2]-0.9, 0.0, 0.0, 0.0, 0, 0);
      packetLabel[selectedLocation] = CreateDynamic3DTextLabel("[Packet]\n"WHITE"Type "YELLOW"/pickpacket"WHITE" to pick the packet.", COLOR_CLIENT, pos[0], pos[1], pos[2]+0.5, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1);
      packetPlayerid[selectedLocation] = INVALID_PLAYER_ID;
      PlayerData[playerid][pSmugglerPick] = 0;
      PlayerData[playerid][pSmugglerFind] = 0;
      DisablePlayerRaceCheckpoint(playerid);
      SendCustomMessage(playerid, "SMUGGLER", "You've failed store a packet.");
      SetSmugglerDelay(playerid, 300);
      DeletePVar(playerid, "sedangSmuggler");
      DeletePVar(playerid, "sedangNganter");
    }
  }
  PlayerData[playerid][pSmugglerPick] = 0;
  PlayerData[playerid][pSmugglerFind] = 0;
  DeletePVar(playerid, "sedangSmuggler");
  DeletePVar(playerid, "sedangNganter");
  return 1;
}*/

CMD:robpoint(playerid, params[]) {
  if (CheckAdmin(playerid, 6))
    return PermissionError(playerid);

  new opsi[24], value[24];
  if (sscanf(params, "s[24]S()[24]", opsi, value)) {
    SendSyntaxMessage(playerid, "/robpoint [option]");
    SendClientMessageEx(playerid, X11_YELLOW_2, "[options]: "WHITE"create, position, money, int, world, delete");
    return 1;
  }

  if (!strcmp(opsi, "create")) {
    new id, Float:poss[3];

    GetPlayerPos(playerid, poss[0], poss[1], poss[2]);
    id = RobPoint_Create(playerid, poss[0], poss[1], poss[2]);

    SendCustomMessage(playerid, "ROBPOINT", "You've created Rob Point ID: %d", id);
  } else if (!strcmp(opsi, "position")) {
    new id, Float:poss[3];

    if (sscanf(value, "d", id))
      return SendSyntaxMessage(playerid, "/robpoint location [id]");

    if (!Iter_Contains(Rob, id))
      return SendErrorMessage(playerid, "Invalid id!");

    GetPlayerPos(playerid, poss[0], poss[1], poss[2]);
    RobPoint[id][robPos][0] = poss[0];
    RobPoint[id][robPos][1] = poss[1];
    RobPoint[id][robPos][2] = poss[2];
    RobPoint_Refresh(id);
    RobPoint_Save(id);
    SendCustomMessage(playerid, "ROBPOINT", "You've been changed location of rob point id: %d to your current location", id);
  } else if (!strcmp(opsi, "money")) {
    new id, amount;

    if (sscanf(value, "dd", id, amount))
      return SendSyntaxMessage(playerid, "/robpoint money [id] [amount]");

    if (!Iter_Contains(Rob, id))
      return SendErrorMessage(playerid, "Invalid id!");

    RobPoint[id][robAmountMoney] = amount;
    RobPoint_Refresh(id);
    RobPoint_Save(id);
    SendCustomMessage(playerid, "ROBPOINT", "You've been changed money of rob point id: %d to %d", id, amount);
  } else if (!strcmp(opsi, "int")) {
    new id, amount;

    if (sscanf(value, "dd", id, amount))
      return SendSyntaxMessage(playerid, "/robpoint int [id] [interior id]");

    if (!Iter_Contains(Rob, id))
      return SendErrorMessage(playerid, "Invalid id!");

    RobPoint[id][robInt] = amount;
    RobPoint_Refresh(id);
    RobPoint_Save(id);
    SendCustomMessage(playerid, "ROBPOINT", "You've been changed interior rob point id: %d to %d", id, amount);
  } else if (!strcmp(opsi, "world")) {
    new id, amount;

    if (sscanf(value, "dd", id, amount))
      return SendSyntaxMessage(playerid, "/robpoint world [id] [world id]");

    if (!Iter_Contains(Rob, id))
      return SendErrorMessage(playerid, "Invalid id!");

    RobPoint[id][robWorld] = amount;
    RobPoint_Refresh(id);
    RobPoint_Save(id);
    SendCustomMessage(playerid, "ROBPOINT", "You've been changed virtual world rob point id: %d to %d", id, amount);
  } else if (!strcmp(opsi, "delete")) {
    new id;
    if (sscanf(value, "d", id))
      return SendSyntaxMessage(playerid, "/robpoint delete [id]");

    if (!Iter_Contains(Rob, id))
      return SendErrorMessage(playerid, "Invalid id!");

    RobPoint_Delete(id);
    SendCustomMessage(playerid, "ROBPOINT", "You've been deleted rob point id: %d", id);
  }
  return 1;
}

CMD:rob(playerid, params[]) {
  if (PlayerData[playerid][pScore] < 3)
    return SendErrorMessage(playerid, "You need to be level 3 or higher to use this command!");

  if(GetFactionType(playerid) != FACTION_GANG)
    return SendErrorMessage(playerid, "Only official family can use this command!");

  if (PlayerData[playerid][pRob])
    return SendErrorMessage(playerid, "You're being robbed, please wait for a while!");

  new id;
  if ((id = RobPoint_Nearest(playerid)) != -1) {
    if (RobPoint[id][robAmountMoney] < 5000)
      return SendErrorMessage(playerid, "Minimal uang yang ada dibrankas harus $5000.");

    if (RobPoint[id][robRobbed])
      return SendErrorMessage(playerid, "This safe are being robbed!");

    RobPoint[id][robRobbed] = 1;
    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 1, 0, 0, 0, 0, 1);
    SetTimerEx("RobTimer", 120000, false, "dd", playerid, id);
    SendWarning(1);
    PlayerData[playerid][pRob] = 1;
    SendCustomMessage(playerid, "ROB", "You're being robbed rob point id "YELLOW"%d "WHITE"please wait for a while.", id);
  } else return SendErrorMessage(playerid, "You are not near in any Rob Point!");
  return 1;
}

Function:RobTimer(playerid, robpoint) {
  new rand = RandomEx(0,2);

  if (rand == 1) {
    SendCustomMessage(playerid, "ROBBANK", "Kamu berhasil merampok bank !");

    PlayerData[playerid][pRob] = 0;

    ClearAnimations(playerid, 1);

    GiveMoney(playerid, RobPoint[robpoint][robAmountMoney]);
    RobPoint[robpoint][robAmountMoney] = 0;
    RobPoint[robpoint][robRobbed] = 0;
    RobPoint_Save(robpoint);
    RobPoint_Refresh(robpoint);
  } else {
    SendCustomMessage(playerid, "ROBBANK", "Brankas tidak dapat dibobol, silahkan coba lagi!");
    ClearAnimations(playerid, 1);
    PlayerData[playerid][pRob] = 0;
    RobPoint[robpoint][robRobbed] = 0;
  }
  return 1;
}
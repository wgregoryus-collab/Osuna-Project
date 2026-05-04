// VIP SYSTEM
#define MAX_VIPS 100

enum vipData {
  vipID,
  vipCode,
  vipType,
  vipTime,
  vipGold,
  vipClaim
};

new VipData[MAX_VIPS][vipData],
    Iterator: Vips<MAX_VIPS>;

#include <YSI\y_hooks>
hook OnGameModeInitEx() {
  mysql_tquery(g_iHandle, "SELECT * FROM `vips`", "Vip_Load", "");
  return 1;
}


hook OnGameModeExit() {
  foreach (new i : Vips) {
    Vip_Save(i);
  }
  Iter_Clear(Vips);
  return 1;
}

Function:Vip_Load() {
  new
      rows = cache_num_rows();

  for (new i = 0; i < rows; i ++) if (i < MAX_VIPS) {

    cache_get_value_int(i, "ID", VipData[i][vipID]);
    cache_get_value_int(i, "Code", VipData[i][vipCode]);
    cache_get_value_int(i, "Type", VipData[i][vipType]);
    cache_get_value_int(i, "Time", VipData[i][vipTime]);
    cache_get_value_int(i, "Gold", VipData[i][vipGold]);
    cache_get_value_int(i, "Claim", VipData[i][vipClaim]);

    Iter_Add(Vips, i);
  }
  printf("*** [GarudaPride Database: Loaded] vip data (%d count).", rows);
  return 1;
}

Function:onVipCreated(id) {
  if (!Iter_Contains(Vips, id))
    return 0;

  VipData[id][vipID] = cache_insert_id();

  Vip_Save(id);
  return 1;
}

Vip_Create(playerid, code, type, time, gold) {
  for (new id; id < MAX_VIPS; id ++) if (!Iter_Contains(Vips, id)) {
    new query[128];

    if (id == -1) return SendErrorMessage(playerid, "Cannot create more giftcodes!");

    VipData[id][vipCode] = code;
    VipData[id][vipType] = type;
    VipData[id][vipTime] = time;
    VipData[id][vipGold] = gold;
    VipData[id][vipClaim] = 0;

    Iter_Add(Vips, id);
    
    format(query,sizeof(query),"INSERT INTO `vips` SET `Code` = '%d', `Type` = '%d', `Time` = '%d', `Gold` = '%d', `Claim` = '%d'",
    VipData[id][vipCode],
    VipData[id][vipType],
    VipData[id][vipTime],
    VipData[id][vipGold],
    VipData[id][vipClaim]);

    mysql_tquery(g_iHandle, query, "onVipCreated", "d", id);

    return id;
  }
  return -1;
}

Vip_Save(id) {
  new query[768];

  format(query,sizeof(query),"UPDATE `vips` SET `Code` = '%d', `Type` = '%d', `Time` = '%d', `Claim` = '%d' WHERE `ID` = '%d'",
  VipData[id][vipCode], VipData[id][vipType], VipData[id][vipTime], VipData[id][vipClaim], VipData[id][vipID]);

  return mysql_tquery(g_iHandle, query);
}

GetVipType(playerid) {
  new type[34];

  switch (PlayerData[playerid][pVip]) {
    case 0: type = ""RED"None";
    case 1: type = ""GREEN"Basic Donator";
    case 2: type = ""GREEN"Advanced Donator";
    case 3: type = ""GREEN"Professional Donator";
    case 4: type = ""GREEN"Lifetime Donator";
  }

  return type;
}

GetVipTime(playerid) {
  static time[64];

  if (PlayerData[playerid][pVip] >= 1) {
    if (PlayerData[playerid][pVipTime] != 0) {
      format(time,sizeof(time), ""LIGHT_BLUE"%s", ConvertTimestamp(Time:PlayerData[playerid][pVipTime]));
    } else {
      format(time,sizeof(time), ""RED"Expired");
    }
  } else format(time,sizeof(time),""RED"None");

  return time;
}

// Commands
CMD:creategiftcode(playerid, params[]) {
  if (CheckAdmin(playerid, 8))
    return PermissionError(playerid);

  new
    id,
    type,
    time,
    code,
    gold
  ;

  if (sscanf(params, "ddd", type, time, gold)) {
    SendSyntaxMessage(playerid, "/creategiftcode [type] [days] [gold]");
    SendClientMessage(playerid, X11_YELLOW_2, "[TYPE]: 1 = Basic, 2 = Advanced, 3 = Professional, 4 = Lifetime");
    return 1;
  }

  code = RandomEx(111111, 999999);

  if (type == 4) {
    time = 365;
  }

  foreach (new i : Vips) {
    if (VipData[i][vipCode] == code) {
      return SendErrorMessage(playerid, "Vip Code already registered! Please try again.");
    }
  }
  id = Vip_Create(playerid, code, type, time, gold);
  SendCustomMessage(playerid, "VIP", "Giftcode has been created successfully, code: %d, id: %d", code, id);
  return 1;
}

CMD:redeem(playerid, params[]) {
  new code;

  if (sscanf(params, "d", code))
    return SendSyntaxMessage(playerid, "/redeem [code]");

  foreach (new i : Vips) {
    if (VipData[i][vipCode] == code) {
      if (VipData[i][vipClaim] == 1)
        return SendErrorMessage(playerid, "This code is expired!");

      if (PlayerData[playerid][pVipTime] > 0)
        return SendErrorMessage(playerid, "You has already active donator!");

      PlayerData[playerid][pVip] = VipData[i][vipType];
      PlayerData[playerid][pVipTime] = (gettime()+((24*3600)*VipData[i][vipTime]));
      PlayerData[playerid][pGold] += VipData[i][vipGold];
      VipData[i][vipClaim] = 1;
      Vip_Save(i);
      SendCustomMessage(playerid, "VIP", "Your vip code has successfully claimed!");
      SendCustomMessage(playerid, "VIP", "You got %s "WHITE"expired on: %s"WHITE" and Gold: %d.", GetVipType(playerid), GetVipTime(playerid), VipData[i][vipGold]);
    }
  }
  return 1;
}

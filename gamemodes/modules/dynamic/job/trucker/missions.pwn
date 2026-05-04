#define MAX_TRUCKER_MISSIONS (10)

new bool:DialogMissions[MAX_TRUCKER_MISSIONS];
new TrailerMission[MAX_PLAYERS];
new PlayerMissions[MAX_PLAYERS];

enum truckerMissions {
  issuerName[32],
  salaryCost,
  Float:takeTrailerX,
  Float:takeTrailerY,
  Float:takeTrailerZ,
  Float:trailerAngle,
  Float:sendTrailerX,
  Float:sendTrailerY,
  Float:sendTrailerZ
};

new const TruckerMissions[MAX_TRUCKER_MISSIONS][truckerMissions] =

{                                             // Checkpoint Ambil Trailer       || // Checkpoint Deliver Trailer
  {"Woods Export To Ocean Doaks", 45000, -446.8232, -64.7943, 60.3277, 181.7968, 2791.4016, -2494.5452, 14.2522}, // Export Kayu 
  {"Ocean Doaks To Sprunk Shop", 43000, 2784.3132, -2456.6299, 14.2415, 89.4938, 1336.9116, 285.6049, 19.5615}, // Import Sprunk
  {"Import Woods To Lumberyard", 42000, -459.3511, -48.3457, 60.5507, 182.7280, 2415.7803, -2470.1309, 13.6300}, // Import Kayu
  {"Oil Factory To Gas Station #1", 40000, -1046.0822, -649.9998, 33.0233, 268.7181, 984.9564, -897.3383, 42.4191}, // Restock Gas Station Vinewood
  {"Oil Factory To Gas Station #2", 40000, -1044.7971, -661.9905, 32.0126, 268.7328, 1937.0649, -1773.0552, 13.3828}, // RestocK Gas Station Idlewood
  {"Oil Factory To Gas Station #3", 38000, -1053.6145, -658.6473, 32.6319, 260.6392, -99.6251, -1167.0382, 2.6273},  // Restock Gas Station Flint County
  {"Import Water To Water Factory", 37500, -543.9775, -497.7669, 26.5399, 359.1365, 2393.8257, -2126.5002, 13.5469}, // Import Air ke Pabrik Air
  {"Export Trash To Ocean Doaks", 27000, -1855.7255, -1726.0389, 22.3566, 124.4187, 2786.8313, -2417.9558, 13.6339}, // Export Sampah
  {"Import Ore To Ocean Doaks", 37000, 2521.6648, -957.3253, 82.4427, 182.2460, 2414.3386, -2469.0791, 14.6544}, // Export batu
  {"Las Venturas Fuel & Gas", 25000, 249.6713, 1395.7150, 11.1923, 269.0699, -2226.1292, -2315.1055, 30.6045}
};

#include <YSI\y_hooks>
hook OnPlayerEnterRaceCP(playerid) {
  if (PlayerData[playerid][pMissions] != 0 && !PlayerData[playerid][pTrailer]) {
    new index = PlayerMissions[playerid];

    DisablePlayerRaceCheckpoint(playerid);
    SendCustomMessage(playerid, "MISSIONS","Attach the trailer to your vehicle to order");
    PlayerData[playerid][pTrailer] = 1;
    SetPlayerRaceCheckpoint(playerid, 1, TruckerMissions[index][sendTrailerX], TruckerMissions[index][sendTrailerY], TruckerMissions[index][sendTrailerZ], 0.0, 0.0, 0.0, 10.0);
    return 1;
  }
  
  if (PlayerData[playerid][pTrailer] != 0 && PlayerData[playerid][pMissions] && !IsPlayerShowWaypoint(playerid)) {
    if (IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid))) {
      new index = PlayerMissions[playerid];
      DisablePlayerRaceCheckpoint(playerid);
      DestroyVehicle(TrailerMission[playerid]);
      TrailerMission[playerid] = INVALID_VEHICLE_ID;
      PlayerData[playerid][pTrailer] = 0;
      PlayerData[playerid][pMissions] = 0;
      PlayerData[playerid][pMissionsDelay] = 900;
      DialogMissions[index] = false;
      AddPlayerSalary(playerid, TruckerMissions[index][salaryCost], "Trucker Missions");
      PlayerMissions[playerid] = -1;
    }
    return 1;
  }
  return 1;
}


hook OnPlayerConnect(playerid) {
  PlayerData[playerid][pTrailer] = 0;
  PlayerData[playerid][pMissions] = 0;
  TrailerMission[playerid] = INVALID_VEHICLE_ID;
  PlayerMissions[playerid] = -1;
  return 1;
}


hook OnPlayerDisconnectEx(playerid) {
  if (PlayerData[playerid][pMissions]) {
    if (IsValidVehicle(TrailerMission[playerid]))
      DestroyVehicle(TrailerMission[playerid]);

    PlayerData[playerid][pTrailer] = 0;
    PlayerData[playerid][pMissions] = 0;

    if (PlayerMissions[playerid] != -1)
      DialogMissions[PlayerMissions[playerid]] = false;
      
    PlayerMissions[playerid] = -1;
  }
  return 1;
}

CMD:missions(playerid) {
  if (GetPlayerJob(playerid, 0) != JOB_COURIER && GetPlayerJob(playerid, 1) != JOB_COURIER)
    return SendErrorMessage(playerid, "You're not a trucker.");

  if(!PlayerData[playerid][pTruckerLicenseExpired])
    return SendErrorMessage(playerid, "You don't have any valid trucker license.");

  if (PlayerData[playerid][pMissionsDelay])
    return SendErrorMessage(playerid, "You must wait for %d minutes to take missions again!", (PlayerData[playerid][pMissionsDelay]/30));

  if (!IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    return SendErrorMessage(playerid, "You must to be driver to use this command!");

  if (!IsATruck(GetPlayerVehicleID(playerid)))
    return SendErrorMessage(playerid, "You must use truck mission to doing missions!");

  if (PlayerData[playerid][pMissions] != 0)
    return SendErrorMessage(playerid, "You already taken truck missions!");

  new str[640];

  format(str, sizeof(str), "Order\tPrice\n");
  for (new i = 0; i < MAX_TRUCKER_MISSIONS; i ++) {
    format(str, sizeof(str), "%s%s\t"GREEN"$%s\n", str, TruckerMissions[i][issuerName], (DialogMissions[i] == true) ? (RED"TAKEN") : (FormatNumber(TruckerMissions[i][salaryCost])));
  }
  Dialog_Show(playerid, TruckMissions, DIALOG_STYLE_TABLIST_HEADERS, "Missions", str, "Take", "Close");
  return 1;
}

SetPlayerMissionsCP(playerid) {
  if ((GetPlayerJob(playerid, 0) == JOB_COURIER || GetPlayerJob(playerid, 1) == JOB_COURIER) && PlayerData[playerid][pMissions]) {
    new index = PlayerMissions[playerid];

    SetPlayerRaceCheckpoint(playerid, 1, TruckerMissions[index][takeTrailerX], TruckerMissions[index][takeTrailerY], TruckerMissions[index][takeTrailerZ], 0.0, 0.0, 0.0, 10.0);
    TrailerMission[playerid] = CreateVehicle(435, TruckerMissions[index][takeTrailerX], TruckerMissions[index][takeTrailerY], TruckerMissions[index][takeTrailerZ], TruckerMissions[index][trailerAngle], 1, 1, -1);
  }
  return 1;
}

CMD:attachtrailer(playerid, params[]) {
  if (GetPlayerJob(playerid, 0) != JOB_COURIER && GetPlayerJob(playerid, 1) != JOB_COURIER) return SendErrorMessage(playerid, "You're not a trucker.");

  if (!PlayerData[playerid][pMissions]) return SendErrorMessage(playerid, "Kamu tidak sedang melakukan truck missions!");
  new vehicleid = TrailerMission[playerid], Float:vPos[3];
  GetVehiclePos(vehicleid, vPos[0], vPos[1], vPos[2]);
  if (!IsPlayerInRangeOfPoint(playerid, 10.0, vPos[0], vPos[1], vPos[2])) return SendErrorMessage(playerid, "Trailer truck kamu tidak berada didekatmu!");
  if (!IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Kamu harus di kendaraan untuk menggunakan perintah ini!");

  AttachTrailerToVehicle(vehicleid, GetPlayerVehicleID(playerid));
  SendCustomMessage(playerid, "TRAILER", "You has successfully attach your trailer!");
  return 1;
}

CMD:findtrailer(playerid) {
  if (GetPlayerJob(playerid, 0) != JOB_COURIER && GetPlayerJob(playerid, 1) != JOB_COURIER) return SendErrorMessage(playerid, "You're not a trucker.");

  if (!PlayerData[playerid][pMissions]) return SendErrorMessage(playerid, "Kamu tidak sedang melakukan truck missions!");

  new vehicleid = TrailerMission[playerid], Float:vPos[3];

  if (IsValidVehicle(vehicleid)) {
    if (IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid)))
      return SendErrorMessage(playerid, "Your Trailer has already attached to your truck");

    GetVehiclePos(vehicleid, vPos[0], vPos[1], vPos[2]);
    SetPlayerWaypoint(playerid, "Missions Trailer", vPos[0], vPos[1], vPos[2]);
    SendCustomMessage(playerid, "FINDTRAILER", "Your trailer is on marked location");
  }
  return 1;
}

public OnTrailerAttach(trailerid, vehicleid) {
  foreach (new i : Player) {
    if ((GetPlayerJob(i, 0) == JOB_COURIER || GetPlayerJob(i, 1) == JOB_COURIER) && PlayerData[i][pMissions]) {
      if (TrailerMission[i] == trailerid) {
        new index = PlayerMissions[i];

        DisablePlayerRaceCheckpoint(i);
        SendCustomMessage(i, "MISSIONS","Please send the trailer to order");
        SetPlayerRaceCheckpoint(i, 1, TruckerMissions[index][sendTrailerX], TruckerMissions[index][sendTrailerY], TruckerMissions[index][sendTrailerZ], 0.0, 0.0, 0.0, 10.0);
      }
    }
  }
  return 1;
}

Dialog:TruckMissions(playerid, response, listitem, inputtext[]) {
  if (response && listitem != -1) {
    if (DialogMissions[listitem] == true)
      return SendErrorMessage(playerid, "This Trucking Missions has already taken by someone!");

    DialogMissions[listitem] = true;
    PlayerMissions[playerid] = listitem;
    PlayerData[playerid][pMissions] = 1;

    SetPlayerMissionsCP(playerid);
    SendCustomMessage(playerid, "MISSIONS", "Go to marked checkpoint on your map");
  }
  return 1;
}

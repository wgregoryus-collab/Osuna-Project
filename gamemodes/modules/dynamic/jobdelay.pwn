#include <YSI\y_hooks>
hook OnPlayerDisconnectEx(playerid) {
    if (PlayerData[playerid][pMiner])
        SetMinerDelay(playerid, 300);

    if (PlayerData[playerid][pSorter])
        SetSorterDelay(playerid, 800);

    if (PlayerData[playerid][pUnloader])
        SetUnloaderDelay(playerid, 800);
    
    return 1;
}


hook OnPlayerSpawn(playerid) {
    PlayerData[playerid][pSorter] = 0;
    PlayerData[playerid][pUnloader] = 0;
    PlayerData[playerid][pMiner] = 0;
    return 1;
}
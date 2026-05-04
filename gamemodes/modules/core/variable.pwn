/*	Varible List */

new MySQL: g_iHandle;
new color_string[3256];

new board[5], FireIncrement[5] = {0, ...}, FireTimer;
new g_StatusOOC = 1, g_TaxVault, g_ServerLocked, Text:gServerTextdraws[11], Auction, newbieschool, /*armedbody_pTick[MAX_PLAYERS], */zones[MAX_ZONES];
new /*Text:gLoginTextdraws, BillboardCheckout[MAX_PLAYERS],*/ g_ServerRestart, g_RestartTime, fishzone[FISH_ZONE], g_MysqlRaceCheck[MAX_PLAYERS];
new Seatbelt[MAX_PLAYERS char], Helmet[MAX_PLAYERS], VehicleSTrashmaster[4], TimerVote;
new ForkliftVehicles[5];
new Flash[MAX_VEHICLES], FlashTime[MAX_VEHICLES];
new ServerData[serverPropertise], deathDialog[MAX_PLAYERS] = {0, ...}, aucQueue[MAX_PLAYERS] = {0, ...};
new vehicledeath[MAX_VEHICLES] = {0, ...}, vehicledeathby[MAX_VEHICLES] = {INVALID_PLAYER_ID, ...}, object_font[500], selectCategory[MAX_PLAYERS] = {-1, ...}, selectIndex[MAX_PLAYERS] = {-1, ...};
new JailArea, NSArea, SAMDArea, tempatganja[2], publicfarm[2];
new farmBoard, fishBoard;
new fishNames[5][] = {
    "Carp", "Bass", "Cod", "Plaice", "Tuna"
};
new Timer:GamemodeInit, LoadGamemodeCount;

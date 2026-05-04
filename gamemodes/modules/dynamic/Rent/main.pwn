#include <YSI\y_hooks>

#define send->%0(%1) SendClientMessageEx(%0,X11_LIGHTBLUE,"RENT:"WHITE""%1)
#define put->%0(%1,%2) RentPoint[%1][%0] = %2
#define get->%0(%1) RentPoint[%1][%0]
#define refresh->Rent(%0) Refresh_RentPoint(%0)
#define delete->Rent(%0) Delete_RentPoint(%0)
#define save->Rent(%0) Save_RentPoint(%0)
#define fmt->%0(%1) format(%0, sizeof(%0), %1)
#define clear->%0() %0[0] = EOS

#define KHUSUS_ADMIN_LEVEL_5 if (AccountData[playerid][pAdmin] < 5) return PermissionError(playerid);

hook OnGameModeInitEx() {
    mysql_pquery(g_iHandle, "SELECT * FROM `rentpoint`", "RentPoint_Load", "");
    return 1;
}

CMD:createrental(playerid, params[]) {

    KHUSUS_ADMIN_LEVEL_5

    static
        createID;

    createID = CreateRentPoint(playerid);

    if (createID == -1)
        return SendErrorMessage(playerid, "Maximum rent point has been reached the server limit!");

    send->playerid("Successfully created rent point, ID: %d", createID);
    return 1;
}


CMD:editrental(playerid, params[]) {

    KHUSUS_ADMIN_LEVEL_5

    new 
        editID, editType[24], editValue[128];

    if (sscanf(params, "is[24]S()[128]", editID, editType, editValue))
        return SendSyntaxMessage(playerid, "/editrental [rentid] [list]"), SendClientMessage(playerid, COLOR_WHITE, GREEN"LIST:"WHITE" pos, spawn");

    if (!get->rentExists(editID) || (editID >= MAX_RENT_POINT || editID < 0))
        return SendErrorMessage(playerid, "Invalid Rent ID");

    if (!strcmp(editType, "pos", true)) {
        new 
            Float:editRentX, Float:editRentY, Float:editRentZ;

        GetPlayerPos(playerid, editRentX, editRentY, editRentZ);

        put->rentPosX(editID, editRentX);
        put->rentPosY(editID, editRentY);
        put->rentPosZ(editID, editRentZ);

        refresh->Rent(editID);
        save->Rent(editID);

        send->playerid(" Sukses mengedit posisi rental point ID: %d", editID);
    } else if (!strcmp(editType, "spawn", true)) {
        new Float:pos[4];
        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        GetPlayerFacingAngle(playerid, pos[3]);

        RentPoint[editID][rentSpawn][0] = pos[0];
        RentPoint[editID][rentSpawn][1] = pos[1];
        RentPoint[editID][rentSpawn][2] = pos[2];
        RentPoint[editID][rentSpawn][3] = pos[3];

        refresh->Rent(editID);
        save->Rent(editID);
        
        send->playerid(" Sukses mengedit spawn rental point ID: %d", editID);
    }
    return 1;
}

CMD:managerental(playerid, params[]) {

    KHUSUS_ADMIN_LEVEL_5

    new 
        srentID;

    if (sscanf(params, "i", srentID))
        return SendSyntaxMessage(playerid, "/managerental [rental point ID]");

    if (!get->rentExists(srentID) || (srentID >= MAX_RENT_POINT || srentID < 0))
        return SendErrorMessage(playerid, "Invalid Rent ID");

    ShowRentCarMenu(playerid, srentID);
    return 1;
}

CMD:deleterental(playerid, params[]) {

    KHUSUS_ADMIN_LEVEL_5

    new 
        deleteRentID, deleteLimit;

    if (sscanf(params, "ii", deleteRentID, deleteLimit))
        return SendSyntaxMessage(playerid, "/deleterental [rental point ID] [1-5]");

    if (!get->rentExists(deleteRentID) || (deleteRentID >= MAX_RENT_POINT || deleteRentID < 0))
        return SendErrorMessage(playerid, "Invalid Rent ID");

    //magic number boi
    deleteLimit = (7 - deleteLimit);

    //seharusnya deleteLimit entah itu 5 sampe 1
    for (new i = deleteLimit; i --> 0;) {
        RentPoint[deleteRentID][rentList][i] = 0;
        RentPoint[deleteRentID][rentPrice][i] = 0;
    }
    save->Rent(deleteRentID);
    return 1;
}


ShowRentCarMenu(playerid, showRentID) {
    new 
        kszk_Output[224], addCount;

    fmt->kszk_Output("Name\tPrice\n");
    for (new i ; i < MAX_RENT_LIST; i ++) {
        format(kszk_Output, sizeof(kszk_Output), "%s%s\t$%s\n", kszk_Output, GetVehicleNameByModel(RentPoint[showRentID][rentList][i]), FormatNumber(RentPoint[showRentID][rentPrice][i]));
        addCount++;
    }

    if (addCount < MAX_RENT_LIST)
        fmt->kszk_Output("%sCreate Car...", kszk_Output);

    SetPVarInt(playerid, "holdingRentID", showRentID);
    Dialog_Show(playerid, rentEdit, DIALOG_STYLE_TABLIST_HEADERS, "Edit Rent Car", kszk_Output, "Edit", "Close");
    return 1;
}

Dialog:rentEdit(playerid, response, listitem, inputtext[])  {
    if (!response)  {
        SetPVarInt(playerid, "holdingRentID", -1);
        SetPVarInt(playerid, "holdingSelectedItem", -1);
        SetPVarInt(playerid, "holdingRentModel", -1);
        return 0;
    }

    SetPVarInt(playerid, "holdingSelectedItem", listitem);
    Dialog_Show(playerid, rentEditName, DIALOG_STYLE_INPUT, "Put Rent Car", "Put vehicle Model/Name below to put into Rent List\n(Example: 400 or Bravura)", "Select", "Back");    
    return 1;
}

Dialog:rentEditName(playerid, response, listitem, inputtext[]) {
    if (!response)
        return ShowRentCarMenu(playerid, GetPVarInt(playerid, "holdingRentID"));


    if((inputtext[0] = GetVehicleModelByName(inputtext)) == 0)
        return SendErrorMessage(playerid, "Invalid Vehicle ID"), Dialog_Show(playerid, rentEditName, DIALOG_STYLE_INPUT, "Put Rent Car" , "Put vehicle Model/Name below to put into Rent List\n(Example: 400 or Bravura)", "Select", "Back");    
    
    SetPVarInt(playerid, "holdingRentModel", inputtext[0]);
    Dialog_Show(playerid, rentEditPrice, DIALOG_STYLE_INPUT, "Edit Rent Price", "Please put a price for vehicle %s\n(Example: $2000 or 2000)", "Done", "Back", GetVehicleNameByModel(inputtext[0]));
    return 1;
}

Dialog:rentEditPrice(playerid, response, listitem, inputtext[]) {
    if (!response) 
        return Dialog_Show(playerid, rentEditName, DIALOG_STYLE_INPUT, "Put Rent Car" , "Put vehicle Model/Name below to put into Rent List\n(Example: 400 or Bravura)", "Select", "Back");    
    new 
        letakDollar = strfind(inputtext, "$", true);

    if (letakDollar != -1) {
        strdel(inputtext, 0, letakDollar);
    }

    if (!IsNumeric(inputtext) || strval(inputtext) > 1000000)
        return SendErrorMessage(playerid, "Invalid Price Number."), Dialog_Show(playerid, rentEditPrice, DIALOG_STYLE_INPUT, "Edit Rent Price", "Please put a price for vehicle $%s\n(Example: $2,000.00 or 2000)", "Done", "Back", GetVehicleNameByModel(GetPVarInt(playerid, "holdingRentModel")));

    new 
        carRentID = GetPVarInt(playerid, "holdingRentID"),
        carRentIdx = GetPVarInt(playerid, "holdingSelectedItem"),
        carRentModel = GetPVarInt(playerid, "holdingRentModel");

    RentPoint[carRentID][rentList][carRentIdx] = carRentModel;
    RentPoint[carRentID][rentPrice][carRentIdx] = strval(inputtext);

    save->Rent(carRentID);

    send->playerid("Sukses memsukan mobil, mengembalikan ke rental menu...");
    ShowRentCarMenu(playerid, GetPVarInt(playerid, "holdingRentID"));
    return 1;
}

CMD:deleterent(playerid, params[]) {

    KHUSUS_ADMIN_LEVEL_5

    new 
        deleteID;

    if (sscanf(params, "i", deleteID))
        return SendSyntaxMessage(playerid, "/deleterent [rentid]");

    if (!get->rentExists(deleteID) || (deleteID >= MAX_RENT_POINT || deleteID < 0))
        return SendErrorMessage(playerid, "Invalid Rent ID");

    delete->Rent(deleteID);
    send->playerid("Sukses menghapus rental dengan ID: %d", deleteID);
    return 1;
}
CMD:rentveh(playerid, params[]) {
    if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
        return SendErrorMessage(playerid, "Anda harus turun dari kendaraan untuk menggunakan perintah ini");

    new 
        nearestID;

    /*if (PlayerPunyaRental(playerid))
        return SendErrorMessage(playerid, "Anda sudah memiliki kendaraan sewa.");*/


    if ((nearestID = GetNearestRentalPoint(playerid)) != -1) {
        if (RentPoint[nearestID][rentSpawn][0] == 0.0 && RentPoint[nearestID][rentSpawn][1] == 0.0 && RentPoint[nearestID][rentSpawn][2] == 0.0 && RentPoint[nearestID][rentSpawn][3] == 0.0) return SendErrorMessage(playerid, "Tempat untuk spawn kendaraan pada rental ini belum diset");
        else return GiveRentalMenu(playerid, nearestID);
    }

    SendErrorMessage(playerid, "Anda tidak dekat dengan Rental Point apapun.");
    return 1;
}

/*static PlayerPunyaRental(playerid) {
    foreach (new i : DynamicVehicles) {
        if (VehicleData[i][cRentOwned] == PlayerData[playerid][pID])
            return 1;
    }
    return 0;
}*/

static GiveRentalMenu(plrID, xrentID) {
    new
        combineString[1024];

    SetPVarInt(plrID, "holdingRentID", xrentID);

    fmt->combineString("Nama\tHarga\n");
    for (new i = 0; i < MAX_RENT_LIST; i ++) {
        fmt->combineString("%s%s\t$%s\n", combineString, GetVehicleNameByModel(RentPoint[xrentID][rentList][i]), FormatNumber(RentPoint[xrentID][rentPrice][i]));
    }
    Dialog_Show(plrID, RentCar, DIALOG_STYLE_TABLIST_HEADERS, "Rental Menu", combineString, "Select", "Back");
    return 1;
}

static CreateRentPoint(plrID) {
    static 
        Float:prentPosX, Float:prentPosY, Float:prentPosZ;

    if (GetPlayerPos(plrID, prentPosX, prentPosY, prentPosZ)) {
        for (new i; i != MAX_RENT_POINT; i ++) if (!RentPoint[i][rentExists]) {

            put->rentExists(i, true);
            put->rentPosX(i, prentPosX);
            put->rentPosY(i, prentPosY);
            put->rentPosZ(i, prentPosZ);
            RentPoint[i][rentSpawn][0] = 0.0;
            RentPoint[i][rentSpawn][1] = 0.0;
            RentPoint[i][rentSpawn][2] = 0.0;
            RentPoint[i][rentSpawn][3] = 0.0;

            //RentPoint[i][rentIcon] = 1239;
            new 
                rentQuery[128];

            format(rentQuery, sizeof(rentQuery), "INSERT INTO `rentpoint` (`PosX`, `PosY`, `PosZ`) VALUES (0.0, 0.0, 0.0)");
            mysql_tquery(g_iHandle, rentQuery, "OnRentPointCreated", "i", i);

            refresh->Rent(i);
            return i;
        }
    }
    return -1;
}

Dialog:RentCar(playerid, response, listitem, inputtext[]) {
    if (!response) {
        SetPVarInt(playerid, "holdingRentID", -1);
        SetPVarInt(playerid, "holdingSelectedItem", -1);
        return 0;
    }

    if (listitem != -1) {
        new 
            selectedRentID = GetPVarInt(playerid, "holdingRentID");

        SetPVarInt(playerid, "holdingSelectedItem", listitem);
        Dialog_Show(playerid, RentConfirm, DIALOG_STYLE_INPUT, "Sewa Kendaraan", "Tolong masukkan berapa jam anda ingin menyewa kendaraan %s", "Oke", "Cancel", GetVehicleNameByModel(RentPoint[selectedRentID][rentList][listitem]));
    }
    return 1;
}

Dialog:RentConfirm(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        if (isnull(inputtext))
            return Dialog_Show(playerid, RentConfirm, DIALOG_STYLE_INPUT, "Sewa Kendaraan", "Tolong masukkan berapa jam anda ingin menyewa kendaraan %s", "Oke", "Cancel", GetVehicleNameByModel(RentPoint[GetPVarInt(playerid, "holdingRentID")][rentList][GetPVarInt(playerid, "holdingSelectedItem")]));

        new
            value = strval(inputtext)
        ;

        if (value <= 0 || value > 5)
            return Dialog_Show(playerid, RentConfirm, DIALOG_STYLE_INPUT, "Sewa Kendaraan", "Tolong masukkan berapa jam anda ingin menyewa kendaraan %s", "Oke", "Cancel", GetVehicleNameByModel(RentPoint[GetPVarInt(playerid, "holdingRentID")][rentList][GetPVarInt(playerid, "holdingSelectedItem")])), SendErrorMessage(playerid, "Minimal jam sewa yaitu 1 jam dan maksimal yaitu 5 jam");

        SetPVarInt(playerid, "Rent_Time", value);
        Dialog_Show(playerid, RentVehicle, DIALOG_STYLE_MSGBOX, "Rental Kendaraan", WHITE"Apakah anda akan menyewa kendaran selama "YELLOW"%d jam\n\n"WHITE"Jumlah tagihan: "GREEN"$%s.", "Ya", "Tidak", value, FormatNumber((value*(RentPoint[GetPVarInt(playerid, "holdingRentID")][rentPrice][GetPVarInt(playerid, "holdingSelectedItem")]))));
    }
    return 1;
}

Dialog:RentVehicle(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        static 
            time,
            selectedItem,
            prices;

        selectedItem = GetPVarInt(playerid, "holdingSelectedItem");
        time = GetPVarInt(playerid, "Rent_Time");
        prices = (RentPoint[GetPVarInt(playerid, "holdingRentID")][rentPrice][selectedItem]*time);

        if(GetMoney(playerid) < prices)
        {
            SendErrorMessage(playerid, "Uang Anda tidak cukup untuk menyewa kendaraan ini.");
            return GiveRentalMenu(playerid, GetPVarInt(playerid, "holdingRentID"));
        }

        static
            model,
            id = -1,
            rentid,
            vehName[32];

        rentid = GetPVarInt(playerid, "holdingRentID");
        model = RentPoint[rentid][rentList][selectedItem];
        id = Vehicle_Create(0, model, RentPoint[rentid][rentSpawn][0], RentPoint[rentid][rentSpawn][1], RentPoint[rentid][rentSpawn][2], RentPoint[rentid][rentSpawn][3], random(255), random(255), 0, GREEN"RENTAL");

        if(id == -1)
            return SendErrorMessage(playerid, "The server has reached the limit for dynamic vehicles.");

        VehicleData[id][cRentTime] = (3600*time);
        VehicleData[id][cRentOwned] = PlayerData[playerid][pID];
        VehicleData[id][cRent] = 1;

        PutPlayerInVehicleEx(playerid, VehicleData[id][cVehicle], 0);

        GiveMoney(playerid, -(prices*time));

        Vehicle_Save(id);

        GetVehicleNameByVehicle(VehicleData[id][cVehicle], vehName);
        DeletePVar(playerid, "Rent_Time");
        SendServerMessage(playerid,"Anda telah menyewa kendaraan "CYAN"%s"WHITE" dengan jangka waktu "YELLOW"%d jam.", vehName, time);
        SendServerMessage(playerid,"Anda di perbolehkan menggunakan perintah "YELLOW"/v engine "WHITE"dan "YELLOW"/v lock");
        SendServerMessage(playerid,"Jika kendaraan sewa meledak, kendaraan akan otomatis hilang dan anda harus menyewa kendaraan baru lagi");
    }
    return 1;
}


Function: OnRentPointCreated(rentid) {
    put->rentID(rentid, cache_insert_id());
    save->Rent(rentid);
    return 1;
}

Function:RentPoint_Load() {
    new rows = cache_num_rows();

    for (new rentid = 0; rentid < rows; rentid ++) {
        cache_get_value_int(rentid, "ID", RentPoint[rentid][rentID]);
        put->rentExists(rentid, true);
        cache_get_value_float(rentid, "PosX", RentPoint[rentid][rentPosX]);
        cache_get_value_float(rentid, "PosY", RentPoint[rentid][rentPosY]);
        cache_get_value_float(rentid, "PosZ", RentPoint[rentid][rentPosZ]);
        cache_get_value_float(rentid, "Spawn_0", RentPoint[rentid][rentSpawn][0]);
        cache_get_value_float(rentid, "Spawn_1", RentPoint[rentid][rentSpawn][1]);
        cache_get_value_float(rentid, "Spawn_2", RentPoint[rentid][rentSpawn][2]);
        cache_get_value_float(rentid, "Spawn_3", RentPoint[rentid][rentSpawn][3]);
        
        cache_get_value_int(rentid, "RentList_0", RentPoint[rentid][rentList][0]);
        cache_get_value_int(rentid, "RentList_1", RentPoint[rentid][rentList][1]);
        cache_get_value_int(rentid, "RentList_2", RentPoint[rentid][rentList][2]);
        cache_get_value_int(rentid, "RentList_3", RentPoint[rentid][rentList][3]);
        cache_get_value_int(rentid, "RentList_4", RentPoint[rentid][rentList][4]);

        cache_get_value_int(rentid, "RentPrice_0", RentPoint[rentid][rentPrice][0]);
        cache_get_value_int(rentid, "RentPrice_1", RentPoint[rentid][rentPrice][1]);
        cache_get_value_int(rentid, "RentPrice_2", RentPoint[rentid][rentPrice][2]);
        cache_get_value_int(rentid, "RentPrice_3", RentPoint[rentid][rentPrice][3]);
        cache_get_value_int(rentid, "RentPrice_4", RentPoint[rentid][rentPrice][4]);
        refresh->Rent(rentid);
    }
    printf("*** [GarudaPride Database: Loaded] rent point data loaded (%d count)", rows);
    return 1;
}

static Refresh_RentPoint(rentid) {

    if (!get->rentExists(rentid))
        return -1;


    // if (IsValidDynamicPickup(RentPoint[rentid][rentObj]))
    DestroyDynamicPickup(RentPoint[rentid][rentObj]);

    if (IsValidDynamic3DTextLabel(get->rentText(rentid)))
        DestroyDynamic3DTextLabel(get->rentText(rentid));

    new 
        rentFmt[64];


    fmt->rentFmt("[ID:%d] Rent Vehicle\nType "YELLOW"\"/rentveh\""WHITE" for rent your own vehicle!", rentid);
    put->rentText(rentid, CreateDynamic3DTextLabel(rentFmt, COLOR_WHITE, get->rentPosX(rentid), get->rentPosY(rentid), get->rentPosZ(rentid), 15.0));
    RentPoint[rentid][rentObj] = CreateDynamicPickup(1239, 23, RentPoint[rentid][rentPosX], RentPoint[rentid][rentPosY], RentPoint[rentid][rentPosZ]);
    return 1;
}

static Save_RentPoint(rentid) {
    new 
        rentQuery[512];

    if (!get->rentExists(rentid))
        return -1;

    format(rentQuery, sizeof(rentQuery), "UPDATE `rentpoint` SET `PosX` = '%.4f', `PosY` = '%.4f', `PosZ` = '%.4f'",
        get->rentPosX(rentid),
        get->rentPosY(rentid),
        get->rentPosZ(rentid)
    );

    for (new i = 0; i < 4; i ++) {
        format(rentQuery, sizeof(rentQuery), "%s, `Spawn_%d` = '%.4f'", rentQuery, i, RentPoint[rentid][rentSpawn][i]);
    }

    for (new i; i < MAX_RENT_LIST; i ++) {
        format(rentQuery, sizeof(rentQuery), "%s, `RentList_%d` = '%d', `RentPrice_%d` = '%d'", rentQuery, i, RentPoint[rentid][rentList][i], i, RentPoint[rentid][rentPrice][i]);
    }

    format(rentQuery, sizeof(rentQuery), "%s WHERE `ID` = '%d'",
        rentQuery,
        get->rentID(rentid)
    );
    mysql_tquery(g_iHandle, rentQuery);
    return 1;
}

static Delete_RentPoint(rentid) {
    new 
        rentQuery[64];

    if (!get->rentExists(rentid))
        return -1;

    DestroyDynamicPickup(get->rentObj(rentid));
    DestroyDynamic3DTextLabel(get->rentText(rentid));

    format(rentQuery, sizeof(rentQuery), "DELETE FROM `rentpoint` WHERE `ID` = '%d'", get->rentID(rentid));
    mysql_tquery(g_iHandle, rentQuery);

    new dummyOnDummy[rentPoint];
    RentPoint[rentid] = dummyOnDummy;

    put->rentExists(rentid, false);
    return 1;
}

GetNearestRentalPoint(playerid) {
    for (new i;  i < MAX_RENT_POINT; i ++) if (get->rentExists(i)) {
        if (IsPlayerInRangeOfPoint(playerid, 3.0, get->rentPosX(i), get->rentPosY(i), get->rentPosZ(i)))
            return i;
    }
    return -1;
}

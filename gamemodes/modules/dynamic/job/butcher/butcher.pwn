#include <a_samp>
#include <evf>
#include <a_mysql>
#include <sscanf2>
#include <streamer>
#include <zcmd>
#include <colors>

#define MYSQL_HOST    "45.146.6.51"      //Alamat IP dari Server MySQL
#define MYSQL_USER    "u358_Z3ZRKndBLh"           //Username untuk masuk
#define MYSQL_PASS    "Tr^kKTmTfJS6dd@E6MJjL30A"               //Password untuk muser
#define MYSQL_DBSE    "s358_lavis"       //Nama dari database

#define Callback::%1(%2) 									forward %1(%2); public %1(%2)


#define 		MAX_GUDANG   		(2)
#define     	MAX_SAPI   			(7)
#define     	MAX_DAGING   		(20)

#define     	HARGA_PER_EKOR     	(70)
#define         HARGA_SCAN_DAGING   (25)
#define     	HARGA_PER_POTONG    (15)
#define     	MAX_POTONG       	(12)

#define     	DIALOG_LISTG    	(51)
#define     	DIALOG_GUDANGCP     (52)
#define     	DIALOG_GUDANGCP1    (53)
#define     	DIALOG_SAVEEMBIM    (54)
#define     	DIALOG_AMBILDAGING  (55)
#define     	DIALOG_STATS   		(56)
#define         DIALOG_NAIK         (57)

#define         level2              (500)//point seleuruh kerja di bagian total kejra
#define         level3              (1000)
#define         level4              (1500)

new
	gmasuk, gkeluar, masukg;
new
    GCP, GCP2, GCP3,
    GCP4, GCP5, KulkasCP,
	DCP, DCP2, TCP, TCP2,
	NaikCP;

enum    duaging
{
	Float: duarX,
	Float: duarY,
	Float: duarZ,
	duarUser,
	Text3D: duarLabel
}

new
	Float: Duar[MAX_POTONG][duaging] = {
	
        { 962.3945,2122.9573,1011.0234 },
        { 962.5198,2126.5129,1011.0234 },
        { 962.4670,2130.2263,1011.0234 },
        { 962.4689,2134.0332,1011.0234 },
        { 962.0140,2137.0681,1011.0234 },
        { 962.3184,2140.5471,1011.0291 },
        { 955.8755,2140.2761,1011.0234 },
        { 956.1301,2137.0024,1011.0234 },
        { 956.1160,2134.0564,1011.0234 },
        { 955.9548,2129.8223,1011.0234 },
        { 956.1662,2126.3286,1011.0234 },
        { 956.3591,2122.8589,1011.0234 }
    }
;

new Float: Sapi[10][6] = {

	{ 1505.15369, -58.63770, 19.40380,   0.00000, 0.00000, 280.00000},
	{ 1504.62305, -60.82820, 19.31980,   0.00000, 0.00000, 287.00000},
	{ 1505.05029, -62.47790, 19.31980,   0.00000, 0.00000, 255.00000},
	{ 1507.75574, -58.27113, 19.31980,   0.00000, 0.00000, 149.00000},
	{ 1512.19800, -58.78720, 19.31980,   0.00000, 0.00000, -11.00000},
	{ 1511.92810, -61.39240, 19.03980,   0.00000, 0.00000, 129.00000},
	{ 1511.59583, -64.56090, 18.87180,   0.00000, 0.00000, -33.00000},
	{ 1509.54407, -58.77344, 19.31980,   0.00000, 0.00000, 149.00000},
	{ 1509.89001, -61.20041, 19.31980,   0.00000, 0.00000, 149.00000},
	{ 1508.29114, -62.15330, 19.31980,   0.00000, 0.00000, -149.00000}
}
;

new
    Float: Toko[ ][ 3 ] =
    {
        // lokasi sebagian di losantos
        { 2413.8171,-1489.6320,23.6162 },
        { 2097.0720,-1814.9861,13.0873 },
        { 1836.7101,-1854.2507,13.0942 },
        { 1317.2887,-870.1953,39.2826 },
        { 935.0750,-1390.5577,13.0574 },
        { 1344.8262,-1752.1460,13.0658 },
        { 2378.2827,-1901.5828,13.1268 },
        { 1198.1213,-888.4818,42.7675 },
        { 1355.1578,244.7723,19.2727 }
        //di kota lain kaming soon.
    },
    TokoCP[MAX_PLAYERS]
;

	
enum pInfo
{
    DealerID,
	rank,
	karung,
	tasdaging,
	daging,
	scan,
	totalkerja,
	pSkin
}

new PlayerInfo[MAX_PLAYERS][pInfo];

enum GUDANG
{
	baju,
	listg,
	veh,
	Potong,
	Jual,
	StoK,
	Float: gudangX,
	Float: gudangY,
	Float: gudangZ
}
new
	GudangData[MAX_GUDANG][GUDANG];


new
	MySQL: SQLHandle;


new
    RefuelTimer[MAX_PLAYERS] = {-1, ...},
    waktugaji[MAX_PLAYERS] = {-1, ...},
    waktupotong[MAX_PLAYERS] = {-1, ...},
    waktuscan[MAX_PLAYERS] = {-1, ...},
    DagingCP[MAX_PLAYERS] = {-1, ...},
    GudangCP[MAX_PLAYERS] = {-1, ...},
    ScanCP[MAX_PLAYERS] = {-1, ...},
	ambilbarang[MAX_PLAYERS] = 0,
	motongdaging[MAX_PLAYERS] = 0,
	LoadedSapi[MAX_VEHICLES],
	LoadedDaging[MAX_VEHICLES],
	AntarDaging[MAX_PLAYERS];



CMD:setbutcher(playerid, params[]) // untuk mengatur level butcher
{
	new Target,level,string[130],name[MAX_PLAYER_NAME];
    if(sscanf(params,"ui",Target,level))return SendClientMessage(playerid, COLOR_WHITE,"{FC03A1}Ketik: /setbutcher <player id> <level>");
    if(Target == INVALID_PLAYER_ID ) return SendClientMessage(playerid, -1, "ID player yang di tuju tidak ada!");
    else if(level > 5)return SendClientMessage(playerid, COLOR_WHITE,"{FC3003}[ERROR]{FFFFFF} Hanya Tersedia <1-4>");
    else
    {
        PlayerInfo[Target][rank] = level;
        format(string,sizeof(string),"{FC03A1}[INFO]{FFFFFF} Your butcher level has been set to {FFFF00}%d.",level);
        SendClientMessage(Target,COLOR_WHITE,string);
		GetPlayerName(Target,name,sizeof(name));
		format(string,sizeof(string),"{FC03A1}[ADMIN]{FFFFFF} You have set {FFFF00}%s's{FFFFFF} butcher level to {FFFF00}%d.",name,level);
		SendClientMessage(playerid,COLOR_WHITE,string);
        //SaveDataPlayer(Target);
	}
	return 1;
}

CMD:saveb(playerid)// buat save data gudang
{
	new query[256];
	mysql_format(SQLHandle, query, sizeof(query), "UPDATE gudang SET daging_potong=%d, siap_jual=%d, penyimpanan=%d WHERE ID=0",
	GudangData[0][Potong], GudangData[0][Jual], GudangData[0][StoK]);
	mysql_tquery(SQLHandle, query, "", "");
	return 1;
}

CMD:savep(playerid)// save data pemain 
{
	new query[256];
	mysql_format(SQLHandle, query, sizeof(query), "UPDATE gudang_user SET rank=%d, karung_hewan=%d, tas_daging=%d, daging=%d, scan_daging=%d, total_kerja=%d WHERE nama='%e'",
	PlayerInfo[playerid][rank],PlayerInfo[playerid][karung],PlayerInfo[playerid][tasdaging],
	PlayerInfo[playerid][daging],PlayerInfo[playerid][scan],PlayerInfo[playerid][totalkerja],
	GetName(playerid));
	print(query);
	mysql_tquery(SQLHandle, query, "", "");
	return 1;
}

CMD:loadp(playerid)// load data pemian
{
	new query[128];
	mysql_format(SQLHandle, query, sizeof(query), "SELECT * FROM gudang_user WHERE nama = '%e'", GetName(playerid));
	mysql_pquery(SQLHandle, query, "loaddata", "d", playerid);
	return 1;
}

CMD:join(playerid)// cek data pemain di mysql. apabila pemain tidak ada maka otomatis data pemain akan di buat databasenya.
{
	// cek data pemain di mysql
	new query[128];
	mysql_format(SQLHandle, query, sizeof(query), "SELECT * FROM gudang_user WHERE nama = '%e'", GetName(playerid));
	mysql_pquery(SQLHandle, query, "UserCheck", "d", playerid);
	return 1;
}

Callback:: loaddata(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows == 0)
	{

	}
	else
	{
		cache_get_value_name_int(0, "rank", PlayerInfo[playerid][rank]);
		cache_get_value_name_int(0, "karung_hewan", PlayerInfo[playerid][karung]);
		cache_get_value_name_int(0, "tas_daging", PlayerInfo[playerid][tasdaging]);
		cache_get_value_name_int(0, "daging", PlayerInfo[playerid][daging]);
		cache_get_value_name_int(0, "scan_daging", PlayerInfo[playerid][scan]);
		cache_get_value_name_int(0, "total_kerja", PlayerInfo[playerid][totalkerja]);	

	}
	return 1;
}


Callback:: UserCheck(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows == 0)
	{
		//SendClientMessage(playerid, -1, "Tidak ada data");
		new query[256];
		mysql_format(SQLHandle, query, sizeof(query), "INSERT INTO gudang_user (nama, rank) VALUES ('%e', 1)", GetName(playerid));
		mysql_tquery(SQLHandle, query, "", "");	
	}
	else
	{
		//SendClientMessage(playerid, -1, "Ada data");
	}
	return 1;
}


public OnFilterScriptInit()
{

	SQLHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DBSE);
	mysql_log(ERROR | WARNING);
	if(mysql_errno() != 0) return print(" [Sistem Butcher] Tidak dapat terhubung ke MySQL.");

	print("\n--------------------------------------");
	print("System Job Butcher by : LNH ShiroNeko");
	print("--------------------------------------\n");

	new tmpobjid = CreateDynamicObject(1439, 944.436828, 2127.660644, 1010.021179, 0.000000, 0.000000, -90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 2803, "cj_meaty", "CJ_FLESH_2", 0x00000000);

	gmasuk = CreateDynamicPickup(1318, 23, 1374.1469,405.0240,19.9555,0);
	gkeluar = CreateDynamicPickup(1318, 23, 965.3796,2107.9758,1011.0303,0);

    GCP = CreateDynamicCP(949.6746,2129.6597,1011.0234,1.0,-1,-1,-1,5.0);
    GCP2 = CreateDynamicCP(934.1964,2133.5818,1011.0234,1.0,-1,-1,-1,5.0);
    GCP3 = CreateDynamicCP(934.5633,2117.0425,1011.0234,1.0,-1,-1,-1,5.0);
    GCP4 = CreateDynamicCP(934.1964,2172.3052,1011.0234,1.0,-1,-1,-1,5.0);
    GCP5 = CreateDynamicCP(934.5612,2155.9578,1011.0234,1.0,-1,-1,-1,5.0);
    
	KulkasCP = CreateDynamicCP(954.8386,2120.9534,1011.0234,1.0,-1,-1,-1,5.0);
	
    DCP = CreateDynamicCP(944.4310,2120.6775,1011.0234,1.0,-1,-1,-1,5.0);
    DCP2 = CreateDynamicCP(944.2912,2156.3564,1011.0234,1.0,-1,-1,-1,5.0);
	
    TCP = CreateDynamicCP(942.3105,2117.9023,1011.0303,1.0,-1,-1,-1,5.0);
    TCP2 = CreateDynamicCP(942.3029,2153.7456,1011.0234,1.0,-1,-1,-1,5.0);
    
    NaikCP = CreateDynamicCP(957.6508,2099.9124,1011.0253,1.0,-1,-1,-1,5.0);

	//masuk ke gudang
	masukg = CreateDynamicCP(1390.2943,378.5014,19.7578,5.0,-1,-1,-1,5.0);

	for(new i; i < MAX_POTONG; i++)
	{
	    Duar[i][duarUser] = INVALID_PLAYER_ID;
	    Duar[i][duarLabel] = CreateDynamic3DTextLabel("{FFFFFF}Tekan {2ECC71}/Alt \n{FFFFFF}untuk memotong daging", 0xF1C40FFF, Duar[i][duarX], Duar[i][duarY], Duar[i][duarZ] + 0.75, 7.5);
	}

	for(new i; i < 10; i++)
	{
		new objsapi[10];
		// Sapi[10][6] = 
		objsapi[i] = CreateDynamicObject(19833, Sapi[i][0], Sapi[i][1], Sapi[i][2], Sapi[i][3], Sapi[i][4], Sapi[i][5]);
	}

	mysql_tquery(SQLHandle, "SELECT * FROM gudang", "LoadGudang", "");
	
	CreateDynamicObject(3175, 1499.76733, -55.78790, 19.48520,   0.00000, 0.00000, 26.00000);
	CreateDynamicObject(3172, 1470.02551, -64.01950, 19.09450,   0.00000, 0.00000, -193.00000);
	CreateDynamicObject(3283, 1502.86890, -74.85598, 18.76770,   0.00000, 0.00000, -46.00000);
	CreateDynamicObject(3252, 1468.58838, -39.03911, 22.24438,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3284, 1479.30933, -43.19120, 22.70730,   0.00000, 0.00000, 98.00000);
	CreateDynamicObject(3425, 1457.32947, -50.78186, 32.16977,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1345, 1480.85571, -50.09460, 21.62475,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1345, 1504.22986, -68.49052, 19.59449,   0.00000, 0.00000, 134.00000);
	CreateDynamicObject(2806, 942.34918, 2131.81519, 1011.22650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1271, 942.24921, 2127.54907, 1010.81909,   0.00000, 0.00000, 0.00000);

	//pagar sapi
	CreateObject(8674, 1508.82446, -66.99543, 19.73850,   0.00000, 0.00000, 0.00000);
	CreateObject(8674, 1513.97534, -61.85762, 19.73850,   0.00000, 0.00000, 90.00000);
	CreateObject(8674, 1508.77856, -56.65055, 19.73850,   0.00000, 0.00000, 0.00000);
	CreateObject(8674, 1503.51428, -59.42223, 19.73850,   0.00000, 0.00000, 90.00000);
	
	//dagging
	CreateDynamicObject(2589, 956.04791, 2130.06592, 1016.36108,   0.00000, 0.00000, 97.00000);
	CreateDynamicObject(2589, 956.03381, 2134.06860, 1016.36108,   0.00000, 0.00000, -121.00000);
	CreateDynamicObject(2589, 956.07971, 2126.56519, 1016.36108,   0.00000, 0.00000, 117.00000);
	CreateDynamicObject(2589, 956.02502, 2137.21069, 1016.36108,   0.00000, 0.00000, -236.00000);
	CreateDynamicObject(2589, 956.06329, 2122.78394, 1016.36108,   0.00000, 0.00000, -62.00000);
	CreateDynamicObject(2589, 955.98822, 2140.28369, 1016.36108,   0.00000, 0.00000, -101.00000);
	CreateDynamicObject(2589, 962.43597, 2122.81079, 1016.36108,   0.00000, 0.00000, 55.00000);
	CreateDynamicObject(2589, 962.36121, 2126.48853, 1016.36108,   0.00000, 0.00000, -127.00000);
	CreateDynamicObject(2589, 962.30249, 2130.12573, 1016.36108,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(2589, 962.27228, 2134.02734, 1016.36108,   0.00000, 0.00000, -26.00000);
	CreateDynamicObject(2589, 962.37097, 2137.22144, 1016.36108,   0.00000, 0.00000, 156.00000);
	CreateDynamicObject(2589, 962.35980, 2140.25415, 1016.36108,   0.00000, 0.00000, -178.00000);
	
	// papan list
	CreateDynamicObject(2616, 932.38025, 2164.09521, 1011.76715,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2615, 932.40002, 2163.58984, 1011.76721,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2616, 957.41382, 2100.19336, 1011.76715,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2615, 957.47418, 2099.64966, 1011.76721,   0.00000, 0.00000, 90.00000);

	//baru kulkas
	CreateDynamicObject(2094, 944.94940, 2120.04980, 1010.04272,   0.00000, 0.00000, 91.00000);
	CreateDynamicObject(2094, 944.79907, 2155.89868, 1010.04272,   0.00000, 0.00000, 91.00000);
	CreateDynamicObject(2806, 942.39893, 2167.62524, 1011.22650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2806, 942.63007, 2167.53638, 1011.22650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1842, 953.44464, 2124.00806, 1010.04260,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1883, 953.48462, 2121.07178, 1010.04260,   0.00000, 0.00000, 90.00000);

	return 1;
}


public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	if(pickupid == gmasuk)
	{
	    SetPlayerPos(playerid,962.1105,2107.3452,1011.0303);
	    SetPlayerFacingAngle(playerid,91.9221);
	    SetPlayerInterior(playerid,1);
	    SetCameraBehindPlayer(playerid);
	    return 1;
	}
	if(pickupid == gkeluar)
	{
	    SetPlayerPos(playerid,1371.3191,406.1893,19.7578);
	    SetPlayerFacingAngle(playerid,69.9652);
	    SetPlayerInterior(playerid,0);
	    SetCameraBehindPlayer(playerid);
	    return 1;
	}
	for(new i; i < MAX_GUDANG; i++)
	{
		if(pickupid == GudangData[i][baju])
		{
	    	if(PlayerInfo[playerid][rank] >= 2 || PlayerInfo[playerid][rank] <= 4)
	  		{
	    	    if(GetPlayerSkin(playerid) != 168) 
	    	    {
	    	    	SetPVarInt(playerid, "Get_Skin", GetPlayerSkin(playerid));
	    	        SetPlayerSkin(playerid, 168);
	    	        SendClientMessage(playerid,-1,"Kamu telah mengganti pakain.");
	    	        SetPVarInt(playerid, "ID_Gudang", i);
				}else{
				    
					SetPlayerSkin(playerid, GetPVarInt(playerid, "Get_Skin"));
					DeletePVar(playerid, "ID_Gudang");
				}
	  		}
	     	return 1;
		}
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(GetPlayerSkin(playerid) == 168)
	{
		SetPlayerSkin(playerid, GetPVarInt(playerid, "Get_Skin"));
		DeletePVar(playerid, "ID_Gudang");
	} 
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	for(new i; i < MAX_GUDANG; i++)
	{
		if(checkpointid == GudangData[i][listg])
		{
			ListGudang(playerid);	
			return 1;
		}
	}
	if(checkpointid == GCP || checkpointid == GCP2 || checkpointid == GCP3 || checkpointid == GCP4 || checkpointid == GCP5)
	{
		if(PlayerInfo[playerid][rank] == 3 || PlayerInfo[playerid][rank] == 4)
  		{
	    	if(PlayerInfo[playerid][scan] >0)
	  		{
	            new string[300], id = PlayerInfo[playerid][DealerID];
	 	  		GudangData[id][Jual]  += PlayerInfo[playerid][scan];
	 	  		PlayerInfo[playerid][totalkerja]  += PlayerInfo[playerid][scan];
		    	ApplyAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0, 0, 1);
	            GivePlayerMoney(playerid, PlayerInfo[playerid][scan] * HARGA_SCAN_DAGING);
	            format(string, sizeof(string), "Butcher: {FFFFFF}%s daging siap kirim dengan harga {2ECC71}%s.", formatInt(PlayerInfo[playerid][scan], .iCurrencyChar = '\0'), formatInt(PlayerInfo[playerid][scan] * HARGA_SCAN_DAGING));
	            SendClientMessage(playerid, 0x3498DBFF, string);
	           	PlayerInfo[playerid][scan] = 0 ;
	            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	            ClearAnimations(playerid);
				return 1;
	  		}
		}
	}
	if(checkpointid == TCP)
	{
	    new cekskin = GetPlayerSkin(playerid);
		if(PlayerInfo[playerid][rank] == 3 || PlayerInfo[playerid][rank] == 4)
  		{
    	    if(cekskin != 168)return SendClientMessage(playerid,-1,"kamu harus ganti pakain dulu.");
    	    if(PlayerInfo[playerid][daging] == MAX_DAGING)
			{
			    SendClientMessage(playerid,-1,"Proses scan daging sedang berlangsung.");
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                ClearAnimations(playerid);
            	PlayerInfo[playerid][daging] = 0;
                waktuscan[playerid] = SetTimerEx("timer_scan", 8000, false, "i", playerid);
 			}
	  	}
		return 1;
	}
	if(checkpointid == TCP2)
	{
	    new cekskin = GetPlayerSkin(playerid);
		if(PlayerInfo[playerid][rank] == 3 || PlayerInfo[playerid][rank] == 4)
  		{
    	    if(cekskin != 168)return SendClientMessage(playerid,-1,"kamu harus ganti pakain dulu.");
    	    if(PlayerInfo[playerid][daging] == MAX_DAGING)
			{
			    SendClientMessage(playerid,-1,"Proses scan daging sedang berlangsung.");
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                ClearAnimations(playerid);
            	PlayerInfo[playerid][daging] = 0;
                waktuscan[playerid] = SetTimerEx("timer_scan1", 8000, false, "i", playerid);
 			}
	  	}
		return 1;
	}
	if(checkpointid == DCP || checkpointid == DCP2)
	{
	    new cekskin = GetPlayerSkin(playerid);
        new dialog[300], id = PlayerInfo[playerid][DealerID];
		if(PlayerInfo[playerid][rank] == 3 || PlayerInfo[playerid][rank] == 4)
  		{
    	    if(cekskin != 168)return SendClientMessage(playerid,-1,"kamu harus ganti pakain dulu.");

			format(
				dialog,
				sizeof(dialog),
				"Daging Potong :\t{%06x}%s\n\
				\n\n\n{FFFFFF}Ket : 20 daging potong baru bisa di ambil",
				(GudangData[id][Potong] > MAX_DAGING) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8,formatInt(GudangData[id][Potong], .iCurrencyChar = '\0')
			);
    	    ShowPlayerDialog(playerid, DIALOG_AMBILDAGING, DIALOG_STYLE_MSGBOX, "Penyimpaan Daging", dialog, "Ambil", "Gak Jadi");
			return 1;
  		}
	}
	if(checkpointid == NaikCP)
	{
		if(PlayerInfo[playerid][rank] >= 1 || PlayerInfo[playerid][rank] <= 4)
  		{
  		    new dialog[500];
 			format(
				dialog,
				sizeof(dialog),
				"{FFFFFF}Point kamu :\t{%06x}%s\n\
				\n\nSyarat Naik Pangkat : \n\
				- Level 2 : %s\n\
				- Level 3 : %s\n\
				- Level 4 : %s\n\
				\nLevel kamu saat ini : %s",
				(PlayerInfo[playerid][totalkerja] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8,formatInt(PlayerInfo[playerid][totalkerja], .iCurrencyChar = '\0'),
				formatInt(level2, .iCurrencyChar = '\0'), formatInt(level3, .iCurrencyChar = '\0'), formatInt(level4, .iCurrencyChar = '\0'), formatInt(PlayerInfo[playerid][rank], .iCurrencyChar = '\0')
			);
    	    ShowPlayerDialog(playerid, DIALOG_NAIK, DIALOG_STYLE_MSGBOX, "Pencapaian Kamu", dialog, "Naik Level", "Gak Jadi");
			return 1;
  		}
	}
	if(checkpointid == KulkasCP)
	{
		if(PlayerInfo[playerid][tasdaging] >0)
  		{
            new string[300], id = PlayerInfo[playerid][DealerID];
 	  		GudangData[id][Potong]  += PlayerInfo[playerid][tasdaging];
 	  		PlayerInfo[playerid][totalkerja]  += PlayerInfo[playerid][tasdaging];
	    	ApplyAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0, 0, 1);
            GivePlayerMoney(playerid, PlayerInfo[playerid][tasdaging] * HARGA_PER_POTONG);
            format(string, sizeof(string), "Butcher: {FFFFFF}%s daging potong dengan harga {2ECC71}%s.", formatInt(PlayerInfo[playerid][tasdaging], .iCurrencyChar = '\0'), formatInt(PlayerInfo[playerid][tasdaging] * HARGA_PER_POTONG));
            SendClientMessage(playerid, 0x3498DBFF, string);
           	PlayerInfo[playerid][tasdaging] = 0 ;

            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
            ClearAnimations(playerid);
			return 1;
  		}
	}
	if(checkpointid == ScanCP[playerid])
	{
	 	PlayerInfo[playerid][scan] = MAX_DAGING;
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
        ClearAnimations(playerid);
        SendClientMessage(playerid, -1,"Pindahkan daging ke tempat tumpukan kardus");
     	DestroyDynamicCP(ScanCP[playerid]);
		ScanCP[playerid] = -1;
	    return 1;
	}
	if(checkpointid == GudangCP[playerid])
	{
	    new vehicleid = GetPVarInt(playerid, "LastVehicleID");
        new dialog[300], id = PlayerInfo[playerid][DealerID];
		if(PlayerInfo[playerid][rank] == 4)
		{
			format(
				dialog,
				sizeof(dialog),
				"{%06x}Simpan Sapi\t%s\n\
				{%06x}Daging siap kirim \t%s\n\
				{FFFFFF}Simpan Kendaraan\t\t",
				(LoadedSapi[vehicleid] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8,formatInt(LoadedSapi[vehicleid], .iCurrencyChar = '\0'),
				(GudangData[id][Jual] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8,formatInt(GudangData[id][Jual], .iCurrencyChar = '\0')
			);
			AntarDaging[playerid] = 1;
			ShowPlayerDialog(playerid, DIALOG_GUDANGCP1, DIALOG_STYLE_LIST, "Gudang Butcher", dialog, "Pilih", "Tutup");
			return 1;
		}
		if(PlayerInfo[playerid][rank] >= 1 || PlayerInfo[playerid][rank] <= 3)
		{
			format(
				dialog,
				sizeof(dialog),
				"{%06x}Simpan Sapi\t%s",
				(LoadedSapi[vehicleid] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8,formatInt(LoadedSapi[vehicleid], .iCurrencyChar = '\0')
			);
			ShowPlayerDialog(playerid, DIALOG_GUDANGCP, DIALOG_STYLE_LIST, "Gudang Butcher", dialog, "Pilih", "Tutup");
			return 1;
		}
	}
	if(checkpointid == DagingCP[playerid])
	{
	    new vehicleid = GetPVarInt(playerid, "LastVehicleID");
	    if(LoadedSapi[vehicleid] >= MAX_SAPI) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Kendaraan ini penuh, Anda tidak dapat memuat barang lagi.");
	    LoadedSapi[vehicleid] += PlayerInfo[playerid][karung];
	    PlayerInfo[playerid][karung] = 0 ;
    	ApplyAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0, 0, 1);
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        ClearAnimations(playerid);
		if(MAX_SAPI - LoadedSapi[vehicleid] > 0)
		{
			new string[96];
			format(string, sizeof(string), "BUTCHER  JOB: {FFFFFF}Anda dapat memuat {F39C12}%d{FFFFFF} ekor ke kendaraan ini.", MAX_SAPI - LoadedSapi[vehicleid]);
			SendClientMessage(playerid, 0x2ECC71FF, string);
		}
		new driver = GetVehicleDriver(vehicleid);
		if(IsPlayerConnected(driver)) Trash_ShowCapacity(driver);
		HoldItems_ResetPlayer(playerid);
		return 1;
	}
	if(checkpointid == masukg)
	{
    	new vehicleid = GetPVarInt(playerid, "LastvehicleID");
	    if(GetVehicleModel(vehicleid) != 498) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Khusus Kendaraan Boxville.");
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    new rand = random( sizeof( Toko ) ), vehicleid = GetPVarInt(playerid, "LastVehicleID");
    if(TokoCP[playerid] == 1)
	{
	    if(LoadedDaging[vehicleid] <= 60)
	    {
	        LoadedDaging[vehicleid] -= 20;
	        PlayerInfo[playerid][totalkerja] += 20;
	        DisablePlayerCheckpoint(playerid);
	       	TokoCP[playerid] = 2;
	  	    SetPlayerCheckpoint( playerid, Toko[ rand ][ 0 ], Toko[ rand ][ 1 ], Toko[ rand ][ 2 ], 5.0 );
		    waktugaji[playerid] = SetTimerEx("timer_gaji", 8000, false, "i", playerid);
	    	TogglePlayerControllable(playerid, 0);
		}else{
		    DisablePlayerCheckpoint(playerid);
	       	TokoCP[playerid] = 4;
		    SetPlayerCheckpoint( playerid, 1390.2943,378.5014,19.7578, 5.0 );
		    SendClientMessage(playerid,-1,"Pulangkan Kendaraan kamu.");
		    waktugaji[playerid] = SetTimerEx("timer_gaji", 8000, false, "i", playerid);
	    	TogglePlayerControllable(playerid, 0);
		}
		return 1;
    }
	if(TokoCP[playerid] == 2)
    {
        if(LoadedDaging[vehicleid] <= 40)
	    {
	        LoadedDaging[vehicleid] -= 20;
	        PlayerInfo[playerid][totalkerja] += 20;
	        DisablePlayerCheckpoint(playerid);
	       	TokoCP[playerid] = 3;
	  	    SetPlayerCheckpoint( playerid, Toko[ rand ][ 0 ], Toko[ rand ][ 1 ], Toko[ rand ][ 2 ], 5.0 );
		    waktugaji[playerid] = SetTimerEx("timer_gaji", 8000, false, "i", playerid);
	    	TogglePlayerControllable(playerid, 0);
		}else{
		    DisablePlayerCheckpoint(playerid);
	       	TokoCP[playerid] = 4;
		    SetPlayerCheckpoint( playerid, 1390.2943,378.5014,19.7578, 5.0 );
		    SendClientMessage(playerid,-1,"Pulangkan Kendaraan kamu.");
		    waktugaji[playerid] = SetTimerEx("timer_gaji", 8000, false, "i", playerid);
	    	TogglePlayerControllable(playerid, 0);
		}
   	    return 1;
    }
	if(TokoCP[playerid] == 3)
    {
        if(LoadedDaging[vehicleid] <= 20)
	    {
	        LoadedDaging[vehicleid] -= 20;
	        PlayerInfo[playerid][totalkerja] += 20;
	        DisablePlayerCheckpoint(playerid);
	       	TokoCP[playerid] = 4;
		    SetPlayerCheckpoint( playerid, 1390.2943,378.5014,19.7578, 5.0 );
		    SendClientMessage(playerid,-1,"Pulangkan Kendaraan kamu.");
		    waktugaji[playerid] = SetTimerEx("timer_gaji", 8000, false, "i", playerid);
	    	TogglePlayerControllable(playerid, 0);
		}else{
		    DisablePlayerCheckpoint(playerid);
	       	TokoCP[playerid] = 4;
		    SetPlayerCheckpoint( playerid, 1390.2943,378.5014,19.7578, 5.0 );
		    SendClientMessage(playerid,-1,"Pulangkan Kendaraan kamu.");
		    waktugaji[playerid] = SetTimerEx("timer_gaji", 8000, false, "i", playerid);
	    	TogglePlayerControllable(playerid, 0);
		}
        return 1;
    }
    if(TokoCP[playerid] == 4)
    {
        DisablePlayerCheckpoint(playerid);
       	TokoCP[playerid] = 0;
		return 1;
	}
	return 1;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || (newkeys & KEY_CROUCH))
	{
		if(PlayerInfo[playerid][rank] >= 1 || PlayerInfo[playerid][rank] <= 4)
		{
		    new vehicleid = GetPVarInt(playerid, "LastvehicleID");
	 		if(IsPlayerInRangeOfPoint(playerid, 4,1390.2943,378.5014,19.7578))
		   	{
    		    if(GetVehicleModel(vehicleid) != 498) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Khusus Kendaraan Boxville.");
		   	   	new car = GetPlayerVehicleID(playerid);
		   		SetVehiclePos(car, 947.9907,2173.7676,1011.0992);
			 	SetVehicleZAngle(car, 358.7489);
		   	    LinkVehicleToInterior(car, 1);
			    SetPlayerInterior(playerid,1);
			    PutPlayerInVehicle(playerid, car, 0);
			    GudangCP[playerid] = CreateDynamicCP(947.0612, 2152.7158, 1011.0915, 5.0, .playerid = playerid);
				return 1;
		   	}
		}
	}
	if (newkeys & KEY_WALK)
    {	    	
        new id = dekat_daging(playerid);
        new gid = GetPVarInt(playerid, "ID_Gudang");
		if(id != -1)
		{				
		    if(PlayerInfo[playerid][rank] >=2)
			{
    		    if(GetPlayerSkin(playerid) != 168) return SendClientMessage(playerid,-1,"kamu harus ganti pakain dulu.");
			    if(GudangData[gid][StoK] == 0) return SendClientMessage(playerid, 0x3498DBFF, "Butcher: {FFFFFF}Penyimpaan di gudang lagi kosong.");
			    if(motongdaging[playerid] == 0)
			    {
			        motongdaging[playerid] = 1;
			        GudangData[gid][StoK] -= 1;
	         		ApplyAnimation(playerid, "KISSING", "GFWAVE2", 4.1, 1, 0, 0, 1, 0, 1);
	         		waktupotong[playerid] = SetTimerEx("timer_daging", 5000, false, "i", playerid);
					return 1;
				}
			}
		}
	    if(IsPlayerInRangeOfPoint(playerid, 4,1504.7336,-62.0368,23.2790))
		{
	        if(PlayerInfo[playerid][rank] == 0 ) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Kamu tidak bekerja di bagian ini.");
			new vehicleid = GetPVarInt(playerid, "LastvehicleID");
			new Float: x, Float: y, Float: z;
			if(LoadedSapi[vehicleid] >= MAX_SAPI) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Muatan penuh, Anda tidak dapat menambah Sapi lagi."), HoldItems_ResetPlayer(playerid), LoadedSapi[vehicleid] = MAX_SAPI;
			if(ambilbarang[playerid] == 0)
			{
		    	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Anda tidak dapat menggunakan perintah ini di dalam kendaraan.");
				if(GetVehicleModel(vehicleid) != 498) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Kendaraan terakhir Anda haruslah Boxville.");
				GetVehicleBoot(vehicleid, x, y, z);

				if(GetPlayerDistanceFromPoint(playerid, x, y, z) >= 30.0) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Anda tidak berada di dekat Boxville Anda.");
		        SendClientMessage(playerid,-1,"Sedang mengikat sapi dengan tali.");
		        RefuelTimer[playerid] = SetTimerEx("timer_refuel", 15000, false, "i", playerid);
		        ambilbarang[playerid] = 1;
	            ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.1, 1, 0, 0, 1, 0, 1);
	            SetVehicleParamsEx(vehicleid, -1, -1, 0, false, -1, -1, -1);
	            return 1;
			}else{
				ambilbarang[playerid] = 0;
				KillTimer(RefuelTimer[playerid]);
				SendClientMessage(playerid,-1,"Anda membatalkan proses pengikatan.");
				ClearAnimations(playerid);
				return 1;
			}
		}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_NAIK:
	    {
	        if(response)
	        {
	            if(PlayerInfo[playerid][rank] == 1)
	            {
	                if(PlayerInfo[playerid][totalkerja] > level2)
	                {
	                    PlayerInfo[playerid][rank] = 2;
	                    SendClientMessage(playerid, -1, "Selamat kamu naik level");
	                    return 1;
					}else{
					    SendClientMessage(playerid, -1, "Point kamu belum memenuhi syarat");
	                    return 1;
					}
				}
				if(PlayerInfo[playerid][rank] == 2)
	            {
	                if(PlayerInfo[playerid][totalkerja] > level3)
	                {
	                    PlayerInfo[playerid][rank] = 3;
	                    SendClientMessage(playerid, -1, "Selamat kamu naik level");
	                    return 1;
					}else{
					    SendClientMessage(playerid, -1, "Point kamu belum memenuhi syarat");
	                    return 1;
					}
				}
				if(PlayerInfo[playerid][rank] == 3)
	            {
	                if(PlayerInfo[playerid][totalkerja] > level4)
	                {
	                    PlayerInfo[playerid][rank] = 4;
	                    SendClientMessage(playerid, -1, "Selamat kamu naik level");
	                    return 1;
					}else{
					    SendClientMessage(playerid, -1, "Point kamu belum memenuhi syarat");
	                    return 1;
					}
				}
				if(PlayerInfo[playerid][rank] == 4 )
				{
				    SendClientMessage(playerid, -1, "Kamu sudah berada di level tertinggi");
                    return 1;
				}
			}
			return 1;
		}
	    case DIALOG_GUDANGCP:
	    {
            ResetGCP(playerid);
         	if(response)
	        {
	            new vehicleid = GetPVarInt(playerid, "LastVehicleID");
                new string[500], id = PlayerInfo[playerid][DealerID];
        		if(listitem == 0)
				{
				    if(LoadedSapi[vehicleid] == 0)
					{
						SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Isi muatan mu kosong.");
			            ShowPlayerDialog(playerid, DIALOG_SAVEEMBIM, DIALOG_STYLE_MSGBOX, "JOB BUTCHER", "Mau lanjut kerja atau Simpan Kendaraan?.", "Kerja", "Simpan");
						return 1;
     				}else{
						GudangData[id][StoK] += LoadedSapi[vehicleid];
						PlayerInfo[playerid][totalkerja] += LoadedSapi[vehicleid];
			            GivePlayerMoney(playerid, LoadedSapi[vehicleid] * HARGA_PER_EKOR);
			            format(string, sizeof(string), "Butcher: {FFFFFF}%s ekor Sapi dengan harga {2ECC71}%s.", formatInt(LoadedSapi[vehicleid], .iCurrencyChar = '\0'), formatInt(LoadedSapi[vehicleid] * HARGA_PER_EKOR));
			            SendClientMessage(playerid, 0x3498DBFF, string);
			            LoadedSapi[vehicleid] = 0;
			            ShowPlayerDialog(playerid, DIALOG_SAVEEMBIM, DIALOG_STYLE_MSGBOX, "JOB BUTCHER", "Mau lanjut kerja atau Simpan Kendaraan?.", "Kerja", "Simpan");
						return 1;
					}
				}
			}
    		if(!response)
	        {
                new id = PlayerInfo[playerid][DealerID];
				GudangData[id][veh] += 1;
				DestroyVehicle(GetPlayerVehicleID(playerid));
				SendClientMessage(playerid, -1, "Kendaraan Berhasil Di Simpan !!!.");
				TogglePlayerControllable(playerid,1);
				return 1;
			}
		    return 1;
	    }
	    
	    case DIALOG_SAVEEMBIM:
	    {
        	ResetGCP(playerid);
		 	if(!response)
	        {
                new id = PlayerInfo[playerid][DealerID];
				GudangData[id][veh] += 1;
				DestroyVehicle(GetPlayerVehicleID(playerid));
				SendClientMessage(playerid, -1, "Kendaraan Berhasil Di Simpan !!!.");
				TogglePlayerControllable(playerid,1);
				return 1;
			}
			if(response)
	        {
                new uwu = GetPlayerVehicleID(playerid);
				if(PlayerInfo[playerid][rank] == 4)
				{
                	new dialog[300], id = PlayerInfo[playerid][DealerID];
					format(
						dialog,
						sizeof(dialog),
						"{%06x}Ambil Sapi \n\
						{%06x}Daging siap kirim \t%s \n\
						{FFFFFF}Simpan Kendaraan\t\t",
						(GudangData[id][Jual] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8,formatInt(GudangData[id][Jual], .iCurrencyChar = '\0')
					);
					ShowPlayerDialog(playerid, DIALOG_GUDANGCP1, DIALOG_STYLE_LIST, "Gudang Butcher", dialog, "Pilih", "Gak Jadi");
					ResetGCP(playerid);
					return 1;
				}    		 
    		    if(PlayerInfo[playerid][rank] == 1 || PlayerInfo[playerid][rank] == 3)
				{
				    SendClientMessage(playerid, 0x3498DBFF, "Butcher: {FFFFFF}Pergi ke pedesaan .");
					SetVehiclePos(uwu, 1405.0497,414.2567,19.8284);
				 	SetVehicleZAngle(uwu,246.5038);
			   	    LinkVehicleToInterior(uwu, 0);
				    SetPlayerInterior(playerid,0);
				    PutPlayerInVehicle(playerid, uwu, 0);
				    ResetGCP(playerid);
					return 1;
				}
			}
	        return 1;
	    }
		case DIALOG_LISTG:
	    {
         	if(response)
	        {
                new dialog[300], id = PlayerInfo[playerid][DealerID];
				if(listitem == 3)
				{
        		    if(GudangData[id][veh] == 0) return  SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Semua kendaraan sedang di pakai."), ListGudang(playerid);
					GudangData[id][veh] -= 1;
					new mobilbox = CreateVehicle(498, 1405.0497,414.2567,19.8284, 246.5038, 13, 120, -1);
					if(PlayerInfo[playerid][rank] == 4)
					{
						format(
							dialog,
							sizeof(dialog),
							"{ffffff}Ambil Sapi \n\
							{%06x}Daging siap kirim \t%s\n\
							{FFFFFF}Simpan Kendaraan\t\t",
							(GudangData[id][Jual] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8,formatInt(GudangData[id][Jual], .iCurrencyChar = '\0')
						);
						AntarDaging[playerid] = 1;
						ShowPlayerDialog(playerid, DIALOG_GUDANGCP1, DIALOG_STYLE_LIST, "Gudang Butcher", dialog, "Pilih", "Gak Jadi");
						SetVehiclePos(mobilbox, 1405.0497,414.2567,19.8284+2);
						SetPlayerInterior(playerid,0);
		    			PutPlayerInVehicle(playerid, mobilbox, 0);
						return 1;
					}
			  		if(PlayerInfo[playerid][rank] >= 1 || PlayerInfo[playerid][rank] <= 3)
					{
					    SendClientMessage(playerid, 0x3498DBFF, "Butcher: {FFFFFF}Pergi ke pedesaan .");
						SetVehiclePos(mobilbox, 1405.0497,414.2567,19.8284+2);
						SetPlayerInterior(playerid,0);
		    			PutPlayerInVehicle(playerid, mobilbox, 0);
						return 1;
					}
					return 1;
					
				}
			}
	        return 1;
	    }
	    case DIALOG_AMBILDAGING:
	    {
			if(response)
			{
                new id = PlayerInfo[playerid][DealerID];
    		    if(GudangData[id][Potong] < MAX_DAGING) return SendClientMessage(playerid, -1, "Minimal penyimanan 20 potong dagging!!!.");
                if(PlayerInfo[playerid][daging] == MAX_DAGING) return SendClientMessage(playerid, -1, "Kamu sudah mengambil potongan daging silahkan masukan ke mesin!!!.");
	 	  		GudangData[id][Potong]  -= MAX_DAGING;
	 	  		PlayerInfo[playerid][daging] = MAX_DAGING;
				SendClientMessage(playerid, -1, "Masukkan kedalam mesin scenner!!!.");
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
				ClearAnimations(playerid);
				return 1;
				
			}
			return 1;
		}
	    case DIALOG_GUDANGCP1:
	    {
	        ResetGCP(playerid);
         	if(!response)
	        {
                new id = PlayerInfo[playerid][DealerID];
				GudangData[id][veh] += 1;
				DestroyVehicle(GetPlayerVehicleID(playerid));
				SendClientMessage(playerid, -1, "Kendaraan Di Simpan !!!.");
				TogglePlayerControllable(playerid,1);
				return 1;

			}
			if(response)
	        {
                new vehicleid = GetPVarInt(playerid, "LastVehicleID");
	    		if(listitem == 0)
				{
	        	    /*SendClientMessage(playerid, 0x3498DBFF, "Butcher: {FFFFFF}Pergi ke pedesaan .");
					SetVehiclePos(vehicleid, 1405.0497,414.2567,19.8284);
				 	SetVehicleZAngle(vehicleid,246.5038);
			   	    LinkVehicleToInterior(vehicleid, 0);
				    SetPlayerInterior(playerid,0);*/
				    new string[500], id = PlayerInfo[playerid][DealerID];
				    if(LoadedSapi[vehicleid] == 0)
					{
						SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Isi muatan mu kosong.");
			            ShowPlayerDialog(playerid, DIALOG_SAVEEMBIM, DIALOG_STYLE_MSGBOX, "JOB BUTCHER", "Mau lanjut kerja atau Simpan Kendaraan?.", "Kerja", "Simpan");
						return 1;
     				}else{
						GudangData[id][StoK] += LoadedSapi[vehicleid];
						PlayerInfo[playerid][totalkerja] += LoadedSapi[vehicleid];
			            GivePlayerMoney(playerid, LoadedSapi[vehicleid] * HARGA_PER_EKOR);
			            format(string, sizeof(string), "Butcher: {FFFFFF}%s ekor Sapi dengan harga {2ECC71}%s.", formatInt(LoadedSapi[vehicleid], .iCurrencyChar = '\0'), formatInt(LoadedSapi[vehicleid] * HARGA_PER_EKOR));
			            SendClientMessage(playerid, 0x3498DBFF, string);
			            LoadedSapi[vehicleid] = 0;
			            ShowPlayerDialog(playerid, DIALOG_SAVEEMBIM, DIALOG_STYLE_MSGBOX, "JOB BUTCHER", "Mau lanjut kerja atau Simpan Kendaraan?.", "Kerja", "Simpan");
						return 1;
					}
				}
				if(listitem == 1)
				{
				    new rand = random( sizeof( Toko ) ), id = PlayerInfo[playerid][DealerID];
		    	    if(GudangData[id][Jual] <60 ) return SendClientMessage(playerid,-1,"Minimal 60 dagging potong di gudang untuk bisa kirim.");

	    			SetVehiclePos(vehicleid, 1405.0497,414.2567,19.8284);
				 	SetVehicleZAngle(vehicleid,246.5038);
			   	    LinkVehicleToInterior(vehicleid, 0);
				    SetPlayerInterior(playerid,0);

				    SendClientMessage(playerid, 0x3498DBFF, "Butcher: {FFFFFF}Antarkan daging potongnya ke Checkpoint.");
					LoadedDaging[vehicleid] = 60;
				    TokoCP[playerid] = 1;
				    SetPlayerCheckpoint( playerid, Toko[ rand ][ 0 ], Toko[ rand ][ 1 ], Toko[ rand ][ 2 ], 5.0 );
					return 1;
				}
				if(listitem == 2)
				{
	                new id = PlayerInfo[playerid][DealerID];
					GudangData[id][veh] += 1;
					DestroyVehicle(GetPlayerVehicleID(playerid));
					SendClientMessage(playerid, -1, "Kendaraan Di Simpan !!!.");
					TogglePlayerControllable(playerid,1);
					return 1;
				}
			}
	        return 1;
	    }
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
	    new
		    string[128],
		    rand = random( sizeof( Toko ) ),
			vehicleid = GetPVarInt(playerid, "LastVehicleID");
			
	    if(GetVehicleModel(vehicleid) == 498)
	    {
	        if(PlayerInfo[playerid][rank] >= 1)
	        {
			    if(LoadedSapi[vehicleid] > 0) {
			        format(string, sizeof(string), "BUTCHER JOB: {FFFFFF}Kendaraan ini memiliki {F39C12}%d{FFFFFF} Sapi yang bernilai{2ECC71} $%d.", LoadedSapi[vehicleid], LoadedSapi[vehicleid] * HARGA_PER_EKOR);
					SendClientMessage(playerid, 0x2ECC71FF, string);
					SendClientMessage(playerid, 0x2ECC71FF, "BUTCHER JOB: {FFFFFF}Anda dapat pergi ke pabrik untuk menjual Sapi di dalam kendaraan.");
					return 1;
			    }else{
			        SendClientMessage(playerid, 0x2ECC71FF, "BUTCHER JOB: {FFFFFF}Pergi ke pedesaan untuk mengambil Sapi disana.");
					return 1;
			    }
			}
			if(PlayerInfo[playerid][rank] == 4)
			{
		    	if(LoadedDaging[vehicleid] >= 0)
    			{
					if(AntarDaging[playerid] == 0)
					{
						SendClientMessage(playerid, 0x2ECC71FF,"Antarkan dagging potong sesuai dengan Checkpoint");
						AntarDaging[playerid] = 1;
						TokoCP[playerid] = 1;
					    SetPlayerCheckpoint( playerid, Toko[ rand ][ 0 ], Toko[ rand ][ 1 ], Toko[ rand ][ 2 ], 5.0 );
						return 1;
					}
				}
			}
		}
  		SetPVarInt(playerid, "LastVehicleID", GetPlayerVehicleID(playerid));
		return 1;
	}
	return 1;
}

Callback:: LoadGudang()
{
	new rows = cache_num_rows();
 	if(rows)
  	{
   		new id, loaded, string[250], Float:x, Float:y, Float:z;
		while(loaded < rows)
		{
  			cache_get_value_name_int(loaded, "id", id);
		    cache_get_value_name_int(loaded, "kendaraan", GudangData[id][veh]);
	     	cache_get_value_name_int(loaded, "daging_potong", GudangData[id][Potong]);
		    cache_get_value_name_int(loaded, "siap_jual", GudangData[id][Jual]);
		    cache_get_value_name_int(loaded, "penyimpanan", GudangData[id][StoK]);

		    cache_get_value_name(loaded, "Pos", string, sizeof(string));
		    sscanf(string, "p<|>fff", GudangData[id][gudangX],GudangData[id][gudangY],GudangData[id][gudangZ]);

		    cache_get_value_name(loaded, "Bpos", string, sizeof(string));
		    sscanf(string, "p<|>fff", x,y,z);
			GudangData[id][baju] = CreateDynamicPickup(1275, 23, x, y, z,0);

	 		GudangData[id][listg] = CreateDynamicCP(GudangData[id][gudangX],GudangData[id][gudangY],GudangData[id][gudangZ],1.0,-1,-1,-1,2.0);

		    
		    loaded++;
	    }

	    printf(" [Sistem Gudang] Memuat %d Gudang.", loaded);
	}

	return 1;
}

Callback:: timer_daging(playerid)
{
    if(motongdaging[playerid] == 1)
	{
	    new randdaging = 5 + random(15);
     	new string[128];
	    PlayerInfo[playerid][tasdaging] += randdaging;
		motongdaging[playerid] = 0;
		KillTimer(waktupotong[playerid]);
		format(string,sizeof(string), "Daging yang di peroleh: %d Potong", randdaging);
		SendClientMessage(playerid, COLOR_WHITE, string);
		SendClientMessage(playerid,0xFFC800FF,"Pindahkan kelemari es");
		ClearAnimations(playerid);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
		ClearAnimations(playerid);
	}
	return 1;
}

Callback:: timer_gaji(playerid)
{
    new string[128];
    SendClientMessage(playerid,COLOR_WHITE,"___________________[PEKERJAAN BUTCHER PENGANTAR DAGING]___________________");
    format(string, sizeof(string),"Atas Nama: %s", GetName(playerid));
    SendClientMessage(playerid, COLOR_WHITE, string);
	new randcheck = 150 + random(50);
    GivePlayerMoney(playerid, randcheck);
	format(string,sizeof(string), "Gaji Pekerjaan: $%d", randcheck);
	SendClientMessage(playerid, COLOR_WHITE, string);
	SendClientMessage(playerid,COLOR_WHITE,"__________________________________________________________________________");
    PlayerPlaySound(playerid, 1058  , 0.0, 0.0, 0.0);
	TogglePlayerControllable(playerid, 1);
	KillTimer(waktugaji[playerid]);
	return 1;
}

Callback::  timer_scan(playerid)
{
	KillTimer(waktuscan[playerid]);
	SendClientMessage(playerid,0xFFC800FF,"Proses scan daging telah selesai");
    ScanCP[playerid] = CreateDynamicCP(942.3690,2137.2954,1011.0234, 1.0, .playerid = playerid);
	return 1;
}

Callback::  timer_scan1(playerid)
{
	KillTimer(waktuscan[playerid]);
	SendClientMessage(playerid,0xFFC800FF,"Proses scan daging telah selesai");
    ScanCP[playerid] = CreateDynamicCP(942.2988,2173.1387,1011.0234, 1.0, .playerid = playerid);
	return 1;
}

Callback::  timer_refuel(playerid)
{
    new vehicleid = GetPVarInt(playerid, "LastVehicleID");
	new Float: x, Float: y, Float: z;
    if(ambilbarang[playerid] == 1)
	{
	    PlayerInfo[playerid][karung] = 1;
		ambilbarang[playerid] = 0;
		KillTimer(RefuelTimer[playerid]);
		SendClientMessage(playerid,0xFFC800FF,"Pindahkan Sapi ke mobil");
		GetVehicleBoot(vehicleid, x, y, z);
		DagingCP[playerid] = CreateDynamicCP(x, y, z, 3.0, .playerid = playerid);
		ClearAnimations(playerid);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
		ClearAnimations(playerid);
	}
	return 1;
}


dekat_daging(playerid, Float: range = 0.8)
{
	new id = -1, Float: dist = range, Float: tempdist;
	for(new i; i < MAX_POTONG; i++)
	{
	    tempdist = GetPlayerDistanceFromPoint(playerid, Duar[i][duarX], Duar[i][duarY], Duar[i][duarZ]);

	    if(tempdist > range) continue;
		if(tempdist <= dist)
		{
			dist = tempdist;
			id = i;
		}
	}

	return id;
}

ListGudang(playerid)
{
	new dialog[300], id = PlayerInfo[playerid][DealerID];
	format(
		dialog,
		sizeof(dialog),
		"{%06x}Daging potong \t%s\n\
		{%06x}Daging siap kirim \t%s\n\
		{%06x}Sapi digudang \t%s\n\
		{%06x}Kendaraan(Spawn) \t%s",
		(GudangData[id][Potong] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8, formatInt(GudangData[id][Potong], .iCurrencyChar = '\0'),
		(GudangData[id][Jual] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8,formatInt(GudangData[id][Jual], .iCurrencyChar = '\0'),
		(GudangData[id][StoK] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8, formatInt(GudangData[id][StoK], .iCurrencyChar = '\0'),
		(GudangData[id][veh] > 0) ? 0xFFFFFFFF >>> 8 : 0xE74C3CFF >>> 8,formatInt(GudangData[id][veh], .iCurrencyChar = '\0')
	);
	ShowPlayerDialog(playerid, DIALOG_LISTG, DIALOG_STYLE_LIST, "Gudang Butcher", dialog, "Pilih", "Tutup");
	return 1;
}


formatInt(intVariable, iThousandSeparator = ',', iCurrencyChar = '$')
{
	static
		s_szReturn[ 32 ],
		s_szThousandSeparator[ 2 ] = { ' ', EOS },
		s_szCurrencyChar[ 2 ] = { ' ', EOS },
		s_iVariableLen,
		s_iChar,
		s_iSepPos,
		bool:s_isNegative
	;

	format( s_szReturn, sizeof( s_szReturn ), "%d", intVariable );

	if(s_szReturn[0] == '-')
		s_isNegative = true;
	else
		s_isNegative = false;

	s_iVariableLen = strlen( s_szReturn );

	if ( s_iVariableLen >= 4 || iThousandSeparator)
	{
		s_szThousandSeparator[ 0 ] = iThousandSeparator;

		s_iChar = s_iVariableLen;
		s_iSepPos = 0;

		while ( --s_iChar > _:s_isNegative )
		{
			if ( ++s_iSepPos == 3 )
			{
				strins( s_szReturn, s_szThousandSeparator, s_iChar );

				s_iSepPos = 0;
			}
		}
	}
	if(iCurrencyChar) {
		s_szCurrencyChar[ 0 ] = iCurrencyChar;
		strins( s_szReturn, s_szCurrencyChar, _:s_isNegative );
	}
	return s_szReturn;
}


HoldItems_ResetPlayer(playerid)
{
	if(IsValidDynamicCP(DagingCP[playerid])) DestroyDynamicCP(DagingCP[playerid]);
	DagingCP[playerid] = -1;
	return 1;
}


Trash_ShowCapacity(playerid)
{
    new vehicleid = GetPlayerVehicleID(playerid), string[32];
    format(string, sizeof(string), "Kapasitas Kendaraan (%d/%d)", LoadedSapi[vehicleid], MAX_SAPI);
    SendClientMessage(playerid, 0x2ECC71FF, string);
	return 1;
}

ResetGCP(playerid)
{
	if(IsValidDynamicCP(GudangCP[playerid])) DestroyDynamicCP(GudangCP[playerid]);
	GudangCP[playerid] = -1;
	return 1;
}

stock GetName(playerid) 
{
    new name[ 32 ]; 
    GetPlayerName(playerid, name, sizeof( name )); 
    return name;
}

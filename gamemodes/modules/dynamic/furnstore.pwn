/*
	Defined list for furniture system.
*/
#define MAX_FURNSTORE				10
#define MAX_EMPLOYE					3

#define MAX_FURN_OBJECT				(MAX_FURNSTORE*100)
#define MAX_FURNSTORE_OBJECT		50

new ManageFurnStore[MAX_PLAYERS] = {-1, ...},
	ManageFurnObject[MAX_PLAYERS] = {-1, ...},
	SelectToFired[MAX_PLAYERS][MAX_EMPLOYE],
	ListedFurnObject[MAX_PLAYERS][MAX_FURNSTORE_OBJECT],
	editFurnPosition[MAX_PLAYERS] = {-1, ...};
		
new produceObject[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...},
	bool:startProduce[MAX_PLAYERS],
	productionCount[MAX_PLAYERS],
	productionAdd[MAX_PLAYERS],
	Timer:productionTimer[MAX_PLAYERS];

new production;

new Float:production_Array[] =
{
	1492.01, 1791.86,
	1491.96, 1786.34,
	1487.19, 1786.48,
	1487.16, 1792.00
};

enum E_FURNSTORE
{
	storeID,

	storeName[32],
	storeOwnerName[MAX_PLAYER_NAME],

	Float:storePos[3],
	Float:storeIntPos[3],

	storeOwner,
	storePrice,
	storeVault,
	storeEmploye[MAX_EMPLOYE],
	storeSeal,
	storeLocked,

	storePickup,
	Text3D:storeLabel,
	storeCP
};

new storeData[MAX_FURNSTORE][E_FURNSTORE],
	Iterator:FurnStore<MAX_FURNSTORE>;


enum E_FURNPROP {
	furnID,

	furnName[32],

	Float:furnPos[3],
	Float:furnRot[3],
	furnPrice,
	furnStock,
	furnModel,
	furnStoreId,

	furnMaterials[MAX_MATERIALS],

	Text3D:furnLabel,
	furnObject
};
new FurnStore[MAX_FURN_OBJECT][E_FURNPROP],
	Iterator:FurnObject<MAX_FURN_OBJECT>;

#include <YSI\y_hooks>
hook OnGameModeInitEx()
{
	new tmpobjid;
	tmpobjid = CreateDynamicObject(19379, 1479.442504, 1771.412963, 9.820310, 0.000000, 90.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "carpbroth1", 0x00000000);
	tmpobjid = CreateDynamicObject(19377, 1479.442504, 1771.412963, 13.380313, 0.000000, 90.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "donut_ceil", 0x00000000);
	tmpobjid = CreateDynamicObject(19379, 1468.942382, 1771.412963, 9.820310, 0.000000, 90.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "carpbroth1", 0xFFFFFFFF);
	tmpobjid = CreateDynamicObject(19379, 1479.442504, 1781.023681, 9.820310, 0.000000, 90.000038, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "carpbroth1", 0x00000000);
	tmpobjid = CreateDynamicObject(19379, 1468.942382, 1781.023681, 9.820310, 0.000000, 90.000038, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "carpbroth1", 0xFFFFFFFF);
	tmpobjid = CreateDynamicObject(19445, 1470.069335, 1766.577636, 11.570336, 0.000022, 0.000000, 89.999931, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 14531, "int_zerosrca", "CJ_RC_WIN", 0x00000000);
	tmpobjid = CreateDynamicObject(19805, 1479.000732, 1766.639282, 12.046256, 0.000000, -0.000022, 179.999862, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 14531, "int_zerosrca", "CJ_RC_WIN", 0x00000000);
	tmpobjid = CreateDynamicObject(19379, 1479.442504, 1790.631347, 9.820310, 0.000000, 90.000045, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "carpbroth1", 0xFFFFFFFF);
	tmpobjid = CreateDynamicObject(19379, 1468.942382, 1790.631347, 9.820310, 0.000000, 90.000045, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "carpbroth1", 0xFFFFFFFF);
	tmpobjid = CreateDynamicObject(19445, 1470.069335, 1795.403076, 11.570336, 0.000029, 0.000000, 89.999908, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 14531, "int_zerosrca", "CJ_RC_WIN", 0x00000000);
	tmpobjid = CreateDynamicObject(19805, 1469.099731, 1766.639282, 12.046256, 0.000000, -0.000022, 179.999862, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 14531, "int_zerosrca", "CJ_RC_WIN", 0x00000000);
	tmpobjid = CreateDynamicObject(19377, 1468.972167, 1771.412963, 13.380313, 0.000000, 90.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "donut_ceil", 0x00000000);
	tmpobjid = CreateDynamicObject(19377, 1479.442504, 1781.003295, 13.380313, 0.000000, 90.000030, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "donut_ceil", 0x00000000);
	tmpobjid = CreateDynamicObject(19377, 1468.972167, 1781.003295, 13.380313, 0.000000, 90.000030, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "donut_ceil", 0x00000000);
	tmpobjid = CreateDynamicObject(19377, 1479.442504, 1790.624023, 13.380313, 0.000000, 90.000038, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "donut_ceil", 0x00000000);
	tmpobjid = CreateDynamicObject(19377, 1468.972167, 1790.624023, 13.380313, 0.000000, 90.000038, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "donut_ceil", 0x00000000);
	tmpobjid = CreateDynamicObject(19445, 1484.748901, 1781.057250, 11.570336, 0.000000, 0.000029, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18065, "ab_sfammumain", "breezewall", 0x00000000);
	tmpobjid = CreateDynamicObject(19445, 1484.748901, 1793.887329, 11.570336, 0.000000, 0.000029, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18065, "ab_sfammumain", "breezewall", 0x00000000);
	tmpobjid = CreateDynamicObject(19383, 1484.748901, 1787.476440, 11.570336, 0.000000, 0.000029, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18065, "ab_sfammumain", "breezewall", 0x00000000);
	tmpobjid = CreateDynamicObject(19445, 1489.417846, 1781.057250, 11.570336, 0.000022, 0.000007, 89.999931, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18065, "ab_sfammumain", "breezewall", 0x00000000);
	tmpobjid = CreateDynamicObject(19445, 1494.109130, 1785.915893, 11.570336, 0.000000, -0.000015, 179.999862, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18065, "ab_sfammumain", "breezewall", 0x00000000);
	tmpobjid = CreateDynamicObject(19445, 1494.109130, 1795.534545, 11.570336, 0.000000, -0.000015, 179.999862, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18065, "ab_sfammumain", "breezewall", 0x00000000);
	tmpobjid = CreateDynamicObject(19445, 1489.588256, 1795.534545, 11.570336, -0.000022, 0.000007, -89.999931, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18065, "ab_sfammumain", "breezewall", 0x00000000);
	tmpobjid = CreateDynamicObject(19377, 1489.911987, 1790.615356, 13.380313, 0.000000, 90.000038, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "donut_ceil", 0x00000000);
	tmpobjid = CreateDynamicObject(19377, 1489.911987, 1781.014282, 13.380313, 0.000000, 90.000038, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "donut_ceil", 0x00000000);
	tmpobjid = CreateDynamicObject(19379, 1489.922729, 1790.631347, 9.820310, 0.000000, 90.000045, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "stadium_ground2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 14531, "int_zerosrca", "stadium_ground2", 0x00000000);
	tmpobjid = CreateDynamicObject(19379, 1489.922729, 1780.996948, 9.820310, 0.000000, 90.000045, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14531, "int_zerosrca", "stadium_ground2", 0x00000000);
	tmpobjid = CreateDynamicObject(2459, 1473.646606, 1776.077148, 9.906250, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 17588, "lae2coast_alpha", "plainglass", 0x00000000);
	tmpobjid = CreateDynamicObject(2459, 1473.646606, 1781.775512, 9.906250, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 17588, "lae2coast_alpha", "plainglass", 0x00000000);
	tmpobjid = CreateDynamicObject(2459, 1473.646606, 1787.336791, 9.906250, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 17588, "lae2coast_alpha", "plainglass", 0x00000000);
	tmpobjid = CreateDynamicObject(2460, 1468.405029, 1767.163330, 9.906250, 0.000022, 0.000000, 89.999931, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 17588, "lae2coast_alpha", "plainglass", 0x00000000);
	tmpobjid = CreateDynamicObject(2460, 1472.895019, 1768.624023, 9.906250, 0.000000, -0.000022, 179.999862, -1, 3, -1, 150.00, 150.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 17588, "lae2coast_alpha", "plainglass", 0x00000000);
	tmpobjid = CreateDynamicObject(19899, 1486.277587, 1795.005615, 9.923306, -0.000022, 0.000000, -89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19445, 1484.598754, 1771.427856, 11.570336, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19445, 1479.688232, 1766.577636, 11.570336, 0.000022, 0.000000, 89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19353, 1463.652099, 1766.557250, 11.570314, 0.000022, 0.000000, 89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19445, 1484.598754, 1781.057250, 11.570336, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19445, 1479.688232, 1795.403076, 11.570336, 0.000029, 0.000000, 89.999908, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19353, 1463.652099, 1795.382690, 11.570314, 0.000029, 0.000000, 89.999908, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19445, 1484.598754, 1793.887329, 11.570336, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19383, 1484.598754, 1787.476440, 11.570336, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19445, 1463.716918, 1774.656982, 11.570336, 0.000000, 0.000029, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19445, 1463.716918, 1784.147583, 11.570336, 0.000000, 0.000029, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19445, 1463.716918, 1793.787231, 11.570336, 0.000000, 0.000029, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19383, 1463.716918, 1768.236083, 11.570336, 0.000000, 0.000029, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(1496, 1463.677368, 1767.508789, 9.816246, 0.000022, 0.000000, 89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(1893, 1478.857543, 1769.752319, 13.296257, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(1893, 1468.365722, 1769.752319, 13.296257, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(1893, 1478.857543, 1779.355102, 13.296257, 0.000000, 0.000029, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(1893, 1468.365722, 1779.355102, 13.296257, 0.000000, 0.000029, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(1893, 1478.857543, 1788.976074, 13.296257, 0.000000, 0.000037, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(1893, 1468.365722, 1788.976074, 13.296257, 0.000000, 0.000037, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2414, 1484.156616, 1771.097045, 9.906250, -0.000022, 0.000000, -89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2414, 1484.156616, 1773.097778, 9.906250, -0.000022, 0.000000, -89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2414, 1484.156616, 1775.097656, 9.906250, -0.000022, 0.000000, -89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2414, 1484.156616, 1777.087036, 9.906250, -0.000029, 0.000000, -89.999908, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2190, 1468.129394, 1767.497436, 10.966259, 0.000022, 0.000000, 89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2414, 1470.454101, 1768.645263, 9.906250, 0.000000, -0.000022, 179.999862, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(1514, 1469.326293, 1768.496215, 11.196251, 0.000000, -0.000022, 179.999862, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2362, 1469.116699, 1768.612792, 10.966258, 0.000000, -0.000022, 179.999862, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(1885, 1469.312866, 1769.303466, 9.906250, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2482, 1471.081176, 1766.759277, 9.886248, 0.000000, -0.000022, 179.999862, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2482, 1472.511474, 1766.759277, 9.886248, 0.000000, -0.000022, 179.999862, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2414, 1484.156616, 1779.087768, 9.906250, -0.000029, 0.000000, -89.999908, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2414, 1484.156616, 1781.087646, 9.906250, -0.000029, 0.000000, -89.999908, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19899, 1485.356323, 1782.964477, 9.923306, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19900, 1485.233764, 1784.734008, 9.882514, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(2491, 1474.002807, 1768.903564, 9.906250, 0.000000, 0.000022, 0.000000, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19921, 1485.542358, 1783.072875, 11.265328, 0.000022, -0.000003, 98.499931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(3033, 1489.404541, 1789.140136, 9.908346, 89.999992, 540.000000, -89.999969, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(3033, 1491.863891, 1789.140136, 9.908346, 89.999992, 540.000000, -89.999969, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(3041, 1493.505004, 1790.096191, 9.842520, 0.000022, 0.000000, 89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(3041, 1493.505004, 1785.454833, 9.842520, 0.000022, 0.000000, 89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19815, 1493.965209, 1785.406738, 11.846323, -0.000022, 0.000000, -89.999931, -1, 3, -1, 150.00, 150.00);
	tmpobjid = CreateDynamicObject(19815, 1493.965209, 1790.218139, 11.846323, -0.000022, 0.000000, -89.999931, -1, 3, -1, 150.00, 150.00);

	// Buypoint
	// CreateDynamic3DTextLabel("[Furniture Buypoint]\n"WHITE"Type '"YELLOW"/buyfurniture"WHITE"' to buying a furniture", X11_LIGHTBLUE, 1470.3416, 1770.1165, 10.9062, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, 3);
	// CreateDynamicPickup(1274, 23, 1470.3416, 1770.1165, 10.9062, -1, 3);

	// Production area
	production = CreateDynamicPolygon(production_Array, _, _, _, _, 3, _);
	return 1;
}

/*
	Furniture store.

	Made by: Agus Syahputra
	Edited by: Lukman
	Idea by: Jogjagamers
*/

Function:FurnStore_Load()
{
	for(new index = 0; index != cache_num_rows(); index++)
	{
		new id = Iter_Free(FurnStore);

		Iter_Add(FurnStore, index);

		cache_get_value_int(index, "id", storeData[id][storeID]);
		cache_get_value_int(index, "owner", storeData[id][storeOwner]);
		cache_get_value_int(index, "price", storeData[id][storePrice]);
		cache_get_value_int(index, "vault", storeData[id][storeVault]);
		cache_get_value_int(index, "employe1", storeData[id][storeEmploye][0]);
		cache_get_value_int(index, "employe2", storeData[id][storeEmploye][1]);
		cache_get_value_int(index, "employe3", storeData[id][storeEmploye][2]);
		cache_get_value_int(index, "seal", storeData[id][storeSeal]);

		cache_get_value(index, "name", storeData[id][storeName], 32);
		cache_get_value(index, "ownername", storeData[id][storeOwnerName], MAX_PLAYER_NAME);

		cache_get_value_float(index, "x", storeData[id][storePos][0]);
		cache_get_value_float(index, "y", storeData[id][storePos][1]);
		cache_get_value_float(index, "z", storeData[id][storePos][2]);

		cache_get_value_float(index, "i_x", storeData[id][storeIntPos][0]);
		cache_get_value_float(index, "i_y", storeData[id][storeIntPos][1]);
		cache_get_value_float(index, "i_z", storeData[id][storeIntPos][2]);

		storeData[id][storeLocked] = 1;

		FurnStore_Refresh(id);
	}
	printf("*** [R:RP Database: Loaded] furnstore data (%d count).", cache_num_rows());
	return 1;
}

Function:OnFurnstoreCreated(index)
{
	storeData[index][storeID] = cache_insert_id();

	FurnStore_Save(index);
	FurnStore_Refresh(index);
	return 1;
}

FurnStore_Save(index)
{
	if(Iter_Contains(FurnStore, index))
	{
		new query[500];
		format(query, sizeof(query), "UPDATE `furnstore` SET `ownername` ='%s', `name` ='%s', `x` =%.1f, `y` =%.1f, `z` =%.1f, `i_x` =%.1f, `owner` =%d, `price`=%d, `vault` =%d, `employe1` =%d, `employe2` =%d, `employe3` =%d, `i_y` =%.1f, `i_z` =%.1f, `seal`=%d WHERE `id` = %d",
			storeData[index][storeOwnerName],
			SQL_ReturnEscaped(storeData[index][storeName]),
			storeData[index][storePos][0],
			storeData[index][storePos][1],
			storeData[index][storePos][2],
			storeData[index][storeIntPos][0],
			storeData[index][storeOwner],
			storeData[index][storePrice],
			storeData[index][storeVault],
			storeData[index][storeEmploye][0],
			storeData[index][storeEmploye][1],
			storeData[index][storeEmploye][2],
			storeData[index][storeIntPos][1],
			storeData[index][storeIntPos][2],
			storeData[index][storeSeal],
			storeData[index][storeID]
		);

		mysql_tquery(g_iHandle, query);
	}
	return 1;
}

FurnStore_Create(playerid, price)
{
	new index = cellmin;

	if((index = Iter_Free(FurnStore)) != cellmin)
	{
		Iter_Add(FurnStore, index);

		new Float:x, Float:y, Float:z;

		GetPlayerPos(playerid, x, y, z);

		storeData[index][storePos][0] = x;
		storeData[index][storePos][1] = y;
		storeData[index][storePos][2] = z;

		storeData[index][storeIntPos][0] = 1464.39;
		storeData[index][storeIntPos][1] = 1768.27;
		storeData[index][storeIntPos][2] = 10.90;

		storeData[index][storePrice] = price;
		storeData[index][storeOwner] = 0;
		storeData[index][storeVault] = 0;
		storeData[index][storeEmploye][0] = storeData[index][storeEmploye][1] = storeData[index][storeEmploye][2] = 0;
		storeData[index][storeSeal] = 0;
		storeData[index][storeLocked] = 1;

		mysql_tquery(g_iHandle, "INSERT INTO `furnstore` (`price`) VALUES (1)", "OnFurnstoreCreated", "d", index);

		return index;
	}
	return cellmin;
}

FurnStore_Refresh(index)
{
	if(Iter_Contains(FurnStore, index))
	{
		if(IsValidDynamicPickup(storeData[index][storePickup]))
			DestroyDynamicPickup(storeData[index][storePickup]);

		if(IsValidDynamic3DTextLabel(storeData[index][storeLabel]))
			DestroyDynamic3DTextLabel(storeData[index][storeLabel]);

		if(IsValidDynamicCP(storeData[index][storeCP]))
			DestroyDynamicCP(storeData[index][storeCP]);

		if(storeData[index][storeOwner])  {
			if (storeData[index][storeSeal]) {
				storeData[index][storeLabel] = CreateDynamic3DTextLabel(sprintf("[ID:%d]\n%s\n"WHITE"Owned by: "YELLOW"%s\n"WHITE"This furniture store is sealed by "RED"authority", index, storeData[index][storeName], storeData[index][storeOwnerName]), X11_LIGHTBLUE, storeData[index][storePos][0], storeData[index][storePos][1], storeData[index][storePos][2]+0.5, 10, _, _, 1, 0, 0);
			} else {
				storeData[index][storeLabel] = CreateDynamic3DTextLabel(sprintf("[ID:%d]\n%s\n"WHITE"Owned by: "YELLOW"%s\n"WHITE"Press '"RED"H"WHITE"' to go inside", index, storeData[index][storeName], storeData[index][storeOwnerName]), X11_LIGHTBLUE, storeData[index][storePos][0], storeData[index][storePos][1], storeData[index][storePos][2]+0.5, 10, _, _, 1, 0, 0);
			}
		}
		else {
			storeData[index][storeLabel] = CreateDynamic3DTextLabel(sprintf("[ID:%d]\n"GREEN"This Furniture Store is for sale\n"WHITE"Price: "YELLOW"%s\n"WHITE"Type /buyfurnstore to buy this", index, FormatNumber(storeData[index][storePrice])), X11_LIGHTBLUE, storeData[index][storePos][0], storeData[index][storePos][1], storeData[index][storePos][2]+0.5, 10, _, _, 1, 0, 0);
		}

		storeData[index][storePickup] = CreateDynamicPickup(1239, 23, storeData[index][storePos][0], storeData[index][storePos][1], storeData[index][storePos][2], 0, 0, _, 5);
		storeData[index][storeCP] = CreateDynamicCP(storeData[index][storePos][0], storeData[index][storePos][1], storeData[index][storePos][2], 1.5, 0, 0, _, 3);
	}
	return 1;
}

FurnStore_Nearest(playerid)
{
	foreach(new i : FurnStore) if(IsPlayerInRangeOfPoint(playerid, 4, storeData[i][storePos][0], storeData[i][storePos][1], storeData[i][storePos][2]) && GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0) {
		return i;
	}
	return -1;
}

FurnStore_Inside(playerid)
{
	if(PlayerData[playerid][pFurnStore] != -1)
	{
		foreach(new i : FurnStore) if(storeData[i][storeID] == PlayerData[playerid][pFurnStore] && GetPlayerInterior(playerid) == 3 && GetPlayerVirtualWorld(playerid) == (storeData[i][storeID]+1)) {
			return i;
		}
	}
	return -1;
}

FurnStore_IsOwner(playerid, index)
{
	if(!PlayerData[playerid][pLogged] || PlayerData[playerid][pID] == -1)
		return 0;

	if((Iter_Contains(FurnStore, index) && storeData[index][storeOwner] != 0) && storeData[index][storeOwner] == GetPlayerSQLID(playerid))
		return 1;

	return 0;
}

FurnStore_IsEmployee(playerid, index)
{
	if(!PlayerData[playerid][pLogged] || PlayerData[playerid][pID] == -1)
		return 0;

	if(Iter_Contains(FurnStore, index) && storeData[index][storeOwner] != 0) {
		for(new i = 0; i != MAX_EMPLOYE; i++) if(storeData[index][storeEmploye][i] == GetPlayerSQLID(playerid)) {
			return 1;
		}
	}
	return 0;
}

stock FurnStore_GetCount(playerid) {
	new count = 0;
	foreach (new i : FurnStore) if (storeData[i][storeOwner] == PlayerData[playerid][pID]) count++;
	return count;
}

GetDataByIndex(index, type = 0)
{
	new name[MAX_PLAYER_NAME] = "None",
		seen,
		Cache:getname;

	getname = mysql_query(g_iHandle, sprintf("SELECT `%s` FROM `characters` WHERE `ID`='%d'", !type ? ("Character") : ("LoginDate"), index));
	if(cache_num_rows()) {
		if(!type)
			cache_get_value(0, "Character", name);
		else {
			cache_get_value_int(0, "LoginDate", seen);
			format(name, MAX_PLAYER_NAME, "%s", GetDuration(gettime()-seen));
		}
	}
	cache_delete(getname);
	return name;
}

Employee_List(playerid, index)
{
	if(!Iter_Contains(FurnStore, index))
		return 0;

	new info[128],
		employe_count = 0;

	strcat(info, "Slot\tEmployee\tLast Login\n");
	for(new i = 0; i != MAX_EMPLOYE; i++) if(storeData[index][storeEmploye][i] > 0)
	{
		strcat(info, sprintf("%d\t%s\t%s\n", i+1, GetDataByIndex(storeData[index][storeEmploye][i]), GetDataByIndex(storeData[index][storeEmploye][i], 1)));
		SelectToFired[playerid][employe_count++] = i;
	}
	if(employe_count != MAX_EMPLOYE)
		strcat(info, "Hire\tNew employee\t-\n");

	Dialog_Show(playerid, FurnStoreEmployee, DIALOG_STYLE_TABLIST_HEADERS, "Employee Management", info, "Hire/Fire", "Close");
	return 1;
}

timer productionTimers[1000](playerid)
{
	new 
		keys,ud,lr;

	GetPlayerKeys(playerid,keys,ud,lr);
	if(keys == KEY_NO && startProduce[playerid] && IsPlayerInDynamicArea(playerid, production) && GetPVarInt(playerid, "lagiedit") == 2)
	{
		if(++productionCount[playerid] >= 20)
		{
			new index = ManageFurnObject[playerid], component = productionAdd[playerid]*15;
			FurnStore[index][furnStock] += productionAdd[playerid];

			startProduce[playerid] = false;
			stop productionTimer[playerid];

			if (IsValidDynamicObject(produceObject[playerid]))
				DestroyDynamicObject(produceObject[playerid]);

			produceObject[playerid] = INVALID_STREAMER_ID;

			FurnObject_Refresh(index);
			FurnObject_Save(index);
			Inventory_Remove(playerid, "Component", component);

			SendServerMessage(playerid, "Production successfull.");
			DeletePVar(playerid, "lagiedit");
		}
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0, 1);
		ShowPlayerFooter(playerid, sprintf("~b~~h~Memproduksi furniture: ~w~%d/~r~~h~20",productionCount[playerid]), 1000);
	}
}

CMD:addfurnstore(playerid, params[])
{
	if (CheckAdmin(playerid, 5))
		return PermissionError(playerid);

	static
		price;

	if(sscanf(params, "d", price))
		return SendSyntaxMessage(playerid, "/addfurnstore [price]");

	new id = FurnStore_Create(playerid, price);

	if(id == cellmin)
		return SendErrorMessage(playerid, "Tidak ada slot furniture store lagi.");

	SendServerMessage(playerid, "Furniture store id %d telah di buat, gunakan /editfurnstore untuk mengubah sesuatu.", id);
	return 1;
}

CMD:destroyfurnstore(playerid, params[])
{
	if (CheckAdmin(playerid, 5))
		return PermissionError(playerid);

	new
		id;

	if(sscanf(params, "d", id))
		return SendSyntaxMessage(playerid, "/destroyfurnstore [index]");

	if(!Iter_Contains(FurnStore, id))
		return SendErrorMessage(playerid, "Invalid furnstore id.");

	for (new i = 0; i < MAX_FURN_OBJECT; i ++) if(Iter_Contains(FurnObject, i) && FurnStore[i][furnStoreId] == storeData[id][storeID])
	{
		if (IsValidDynamic3DTextLabel(FurnStore[i][furnLabel]))
			DestroyDynamic3DTextLabel(FurnStore[i][furnLabel]);
		
		if (IsValidDynamicObject(FurnStore[i][furnObject]))
			DestroyDynamicObject(FurnStore[i][furnObject]);

		FurnStore[i][furnObject] = INVALID_STREAMER_ID;
		FurnStore[i][furnLabel] = Text3D:INVALID_STREAMER_ID;

		mysql_tquery(g_iHandle, sprintf("DELETE FROM `furnobject` WHERE id='%d'", FurnStore[i][furnID]));

		FurnStore[i][furnID] = 0;
		FurnStore[i][furnStoreId] = 0;

		Iter_Remove(FurnObject, i);
	}

	mysql_tquery(g_iHandle, sprintf("DELETE FROM `furnstore` WHERE id = '%d'", storeData[id][storeID]));

	storeData[id][storeID] = 0;
	storeData[id][storeOwner] = 0;

	if (IsValidDynamicPickup(storeData[id][storePickup]))
		DestroyDynamicPickup(storeData[id][storePickup]);

	if (IsValidDynamic3DTextLabel(storeData[id][storeLabel]))
		DestroyDynamic3DTextLabel(storeData[id][storeLabel]);

	if (IsValidDynamicCP(storeData[id][storeCP]))
		DestroyDynamicCP(storeData[id][storeCP]);

	Iter_Remove(FurnStore, id);	

	SendServerMessage(playerid, "Kamu telah menghapus furnstore id %d", id);
	return 1;
}

CMD:editfurnstore(playerid, params[])
{
	if (CheckAdmin(playerid, 5))
		return PermissionError(playerid);

	static
		id,
		opsi[32],
		extend_str[128];

	if(sscanf(params, "ds[32]S()[128]", id, opsi, extend_str))
		return SendSyntaxMessage(playerid, "/editfurnstore [index] [location/price/vault/resetemployee/sell]");

	if(!Iter_Contains(FurnStore, id))
		return SendErrorMessage(playerid, "Invalid furnstore id.");

	if(!strcmp(opsi, "location"))
	{
		GetPlayerPos(playerid, storeData[id][storePos][0], storeData[id][storePos][1], storeData[id][storePos][2]);

		FurnStore_Refresh(id);
		FurnStore_Save(id);
	}
	else if(!strcmp(opsi, "price"))
	{
		new price;

		if(sscanf(extend_str, "d", price))
			return SendSyntaxMessage(playerid, "/editfurnstore [id] [price]");

		storeData[id][storePrice] = price;
		SendServerMessage(playerid, "You've update price for furnstore id #%d to %d.", id, price);

		FurnStore_Refresh(id);
		FurnStore_Save(id);
	}
	else if(!strcmp(opsi, "vault"))
	{
		new vault;

		if(sscanf(extend_str, "d", vault))
			return SendSyntaxMessage(playerid, "/editfurnstore [id] [vault]");

		storeData[id][storeVault] = vault;
		SendServerMessage(playerid, "You've update vault for furnstore id #%d to %s.", id, FormatNumber(vault));

		FurnStore_Refresh(id);
		FurnStore_Save(id);
	}
	else if(!strcmp(opsi, "resetemployee"))
	{
		storeData[id][storeEmploye][0] = storeData[id][storeEmploye][1] = storeData[id][storeEmploye][2] = 0;
		SendServerMessage(playerid, "You've reset employee for furnstore id #%d", id);
		FurnStore_Save(id);
	}
	else if(!strcmp(opsi, "sell"))
	{
		if (CheckAdmin(playerid, 7))
			return PermissionError(playerid);

		if(!storeData[id][storeOwner])
			return SendErrorMessage(playerid, "There are no one owned this furnstore.");

		storeData[id][storeVault] = storeData[id][storeOwner] = 0;
		storeData[id][storeEmploye][0] = storeData[id][storeEmploye][1] = storeData[id][storeEmploye][2] = 0;
		format(storeData[id][storeOwnerName], MAX_PLAYER_NAME, "NONE");

		SendServerMessage(playerid, "You've selling furnstore id #%d.", id);

		FurnStore_Refresh(id);
		FurnStore_Save(id);
	}
	else if(!strcmp(opsi, "employee"))
	{
		if (CheckAdmin(playerid, 7))
			return PermissionError(playerid);

		ManageFurnStore[playerid] = id;
		Employee_List(playerid, id);
		SendServerMessage(playerid, "You've edit employee for furnstore id #%d", id);
	}
	else SendSyntaxMessage(playerid, "/editfurnstore [index] [location/price/vault/resetemployee/sell]");
	return 1;
}

CMD:buyfurnstore(playerid, params[])
{
	static
		id = -1;

	if((id = FurnStore_Nearest(playerid)) != -1)
	{
		if (FurnStore_GetCount(playerid))
			return SendErrorMessage(playerid, "You've already have furniture store!");

		if(GetMoney(playerid) < storeData[id][storePrice])
			return SendErrorMessage(playerid, "Uang kamu tidak mencukupi.");

		if (storeData[id][storeOwner])
			return SendErrorMessage(playerid, "This furniture store is already owned by other players.");

		storeData[id][storeOwner] = GetPlayerSQLID(playerid);
		format(storeData[id][storeOwnerName], MAX_PLAYER_NAME, ReturnName2(playerid));

		FurnStore_Refresh(id);
		FurnStore_Save(id);

		GiveMoney(playerid, -storeData[id][storePrice]);
		SendServerMessage(playerid, "Kamu telah membeli furniture store baru!.");
		return 1;
	}
	SendErrorMessage(playerid, "Kamu tidak berada di dekat furnstore.");
	return 1;
}

CMD:fsm(playerid, params[])
{
	static
		id = -1;

	if((id = FurnStore_Inside(playerid)) != -1)
	{
		if(FurnStore_IsOwner(playerid, id) || FurnStore_IsEmployee(playerid, id))
		{
			Dialog_Show(playerid, FurnStoreMenu, DIALOG_STYLE_LIST, "Furniture Store Menu", "Exhibits%s", "Select", "Close", FurnStore_IsOwner(playerid, id) ? ("\nEmployee\nBank\nChange Name") : (""));
			ManageFurnStore[playerid] = id;
			return 1;
		}
		SendErrorMessage(playerid, "Kamu bukan pemilik/pegawai furniture store ini (%d-%d).", FurnStore_IsOwner(playerid, id), FurnStore_IsEmployee(playerid, id));
		return 1;
	}
	SendErrorMessage(playerid, "Kamu tidak berada di dalam furniture store.");
	return 1;
}

CMD:gotofurnstore(playerid, params[])
{
	if (CheckAdmin(playerid, 5))
		return PermissionError(playerid);

	static
		index;

	if(sscanf(params, "d", index))
		return SendSyntaxMessage(playerid, "/gotofurnstore [id]");

	if(!Iter_Contains(FurnStore, index))
		return SendErrorMessage(playerid, "Invalid furnstore id.");

	SetPlayerPos(playerid, storeData[index][storePos][0], storeData[index][storePos][1], storeData[index][storePos][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SendServerMessage(playerid, "You've teleported to furn store id %d.", index);
	return 1;
}

Dialog:SelectType(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new furniture[64 * 128];

		for (new i = 0; i < sizeof(g_aFurnitureData); i ++) if(g_aFurnitureData[i][e_FurnitureType] == listitem + 1) {
			strcat(furniture, sprintf("%i\t%s\n", g_aFurnitureData[i][e_FurnitureModel], g_aFurnitureData[i][e_FurnitureName]));
		}
		ShowPlayerDialog(playerid, DIALOG_ADDFURNOBJECT, DIALOG_STYLE_PREVIEW_MODEL, "Select Furniture", furniture, "Select", "Close");
	}
	else FurnObject_List(playerid, ManageFurnStore[playerid]);
	return 1;
}

/*Dialog:SelectFurnObject(playerid, response, listitem, inputtext[])
{
		if (response)
		{
		SendServerMessage(playerid, "listitem: %d , model: %s", listitem, inputtext);
	}
	return 1;
}
*/
Dialog:ManageFurn(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(!strcmp(inputtext, "Add New"))
		{
			FurnObject_Category(playerid);
			return 1;
		}

		ManageFurnObject[playerid] = ListedFurnObject[playerid][listitem];
		Dialog_Show(playerid, ManageFurnObject, DIALOG_STYLE_LIST, "Manage Object", "Produce\nMove\nSet Name\nSet Price\nTexture\nDelete", "Select", "Close");
	}
	else Dialog_Show(playerid, FurnStoreMenu, DIALOG_STYLE_LIST, "Furniture Store Menu", "Exhibits%s", "Select", "Close", FurnStore_IsOwner(playerid, ManageFurnStore[playerid]) ? ("\nEmployee\nBank\nChange Name") : (""));
	return 1;
}

Dialog:ManageFurnObject(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new id = ManageFurnObject[playerid];
		switch(listitem)
		{
			case 0: {
				if(IsPlayerInDynamicArea(playerid, production))
					return SendErrorMessage(playerid, "Kamu harus berada di luar area kerja terlebih dahulu.");

				if (GetPlayerJob(playerid, 0) != JOB_BUILDER && GetPlayerJob(playerid, 1) != JOB_BUILDER)
					return SendErrorMessage(playerid, "You must to be a Builder to restocking furniture.");

				Dialog_Show(playerid, FurnStoreProduct, DIALOG_STYLE_INPUT, "Produce", "Berapa banyak yang akan di produksi?.", "Start", "Close");
			}
			case 1: {
				editFurnPosition[playerid] = id;
				PlayerEditPoint(playerid, FurnStore[id][furnPos][0], FurnStore[id][furnPos][1], FurnStore[id][furnPos][2], FurnStore[id][furnRot][0], FurnStore[id][furnRot][1], FurnStore[id][furnRot][2], "editFurnObject", FurnStore[id][furnObject]);
			}
			case 2: Dialog_Show(playerid, FurnObjectName, DIALOG_STYLE_INPUT, "Set Name", "Masukkan nama untuk furniture ini", "Set", "Close");
			case 3: Dialog_Show(playerid, FurnObjectPrice, DIALOG_STYLE_INPUT, "Set Price", "Masukkan harga untuk furniture ini", "Set", "Close");
			case 4: Dialog_Show(playerid, FurnObjectTexture, DIALOG_STYLE_INPUT, "Set Texture", "Masukkan data texture dengan mengikuti format berikut:\nFormat: "YELLOW"[index(0-16)] [Model ID] [TXD Name] [Texture Name]", "Update", "Back");
			case 5: {
				if (IsValidDynamic3DTextLabel(FurnStore[id][furnLabel]))
					DestroyDynamic3DTextLabel(FurnStore[id][furnLabel]);
				
				if (IsValidDynamicObject(FurnStore[id][furnObject]))
					DestroyDynamicObject(FurnStore[id][furnObject]);

				FurnStore[id][furnObject] = INVALID_STREAMER_ID;
				FurnStore[id][furnLabel] = Text3D:INVALID_STREAMER_ID;

				mysql_tquery(g_iHandle, sprintf("DELETE FROM `furnobject` WHERE id='%d'", FurnStore[id][furnID]));

				FurnStore[id][furnID] = 0;
				FurnStore[id][furnStoreId] = 0;

				Iter_Remove(FurnObject, id);
			}
		}
	}
	else FurnObject_List(playerid, ManageFurnStore[playerid]);
	return 1;
}

Dialog:FurnStoreProduct(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(strval(inputtext) < 1 || strval(inputtext) > 10)
			return Dialog_Show(playerid, FurnStoreProduct, DIALOG_STYLE_INPUT, "Produce", "Error: Tidak dapat memasukkan kurang dari 1 dan lebih dari 10.\n\nBerapa banyak yang akan di produksi?.", "Start", "Close");

		new component = strval(inputtext)*15;
		if (Inventory_Count(playerid, "Component") < component)
			return SendErrorMessage(playerid, "You need %d component(s) to produce furniture.", component);

		new index = ManageFurnObject[playerid];

		startProduce[playerid] = true;

		productionAdd[playerid] = strval(inputtext);
		productionCount[playerid] = 0;

		productionTimer[playerid] = repeat productionTimers(playerid);

		produceObject[playerid] = CreateDynamicObject(FurnStore[index][furnModel], 1489.54, 1789.14, 10.90, 0.0, 0.0, 0.0, (FurnStore[index][furnStoreId]+1), 3);
		
		for(new i = 0; i != MAX_MATERIALS; i++) if(FurnStore[index][furnMaterials][i] > 0)
		{
			SetDynamicObjectMaterial(produceObject[playerid], i, 
				GetTModel(FurnStore[index][furnMaterials][i]), 
				GetTXDName(FurnStore[index][furnMaterials][i]), 
				GetTextureName(FurnStore[index][furnMaterials][i]), 0
			);

		}
		SetPVarInt(playerid, "lagiedit", 0);
		SendServerMessage(playerid, "Pergilah ke area produksi untuk memulainya.");
	}
	else Dialog_Show(playerid, ManageFurnObject, DIALOG_STYLE_LIST, "Manage Object", "Produce\nMove\nSet Name\nSet Price\nTexture\nDelete", "Select", "Close");
	return 1;
}

Dialog:FurnObjectTexture(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new index, model, txd[32], textures[32];

		if(sscanf(inputtext, "dds[32]s[32]", index, model, txd, textures))
			return Dialog_Show(playerid, FurnObjectTexture, DIALOG_STYLE_INPUT, "Set Price", "Masukkan data texture dengan mengikuti format berikut:\nFormat: "YELLOW"[index(0-16)] [Model ID] [TXD Name] [Texture Name]", "Update", "Back");

		if(index < 0 || index > 16)
			return Dialog_Show(playerid, FurnObjectTexture, DIALOG_STYLE_INPUT, "Set Price", "ERROR: Index yang hanya dapat di gunakan 0 - 16\n\nMasukkan data texture dengan mengikuti format berikut:\nFormat: "YELLOW"[index(0-16)] [Model ID] [TXD Name] [Texture Name]", "Update", "Back");

		if(!IsValidTexture(textures))
			return Dialog_Show(playerid, FurnObjectTexture, DIALOG_STYLE_INPUT, "Set Price", "ERROR: Texture model tidak terdaftar dalam database.\n\nMasukkan data texture dengan mengikuti format berikut:\nFormat: "YELLOW"[index(0-16)] [Model ID] [TXD Name] [Texture Name]", "Update", "Back");

		for (new i = 0; i < MAX_MATERIALS; i ++) {
			//RemoveDynamicObjectMaterial(FurnStore[ManageFurnObject[playerid]][furnObject], i);
		}
		
		FurnStore[ManageFurnObject[playerid]][furnMaterials][index] = GetTextureIndex(textures);
		
		FurnObject_Refresh(ManageFurnObject[playerid]);
		FurnObject_Save(ManageFurnObject[playerid]);

		Dialog_Show(playerid, ManageFurnObject, DIALOG_STYLE_LIST, "Manage Object", "Produce\nMove\nSet Name\nSet Price\nTexture\nDelete", "Select", "Close");
	}
	else Dialog_Show(playerid, ManageFurnObject, DIALOG_STYLE_LIST, "Manage Object", "Produce\nMove\nSet Name\nSet Price\nTexture\nDelete", "Select", "Close");
	return 1;
}

Dialog:FurnObjectName(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(isnull(inputtext))
			return Dialog_Show(playerid, FurnObjectName, DIALOG_STYLE_INPUT, "Set Name", "ERROR: Nama tidak boleh kosong\nMasukkan nama untuk furniture ini", "Set", "Close");

		if(strval(inputtext) > 32)
			return Dialog_Show(playerid, FurnObjectName, DIALOG_STYLE_INPUT, "Set Name", "ERROR: Nama terlalu panjang, maksimal 32 karakter\nMasukkan nama untuk furniture ini", "Set", "Close");

		format(FurnStore[ManageFurnObject[playerid]][furnName], 32, inputtext);
		FurnObject_Refresh(ManageFurnObject[playerid]);
		FurnObject_Save(ManageFurnObject[playerid]);
		SendServerMessage(playerid, "Nama telah di ganti menjadi: "GREEN"%s", FurnStore[ManageFurnObject[playerid]][furnName]);
	}
	return 1;
}

Dialog:FurnObjectPrice(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(isnull(inputtext))
			return Dialog_Show(playerid, FurnObjectPrice, DIALOG_STYLE_INPUT, "Set Name", "ERROR: Harga tidak boleh kosong\nMasukkan harga untuk furniture ini", "Set", "Close");

		if(strval(inputtext) < 1)
			return Dialog_Show(playerid, FurnObjectPrice, DIALOG_STYLE_INPUT, "Set Name", "ERROR: Harga tidak sesuai, tidak dapat di bawah harga 1\nMasukkan harga untuk furniture ini", "Set", "Close");

		FurnStore[ManageFurnObject[playerid]][furnPrice] = strval(inputtext);
		FurnObject_Refresh(ManageFurnObject[playerid]);
		FurnObject_Save(ManageFurnObject[playerid]);
		SendServerMessage(playerid, "Harga telah di ganti menjadi: "YELLOW"%s", FormatNumber((FurnStore[ManageFurnObject[playerid]][furnPrice])));
	}
	return 1;
}

Dialog:FurnStoreMenu(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new index = ManageFurnStore[playerid];

		switch(listitem)
		{
			case 0: FurnObject_List(playerid, index);
			case 1: Employee_List(playerid, index);
			case 2: Dialog_Show(playerid, FurnStoreBank, DIALOG_STYLE_LIST, "Furniture Store Bank", "Deposit\nWithdraw\nCurrent balance: %s", "Select", "Close", FormatNumber(storeData[index][storeVault]));
			case 3: Dialog_Show(playerid, FurnStoreName, DIALOG_STYLE_INPUT, "Furniture Store Change Name", "Masukkan nama baru untuk furniture store ini:", "Change", "Close");
		}
	}
	return 1;
}

Dialog:FurnStoreEmployee(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(!strcmp(inputtext, "Hire"))
			return Dialog_Show(playerid, HireEmployee, DIALOG_STYLE_INPUT, "Hire Employee", "Masukkan nama ataupun id player yang akan di pekerjakan:", "Hire", "Close");

		Dialog_Show(playerid, FiredEmployee, DIALOG_STYLE_MSGBOX, "Fired Employee", "Kamu yakin ingin memecat pegawai ini?", "Fired", "No");
		SetPVarInt(playerid, "SelectToFired", SelectToFired[playerid][listitem]);
	}
	return 1;
}

Dialog:HireEmployee(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new userid,
			index = ManageFurnStore[playerid];

		if(sscanf(inputtext, "u", userid)) 
			return Dialog_Show(playerid, HireEmployee, DIALOG_STYLE_INPUT, "Hire Employee", "ERROR: ID atau playerid tidak di masukkan\nMasukkan nama ataupun id player yang akan di pekerjakan:", "Hire", "Close");

		if(!IsPlayerNearPlayer(playerid, userid, 5.0))
			return Dialog_Show(playerid, HireEmployee, DIALOG_STYLE_INPUT, "Hire Employee", "ERROR: Player tersebut tidak berada dekat denganmu\nMasukkan nama ataupun id player yang akan di pekerjakan:", "Hire", "Close");

		if(IsPlayerConnected(userid) && SQL_IsLogged(userid))
		{
			for(new i = 0; i != MAX_EMPLOYE; i++) if(!storeData[index][storeEmploye][i])
			{
				storeData[index][storeEmploye][i] = GetPlayerSQLID(userid);
				FurnStore_Save(index);
				SendServerMessage(playerid, "Kamu telah mempekerjakan "YELLOW"%s "WHITE"ke dalam furniture store milikmu.", ReturnName(userid, 0));
				SendServerMessage(playerid, "Kamu telah dipekerjakan oleh "YELLOW"%s "WHITE"di furniture store miliknya.", ReturnName(playerid, 0));
				printf("Slot: %d", i);
				return 1;
			}
		}
		Dialog_Show(playerid, HireEmployee, DIALOG_STYLE_INPUT, "Hire Employee", "ERROR: ID atau playerid tidak berada dalam server\nMasukkan nama ataupun id player yang akan di pekerjakan:", "Hire", "Close");
		return 1;
	}
	return 1;
}

Dialog:FiredEmployee(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new index = ManageFurnStore[playerid],
			list = GetPVarInt(playerid, "SelectToFired");

		if(response)
		{
			storeData[index][storeEmploye][list] = 0;
			FurnStore_Save(index);

			SendServerMessage(playerid, "Kamu telah memecat pegawai dari furniture store milikmu.");

			DeletePVar(playerid, "SelectToFired");
			ManageFurnStore[playerid] = -1;
		}
		else Employee_List(playerid, index);
	}
	return 1;
}

Dialog:FurnStoreBank(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0: Dialog_Show(playerid, BankSelect, DIALOG_STYLE_INPUT, "Deposit", "Masukkan berapa uang yang akan kamu simpan:", "Deposit", "Close"), SetPVarInt(playerid, "bankSelect", 1);
			case 1: Dialog_Show(playerid, BankSelect, DIALOG_STYLE_INPUT, "Withdraw", "Masukkan berapa uang yang akan kamu ambil:", "Withdraw", "Close"), SetPVarInt(playerid, "bankSelect", 2);
			case 2: Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "Balance", "Current balance on this furniture store: %s", "Close", "", FormatNumber(storeData[ManageFurnStore[playerid]][storeVault]));
		}
	}
	return 1;
}

Dialog:BankSelect(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new index = ManageFurnStore[playerid],
			type = GetPVarInt(playerid, "bankSelect");

		if(strval(inputtext) < 1)
			return Dialog_Show(playerid, BankSelect, DIALOG_STYLE_INPUT, (type == 1) ? ("Deposit") : ("Withdraw"), "ERROR: Tidak dapat memasukkan input kurang dari 0\nMasukkan berapa uang yang akan kamu %s:", (type == 1) ? ("Deposit") : ("Withdraw"), "Close", (type == 1) ? ("simpan") : ("ambil"));

		if(type == 1) {
			if(GetMoney(playerid) < strval(inputtext))
				return Dialog_Show(playerid, BankSelect, DIALOG_STYLE_INPUT, "Deposit", "ERROR: Uang kamu tidak mencukupi\nMasukkan berapa uang yang akan kamu simpan:", "Deposit", "Close");
		}
		else {
			if(strval(inputtext) > storeData[index][storeVault])
				return Dialog_Show(playerid, BankSelect, DIALOG_STYLE_INPUT, "Withdraw", "ERROR: Uang dalam furniture store tidak mencukupi\nMasukkan berapa uang yang akan kamu ambil:", "Withdraw", "Close");
		}

		switch(type)
		{
			case 1: GiveMoney(playerid, -strval(inputtext)), storeData[index][storeVault] += strval(inputtext);
			case 2: GiveMoney(playerid, strval(inputtext)), storeData[index][storeVault] -= strval(inputtext);
		}
		SendServerMessage(playerid, "Kamu telah %s uang sebesar %s %s furniture store.", (type == 1) ? ("menyimpan") : ("mengambil"), FormatNumber(strval(inputtext)), (type == 1) ? ("untuk") : ("dari"));
		FurnStore_Save(index);

		DeletePVar(playerid, "bankSelect");
	}
	return 1;
}

Dialog:FurnStoreName(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(isnull(inputtext))
			return Dialog_Show(playerid, FurnStoreName, DIALOG_STYLE_INPUT, "Furniture Store Change Name", "ERROR: Masukkan nama yang benar, tidak boleh di kosongkan\nMasukkan nama baru untuk furniture store ini:", "Change", "Close");

		if(strlen(inputtext) > 32)
			return Dialog_Show(playerid, FurnStoreName, DIALOG_STYLE_INPUT, "Furniture Store Change Name", "ERROR: Nama yang kamu masukkan terlalu panjang ...\n ... maksimal memasukkan 32 karakter\nMasukkan nama baru untuk furniture store ini:", "Change", "Close");

		format(storeData[ManageFurnStore[playerid]][storeName], 32, ColouredText(inputtext));

		SendServerMessage(playerid, "Nama furniture store di ganti menjadi: %s", storeData[ManageFurnStore[playerid]][storeName]);

		FurnStore_Save(ManageFurnStore[playerid]);
		FurnStore_Refresh(ManageFurnStore[playerid]);
	}
	return 1;
}

Function:editFurnObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:offx, Float:offy, Float:offz)
{
	if(response == EDIT_RESPONSE_CANCEL)
	{
		if(editFurnPosition[playerid] != -1) 
		{
			new i = editFurnPosition[playerid];
			FurnObject_Refresh(i);
			
			editFurnPosition[playerid] = -1;
		}
	}
	if(response == EDIT_RESPONSE_FINAL)
	{
		new id = editFurnPosition[playerid];

		if(Iter_Contains(FurnObject, id))
		{
			FurnStore[id][furnPos][0] = x;
			FurnStore[id][furnPos][1] = y;
			FurnStore[id][furnPos][2] = z;
			FurnStore[id][furnRot][0] = rx;
			FurnStore[id][furnRot][1] = ry;
			FurnStore[id][furnRot][2] = rz;

			FurnObject_Refresh(id);
			FurnObject_Save(id);

			editFurnPosition[playerid] = -1;
		}
	}
	return 1;
}

Function:editLokasiFurn(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:offx, Float:offy, Float:offz)
{
	if(response == EDIT_RESPONSE_CANCEL)
	{
		if(startProduce[playerid])
		{
			PlayerEditPoint(playerid, 1489.54, 1789.14, 10.90, 0.0, 0.0, 0.0, "editLokasiFurn", produceObject[playerid]);
			ShowPlayerFooter(playerid, "~r~~h~Tidak dapat menekan 'ESC' dalam mode ini");
		}
	}
	if(response == EDIT_RESPONSE_FINAL)
	{
		if(startProduce[playerid])
		{
			if(!IsPointInDynamicArea(production, x, y, z))
				return PlayerEditPoint(playerid, 1489.54, 1789.14, 10.90, 0.0, 0.0, 0.0, "editLokasiFurn", produceObject[playerid]), ShowPlayerFooter(playerid, "~r~~h~Tidak dapat di lakukan di luar area produksi.");

			SendServerMessage(playerid, "Mulailah memproduksi furniture dengan menahan tombol "RED"'N'");
			SetPVarInt(playerid, "lagiedit", 2);
		}
	}
	return 1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_SECONDARY_ATTACK))
	{
		static
			id = -1;

		if((id = FurnStore_Nearest(playerid)) != -1 && IsPlayerInDynamicCP(playerid, storeData[id][storeCP]))
		{
			if (storeData[id][storeSeal])
            	return SendErrorMessage(playerid, "This furniture store is sealed by authority.");
			
			if (storeData[id][storeLocked])
				return SendErrorMessage(playerid, "This furniture store is locked.");

			SetPlayerPosEx(playerid, storeData[id][storeIntPos][0], storeData[id][storeIntPos][1], storeData[id][storeIntPos][2], 1000);
			SetPlayerFacingAngle(playerid, 269.60);
			SetPlayerInterior(playerid, 3);
			SetPlayerVirtualWorld(playerid, storeData[id][storeID] + 1);

			Streamer_Update(playerid);

			PlayerData[playerid][pFurnStore] = storeData[id][storeID];
			SetPlayerWeather(playerid, 0);
			SetPlayerTime(playerid, 12, 0);
			return 1;
		}
		if((id = FurnStore_Inside(playerid)) != -1 && IsPlayerInRangeOfPoint(playerid, 2.5, storeData[id][storeIntPos][0], storeData[id][storeIntPos][1], storeData[id][storeIntPos][2]))
		{
			SetPlayerPos(playerid, storeData[id][storePos][0], storeData[id][storePos][1], storeData[id][storePos][2]);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			SetCameraBehindPlayer(playerid);

			PlayerData[playerid][pFurnStore] = -1;
			return 1;
		}
	}
	return 1;
}

/*
	Furniture object maker.

	Made by: Agus Syahputra
	Edited by: Lukman
	Idea by: Jogjagamers
*/
Function:FurnObject_Load(index)
{
	new query[32], id = cellmin;

	for(new i = 0; i != cache_num_rows(); i++) if ((id = Iter_Free(FurnObject)) != cellmin)
	{
		Iter_Add(FurnObject, id);

		cache_get_value(i, "name", FurnStore[id][furnName], 32);

		cache_get_value(i, "materials", query, 32);
		sscanf(query, "p<|>dddddddddddddddd", 
			FurnStore[id][furnMaterials][0],
			FurnStore[id][furnMaterials][1],
			FurnStore[id][furnMaterials][2],
			FurnStore[id][furnMaterials][3],
			FurnStore[id][furnMaterials][4],
			FurnStore[id][furnMaterials][5],
			FurnStore[id][furnMaterials][6],
			FurnStore[id][furnMaterials][7],
			FurnStore[id][furnMaterials][8],
			FurnStore[id][furnMaterials][9],
			FurnStore[id][furnMaterials][10],
			FurnStore[id][furnMaterials][11],
			FurnStore[id][furnMaterials][12],
			FurnStore[id][furnMaterials][13],
			FurnStore[id][furnMaterials][14],
			FurnStore[id][furnMaterials][15]
		);

		cache_get_value_int(i, "id", FurnStore[id][furnID]);
		cache_get_value_int(i, "model", FurnStore[id][furnModel]);

		cache_get_value_float(i, "x", FurnStore[id][furnPos][0]);
		cache_get_value_float(i, "y", FurnStore[id][furnPos][1]);
		cache_get_value_float(i, "z", FurnStore[id][furnPos][2]);
		cache_get_value_float(i, "rx", FurnStore[id][furnRot][0]);
		cache_get_value_float(i, "ry", FurnStore[id][furnRot][1]);
		cache_get_value_float(i, "rz", FurnStore[id][furnRot][2]);
		
		cache_get_value_int(i, "price", FurnStore[id][furnPrice]);
		cache_get_value_int(i, "stock", FurnStore[id][furnStock]);
		cache_get_value_int(i, "storeid", FurnStore[id][furnStoreId]);

		FurnObject_Refresh(id);
	}
	printf("*** [R:RP Database: Loaded] furnobject data (%d count).", cache_num_rows());
	return 1;
}

FurnObject_Save(index)
{
	if(Iter_Contains(FurnObject, index))
	{
		new query[500];

		format(query, sizeof(query), "UPDATE `furnobject` SET model=%d,name='%s',x=%.3f,y=%.3f,z=%.3f,rx=%.3f,ry=%.3f,rz=%.3f", 
			FurnStore[index][furnModel],
			SQL_ReturnEscaped(FurnStore[index][furnName]),
			FurnStore[index][furnPos][0],
			FurnStore[index][furnPos][1],
			FurnStore[index][furnPos][2],
			FurnStore[index][furnRot][0],
			FurnStore[index][furnRot][1],
			FurnStore[index][furnRot][2]
		);
		format(query, sizeof(query), "%s, price=%d,stock=%d,storeid=%d,materials='%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d' WHERE id=%d", 
			query,
			FurnStore[index][furnPrice],
			FurnStore[index][furnStock],
			FurnStore[index][furnStoreId],
			FurnStore[index][furnMaterials][0],
			FurnStore[index][furnMaterials][1],
			FurnStore[index][furnMaterials][2],
			FurnStore[index][furnMaterials][3],
			FurnStore[index][furnMaterials][4],
			FurnStore[index][furnMaterials][5],
			FurnStore[index][furnMaterials][6],
			FurnStore[index][furnMaterials][7],
			FurnStore[index][furnMaterials][8],
			FurnStore[index][furnMaterials][9],
			FurnStore[index][furnMaterials][10],
			FurnStore[index][furnMaterials][11],
			FurnStore[index][furnMaterials][12],
			FurnStore[index][furnMaterials][13],
			FurnStore[index][furnMaterials][14],
			FurnStore[index][furnMaterials][15],
			FurnStore[index][furnID]
		);
		mysql_tquery(g_iHandle, query);
	}
	return 1;
}

FurnObject_Sync(index)
{
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnStore[index][furnObject], E_STREAMER_X, FurnStore[index][furnPos][0]);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnStore[index][furnObject], E_STREAMER_Y, FurnStore[index][furnPos][1]);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnStore[index][furnObject], E_STREAMER_Z, FurnStore[index][furnPos][2]);

	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnStore[index][furnObject], E_STREAMER_R_X, FurnStore[index][furnRot][0]);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnStore[index][furnObject], E_STREAMER_R_Y, FurnStore[index][furnRot][1]);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, FurnStore[index][furnObject], E_STREAMER_R_Z, FurnStore[index][furnRot][2]);

	Streamer_SetIntData(STREAMER_TYPE_OBJECT, FurnStore[index][furnObject], E_STREAMER_MODEL_ID, FurnStore[index][furnModel]);

	for(new i = 0; i != MAX_MATERIALS; i++) if(FurnStore[index][furnMaterials][i] > 0) {
		SetDynamicObjectMaterial(FurnStore[index][furnObject], i, GetTModel(FurnStore[index][furnMaterials][i]), GetTXDName(FurnStore[index][furnMaterials][i]), GetTextureName(FurnStore[index][furnMaterials][i]), 0);
	}
	return 1;
}

FurnObject_Refresh(index)
{
	if(Iter_Contains(FurnObject, index)) 
	{
		if(!IsValidDynamicObject(FurnStore[index][furnObject]))
		{
			FurnStore[index][furnObject] = CreateDynamicObject(FurnStore[index][furnModel], 
				FurnStore[index][furnPos][0], FurnStore[index][furnPos][1], FurnStore[index][furnPos][2], 
				FurnStore[index][furnRot][0], FurnStore[index][furnRot][1], FurnStore[index][furnRot][2], 
				(FurnStore[index][furnStoreId]+1), 3
			);
		}
		FurnObject_Sync(index);	    
			
		if(IsValidDynamic3DTextLabel(FurnStore[index][furnLabel]))
			DestroyDynamic3DTextLabel(FurnStore[index][furnLabel]);

		FurnStore[index][furnLabel] = CreateDynamic3DTextLabel(sprintf("[id:%d]\n"YELLOW"%s\n"WHITE"Price: "GREEN"%s\n"WHITE"Stock: "GREEN"%d", index, FurnStore[index][furnName], FormatNumber(FurnStore[index][furnPrice]), FurnStore[index][furnStock]), X11_LIGHTBLUE, FurnStore[index][furnPos][0], FurnStore[index][furnPos][1], FurnStore[index][furnPos][2], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, (FurnStore[index][furnStoreId]+1), 3);

		foreach(new i : Player) if(SQL_IsLogged(i) && IsPlayerInRangeOfPoint(i, 5, FurnStore[index][furnPos][0], FurnStore[index][furnPos][1], FurnStore[index][furnPos][2])) {
			Streamer_Update(i);
		}
	}
	return 1;
}

FurnObject_List(playerid, index)
{
	if(Iter_Contains(FurnStore, index))
	{
		new count = 0,
			info[MAX_FURNSTORE_OBJECT * 128];

		strcat(info, "Furniture\tSlot (ID)\tDistance (meters)\n");
		foreach(new i : FurnObject) if(FurnStore[i][furnStoreId] == storeData[index][storeID])
		{
			strcat(info, sprintf("%s\t%d\t%.1f\n", FurnStore[i][furnName], i, GetPlayerDistanceFromPoint(playerid, FurnStore[i][furnPos][0], FurnStore[i][furnPos][1], FurnStore[i][furnPos][2])));
			ListedFurnObject[playerid][count++] = i;
		}
		if(count != MAX_FURNSTORE_OBJECT)
			strcat(info, "Add New\t\n");

		Dialog_Show(playerid, ManageFurn, DIALOG_STYLE_TABLIST_HEADERS, "Exhibits", info, "Select", "Back");
	}
	return 1;
}

FurnObject_Category(playerid)
{
	new string[120];
	for (new i = 0; i < sizeof(g_aFurnitureTypes); i ++) {
		strcat(string, sprintf("%s\n", g_aFurnitureTypes[i]));
	}
	Dialog_Show(playerid, SelectType, DIALOG_STYLE_LIST, "Object Category", string, "Modify", "Cancel");
	return 1;
}

FurnObject_Count(index)
{
	new count = 0;

	foreach(new i : FurnObject) if(FurnStore[i][furnStoreId] == storeData[index][storeID]) {
		count++;
	}
	return count;
}

FurnObject_Add(playerid, objectid, index)
{
	if(FurnObject_Count(index) >= MAX_FURNSTORE_OBJECT) return -1;

	if (Inventory_Count(playerid, "Component") < 30)
		return SendErrorMessage(playerid, "You need 30 components to create new furniture.");

	new id = Iter_Free(FurnObject),
		Float:x, Float:y, Float:z;

	if (id == cellmin)
		return SendErrorMessage(playerid, "Server has reached the maximum of furniture object!");

	GetPlayerPos(playerid, x, y, z);
	GetXYInFrontOfPlayer(playerid, x, y, 1.5);

	format(FurnStore[id][furnName], 32, "Unnamed");

	FurnStore[id][furnPos][0] = x;
	FurnStore[id][furnPos][1] = y;
	FurnStore[id][furnPos][2] = z;
	FurnStore[id][furnRot][0] = 0;
	FurnStore[id][furnRot][1] = 0;
	FurnStore[id][furnRot][2] = 0;

	FurnStore[id][furnModel] = objectid;
	FurnStore[id][furnStoreId] = storeData[index][storeID];
	FurnStore[id][furnPrice] = 0;
	FurnStore[id][furnStock] = 0;
	Inventory_Remove(playerid, "Component", 30);

	Iter_Add(FurnObject, id);

	mysql_tquery(g_iHandle, "INSERT INTO `furnobject`(`price`) VALUES (0)", "FurnObject_Created", "d", id);
	
	FurnObject_Refresh(id);
	Streamer_Update(playerid);
	return id;
}

Function:FurnObject_Created(index)
{
	FurnStore[index][furnID] = cache_insert_id();
	
	FurnObject_Save(index);
	return 1;
}

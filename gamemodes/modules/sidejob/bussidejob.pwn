//defined
#define MAX_BUS_VEHICLE		4
#define BUS_SALARY			12500


#define IsPlayerWorkInBus(%0)		hasBusses[%0]

#define SetPlayerWorkInBus(%0)		hasBusses[%0] = true
#define StopPlayerWorkInBus(%0)		hasBusses[%0] = false

// global variable
static
	busVehicle[MAX_BUS_VEHICLE] = {INVALID_VEHICLE_ID, ...};
	
new bool:DialogSidejob[MAX_BUS_VEHICLE];
//new TrailerMission[MAX_PLAYERS];
new PlayerSidejob[MAX_PLAYERS];

// player variable
static
	bool:hasBusses[MAX_PLAYERS] = {false, ...},
	busRoute[MAX_PLAYERS] = {0, ...},
	busCounter[MAX_PLAYERS] = {0, ...},
	busOut[MAX_PLAYERS] = {0, ...},
	currentBRoute[MAX_PLAYERS] = {0, ...},
	outCheck[MAX_PLAYERS],
	Timer:busTimer[MAX_PLAYERS],
	Timer:outTimer[MAX_PLAYERS],
	Timer:outTime[MAX_PLAYERS];

// vehicle arrays
/*stock const Float:arr_coachPosition[][] =
{
	{1011.1265, -1339.5845, 13.7566, 90.0},
	{1008.510, -1345.753, 13.541, 90.0},
	{1008.320, -1351.586, 13.526, 90.0},
	{1010.0966, -1357.8387, 13.7576, 90.0}
};*/

/*stock const Float:busSpawn[][] = {
    {1011.1265, -1339.5845, 13.7566, 90.0},
	{1008.510, -1345.753, 13.541, 90.0},
	{1008.320, -1351.586, 13.526, 90.0},
	{1010.0966, -1357.8387, 13.7576, 90.0}
};*/

enum array_busRoute
{
	Float:b_x,
	Float:b_y,
	Float:b_z,
	b_time
};

stock const arr_busRoute1[][array_busRoute] = {
	{1001.7438,-1339.4542,13.5062, 1},
	{1037.1460,-1328.0721,13.5265, 1},
	{1055.9114,-1377.9695,13.5870, 1},
	{1087.3961,-1408.4526,13.6341, 1},
	{1167.6788,-1408.0112,13.5021, 21},
	{1318.7351,-1407.8945,13.4265, 1},
	{1383.1248,-1407.6826,13.5197, 1},
	{1394.0814,-1437.3165,13.5212, 1},
	{1452.0226,-1450.0040,13.5103, 1},
	{1427.8564,-1573.2834,13.4900, 1},
	{1427.4318,-1642.8768,13.5036, 1},
	{1426.2866,-1693.4377,13.5162, 1},
	{1427.2761,-1730.1301,13.5161, 1},
	{1474.4266,-1735.0731,13.5153, 1},
	{1593.2484,-1735.1190,13.5175, 1},
	{1780.5382,-1735.8007,13.5198, 21},
	{1819.6693,-1736.2040,13.5192, 1},
	{1823.7198,-1683.6631,13.5160, 1},
	{1824.1674,-1595.2692,13.4893, 1},
	{1852.6650,-1483.1239,13.5115, 1},
	{1852.9927,-1281.6700,13.5197, 1},
	{1855.4384,-1222.6501,18.3795, 21},
	{1827.4266,-1179.1720,23.7644, 1},
	{1771.4250,-1165.6157,23.7887, 1},
	{1682.3989,-1158.9069,23.7890, 1},
	{1599.7186,-1158.8014,24.0375, 1},
	{1559.1372,-1065.3888,23.7056, 1},
	{1433.2532,-1029.8988,23.8719, 21},
	{1319.7312,-1035.2764,29.3457, 1},
	{1197.2450,-1036.6276,31.8863, 1},
	{1159.4254,-1115.6154,24.3506, 1},
	{1003.1508,-1138.1097,23.8116, 21},
	{940.4587,-1164.1160,22.8322, 1},
	{940.2219,-1295.5271,14.2368, 1},
	{978.2174,-1327.6427,13.5064, 1},
	{1001.7438,-1339.4542,13.5062, 1}
};

stock const arr_busRoute2[][array_busRoute] = {
	{1001.7438,-1339.4542,13.5062, 1},
	{991.5820,-1318.8115,13.5225, 1},
	{841.9654,-1316.9319,13.5174, 21},
	{761.8242,-1317.2452,13.5227, 1},
	{649.5710,-1317.0037,13.5080, 1},
	{635.5519,-1233.9930,17.8356, 1},
	{572.8350,-1222.5004,17.6322, 21},
	{492.6930,-1277.6561,15.7323, 1},
	{408.2432,-1338.0629,14.8424, 1},
	{274.9594,-1409.4645,13.7954, 1},
	{176.4312,-1508.0796,12.4831, 1},
	{190.7393,-1631.1984,14.5104, 1},
	{278.7926,-1706.9077,7.6522, 21},
	{390.5268,-1718.5886,8.0651, 1},
	{529.6396,-1733.1476,12.2608, 1},
	{781.4308,-1786.5509,13.1903, 21},
	{952.0578,-1796.3433,14.1844, 1},
	{1018.6432,-1814.9999,14.0930, 1},
	{1043.5164,-1871.9229,13.3832, 1},
	{1044.1467,-1973.7954,13.0847, 1},
	{1025.9418,-2254.6782,13.0821, 1},
	{1219.0736,-2454.1509,9.4943, 21},
	{1309.5413,-2467.2351,7.7935, 1},
	{1346.6144,-2515.7356,13.5087, 1},
	{1348.2764,-2317.1765,13.5186, 1},
	{1403.2711,-2288.9563,13.5160, 1},
	{1475.9844,-2335.1997,13.5159, 1},
	{1522.8612,-2301.7156,13.5203, 21},
	{1477.4829,-2222.6958,13.5140, 1},
	{1543.4133,-2197.9629,13.5084, 1},
	{1711.4138,-2196.6460,13.5084, 21},
	{1702.6241,-2163.4839,15.6925, 1},
	{1558.2759,-2095.6882,33.9805, 1},
	{1532.3760,-1881.1332,13.5764, 1},
	{1415.3015,-1870.0767,13.5162, 1},
	{1314.6676,-1833.9587,13.5175, 1},
	{1352.6488,-1469.6483,13.5159, 1},
	{1295.7249,-1391.8641,13.4090, 21},
	{1075.3953,-1393.8588,13.7103, 1},
	{1061.0625,-1328.3419,13.5169, 1},
	{1014.0223,-1319.0310,13.5161, 1},
	{1001.7438,-1339.4542,13.5062, 1} ///cobject 1257
};

stock const arr_busRoute3[][array_busRoute] = {
	{1001.7438,-1339.4542,13.5062, 1},
	{1010.0273,-1319.6139,13.5206, 1},
	{1057.0900,-1319.2128,13.5157, 1},
	{1060.8992,-1252.3329,15.0000, 1},
	{1060.8175,-1185.5254,21.5699, 1},
	{1088.1741,-1150.9889,23.7901, 1},
	{1169.1617,-1149.3811,23.7898, 1},
	{1255.0975,-1149.5692,23.7811, 1},
	{1361.5353,-1120.3995,23.8351, 21},
	{1377.5463,-972.4774,33.0443, 1},
	{1464.9624,-957.1317,36.2664, 1},
	{1594.5404,-972.1356,38.3682, 1},
	{1765.6326,-998.6263,37.1122, 1},
	{1977.8820,-1028.0259,34.4860, 1},
	{2136.0127,-1093.8973,24.5330, 21},
	{2237.9097,-1141.5280,25.8091, 1},
	{2344.1069,-1156.4414,27.1813, 1},
	{2425.0784,-1183.9458,34.7575, 1},
	{2448.5330,-1241.8375,24.6684, 1},
	{2397.7195,-1253.3616,23.9554, 21},
	{2368.5896,-1278.4850,23.9704, 1},
	{2368.6953,-1364.5143,23.9780, 1},
	{2339.4946,-1400.2916,23.9458, 1},
	{2339.7275,-1520.7869,23.9671, 1},
	{2339.9897,-1644.0795,14.5849, 1},
	{2311.6877,-1729.7231,13.5163, 1},
	{2258.9197,-1728.8118,13.5203, 21},
	{2169.2964,-1749.8367,13.5172, 1}, 
	{2147.3105,-1748.6372,13.5284, 21},
	{2105.5508,-1749.6904,13.5302, 1}, 
	{2113.3477,-1691.0081,13.5176, 1}, 
	{2115.0154,-1590.0444,25.9281, 1}, 
	{2114.9180,-1450.3945,23.9649, 1}, 
	{2115.6431,-1387.2654,23.9615, 1}, 
	{2088.0938,-1381.6660,23.9623, 1}, 
	{2073.5945,-1319.5302,23.9536, 1}, 
	{2073.5874,-1276.0782,23.9603, 1}, 
	{2027.3640,-1257.2751,23.9528, 21},
	{1905.4900,-1258.5430,13.7019, 1}, 
	{1794.0525,-1269.3597,13.6043, 1}, 
	{1678.9495,-1294.8450,13.9952, 21},
	{1576.6237,-1296.8680,17.4084, 1}, 
	{1480.6361,-1298.2660,13.6852, 1}, 
	{1457.9266,-1252.8566,13.5213, 1}, 
	{1377.8198,-1238.1909,13.5161, 1}, 
	{1340.8928,-1259.7488,13.5162, 1}, 
	{1290.0283,-1278.2953,13.5003, 1}, 
	{1172.6907,-1277.7358,13.5568, 21},
	{1086.3927,-1278.4871,13.5765, 1}, 
	{1056.1998,-1304.4771,13.6137, 1}, 
	{1017.3232,-1318.7650,13.5164, 1}, 
	{1001.7438,-1339.4542,13.5062, 1}
};

/*
	SAMP CALLBACK BUS SIDEJOB
*/

#include <YSI\y_hooks>
hook OnGameModeInitEx()
{
	/*for(new index = 0; index < sizeof(arr_coachPosition); index++)
	{
		busVehicle[index] = CreateVehicle(431, arr_coachPosition[index][0], arr_coachPosition[index][1], arr_coachPosition[index][2], 
			arr_coachPosition[index][3], 1, 2, 1000
		);
	}*/
	
	CreateDynamicMapIcon(1004.3510,-1337.5665,13.5072, 56, -1, -1, 0); //Map Icon

	//Mapping Base
	new tmpobjid;
	/* tmpobjid = CreateDynamicObject(19464, 999.903259, -1372.618652, 14.808098, 0.000000, 0.000000, 77.200149, 0, 0, -1, 200.00, 200.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 8130, "vgsschurch", "vgschurchwall04_256", 0xFD743D1F);
	tmpobjid = CreateDynamicObject(19464, 994.140625, -1371.964843, 14.808098, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 8130, "vgsschurch", "vgschurchwall04_256", 0xFD743D1F);
	tmpobjid = CreateDynamicObject(19980, 1006.609130, -1332.428222, 10.382783, 0.000000, 0.000000, 180.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 18800, "mroadhelix1", "road1-3", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19480, "signsurf", "sign", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19480, "signsurf", "sign", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 3, 19962, "samproadsigns", "greenbackgroundsign", 0x00000000);
	tmpobjid = CreateDynamicObject(19329, 1006.607360, -1332.404418, 13.232826, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterialText(tmpobjid, 0, "LOS SANTOS", 120, "Ariel", 50, 1, 0xFFFFFFFF, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19329, 1006.607360, -1332.404418, 12.842818, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterialText(tmpobjid, 0, "BUS STATION", 120, "Ariel", 32, 1, 0xFFFFFFFF, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(950, 1018.015136, -1337.340087, 13.046831, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF00);
	tmpobjid = CreateDynamicObject(950, 1015.628784, -1333.643310, 13.046831, 0.000000, 0.000000, -140.600097, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF00);
	tmpobjid = CreateDynamicObject(950, 1015.576843, -1340.960327, 13.046831, 0.000000, 0.000000, 141.700073, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF00);
	tmpobjid = CreateDynamicObject(8843, 1001.470031, -1342.208129, 12.395067, 0.099999, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFFFFFF00);
	tmpobjid = CreateDynamicObject(8843, 1001.470031, -1368.268066, 12.349578, 0.099999, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFFFFFF00);
	
	CreateDynamicObject(982, 1018.626708, -1355.118896, 13.188969, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(983, 1018.626708, -1371.171508, 13.188969, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(982, 991.205932, -1352.068725, 12.958964, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(983, 991.205932, -1368.648803, 12.958964, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(984, 1012.196655, -1332.438598, 12.982821, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(983, 994.405456, -1332.438598, 12.982821, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(983, 991.205932, -1335.617187, 12.958964, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(1297, 991.943786, -1365.151733, 14.308639, 0.000000, 0.000000, 180.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(1297, 1017.883605, -1365.151733, 14.308639, 0.000000, 0.000000, 360.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(1297, 991.943786, -1339.000854, 14.308639, 0.000000, 0.000000, 180.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(1297, 1017.874511, -1342.332885, 14.308639, 0.000000, 0.000000, 360.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(1251, 1001.042419, -1332.382934, 12.382812, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(1251, 1002.373535, -1332.392944, 12.382812, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(983, 1018.626708, -1339.079101, 13.188969, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(983, 1018.626708, -1335.869018, 13.188969, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(1297, 1018.056396, -1333.112915, 14.308639, 0.000000, 0.000000, 42.699989, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(3657, 1017.791687, -1334.618652, 13.089875, 0.000000, 0.000000, 270.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(3657, 1017.791687, -1340.011108, 13.089875, 0.000000, 0.000000, 270.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(642, 1018.311340, -1334.571044, 13.813838, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(642, 1018.311340, -1340.030883, 13.813838, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); */

	//Mappping Halte
	tmpobjid = CreateDynamicObject(1257, 1167.618041, -1412.513183, 13.758987, 0.000000, 0.000000, 270.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1780.371704, -1738.915893, 13.792823, 0.000000, 0.000000, -90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1858.905151, -1222.914550, 18.571943, 10.100000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1433.347045, -1027.364257, 24.086256, 0.000000, 0.000000, -270.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1003.368835, -1134.167724, 24.049919, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 842.039062, -1313.619873, 13.775012, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 571.511901, -1219.486572, 17.860269, 0.000000, 0.000000, 112.999969, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 277.747375, -1709.758422, 7.886290, -1.800000, 0.000000, -108.999992, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 781.402954, -1790.508911, 13.342281, 0.000000, 0.000000, 270.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1218.219604, -2457.221679, 9.718414, 0.000000, 0.000000, -108.199989, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1526.433593, -2302.295410, 13.719610, 0.000000, 0.000000, -6.799997, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1711.583740, -2201.454345, 13.725006, 0.000000, 0.000000, -90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(19464, 1779.686035, -2178.789306, 12.454985, 360.000000, 90.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 18757, "vcinteriors", "dts_elevator_carpet3", 0x00000000);
	tmpobjid = CreateDynamicObject(19464, 1773.765502, -2178.789306, 12.454985, 360.000000, 90.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 18757, "vcinteriors", "dts_elevator_carpet3", 0x00000000);
	tmpobjid = CreateDynamicObject(19464, 1773.765502, -2182.201171, 12.444985, 360.000000, 90.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 18757, "vcinteriors", "dts_elevator_carpet3", 0x00000000);
	tmpobjid = CreateDynamicObject(19464, 1779.685668, -2182.201171, 12.444985, 360.000000, 90.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 18757, "vcinteriors", "dts_elevator_carpet3", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1364.798950, -1120.750366, 24.052433, 0.000000, 0.000000, -2.599999, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 2134.228027, -1096.778808, 24.665033, 0.399999, 0.000000, -117.099960, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 2397.990478, -1249.989868, 24.121847, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 2258.935546, -1725.727294, 13.722812, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 2147.203857, -1745.792968, 13.742128, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 2027.300048, -1254.253051, 24.210321, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1679.217407, -1291.746582, 14.208199, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	tmpobjid = CreateDynamicObject(1257, 1172.846191, -1274.274536, 13.699880, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 18632, "fishingrod", "handle2", 0x00000000);
	
	CreateDynamicObject(982, 1757.967041, -2176.490722, 13.174695, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(982, 1732.359375, -2176.490722, 13.174695, 0.000000, 0.000000, 90.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(983, 1782.676757, -2179.817626, 13.214699, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(983, 1770.794433, -2179.687500, 13.174698, 0.000000, 0.000000, 0.000000, 0, 0, -1, 200.00, 200.00); 
	CreateDynamicObject(10837, 1770.666503, -2181.002685, 16.636863, 0.000000, 0.000000, -15.000000, 0, 0, -1, 200.00, 200.00); 

	return 1;
}


hook OnPlayerConnect(playerid)
{
    PlayerData[playerid][pBussidejob] = 0;
  	PlayerSidejob[playerid] = -1;
	StopPlayerWorkInBus(playerid);
	busRoute[playerid] = 0;
	outCheck[playerid] = 0;
	currentBRoute[playerid] = 0;
    stop outTimer[playerid];
	stop outTime[playerid];
	stop busTimer[playerid];
	RemoveBuildingForPlayer(playerid, 1438, 1015.530, -1337.170, 12.554, 0.250);

	return 1;
}


hook OnPlayerDisconnectEx(playerid)
{
    stop outTimer[playerid];
	stop outTime[playerid];
	stop busTimer[playerid];
	if(IsPlayerWorkInBus(playerid))
	{
	    if (PlayerData[playerid][pBussidejob])
		{
		    PlayerData[playerid][pBussidejob] = 0;

		    if (PlayerSidejob[playerid] != -1)
		      	DialogSidejob[PlayerSidejob[playerid]] = false;

		    PlayerSidejob[playerid] = -1;
		    
		    outCheck[playerid] = 0;
			DestroyVehicle(GetPlayerLastVehicle(playerid));
			DisablePlayerRaceCheckpoint(playerid);

	        stop outTimer[playerid];
			stop outTime[playerid];
			stop busTimer[playerid];
			SetBusDelay(playerid, 600);
		}
	}

	return 1;
}

CancelBusProgress(playerid)
{
	if(IsPlayerWorkInBus(playerid))
	{
		if (IsBusVehicle(GetPlayerLastVehicle(playerid)))
		{
		    stop busTimer[playerid];
		    busOut[playerid] = 25;
		    outCheck[playerid] = 1;
    		outTimer[playerid] = repeat InsideBusOut(playerid);
    		outTime[playerid] = defer SetPlayerToCancel[25000](playerid);
    		GameTextForPlayer(playerid, sprintf("ENTER THE BUS~n~~y~%02d SECONDS", busOut[playerid]), 1000, 6);
			PlayerPlaySoundEx(playerid, 43000);
			/*StopPlayerWorkInBus(playerid);
			currentBRoute[playerid] = 0;
			busRoute[playerid] = 0;
			busCounter[playerid] = 0;

			stop busTimer[playerid];

			SetVehicleToRespawn(GetPlayerLastVehicle(playerid));
			DisablePlayerRaceCheckpoint(playerid);

			SetBusDelay(playerid, 600);
			SendCustomMessage(playerid, "BUS","Kamu gagal dan tidak tuntas menyelesaikan pekerjaan ini.");*/
		}

	}
    return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_CTRL_BACK) //Key H
    {
        if(IsPlayerInRangeOfPoint(playerid, 2, 1007.57, -1369.81, 13.75))
        {
            if(PlayerData[playerid][pBussidejob] == 1)
				return SendErrorMessage(playerid, "Kamu sedang bekerja bus, tidak bisa mengambil bus kembali");
				
            if(PlayerData[playerid][pMaskOn])
				return SendErrorMessage(playerid, "Disable your mask first."), RemovePlayerFromVehicle(playerid);
				
            if(GetBusDelay(playerid) > 0)
			{
				SendCustomMessage(playerid, "BUS", "Kamu tidak dapat bekerja sekarang, tunggu %d menit untuk memulainya kembali.", (GetBusDelay(playerid)/60));
				return 1;
			}
	        new str[640];

    		format(str, sizeof(str), "Bus\tStatus\n");
		  	for (new i = 0; i < 4; i ++) {
		    	format(str, sizeof(str), "%sBusType %d\t"GREEN"%s\n", str, i, (DialogSidejob[i] == true) ? (RED"Taken") : (GREEN"Availeble"));
		  	}
		  	Dialog_Show(playerid, SidejobBusstatus, DIALOG_STYLE_TABLIST_HEADERS, "Bus Sidejob", str, "Start", "Close");
		}
    }
	return 1;
}

Dialog:SidejobBusstatus(playerid, response, listitem, inputtext[]) {
  if (response && listitem != -1) {
    if (DialogSidejob[listitem] == true)
      return SendErrorMessage(playerid, "This Bus Sidejob has already taken by someone!");
      
    if(listitem == 0)
	{
		DialogSidejob[listitem] = true;
	    PlayerSidejob[playerid] = listitem;
	    PlayerData[playerid][pBussidejob] = 1;

	    busVehicle[0] = CreateVehicle(431, 1011.1265, -1339.5845, 13.7566, 90.0, 1, 2, 1000);
	    ResetVehicle(busVehicle[0]);

	    CoreVehicles[busVehicle[0]][vehTemporary] = true;
	    SetVehicleNumberPlate(busVehicle[0], "BUS VEHICLE-0");
	    PutPlayerInVehicle(playerid, busVehicle[0], 0);
		SetCameraBehindPlayer(playerid);
		Dialog_Show(playerid, BusSidejob, DIALOG_STYLE_MSGBOX, "Bus Sidejob", ""WHITE"Kamu sedang menaiki bus kerja Type 0. Apakah kamu ingin memulai pekerjaan ini?.\nKamu akan di tugaskan untuk kelilingi menuju beberapa halte di kota Los Santos.\n\nPilik opsi \"Mulai\" untuk melakukan pekerjaan.", "Mulai", "Turun");
	}
	if(listitem == 1)
	{
		DialogSidejob[listitem] = true;
	    PlayerSidejob[playerid] = listitem;
	    PlayerData[playerid][pBussidejob] = 1;

	    busVehicle[1] = CreateVehicle(431, 1008.510, -1345.753, 13.541, 90.0, 1, 2, 1000);
	    ResetVehicle(busVehicle[1]);

	    CoreVehicles[busVehicle[1]][vehTemporary] = true;
	    SetVehicleNumberPlate(busVehicle[1], "BUS VEHICLE-1");
	    PutPlayerInVehicle(playerid, busVehicle[1], 0);
		SetCameraBehindPlayer(playerid);
		Dialog_Show(playerid, BusSidejob, DIALOG_STYLE_MSGBOX, "Bus Sidejob", ""WHITE"Kamu sedang menaiki bus kerja Type 1. Apakah kamu ingin memulai pekerjaan ini?.\nKamu akan di tugaskan untuk kelilingi menuju beberapa halte di kota Los Santos.\n\nPilik opsi \"Mulai\" untuk melakukan pekerjaan.", "Mulai", "Turun");
	}
	if(listitem == 2)
	{
		DialogSidejob[listitem] = true;
	    PlayerSidejob[playerid] = listitem;
	    PlayerData[playerid][pBussidejob] = 1;

	    busVehicle[2] = CreateVehicle(431, 1008.320, -1351.586, 13.526, 90.0, 1, 2, 1000);
	    ResetVehicle(busVehicle[2]);

	    CoreVehicles[busVehicle[2]][vehTemporary] = true;
	    SetVehicleNumberPlate(busVehicle[2], "BUS VEHICLE-2");
	    PutPlayerInVehicle(playerid, busVehicle[2], 0);
		SetCameraBehindPlayer(playerid);
		Dialog_Show(playerid, BusSidejob, DIALOG_STYLE_MSGBOX, "Bus Sidejob", ""WHITE"Kamu sedang menaiki bus kerja Type 2. Apakah kamu ingin memulai pekerjaan ini?.\nKamu akan di tugaskan untuk kelilingi menuju beberapa halte di kota Los Santos.\n\nPilik opsi \"Mulai\" untuk melakukan pekerjaan.", "Mulai", "Turun");
	}
	if(listitem == 3)
	{
		DialogSidejob[listitem] = true;
	    PlayerSidejob[playerid] = listitem;
	    PlayerData[playerid][pBussidejob] = 1;

	    busVehicle[3] = CreateVehicle(431, 1010.0966, -1357.8387, 13.7576, 90.0, 1, 2, 1000);
	    ResetVehicle(busVehicle[3]);

	    CoreVehicles[busVehicle[3]][vehTemporary] = true;
	    SetVehicleNumberPlate(busVehicle[3], "BUS VEHICLE-3");
	    PutPlayerInVehicle(playerid, busVehicle[3], 0);
		SetCameraBehindPlayer(playerid);
		Dialog_Show(playerid, BusSidejob, DIALOG_STYLE_MSGBOX, "Bus Sidejob", ""WHITE"Kamu sedang menaiki bus kerja Type 3. Apakah kamu ingin memulai pekerjaan ini?.\nKamu akan di tugaskan untuk kelilingi menuju beberapa halte di kota Los Santos.\n\nPilik opsi \"Mulai\" untuk melakukan pekerjaan.", "Mulai", "Turun");
	}
  }
  return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT)
	{
     	if(outCheck[playerid] == 1)
		{
      		if(IsBusVehicle(GetPlayerLastVehicle(playerid)))
			{
			    if(!GetPlayerLastVehicle(playerid))
				{
					SendCustomMessage(playerid, "BUS", "Silahkan pilih bus yang terakhir kamu naiki.");
					RemovePlayerFromVehicle(playerid);
					return 1;
				}
				busTimer[playerid] = repeat InsideBusCheckpoint(playerid);
				outCheck[playerid] = 0;
			    stop outTimer[playerid];
				stop outTime[playerid];
			}
			return 1;
		}
		/*if(outCheck[playerid] == 0)
		{
      		if(IsBusVehicle(GetPlayerVehicleID(playerid)))
			{
			    if(!GetPlayerLastVehicle(playerid))
				{
					SendCustomMessage(playerid, "BUS", "Silahkan pilih bus yang terakhir kamu naiki.");
					RemovePlayerFromVehicle(playerid);
					return 1;
				}
				if(GetBusDelay(playerid) > 0)
				{
					SendCustomMessage(playerid, "BUS", "Kamu tidak dapat bekerja sekarang, tunggu %d menit untuk memulainya kembali.", (GetBusDelay(playerid)/60));
					RemovePlayerFromVehicle(playerid);
					return 1;
				}

				
			}
			return 1;
		}*/
	}

	if(newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER)
		CancelBusProgress(playerid);

	return 1;
}


hook OnPlayerEnterRaceCP(playerid)
{
	if(IsPlayerConnected(playerid) && IsPlayerWorkInBus(playerid))
	{
		if(busCounter[playerid] == 1)
		{
			SetBusCheckpointRoute(playerid);
		}
	}

	return 1;
}


hook OnPlayerLeaveRaceCP(playerid)
{
	if(IsPlayerConnected(playerid) && IsPlayerWorkInBus(playerid))
	{
		switch(busRoute[playerid])
		{
			case 1: busCounter[playerid] = arr_busRoute1[currentBRoute[playerid]][b_time];
			case 2: busCounter[playerid] = arr_busRoute2[currentBRoute[playerid]][b_time];
			case 3: busCounter[playerid] = arr_busRoute3[currentBRoute[playerid]][b_time];
		}
	}

	return 1;
}

// hook OnVehicleDeath(vehicleid, killerid)
// {
// 	if(IsBusVehicle(vehicleid))
// 	{
// 		// SetVehicleToRespawn(vehicleid);
// 		if (IsPlayerWorkInBus(killerid)) {
// 			StopPlayerWorkInBus(killerid);
// 			currentBRoute[killerid] = 0;
// 			busRoute[killerid] = 0;
// 			busCounter[killerid] = 0;

// 			stop busTimer[killerid];

// 			DisablePlayerRaceCheckpoint(killerid);

// 			SetBusDelay(killerid, 600);
// 			SendCustomMessage(killerid, "BUS","Kamu gagal dan tidak tuntas menyelesaikan pekerjaan ini.");
// 		}
// 	}
// 	return 1;
// }

/*hook OnPlayerVehicleDamage(playerid, vehicleid, Float:Damage)
{
	new
		veh = GetPlayerVehicleID(playerid);

	if(IsBusVehicle(veh))
	{
		if(ReturnVehicleHealth(veh) < 1000 || ReturnVehicleHealth(veh) > 990)
		{
			SendCustomMessage(playerid, "BUS", "Bus lecet! Kamu terkena denda sebesar "RED"$25 dollar."WHITE" Berhati- hatilah membawa bus!");
			GiveMoney(playerid, -25);
		}
		else {
			if(ReturnVehicleHealth(GetPlayerVehicleID(playerid)) < 995 || > 990)
			SendCustomMessage(playerid, "BUS", "Bus lecet! Kamu terkena denda sebesar "RED"$25 dollar."WHITE" Berhati- hatilah membawa bus!");
			GiveMoney(playerid, -25);
		}
		return 1;
	}
	return 1;
}*/

//	NEW FUNCTION BUS SIDEJOB


IsBusVehicle(vehicleid)
{
	for(new i = 0; i < MAX_BUS_VEHICLE; i++) if(vehicleid == busVehicle[i])
		return 1;

	return 0;
}

SetBusCheckpoin(playerid, mode)
{
	if(IsPlayerWorkInBus(playerid))
	{
		switch(busRoute[playerid])
		{
			case 1:
			{
				SetPlayerRaceCheckpoint(playerid, mode, arr_busRoute1[currentBRoute[playerid]][b_x], arr_busRoute1[currentBRoute[playerid]][b_y], arr_busRoute1[currentBRoute[playerid]][b_z], mode ? (-1.0) : (arr_busRoute1[currentBRoute[playerid] + 1][b_x]), mode ? (-1.0) : (arr_busRoute1[currentBRoute[playerid] + 1][b_y]), mode ? (-1.0) : (arr_busRoute1[currentBRoute[playerid] + 1][b_z]), 6);
				busCounter[playerid] = arr_busRoute1[currentBRoute[playerid]][b_time];
			}
			case 2:
			{
				SetPlayerRaceCheckpoint(playerid, mode, arr_busRoute2[currentBRoute[playerid]][b_x], arr_busRoute2[currentBRoute[playerid]][b_y], arr_busRoute2[currentBRoute[playerid]][b_z], mode ? (-1.00) : (arr_busRoute2[currentBRoute[playerid] + 1][b_x]), mode ? (-1.00) : (arr_busRoute2[currentBRoute[playerid] + 1][b_y]), mode ? (-1.00) : (arr_busRoute2[currentBRoute[playerid] + 1][b_z]), 6);
				busCounter[playerid] = arr_busRoute2[currentBRoute[playerid]][b_time];
			}
			case 3:
			{
				SetPlayerRaceCheckpoint(playerid, mode, arr_busRoute3[currentBRoute[playerid]][b_x], arr_busRoute3[currentBRoute[playerid]][b_y], arr_busRoute3[currentBRoute[playerid]][b_z], mode ? (-1.00) : (arr_busRoute3[currentBRoute[playerid] + 1][b_x]), mode ? (-1.00) : (arr_busRoute3[currentBRoute[playerid] + 1][b_y]), mode ? (-1.00) : (arr_busRoute3[currentBRoute[playerid] + 1][b_z]), 6);
				busCounter[playerid] = arr_busRoute3[currentBRoute[playerid]][b_time];
			}
		}
	}
	return 1;
}

SetBusCheckpointRoute(playerid)
{
	currentBRoute[playerid] ++;

	if((busRoute[playerid] == 1 && currentBRoute[playerid] == sizeof(arr_busRoute1)) ||	(busRoute[playerid] == 2 && currentBRoute[playerid] == sizeof(arr_busRoute2)) || (busRoute[playerid] == 3 && currentBRoute[playerid] == sizeof(arr_busRoute3)))
	{
		new index = PlayerSidejob[playerid];
	    PlayerData[playerid][pBussidejob] = 0;
	    DialogSidejob[index] = false;
	    StopPlayerWorkInBus(playerid);
		currentBRoute[playerid] = 0;
		busRoute[playerid] = 0;
	    DestroyVehicle(GetPlayerVehicleID(playerid));
	    DisablePlayerRaceCheckpoint(playerid);
	    new bonus = RandomEx(25,99);
		SendCustomMessage(playerid, "BUS","Kamu telah menyelesaikan pekerjaan, dan kamu mendapat upah "COL_GREEN"$%s "WHITE"dari pekerjaan ini, dan bonus sebesar "COL_GREEN"$%d", FormatNumber(12500), bonus);
		AddPlayerSalary(playerid, BUS_SALARY+bonus, "Bus Sidejob + Bonus");
		SetBusDelay(playerid, 1800);

		stop busTimer[playerid];
	    PlayerSidejob[playerid] = -1;
	}
	else if((busRoute[playerid] == 1 && currentBRoute[playerid] == sizeof(arr_busRoute1) - 1) || (busRoute[playerid] == 2 && currentBRoute[playerid] == sizeof(arr_busRoute2) - 1) || (busRoute[playerid] == 3 && currentBRoute[playerid] == sizeof(arr_busRoute3) - 1))
	{
		SetBusCheckpoin(playerid, 1);
	}
	else
	{
		SetBusCheckpoin(playerid, 0);
	}
	return 1;
}

/*
	Timer Bus Sidejob
*/
timer SetPlayerToCancel[1000](playerid)
{
    PlayerData[playerid][pBussidejob] = 0;

    if (PlayerSidejob[playerid] != -1)
      	DialogSidejob[PlayerSidejob[playerid]] = false;

    PlayerSidejob[playerid] = -1;
    StopPlayerWorkInBus(playerid);
	currentBRoute[playerid] = 0;
	busRoute[playerid] = 0;
	busCounter[playerid] = 0;
	outCheck[playerid] = 0;

	stop busTimer[playerid];
	stop outTimer[playerid];
	stop outTime[playerid];

	DestroyVehicle(GetPlayerLastVehicle(playerid));
	DisablePlayerRaceCheckpoint(playerid);

	SetBusDelay(playerid, 600);
	SendCustomMessage(playerid, "BUS","Kamu gagal dan tidak tuntas menyelesaikan pekerjaan ini.");
    return 1;
}
timer InsideBusOut[1000](playerid)
{
    busOut[playerid]--;
	GameTextForPlayer(playerid, sprintf("ENTER THE BUS~n~~y~%02d SECONDS", busOut[playerid]), 1000, 6);
	PlayerPlaySoundEx(playerid, 43000);
	return 1;
}
timer InsideBusCheckpoint[1000](playerid)
{
	if(IsPlayerConnected(playerid) && IsPlayerWorkInBus(playerid))
	{
		
		if(IsPlayerInRaceCheckpoint(playerid))
		{
			if(--busCounter[playerid] == 0)
			{
				SetBusCheckpointRoute(playerid);
				return 1;
			}

			GameTextForPlayer(playerid, sprintf("PLEASE WAIT~n~~y~%02d SECONDS", busCounter[playerid]), 1000, 6);
			PlayerPlaySoundEx(playerid, 43000);
		}

		// if(GetVehicleSpeed(GetPlayerVehicleID(playerid)) > 80.0)    
		// {
	  //       if(++PlayerData[playerid][pTestWarns] < 4)
		// 	{
		// 		SendClientMessageEx(playerid, X11_TOMATO_1, "WARNING:"WHITE" Kamu melewati batas kecepatan dalam mengendarai Bus, awas gagal!"YELLOW"(MAX SPEED: 80))"WHITE"(%d/4)", PlayerData[playerid][pTestWarns]);
		// 		SetVehicleSpeed(GetPlayerVehicleID(playerid), 20);
		// 	}
	  //       else {
	  //       	PlayerData[playerid][pTestWarns] = 0;
	  //       	CancelBusProgress(playerid);
	  //       }
	  //   }

	}
	return 1;
}

/*
	DIALOG CALLBACK BUS SIDEJOB
*/

Dialog:BusSidejob(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new route = RandomEx(1, 4);

		SetPlayerWorkInBus(playerid);
		currentBRoute[playerid] = 0;
		busRoute[playerid] = route;

		busTimer[playerid] = repeat InsideBusCheckpoint(playerid);

		SetEngineStatus(GetPlayerVehicleID(playerid), true);
		CoreVehicles[GetPlayerVehicleID(playerid)][vehFuel] = 100;

		SetBusCheckpoin(playerid, 0);
	}
	else
	{
	    PlayerData[playerid][pBussidejob] = 0;

	    if (PlayerSidejob[playerid] != -1)
	      	DialogSidejob[PlayerSidejob[playerid]] = false;

	    PlayerSidejob[playerid] = -1;
		DestroyVehicle(GetPlayerVehicleID(playerid));
	}
	return 1;
}
CMD:resettratimer(playerid, params[])
{

   	if(CheckAdmin(playerid, 5))
        return PermissionError(playerid);
	static
		userid;

	if(sscanf(params, "u", userid))
		return SendSyntaxMessage(playerid, "/resettratimer [targetid]");

	PlayerData[userid][pWork] = 0;
	return 1;
}
/*	COMMANDS */
CMD:resetbustimer(playerid, params[])
{

   	if(CheckAdmin(playerid, 5))
        return PermissionError(playerid);
	static
		userid;

	if(sscanf(params, "u", userid))
		return SendSyntaxMessage(playerid, "/resetbustimer [targetid]");

	SetBusDelay(userid, 0);
	return 1;
}

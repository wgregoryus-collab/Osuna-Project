/*  Array List */

stock const ColorList[] = {
    0x000000FF, 0xF5F5F5FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF, 0x5E7072FF,
    0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF, 0x9F9D94FF,
    0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF, 0x979592FF,
    0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF, 0x6D7A88FF,
    0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF, 0xADB0B0FF,
    0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF, 0x4E6881FF,
    0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF, 0xAB988FFF,
    0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF, 0x0E316DFF,
    0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF, 0xA7A28FFF,
    0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0x0F6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF, 0xAE9B7FFF,
    0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF, 0x525661FF,
    0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0x640D1BFF, 0xA3ADC6FF, 0x695853FF,
    0x9B8B80FF, 0x620B1CFF, 0x5B5D5EFF, 0x624428FF, 0x731827FF, 0x1B376DFF, 0xEC6AAEFF, 0x000000FF, 0x177517FF, 0x210606FF,
    0x125478FF, 0x452A0DFF, 0x571E1EFF, 0x010701FF, 0x25225AFF, 0x2C89AAFF, 0x8A4DBDFF, 0x35963AFF, 0xB7B7B7FF, 0x464C8DFF,
    0x84888CFF, 0x817867FF, 0x817A26FF, 0x6A506FFF, 0x583E6FFF, 0x8CB972FF, 0x824F78FF, 0x6D276AFF, 0x1E1D13FF, 0x1E1306FF,
    0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF, 0x7C8499FF, 0x992E1EFF, 0x2C1E08FF,
    0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF, 0x6C3F99FF, 0x481A0EFF, 0x7A7399FF,
    0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF, 0x805B80FF, 0x7B3E7EFF, 0x3C1737FF,
    0x733517FF, 0x781818FF, 0x83341AFF, 0x8E2F1CFF, 0x7E3E53FF, 0x7C6D7CFF, 0x020C02FF, 0x072407FF, 0x163012FF, 0x16301BFF,
    0x642B4FFF, 0x368452FF, 0x999590FF, 0x818D96FF, 0x99991EFF, 0x7F994CFF, 0x839292FF, 0x788222FF, 0x2B3C99FF, 0x3A3A0BFF,
    0x8A794EFF, 0x0E1F49FF, 0x15371CFF, 0x15273AFF, 0x375775FF, 0x060820FF, 0x071326FF, 0x20394BFF, 0x2C5089FF, 0x15426CFF,
    0x103250FF, 0x241663FF, 0x692015FF, 0x8C8D94FF, 0x516013FF, 0x090F02FF, 0x8C573AFF, 0x52888EFF, 0x995C52FF, 0x99581EFF,
    0x993A63FF, 0x998F4EFF, 0x99311EFF, 0x0D1842FF, 0x521E1EFF, 0x42420DFF, 0x4C991EFF, 0x082A1DFF, 0x96821DFF, 0x197F19FF,
    0x3B141FFF, 0x745217FF, 0x893F8DFF, 0x7E1A6CFF, 0x0B370BFF, 0x27450DFF, 0x071F24FF, 0x784573FF, 0x8A653AFF, 0x732617FF,
    0x319490FF, 0x56941DFF, 0x59163DFF, 0x1B8A2FFF, 0x38160BFF, 0x041804FF, 0x355D8EFF, 0x2E3F5BFF, 0x561A28FF, 0x4E0E27FF,
    0x706C67FF, 0x3B3E42FF, 0x2E2D33FF, 0x7B7E7DFF, 0x4A4442FF, 0x28344EFF
};

stock const g_aWeaponSlots[] = {
    0, // Fist
    0, // Brass Knuckle
    1, // Golf Club
    1, // Nightstick
    1, // Knife
    1, // Baseball Bat
    1, // Shovel
    1, // Pool Clue
    1, // Katana
    1, // Chainsaw
    10, //Purple Dildo
    10, // Dildo
    10, // Vibrator
    10, // Silver Vibrator
    10, // Flowers
    10, // Cane
    8, // Grenade
    8, // Teargas (17)
    8, // Molotov Cocktail (18)
    0, // (unused) (19)
    0, // (unused) (20)
    0, // (unused) (21)
    2, // 9mm
    2, // Silenced 9mm
    2, // Desert Eagle
    3, // Shotgun
    3, // Sawnoff Shotgun
    3, // Combat Shotgun
    4, // Micro SMG/Uzi
    4, // MP5
    5, // AK47
    5, // M4
    4, //TEC-9
    6, //County Rifle
    6, // Sniper Rifle
    7, // RPG
    7, // HS Rocket
    7, // Flamethrower
    7, // Minigun
    8, // Satchel Charge
    12, // Detonator
    9, // Spraycan
    9, // Fire Extinguisher
    9, // Camera
    11, // Night Vision Goggles
    11, // Thermal Googgles
    11 // Parachute
};

/*==============================================================================
    Fixed Arrays
==============================================================================*/

new Float:NSArray[] =
{
    1475.89, -1536.16,
    1474.15, -1567.77,
    1514.03, -1570.38,
    1518.06, -1536.91
};

new Float:SAMDArray[] =
{
    974.0, 2440.0,
    974.0, 2417.0,
    1006.0, 2416.0,
    1007.0, 2438.0,
    974.0, 2440.0
};

new Float:JailArray[] =
{
    -3436.51, 1586.94,
    -3436.66, 1553.46,
    -3415.43, 1551.47,
    -3414.27, 1586.35
};

new Float:Woods[5][3] = {
    {0.000, 1.440, 0.000},
    {0.000, 0.070, 0.000},
    {0.000, -1.130, 0.000},
    {0.000, -2.650, 0.000},
    {0.000, -4.239, 0.009}
};

new Float:WoodsCheckpoint[][3] = {
    {2786.84, -2456.11, 13.63},
    {2347.86, -1411.97, 23.99},
    {2051.14, -1809.57, 13.38},
    {1012.26, -1412.53, 13.19},
    {777.37, -1040.26, 24.25}
};

//Small
new Float:zones_points_0[] = {
    710.0,-2085.0,140.0,-2085.0,140.0,-1807.0,-246.0,-1805.0,-272.0,-1879.0,-248.0,-1941.0,-228.0,-1997.0,-230.0,-2027.0,-212.0,-2061.0,-214.0,-2095.0,
    -216.0,-2135.0,-126.0,-2353.0,26.0,-2471.0,30.0,-2511.0,66.0,-2601.0,66.0,-2663.0,64.0,-2705.0,130.0,-2619.0,142.0,-2531.0,126.0,-2437.0,
    466.0,-2439.0,994.0,-2451.0,944.0,-2271.0,822.0,-2181.0,710.0,-2085.0
};

new Float:zones_points_10[] = {
    996.0,-2453.0,590.0,-2457.0,588.0,-2521.0,568.0,-2541.0,534.0,-2547.0,502.0,-2521.0,490.0,-2475.0,324.0,-2477.0,324.0,-2539.0,458.0,-2547.0,
    378.0,-2653.0,180.0,-2725.0,68.0,-2731.0,64.0,-2905.0,266.0,-2863.0,534.0,-2863.0,592.0,-2543.0,998.0,-2541.0,794.0,-2639.0,784.0,-2749.0,
    876.0,-2773.0,884.0,-2651.0,1138.0,-2737.0,996.0,-2453.0
};
new Float:zones_points_6[] = {
    266.0, -2865.0, 766.0, -2815.0
};

new Float:zones_points_11[] = {
	319.0, -2103.0, 435.0, -2011.0
};
new Float:zones_points_12[] = {
	1007.0,-2362.0,1119.0,-2433.0,1179.0,-2481.0,1227.0,-2503.0,1235.0,-2549.0,1235.0,-2598.0,1236.0,-2625.0,1278.0,-2723.0,1310.0,-2748.0,1335.0,-2763.0,
	1355.0,-2818.0,1356.0,-2875.0,1353.0,-2931.0,1317.0,-2960.0,1192.0,-2969.0,1086.0,-2965.0,999.0,-2959.0,1007.0,-2362.0
};
new Float:zones_points_16[] = {
	2881.0,-2215.0,2911.0,-2167.0,2941.0,-2077.0,2943.0,-1881.0,2991.0,-1881.0,2991.0,-2219.0,2881.0,-2215.0
};
//Medium
new Float:zones_points_7[] = {
    994.0,-2453.0,128.0,-2453.0,142.0,-2531.0,130.0,-2619.0,172.0,-2711.0,366.0,-2645.0,436.0,-2559.0,214.0,-2547.0,214.0,-2461.0,994.0,-2453.0
};
new Float:zones_points_8[] = {
    996.0,-2543.0,596.0,-2545.0,530.0,-2865.0,766.0,-2867.0,912.0,-2815.0,738.0,-2751.0,700.0,-2753.0,696.0,-2663.0,996.0,-2543.0
};
new Float:zones_points_9[] = {
    886.0,-2651.0,1132.0,-2735.0,998.0,-2793.0,876.0,-2767.0,886.0,-2651.0
};
new Float:zones_points_13[] = {
	1399.0,-2785.0,2083.0,-2791.0,2221.0,-2717.0,2273.0,-2719.0,2275.0,-2969.0,1397.0,-2967.0,1399.0,-2785.0
};
new Float:zones_points_15[] = {
	2869.0,-2543.0,2867.0,-2267.0,2971.0,-2267.0,2973.0,-2537.0,2869.0,-2543.0
};
//Big
new Float:zones_points_1[] = {
    258.0, -2505.0, 43.0
};
new Float:zones_points_2[] = {
    546.0, -2505.0, 43.0
};
new Float:zones_points_3[] = {
    742.0, -2707.0, 43.0
};
new Float:zones_points_4[] = {
    370.0, -2737.0, 43.0
};
new Float:zones_points_5[] = {
    990.0, -2879.0, 43.0
};
new Float:zones_points_14[] = {
	2377.0,-2721.0,2517.0,-2727.0,2579.0,-2683.0,2573.0,-2587.0,2671.0,-2591.0,2771.0,-2599.0,2965.0,-2603.0,2963.0,-2975.0,2377.0,-2973.0,2377.0,-2721.0
};

new zones_text[FISH_ZONE][64] = {
    "Small",
    "Small",
    "Small ",
    "Medium",
    "Medium",
    "Medium",
    "Big",
    "Big",
    "Big",
    "Big",
    "Big",
    "Small",
	"Small",
	"Medium",
	"Big",
	"Medium",
	"Small"
};

new roadblock[] = {
    19975, 19972, 19966, 1459, 978,
    981, 1238, 1425, 3265, 3091,
    970, 1422, 19970, 19971, 1237,
    1423, 983, 1251, 19953, 19954,
    19974, 19834
};

enum g_accList
{
    accListType,
    accListModel,
    accListName[24]
};

new const accList[][g_accList] =
{
    //Cap
    {1,18955,"CapOverEye1"},
    {1,18956,"CapOverEye2"},
    {1,18957,"CapOverEye3"},
    {1,18958,"CapOverEye4"},
    {1,18959,"CapOverEye5"},
    {1,19553,"StrawHat1"},
    {1,19554,"Beanie1"},
    {1,19558,"19558"},
    {1,18639,"BlackHat1"},
    {1,18638,"HardHat1"},
    {1,19097,"CowboyHat4"},
    {1,19096,"CowboyHat3"},
    {1,18964,"SkullyCap1"},
    {1,18969,"HatMan1"},
    {1,18968,"HatMan2"},
    {1,18967,"HatMan3"},
    {1,18950,"HatBowler4"},
    {1,18948,"HatBowler2"},
    {1,18949,"HatBowler3"},
    {1,19137,"CluckinBellHat1"},
    {1,18926,"Hat1"},
    {1,18927,"Hat2"},
    {1,18928,"Hat3"},
    {1,18940,"CapBack3"},
    {1,18943,"CapBack5"},
    {1,18922,"Beret2"},
    {1,18921,"Beret1"},
    {1,18923,"Beret3"},
    {1,9067,"HoodyHat1"},
    {1,19069,"HoodyHat3"},
    {1,19161,"PoliceHat1"},

    //Bandana
    {2,18891, "Bandana1"},
    {2,18892, "Bandana2"},
    {2,18893, "Bandana3"},
    {2,18894, "Bandana4"},
    {2,18895, "Bandana5"},
    {2,18896, "Bandana6"},
    {2,18897, "Bandana7"},
    {2,18898, "Bandana8"},
    {2,18899, "Bandana9"},
    {2,18900, "Bandana10"},
    {2,18901, "Bandana11"},
    {2,18902, "Bandana12"},
    {2,18903, "Bandana13"},
    {2,18904, "Bandana14"},
    {2,18905, "Bandana15"},
    {2,18906, "Bandana16"},
    {2,18907, "Bandana17"},
    {2,18908, "Bandana18"},
    {2,18909, "Bandana19"},
    {2,18910, "Bandana20"},

    //Mask
    {3,18911, "Mask1"},
    {3,18912, "Mask2"},
    {3,18913, "Mask3"},
    {3,18914, "Mask4"},
    {3,18915, "Mask5"},
    {3,18916, "Mask6"},
    {3,18917, "Mask7"},
    {3,18918, "Mask8"},
    {3,18919, "Mask9"},
    {3,18920, "Mask10"},
    {3,19036,"HockeyMask1"},
    {3,18974,"MaskZorro1"},
    {3,19163,"GimpMask1"},

    //Helmet
    {4,19113, "SillyHelmet1"},
    {4,19114, "SillyHelmet2"},
    {4,19115, "SillyHelmet3"},
    {4,19116, "PlainHelmet1"},
    {4,19117, "PlainHelmet2"},
    {4,19118, "PlainHelmet3"},
    {4,19119, "PlainHelmet4"},
    {4,19120, "PlainHelmet5"},
    {4,18976, "MotorcycleHelmet2"},
    {4,18977, "MotorcycleHelmet3"},
    {4,18978, "MotorcycleHelmet4"},
    {4,18979, "MotorcycleHelmet5"},

    //Watch
    {5,19039, "WatchType1"},
    {5,19040, "WatchType2"},
    {5,19041, "WatchType3"},
    {5,19042, "WatchType4"},
    {5,19043, "WatchType5"},
    {5,19044, "WatchType6"},
    {5,19045, "WatchType7"},
    {5,19046, "WatchType8"},
    {5,19047, "WatchType9"},
    {5,19048, "WatchType10"},
    {5,19049, "WatchType11"},
    {5,19050, "WatchType12"},
    {5,19051, "WatchType13"},
    {5,19052, "WatchType14"},
    {5,19053, "WatchType15"},

    //Glasses
    {6,19006, "GlassesType1"},
    {6,19007, "GlassesType2"},
    {6,19008, "GlassesType3"},
    {6,19009, "GlassesType4"},
    {6,19010, "GlassesType5"},
    {6,19011, "GlassesType6"},
    {6,19012, "GlassesType7"},
    {6,19013, "GlassesType8"},
    {6,19014, "GlassesType9"},
    {6,19015, "GlassesType10"},
    {6,19016, "GlassesType11"},
    {6,19017, "GlassesType12"},
    {6,19018, "GlassesType13"},
    {6,19019, "GlassesType14"},
    {6,19020, "GlassesType15"},
    {6,19021, "GlassesType16"},
    {6,19022, "GlassesType17"},
    {6,19023, "GlassesType18"},
    {6,19024, "GlassesType19"},
    {6,19025, "GlassesType20"},
    {6,19026, "GlassesType21"},
    {6,19027, "GlassesType22"},
    {6,19028, "GlassesType23"},
    {6,19029, "GlassesType24"},
    {6,19030, "GlassesType25"},
    {6,19031, "GlassesType26"},
    {6,19032, "GlassesType27"},
    {6,19033, "GlassesType28"},
    {6,19034, "GlassesType29"},
    {6,19035, "GlassesType30"},

    // Hair
    {7,19517,"Hair 1"},
    {7,19516,"Hair 2"},
    {7,19274,"Hair 3"},
    {7,19518,"Hair 4"},
    {7,19519,"Hair 5"},
    {7,19077,"Hair 6"},
    {7,18975,"Hair 7"},
    {7,18640,"Hair 8"},

    //Misc
    {8,19896,"CigarettePack1"},
    {8,19897,"CigarettePack2"},
    {8,19904,"ConstructionVest1"},
    {8,19942,"PoliceRadio1"},
    {8,19801,"Balaclava1"},
    {8,19623,"Camera1"},
    {8,19625,"Ciggy1"},
    {8,1485,"Ciggy2"},
    {8,19624,"Case1"},
    {8,19559,"HikerBackpack1"},
    {8,19556,"BoxingGloveR"},
    {8,19555,"BoxingGloveL"},
    {8,19142,"SWATARMOUR1"},
    {8,19141,"SWATHELMET1"},
    {8,19520,"pilotHat01"},
    {8,19521,"policeHat01"},
    {8,19515,"SWATAgrey"},
    {8,19330,"fire_hat01"},
    {8,1550,"CJ_MONEY_BAG"},
    {8,19347,"badge01"},
    {8,371,"gun_para"},
    // {8,2919,"kmb_holdall"}
    {8,11745,"Dufflebag"},
    {8,19317,"Guitar 1"},
    {8,19318,"Guitar 2"},
    {8,19610,"Mic"},
    {8,19611,"Mic Stand"},
    {8,18632,"Fishing Rod"}
};

stock const gAdminLevel[][] = {
    "Player",
    "Volunter", //VOLUNTER 1
    "Prob.Helper", //HELPER 2
    "Junior Helper", //Senior Helper 3
    "Senior Helper", //Administrator 4
    "Prob.Administrator", //Senior Administrator 5
    "Junior Administrator", //Community Of Administrator 6
    "Senior Administrator", //Supervisor Of Administrator 7
    "Head Administrator", //Management Of Administrator 8
    "Manager", // Head Of Administrator  9
    "General Manager", // Executive Levels 10
    "Executive Admin" // Chief Executive Officer 11
};

stock const gAdminAlias[][] = {
    "Player",
    "Volunter", //VOLUNTER 1
    "Prob.Helper", //HELPER 2
    "Junior Helper", //Senior Helper 3
    "Senior Helper", //Administrator 4
    "Prob.Administrator", //Senior Administrator 5
    "Junior Administrator", //Community Of Administrator 6
    "Senior Administrator", //Supervisor Of Administrator 7
    "Head Administrator", //Management Of Administrator 8
    "Manager", // Head Of Administrator  9
    "General Manager", // Executive Levels 10
    "Executive Admin" // Chief Executive Officer 11
};

enum e_Cargo {
    Float:cX,
    Float:cY,
    Float:cZ,
    cType[16],
    cPrice
};
new Text3D:CargoLabel[6];

new const arrCargo[6][e_Cargo] = {
    {816.66, 856.76, 12.78, "Gas Station", 100}, // Gas Station
    {2832.46, -1537.04, 11.09, "Retail", 40}, //retail
    {2742.23, -2431.33, 13.62, "Clothes", 40}, //clothes
    {-408.53, -1426.32, 25.98, "Food", 60}, //food
    {-1425.66, -1528.52, 102.03, "GYM", 40}, //gym
    {-59.78, -223.97, 5.42, "Electronics", 40} //electric
};

stock const Float:arrHospitalDeliver[][3] = {
    {-2692.6580, 635.4608, 14.4531},
    {-334.9757, 1063.0171, 19.7392},
    {1579.9666, 1767.1462, 10.8203},
    {1177.8599, -1308.3982, 13.8301},
    {2024.4246, -1404.1580, 17.2020},
    {1243.9304, 331.4186, 19.5547}
};

enum houseEnum {
    Float:hX,
    Float:hY,
    Float:hZ,
    Float:hAngle
};

new houseArray[11][houseEnum] = {
    {1543.9897, -2486.3916, 13.7540, 92.1270},
    {1517.5620, -2483.8594, 13.7425, 87.8853},
    {1485.3700, -2499.6243, 13.5573, 359.6927},
    {1473.7440, -2487.0452, 13.5764, 359.2749},
    {1487.9198, -2448.4448, 13.9171, 176.4955},
    {1464.7544, -2457.4954, 13.6111, 2.4084},
    {1446.0667, -2451.9429, 13.7030, 88.5758},
    {1450.1096, -2471.6782, 13.5693, 177.7722},
    {1457.6028, -2498.3154, 13.6583, 179.9655},
    {1416.9957, -2488.6570, 13.7853, 357.8532},
    {1410.9006, -2466.5034, 13.8044, 356.1415}

};

stock const Float:arrAdminJail[][4] = {
    {-3421.3916,1560.4224,98.9136,89.9974},
    {-3421.4558,1567.0017,98.9136,87.4907},
    {-3421.1814,1573.3403,98.9136,91.2507},
    {-3421.2336,1579.7987,98.9136,89.9974},
    {-3432.7085,1579.7437,98.9136,268.7242},
    {-3432.1582,1573.1807,98.9136,269.2651},
    {-3431.7971,1566.7642,98.9136,270.1425},
    {-3432.3176,1560.5348,98.9136,270.1425}
};

stock const Float:arrModshop[][3] = {
    {2240.30,-1990.74,13.30},
    {2259.24,-1990.41,13.41},
    {2268.60,-1990.53,13.68},
    {2249.71,-1990.91,13.30}
};

stock const Float:arrMiner[][3] = {
    {2453.5083, -940.3727, 80.0893},
    {2461.6069, -943.4766, 80.0748},
    {2466.4910, -945.5204, 80.0941},
    {2472.4971, -947.7623, 80.1411},
    {551.30, 916.18, -38.94}
};

stock const Float:arrMechanic[][4] = {
    {2390.0518,-2582.4038,14.1589},
    {2455.3494,-2578.9673, 14.1589},
    {2438.6133, -2619.2097, 14.1589},
    {2362.8491, -2631.4651, 3.1906}
};

// stock const Float:randomBuilding[][4] = {
//     {-85.0017, -1170.4509, 1.2815, 40.57}, // Pom flint
//     {2450.7646, -2089.3386, 12.5427, 80.13}, // MC
//     {1002.24, -1287.45, 19.38, 70.42}, // Bus Station
//     {1941.6563, -1771.3438, 14.1406, 35.04}, // Pom idlewood
//     {1004.6442, -933.2282, 41.1740, 65.08} // Pom Vinewood
// };

stock Float:mekanikzone[] = {
    2165.09, -2215.80,
    2198.98, -2253.10,
    2238.50, -2215.96,
    2202.50, -2175.28,
    2165.09, -2215.80
};

stock Float:mekanikzone2[] = {
    2165.09,-2215.80,2198.98,-2253.10,2238.50,-2215.96,2202.50,-2175.28,2165.09,-2215.80
};

stock Float:ganjazone[] = {
    1122.0,-370.0,1122.0,-288.0,1004.0,-279.0,1002.0,-368.0,1122.0,-370.0
}; //(RECTANGLE) GANJA

// Public farm
stock Float:publicFarm1[] = {
    -332.0,-1433.0,-159.0,-1417.0,-161.0,-1299.0,-326.0,-1313.0,-332.0,-1433.0
};

stock Float:publicFarm2[] = {
    -334.0,-1560.0,-243.0,-1559.0,-212.0,-1517.0,-212.0,-1467.0,-336.0,-1468.0,-334.0,-1560.0
};

stock const accBones[][24] = {
    {"Spine"},
    {"Head"},
    {"Left upper arm"},
    {"Right upper arm"},
    {"Left hand"},
    {"Right hand"},
    {"Left thigh"},
    {"Right thigh"},
    {"Left foot"},
    {"Right foot"},
    {"Right calf"},
    {"Left calf"},
    {"Left forearm"},
    {"Right forearm"},
    {"Left clavicle"},
    {"Right clavicle"},
    {"Neck"},
    {"Jaw"}
};


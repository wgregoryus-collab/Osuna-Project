#define SERVER_NAME                     "Osuna Roleplay | One of the best roleplay server in Indonesia"
#define SERVER_URL                      "https://forum/garudapride"
#define SERVER_DISCORD					"https://discord.gg/osuna"
#define SERVER_REVISION                 "ORP - v1.0.0"

//==============================   SERVER MACROS 	=============================

#define Function:%0(%1)                 forward %0(%1); public %0(%1)
#define posArr{%0}                      %0[0], %0[1], %0[2]
#define posArrEx{%0}                    %0[0], %0[1], %0[2], %0[3]

#define SpeedCheck(%0,%1,%2,%3,%4)      floatround(floatsqroot(%4?(%0*%0+%1*%1+%2*%2):(%0*%0+%1*%1) ) *%3*1.6)
#define RGBAToInt(%0,%1,%2,%3)          ((16777216 * (%0)) + (65536 * (%1)) + (256 * (%2)) + (%3))
#define PRESSED(%0)						(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define HOLDING(%0)                     ((newkeys & (%0)) == (%0))
#define RELEASED(%0)					(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define Loop(%0,%1)                     for(new %0; %0 != %1; %0++)

#define SendServerMessage(%0,%1)        SendClientMessageEx(%0, X11_LIGHTBLUE, "SERVER: "WHITE""%1)
#define SendCustomMessage(%0,%1,%2)     SendClientMessageEx(%0, X11_LIGHTBLUE, %1": "WHITE""%2)
#define SendSyntaxMessage(%0,%1)        SendClientMessageEx(%0, X11_GREY_80, "USAGE: "%1)
#define SendErrorMessage(%0,%1)         SendClientMessageEx(%0, X11_GREY_80, "ERROR: "%1)
#define SendAdminAction(%0,%1)          SendClientMessageEx(%0, X11_TOMATO, "ADMIN: "%1)
#define PermissionError(%0)				SendClientMessageEx(%0, X11_GREY_80, "ERROR: You don't have any permission to use this command!")
#define GetPlayerSQLID(%0)              PlayerData[%0][pID]
#define GetMoney(%0)                    PlayerData[%0][pMoney]
#define ReturnAdminName(%0)             AccountData[%0][pAdmname]
#define ReturnAdminNamee(%0)            AccountData[%0][pUsername]
#define NormalName(%0)                  CharacterList[%0][PlayerData[%0][pCharacter]]

#define IsOwnedVehicle(%0)              VehicleData[%0][cOwner]
#define IsPlayerInjured(%0)             PlayerData[%0][pInjured]
#define GetPlayerLastVehicle(%0)        PlayerData[%0][pLastCar]

#define GetAdminLevel(%0)               PlayerData[%0][pAdmin]
#define GetPlayerFaction(%0)            PlayerData[%0][pFaction]
#define GetPlayerFactionID(%0)          PlayerData[%0][pFactionID]
#define IsPlayerDuty(%0)                PlayerData[%0][pOnDuty]

#define SetSweeperDelay(%0,%1)          PlayerData[%0][pSweeperDelay] = %1
#define GetSweeperDelay(%0)             PlayerData[%0][pSweeperDelay]

#define SetBusDelay(%0,%1)              PlayerData[%0][pBusDelay] = %1
#define GetBusDelay(%0)                 PlayerData[%0][pBusDelay]

#define SetSorterDelay(%0,%1)           PlayerData[%0][pSorterDelay] = %1
#define GetSorterDelay(%0)              PlayerData[%0][pSorterDelay]

#define SetUnloaderDelay(%0,%1)         PlayerData[%0][pUnloaderDelay] = %1
#define GetUnloaderDelay(%0)            PlayerData[%0][pUnloaderDelay]

new g_player_listitem[MAX_PLAYERS][96];
#define GetPlayerListitemValue(%0,%1) 		g_player_listitem[%0][%1]
#define SetPlayerListitemValue(%0,%1,%2) 	g_player_listitem[%0][%1] = %2

#define SetMinerDelay(%0,%1)            PlayerData[%0][pMinerDelay] = %1
#define GetMinerDelay(%0)               PlayerData[%0][pMinerDelay]

#define SetFarmerDelay(%0,%1)           PlayerData[%0][pFarmerDelay] = %1
#define GetFarmerDelay(%0)              PlayerData[%0][pFarmerDelay]

#define GetPlayerJob(%0,%1)             PlayerData[%0][pJob][%1]

#define AddBankMoney(%0,%1)             PlayerData[%0][pBankMoney] += %1

#define CheckAdmin(%0,%1)               PlayerData[%0][pAdmin] < %1

//================================ DYNAMIC SYSTEM ===============================

#define MAX_CHARACTERS                  (3)
#define MAX_WORKSHOP										(21)
#define MAX_FACTIONS                    (50)
#define MAX_DYNAMIC_JOBS                (25)
#define MAX_DYNAMIC_VEHICLES	        	(2000)
#define MAX_HOUSES                      (1000)
#define MAX_RENT_POINT									(100)
#define MAX_RENT_LIST										(5)
#define MAX_MATERIALS              	 		(16)
#define MAX_ACC                         (5)
#define MAX_TENANT                         (5000)
#define MAX_ADVERTISEMENTS							(500)
#define MAX_TRASH_VEHICLE		(4)

#define COLOR_WHITE                     (0xFFFFFFFF)
#define COLOR_CLIENT                    RGBAToInt(0,255,255,255)
#define COLOR_HOSPITAL                  (0xFF8282FF)
#define COLOR_ORANGE                    (0xFFA500FF)
#define COLOR_LIME                      (0x00FF00FF)
#define COLOR_GREEN                     (0x33AA33FF)
#define COLOR_BLUE                      (0x2641FEFF)
#define COLOR_FACTION                   (0xBDF38BFF)
#define COLOR_RADIO                     (0x4D4DFFAA)
#define COLOR_SERVER                    (0xFFFF90FF)
#define COLOR_DEPARTMENT                (0xFFD700AA)
#define COLOR_ADMINCHAT                 (0x33EE33FF)
#define DEFAULT_COLOR                   (0xFFFFFF00)
#define COLOR_INFLUENCER                (0x33FCFFFF)
#define COLOR_RADIO1                    (0x2D492D)

#define COLOR_FADE1                     (0xE6E6E6E6)
#define COLOR_FADE2                     (0xC8C8C8C8)
#define COLOR_FADE3                     (0xAAAAAAAA)
#define COLOR_FADE4                     (0x8C8C8C8C)
#define COLOR_FADE5                     (0x6E6E6E6E)

//#define COL_WHITE                       "{FFFFFF}"
#define COL_AD							"{00aa00}"
#define COL_GREY                        "{C3C3C3}"
#define COL_GREEN                       "{00FF00}"
#define COL_RED                         "{FF0000}"
#define COL_NICERED                     "{FF0000}"
#define COL_ORANGE                      "{F9B857}"
#define COL_BLUE                        "{0049FF}"
#define COL_PINK                        "{FF00EA}"
#define COL_LIGHTBLUE                   "{00C0FF}"
#define COL_LGREEN                      "{C9FFAB}"
#define COL_LIGHTGREEN                  "{9ACD32}"
#define COL_DEPARTMENT                  "{F0CC00}"
#define COL_LIGHTRED                    "{FF6347}"
#define COL_CLIENT                      "{AAC4E5}"

#define WEAPON_SLOT                     (9)
#define JOB_SLOT                        (9)
#define AUTOSELLDAYS                    (15)
#define MAX_STOCK                       (10000)

#define MAX_PLAYER_VEHICLE              (2)
#define MAX_ZONES                       (2)
#define MAX_CAR_STORAGE                 (5)
//#define MAX_BOOTHS                    (8)
#define MAX_DEALER_VEHICLES             (12)
#define MAX_BILLBOARDS                  (50)
#define MAX_REPORTS                     (50)
#define MAX_ASK                         (50)
#define MAX_INVENTORY                   (32)
#define MAX_HOUSE_STORAGE               (10)
#define MAX_HOUSE_TENANT_STORAGE        (5)
#define MAX_DEALER                      (15)
#define MAX_DEALERSHIP_CARS             (10)
#define MAX_GYM_OBJECTS                 (100)
#define MAX_FURNITURE             			(200)
#define MAX_HOUSE_STRUCTURES            (300)
#define MAX_CONTACTS                    (30)
#define MAX_DAMAGE                      (55)
#define MAX_GPS_LOCATIONS               (20)
#define MAX_ARREST_POINTS               (50)
#define MAX_PLAYER_TICKETS              (10)
#define MAX_BARRICADES                  (100)
#define MAX_IMPOUND_LOTS                (20)
#define MAX_ATM_MACHINES                (100)
#define MAX_GARBAGE_BINS                (50)
#define MAX_VENDORS                     (50)
#define MAX_LISTED_ITEMS                (10)
#define MAX_METAL_DETECTORS             (20)
#define MAX_BACKPACK_CAPACITY           (10)
#define MAX_SAMPAH                      (50)
#define FISH_ZONE                       (17)
#define MAX_FISH                        (10)
#define MAX_ENTRANCES                   (500)
#define MAX_SPEED_CAMERAS               (100)
#define MAX_GAS_PUMPS                   (100)
#define MAX_CRATES                      (200)
#define MAX_TEXTOBJECT                  (200)
#define MAX_PLANTS                      (5000)
#define MAX_BUSINESSES                  (500)
#define MAX_WEAPON_RACKS                (500)
#define PRISON_WORLD                    (1000)
#define MAX_BACKPACKS                   (2000)
#define MAX_DROPPED_ITEMS               (3000)
#define MAX_BACKPACK_ITEMS              (4000)
#define MAX_OWNABLE_CARS                (5)
#define MAX_OWNABLE_HOUSES              (1)
#define MAX_OWNABLE_BUSINESSES          (1)
#define MAX_OWNABLE_WORKSHOP            (1)
#define MAX_OWNABLE_FARM                (1)
#define MAX_OWNABLE_GARAGE              (1)

#define BODY_PART_TORSO                 (3)
#define BODY_PART_GROIN                 (4)
#define BODY_PART_RIGHT_ARM             (5)
#define BODY_PART_LEFT_ARM              (6)
#define BODY_PART_RIGHT_LEG             (7)
#define BODY_PART_LEFT_LEG              (8)
#define BODY_PART_HEAD                  (9)

#define STRUCTURE_SELECT_EDITOR         1
#define STRUCTURE_SELECT_DELETE	        2
#define STRUCTURE_SELECT_RETEXTURE	    3
#define STRUCTURE_SELECT_COPY						4

#define FURNITURE_SELECT_MOVE						1
#define FURNITURE_SELECT_DESTROY				2
#define FURNITURE_SELECT_STORE					3

// stock Float:cache_get_field_float(row, const field_name[]);

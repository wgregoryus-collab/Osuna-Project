/*	
	Script name: cargo-v2.pwn
	Modify date: 21 June 2018 - 16:35.
	Release by: Agus Syahputra

	NOTE:
	- 

*/

#include <YSI\y_hooks>

// --
// Definitions list
// --

#define  CARGO_MULTIPLY		2


// --
// Variable list
// --

static
	bool:cargo_holding[MAX_PLAYERS] = {false, ...},
	cargo_product[MAX_PLAYERS] = {0, ...},
	cargo_type[MAX_PLAYERS] = {0, ...};

// --
// Enum's list
// --

enum e_CargoData {
    Float:spot_x,
    Float:spot_y,
    Float:spot_z,
    spot_type
};

new const arrCargoSpot[][e_CargoData] = {
    {2354.2861, -2288.2808, 17.4219, 1},
	{2255.6082, -2387.6851, 17.4219, 3},
	{2615.5457, -2382.3250, 13.6250, 4},
	{2508.3826, -2205.7415, 13.5469, 6},
	{2490.9121, -2468.5664, 17.8828, 7},
	{2445.1274, -2548.2874, 17.9107, 8}
};

// --
// Function list
// --

SetPlayerCargoAnimation(playerid)
{
	if(IsPlayerAttachedObjectSlotUsed(playerid, JOB_SLOT))
		RemovePlayerAttachedObject(playerid, JOB_SLOT);

	SetPlayerAttachedObject(playerid, JOB_SLOT, 1271, 1,0.237980,0.473312,-0.066999, 1.099999,88.000007,-177.400085, 0.716000,0.572999,0.734000);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);

	ApplyAnimation(playerid, "CARRY", "liftup", 4.1, 0, 0, 0, 0, 0, 1);
	return 1;
}

GetPlayerCargoID(playerid) {
	for(new i = 0; i < sizeof(arrCargoSpot); i++) if(IsPlayerInRangeOfPoint(playerid, 3.0, arrCargoSpot[i][spot_x], arrCargoSpot[i][spot_y], arrCargoSpot[i][spot_z])) {
		printf("Near cargo spot: %d", i);
		return i;
	}
	return -1;
}

// --
// Command's list
// --

CMD:cargo(playerid, params[])
{
	static
		category[10],
		extend[24]
	;

	if(sscanf(params, "s[10]S()[24]", category, extend))
		return SendSyntaxMessage(playerid, "/cargo [buy]");

	if(!strcmp(category, "buy"))
	{
		static
			index = -1,
			product = 0
		;
		if(sscanf(extend, "d", extend))
			return SendSyntaxMessage(playerid, "/cargo buy [product] (price: "YELLOW"product"WHITE"*"GREEN"$2"WHITE")");

		if(extend < 0 || extend > 50)
			return SendErrorMessage(playerid, "Kamu hanya di batasi membeli 0 sampai 50 produk.");

		if((index = GetPlayerCargoID(playerid)) != -1)
		{
			if(cargo_holding[playerid])
				return SendErrorMessage(playerid, "Kamu sedang mengangkat cargo.");

			cargo_holding[playerid] = true;
			cargo_product[playerid]	= product;
			cargo_type[playerid] 	= arrCargoSpot[index][spot_type];

			GiveMoney(playerid, -(product*CARGO_MULTIPLY));

			SetPlayerCargoAnimation(playerid);
			SendServerMessage(playerid, "Kamu telah membeli %d produk dengan harga %s.", product, FormatNumber(product*CARGO_MULTIPLY));
			return 1;
		}
		SendErrorMessage(playerid, "Kamu tidak berada dilokasi pembelian cargo.");
	}
	return 1;
}

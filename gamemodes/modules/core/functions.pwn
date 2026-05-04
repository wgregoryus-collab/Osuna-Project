/*	Function List */
GetMonth(bulan)
{
    static
        month[12];

    switch (bulan) {
        case 1: month = "January";
        case 2: month = "February";
        case 3: month = "March";
        case 4: month = "April";
        case 5: month = "May";
        case 6: month = "June";
        case 7: month = "July";
        case 8: month = "August";
        case 9: month = "September";
        case 10: month = "October";
        case 11: month = "November";
        case 12: month = "December";
    }
    return month;
}

ReturnTime()
{
    static
        time[3],
        string[72];

    gettime(time[0], time[1], time[2]);

    format(string, sizeof(string), "%02d:%02d:%02d", time[0], time[1], time[2]);
    return string;
}

ReturnDate()
{
    static
        date[6],
        string[72];

    getdate(date[2], date[1], date[0]);
    gettime(date[3], date[4], date[5]);

    format(string, sizeof(string), "%02d %s %d, %02d:%02d:%02d", date[0],GetMonth(date[1]), date[2], date[3], date[4], date[5]);
    return string;
}

ReturnVehicleHealth(vehicleid)
{
    if(!IsValidVehicle(vehicleid))
        return 0;

    static
        Float:amount;

    GetVehicleHealth(vehicleid, amount);
    return floatround(amount, floatround_round);
}

ReturnArmour(playerid)
{
    static
        Float:amount;

    GetPlayerArmour(playerid, amount);
    return floatround(amount, floatround_round);
}

ReturnHealth(playerid)
{
    static
        Float:amount;

    GetPlayerHealth(playerid, amount);
    return floatround(amount, floatround_round);
}

Float:ReturnHealth2(playerid) {
    static
        Float:amount;

    GetPlayerHealth(playerid, amount);
    return amount;
}

Float:ReturnArmour2(playerid) {
    static
        Float:amount;

    GetPlayerArmour(playerid, amount);
    return amount;
}

ReturnName(playerid, underscore=1, mask = 0)
{
    new
        name[MAX_PLAYER_NAME + 1];

    GetPlayerName(playerid, name, sizeof(name));

    if(!underscore) {
        for (new i = 0, len = strlen(name); i < len; i ++) {
                if(name[i] == '_') name[i] = ' ';
        }
    }

    if(mask){
        if(PlayerData[playerid][pMaskOn] && !AccountData[playerid][pAdminDuty])
            format(name, sizeof(name), "Mask_#%d", PlayerData[playerid][pMaskID]);
    }
    return name;
}

ReturnName2(playerid, underscore=1)
{
    static
        name[MAX_PLAYER_NAME + 1];

    GetPlayerName(playerid, name, sizeof(name));

    if(!underscore) {
        for (new i = 0, len = strlen(name); i < len; i ++) {
            if(name[i] == '_') name[i] = ' ';
        }
    }
    return name;
}

ReturnIP(playerid)
{
    new ip[16];
    GetPlayerIp(playerid, ip, sizeof(ip));

    return ip;
}

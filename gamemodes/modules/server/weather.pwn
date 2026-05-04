#include <YSI\y_hooks>

new current_hour, current_weather;
new fine_weather_ids[] = {2,3,4,5,6,7,12,13,14,15,17};
new wet_weather_ids[] = {8};

hook OnGameModeInit() {
    gettime(current_hour, _);
    SetWorldTime(current_hour);
    return 1;
}


CMD:setweather(playerid, params[])
{
    new weatherid;

    if (CheckAdmin(playerid, 3))
        return PermissionError(playerid);

    if(sscanf(params, "d", weatherid))
        return SendSyntaxMessage(playerid, "/setweather [weather ID]");

    current_weather = weatherid;

    foreach(new x : Player) if (GetPlayerInterior(x) == 0) {
        SetPlayerWeather(x, current_weather);
    }
    SendRconCommand(sprintf("weather %d", current_weather));
    SendClientMessageToAllEx(X11_LIGHTBLUE, "WEATHER: "RED"%s "WHITE"has changed the weather ID to: "YELLOW"%d", AccountData[playerid][pAdmname], weatherid);
    return 1;
}

CMD:settime(playerid, params[])
{
    if (CheckAdmin(playerid, 3))
        return PermissionError(playerid);

	new times;
	if(sscanf(params, "d", times))
	{
		SendSyntaxMessage(playerid, "/settime [time ID]");
		return true;
	}
	foreach(new x : Player) {
        SetPlayerTime(x, times, 0);
    }
    SendRconCommand(sprintf("times %d", times));
    SendClientMessageToAllEx(X11_LIGHTBLUE, "TIME: "RED"%s "WHITE"has changed the time ID to: "YELLOW"%d", AccountData[playerid][pAdmname], times);
	return 1;
}

task UpdateWeatherAndTime[1000]() {
    new h, m, s;

    gettime(h, m, s);

    if (m == 0 && s == 0) {
        gettime(current_hour, _);

        new nextWeather = random(91);

        if (nextWeather < 70) current_weather = fine_weather_ids[random(sizeof(fine_weather_ids))];
        else current_weather = wet_weather_ids[0];

        foreach(new i : Player) if (GetPlayerInterior(i) == 0) {
            SetPlayerWeather(i, current_weather);
            SetPlayerTime(i, current_hour, 0);
        }
        SendRconCommand(sprintf("weather %d", current_weather));
        SendRconCommand(sprintf("worldtime %02d:00", current_hour));
    }
    return 1;
}

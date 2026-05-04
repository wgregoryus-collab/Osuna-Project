/*
    Script description.

    Module name: waypoint.pwn
    Made by: Agus Syahputra.
    Date: 02/02/18 - 18:01
*/
// ------------------------------------------------------------------------------
static 
    playerWaypoint[MAX_PLAYERS],
    waypointName[MAX_PLAYERS][24],
    Float:waypointLoc[MAX_PLAYERS][3],
    PlayerText:waypointTD[MAX_PLAYERS][2];

// ------------------------------------------------------------------------------
IsPlayerShowWaypoint(playerid) 
{
    if(!playerWaypoint[playerid]) return 0;
    return 1;
}

SetPlayerWaypoint(playerid, name[], Float:x, Float:y, Float:z)
{
    DisableWaypoint(playerid);
    format(waypointName[playerid], 24, name);

    playerWaypoint[playerid] = true;

    waypointLoc[playerid][0] = x;
    waypointLoc[playerid][1] = y;
    waypointLoc[playerid][2] = z;

    waypointTD[playerid][0] = waypointTD[playerid][1] = PlayerText:INVALID_TEXT_DRAW;

    waypointTD[playerid][0] = CreatePlayerTextDraw(playerid, 34.299453, 363.551025, "hud:radarRingPlane");
    PlayerTextDrawLetterSize(playerid, waypointTD[playerid][0], 0.000000, 0.000000);
    PlayerTextDrawTextSize(playerid, waypointTD[playerid][0], 105.000000, 59.000000);
    PlayerTextDrawAlignment(playerid, waypointTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, waypointTD[playerid][0], 127);
    PlayerTextDrawSetShadow(playerid, waypointTD[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, waypointTD[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, waypointTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, waypointTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, waypointTD[playerid][0], 0);
    PlayerTextDrawSetShadow(playerid, waypointTD[playerid][0], 0);

    waypointTD[playerid][1] = CreatePlayerTextDraw(playerid, 86.500000, 396.937500, "Tracking ...");
    PlayerTextDrawLetterSize(playerid, waypointTD[playerid][1], 0.140999, 0.847500);
    PlayerTextDrawAlignment(playerid, waypointTD[playerid][1], 2);
    PlayerTextDrawColor(playerid, waypointTD[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, waypointTD[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, waypointTD[playerid][1], 1);
    PlayerTextDrawBackgroundColor(playerid, waypointTD[playerid][1], 255);
    PlayerTextDrawFont(playerid, waypointTD[playerid][1], 1);
    PlayerTextDrawSetProportional(playerid, waypointTD[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, waypointTD[playerid][1], 0);

    PlayerTextDrawShow(playerid, waypointTD[playerid][0]);
    PlayerTextDrawShow(playerid, waypointTD[playerid][1]);

    SetPlayerRaceCheckpoint(playerid, 1, x, y, z, -1, -1, -1, 3);
    ShowPlayerFooter(playerid, "Type ~r~/disablecp ~w~to clear checkpoint.");
    return 1;
}

DisableWaypoint(playerid) 
{
    if(!IsPlayerShowWaypoint(playerid)) return 0;

    DisablePlayerRaceCheckpoint(playerid);

    PlayerTextDrawDestroy(playerid, waypointTD[playerid][0]);
    PlayerTextDrawDestroy(playerid, waypointTD[playerid][1]);

    playerWaypoint[playerid] = false;

    waypointTD[playerid][0] = waypointTD[playerid][1] = PlayerText:INVALID_TEXT_DRAW;
    return 1;
}

// ------------------------------------------------------------------------------
#include <YSI\y_hooks>
hook OnPlayerDisconnectEx(playerid)
{
    DisableWaypoint(playerid);
    return 1;
}


hook OnPlayerEnterRaceCP(playerid)
{
    if(IsPlayerShowWaypoint(playerid))
    {
        DisableWaypoint(playerid);
        GameTextForPlayer(playerid, "~b~~h~You are now arrived!", 1500, 3);
    }
    return 1;
}

// ------------------------------------------------------------------------------
ptask WaypointUpdate[1000](playerid)
{
    if(IsPlayerConnected(playerid) && IsPlayerShowWaypoint(playerid)) {
        PlayerTextDrawSetString(playerid, waypointTD[playerid][1], sprintf("%s~n~Distance: %.1fm", waypointName[playerid], GetPlayerDistanceFromPoint(playerid, waypointLoc[playerid][0], waypointLoc[playerid][1], waypointLoc[playerid][2])));
    }
}
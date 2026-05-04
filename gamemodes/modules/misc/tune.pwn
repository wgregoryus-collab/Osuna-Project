CMD:apaintjob(playerid, params[])
{
    CheckAdmin(playerid, 4);

    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) 
        return SendErrorMessage(playerid, "You need to be driver to use this command.");

    new modelid = GetVehicleModel(GetPlayerVehicleID(playerid));

    switch (modelid)
    {
        case 483: Dialog_Show(playerid, Paintjob, DIALOG_STYLE_LIST, "Available Paintjobs", "Paintjob ID: 0\nRemove Paintjob", "Select", "Cancel");
        case 575: Dialog_Show(playerid, Paintjob, DIALOG_STYLE_LIST, "Available Paintjobs", "Paintjob ID: 0\nPaintjob ID: 1\nRemove Paintjob", "Select", "Cancel");
        case 534 .. 536, 558 .. 562, 565, 567, 576: Dialog_Show(playerid, Paintjob, DIALOG_STYLE_LIST, "Available Paintjobs", "Paintjob ID: 0\nPaintjob ID: 1\nPaintjob ID: 2\nRemove Paintjob", "Select", "Cancel");
        default: SendErrorMessage(playerid, "This vehicle does not support any paintjob.");
    }
    return 1;
}

CMD:atune(playerid, params[])
{
    CheckAdmin(playerid, 4);

    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You need to be driver to use this command.");
    
    new modelid = GetVehicleModel(GetPlayerVehicleID(playerid));
    
    switch (modelid)
    {
        case 534 .. 536, 558 .. 562, 565, 567, 575, 576:
        {
            new Query[128];
            mysql_format(g_iHandle, Query, sizeof Query, "SELECT DISTINCT part FROM vehicle_components WHERE cars=%i OR cars=-1 ORDER BY CAST(part AS CHAR)", modelid);
            mysql_tquery(g_iHandle, Query, "OnTuneLoad", "ii", playerid, 0);
        }
        default:
        {
            static Query[352];
            
            mysql_format(g_iHandle, Query, sizeof Query,
            "SELECT " \
            "IF(parts & 1 <> 0,'Exhausts','')," \
            "IF(parts & 2 <> 0,'Hood','')," \
            "IF(parts & 256 <> 0,'Hydraulics','')," \
            "IF(parts & 4 <> 0,'Lamps','')," \
            "IF(parts & 8 <> 0,'Roof','')," \
            "IF(parts & 16 <> 0,'Side Skirts','')," \
            "IF(parts & 32 <> 0,'Spoilers','')," \
            "IF(parts & 64 <> 0,'Vents','')," \
            "IF(parts & 128 <> 0,'Wheels','') " \
            "FROM vehicle_model_parts WHERE modelid=%i", modelid);
            mysql_tquery(g_iHandle, Query, "OnTuneLoad", "ii", playerid, 1);
        }
    }
    return 1;
}

CMD:colorlist(playerid, params[])
{
    Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "Available Color List", color_string, "Close", "");
    return 1;
}

Dialog:Tune(playerid, response, listitem, inputtext[])
{
    if (response)
    {
        if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You need to be driver to tune a vehicle.");

        new modelid = GetVehicleModel(GetPlayerVehicleID(playerid));

        switch (modelid)
        {
            case 534 .. 536, 558 .. 562, 565, 567, 575, 576:
            {
                if (!strcmp(inputtext, "Wheels") || !strcmp(inputtext, "Hydraulics"))
                {
                    new Query[128];
		            
                    mysql_format(g_iHandle, Query, sizeof Query, "SELECT componentid,type FROM vehicle_components WHERE part='%e' ORDER BY type", inputtext);
                    mysql_tquery(g_iHandle, Query, "OnTuneLoad", "ii", playerid, 2);
                }
                else
                {
                    new Query[128];
		            
                    mysql_format(g_iHandle, Query, sizeof Query, "SELECT componentid,type FROM vehicle_components WHERE cars=%i AND part='%e' ORDER BY type", modelid, inputtext);
                    mysql_tquery(g_iHandle, Query, "OnTuneLoad", "ii", playerid, 2);
                }
            }
            default:
            {
                new Query[128];
		        
                mysql_format(g_iHandle, Query, sizeof Query, "SELECT componentid,type FROM vehicle_components WHERE cars<=0 AND part='%e' ORDER BY type", inputtext);
                mysql_tquery(g_iHandle, Query, "OnTuneLoad", "ii", playerid, 2);
            }
        }
    }
    return 1;
}

Dialog:TuneTwo(playerid, response, listitem, inputtext[])        
{
    if (!response) return cmd_atune(playerid, "");
    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You need to be driver to tune a vehicle.");

    new vehicleid = GetPlayerVehicleID(playerid), componentid;
    
    if (!sscanf(inputtext, "i", componentid)) AddComponent(vehicleid, componentid);
    else return RemoveVehicleComponent(vehicleid, 1087);
	
    // sideskirts and vents that have left and right side should be applied twice
    switch (componentid)
    {
        case 1007, 1027, 1030, 1039, 1040, 1051, 1052, 1062, 1063, 1071, 1072, 1094, 1099, 1101, 1102, 1107, 1120, 1121, 1124, 1137, 1142 .. 1145: AddComponent(vehicleid, componentid);
    }
    return 1;
}

Dialog:Paintjob(playerid, response, listitem, inputtext[])
{
    if (response)
    {
        if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You need to be driver to tune a vehicle.");

        new paintjobid;
	
        if (!sscanf(inputtext, "'Paintjob ID:'i", paintjobid)) SetVehiclePaintjob(GetPlayerVehicleID(playerid), paintjobid);
        else SetVehiclePaintjob(GetPlayerVehicleID(playerid), 3);
    }
    return 1;
}

//-----------------------------------------------------

forward OnTuneLoad(playerid, idx);
public OnTuneLoad(playerid, idx)
{
    switch (idx)
    {
        case 0:
        {
            new dialog_info[79], part_name[14];

            for (new i, j = cache_get_row_count(g_iHandle); i != j; i++)
            {
                cache_get_row(i, 0, part_name, g_iHandle);

                strcat(dialog_info, part_name);
                strcat(dialog_info, "\n");
            }
			Dialog_Show(playerid, Tune, DIALOG_STYLE_LIST, "Available Parts", dialog_info, "Select", "Cancle");
        }
        case 1:
        {
            new rows = cache_num_rows();
			
            if (rows)
            {
                new dialog_info[80], part_name[13];

                for (new i, j = cache_get_field_count(g_iHandle); i != j; i++)
                {
                    cache_get_row(0, i, part_name, g_iHandle);

                    if (!isnull(part_name))
                    {
                        strcat(dialog_info, part_name);
                        strcat(dialog_info, "\n");
                    }
                }
				
                Dialog_Show(playerid, Tune, DIALOG_STYLE_LIST, "Available Parts", dialog_info, "Select", "Cancle");
            }
            else SendErrorMessage(playerid, "You cannot tune this vehicle.");
        }
        case 2:
        {
            static dialog_info[716];
            new componentid, type[32];

            dialog_info = "{FF0000}Component ID\t{FF8000}Type\n";
	        
            for (new i, j = cache_get_row_count(g_iHandle); i != j; i++)
            {
                componentid = cache_get_row_int(i, 0, g_iHandle);
                cache_get_row(i, 1, type, g_iHandle);
                
                format(dialog_info, sizeof dialog_info, "%s%i\t%s\n", dialog_info, componentid, type);
            }
	        
            if (componentid == 1087) strcat(dialog_info, " ----\tRemove Hydraulics");
            
            Dialog_Show(playerid, TuneTwo, DIALOG_STYLE_TABLIST_HEADERS, "Available Parts", dialog_info, "Install", "Back");
        }
    }
}

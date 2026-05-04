#define MAX_TREE_FORAGER (200)

enum treeEnum {
    treeID,
    treeType,
    treeAmount,
    Float:treePos[3],
    Float:treeRot[3],
    treeObject
};
new TreeData[MAX_TREE_FORAGER][treeEnum],
    Iterator:TreeForager<MAX_TREE_FORAGER>;

new EditTreeForager[MAX_PLAYERS] = {-1, ...};

timer StartForaging[1000](playerid) 
{
    if (Bush_Nearest(playerid) == GetPVarInt(playerid,"nearTreeForager") && PlayerData[playerid][pForaging]) {
        new id = GetPVarInt(playerid,"nearTreeForager");

        if (++PlayerData[playerid][pForager] >= 10) {
            new rand = RandomEx(2, 10);

            if (TreeData[id][treeType] == 14469) Inventory_Add(playerid, "Orange", 19574, rand);
            else if (TreeData[id][treeType] == 14402) Inventory_Add(playerid, "Tomato", 19577, rand);

            TreeData[id][treeAmount] -= rand;
            if (TreeData[id][treeAmount] < 2) TreeData[id][treeAmount] = 1;
            Bush_Save(id);

            stop PlayerData[playerid][pForagerTimer];
            ClearAnimations(playerid, 1);
            DeletePVar(playerid, "nearTreeForager");
            PlayerData[playerid][pForager] = 0;
            PlayerData[playerid][pForaging] = 0;
            SendCustomMessage(playerid, "FORAGER","You've foraged "YELLOW"%d %s "WHITE"from this bush", rand, Bush_GetName(id));
        } else {
            ShowPlayerFooter(playerid, sprintf("~b~Picking %s~n~Waiting for picking progress for ~g~%d~b~/10 ...",Bush_GetName(id),PlayerData[playerid][pForager]), 1000);
        }
    } else {
        stop PlayerData[playerid][pForagerTimer];
        ClearAnimations(playerid, 1);
        DeletePVar(playerid, "nearTreeForager");
        PlayerData[playerid][pForager] = 0;
        PlayerData[playerid][pForaging] = 0;
        return 1;
    }
    return 1;
}

#include <YSI\y_hooks>
hook OnGameModeInitEx() {
    mysql_tquery(g_iHandle, "SELECT * FROM `bush_forager`", "Bush_Load", "");
    return 1;
}


hook OnGameModeExit() {
    foreach (new i : TreeForager) {
        Bush_Save(i);
    }
    return 1;
}


hook OnPlayerConnect(playerid) {
    EditTreeForager[playerid] = -1;
    return 1;
}


hook OnPlayerDisconnectEx(playerid) {
    EditTreeForager[playerid] = -1;
    return 1;
}


hook OnPlayerEditDynObj(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    if (EditTreeForager[playerid] != -1) {
        switch (response) {
            case EDIT_RESPONSE_CANCEL: {
                new id = EditTreeForager[playerid],Float:position[3],Float:rotation[3];

                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,TreeData[id][treeObject],E_STREAMER_X,position[0]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,TreeData[id][treeObject],E_STREAMER_Y,position[1]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,TreeData[id][treeObject],E_STREAMER_Z,position[2]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,TreeData[id][treeObject],E_STREAMER_R_X,rotation[0]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,TreeData[id][treeObject],E_STREAMER_R_Y,rotation[1]);
                Streamer_GetFloatData(STREAMER_TYPE_OBJECT,TreeData[id][treeObject],E_STREAMER_R_Z,rotation[2]);
                SetDynamicObjectPos(objectid,position[0],position[1],position[2]);
                SetDynamicObjectRot(objectid,rotation[0],rotation[1],rotation[2]);

                EditTreeForager[playerid] = -1;
                SendCustomMessage(playerid,"FORAGER","You've canceled editing bush.");
            }
            case EDIT_RESPONSE_FINAL: {
                new id = EditTreeForager[playerid];

                TreeData[id][treePos][0] = x;
                TreeData[id][treePos][1] = y;
                TreeData[id][treePos][2] = z;
                TreeData[id][treeRot][0] = rx;
                TreeData[id][treeRot][1] = ry;
                TreeData[id][treeRot][2] = rz;
                
                SetDynamicObjectPos(objectid,x,y,z);
                SetDynamicObjectRot(objectid,rx,ry,rz);
                Bush_Refresh(id);
                Bush_Save(id);

                EditTreeForager[playerid] = -1;
                SendCustomMessage(playerid,"FORAGER","Bush position has been saved.");
            }
        }
    }
    return 1;
}

Function:Bush_Load() {
    new rows = cache_num_rows(), str[65];

    for (new i = 0; i < rows; i ++) {
        Iter_Add(TreeForager, i);

        cache_get_value_int(i, "ID", TreeData[i][treeID]);
        cache_get_value_int(i, "Type", TreeData[i][treeType]);
        cache_get_value_int(i, "Amount", TreeData[i][treeAmount]);

        cache_get_value(i, "Position", str);
        sscanf(str, "p<|>fff", TreeData[i][treePos][0], TreeData[i][treePos][1], TreeData[i][treePos][2]);

        cache_get_value(i, "Rotation", str);
        sscanf(str, "p<|>fff", TreeData[i][treeRot][0], TreeData[i][treeRot][1], TreeData[i][treeRot][2]);

        Bush_Refresh(i);
    }
    printf("*** [GarudaPride Database: Loaded] bush forager data loaded (%d count)", rows);
    return 1;
}

Bush_Refresh(id) {
    if (!Iter_Contains(TreeForager, id))
        return 0;
    
    if (!IsValidDynamicObject(TreeData[id][treeObject]))
        TreeData[id][treeObject] = CreateDynamicObject(TreeData[id][treeType], TreeData[id][treePos][0], TreeData[id][treePos][1], TreeData[id][treePos][2], TreeData[id][treeRot][0], TreeData[id][treeRot][1], TreeData[id][treeRot][2], 0, 0);
    Bush_Update(id);
    return 1;
}

Bush_Update(id) {
    if (!Iter_Contains(TreeForager, id))
        return 0;

    if (IsValidDynamicObject(TreeData[id][treeObject])) {
        new objectid = TreeData[id][treeObject];

        Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_X, TreeData[id][treePos][0]);
        Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Y, TreeData[id][treePos][1]);
        Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Z, TreeData[id][treePos][2]);
        Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_X, TreeData[id][treeRot][0]);
        Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Y, TreeData[id][treeRot][1]);
        Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Z, TreeData[id][treeRot][2]);

        Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_WORLD_ID, 0);
        Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_INTERIOR_ID, 0);
    }
    return 1;
}

Bush_Create(type, Float:x, Float:y, Float:z, Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0) {
    new id = cellmin;

    if ((id = Iter_Free(TreeForager)) != cellmin) {
        Iter_Add(TreeForager, id);

        TreeData[id][treeType] = type;
        TreeData[id][treePos][0] = x;
        TreeData[id][treePos][1] = y;
        TreeData[id][treePos][2] = z;
        TreeData[id][treeRot][0] = rx;
        TreeData[id][treeRot][1] = ry;
        TreeData[id][treeRot][2] = rz;
        TreeData[id][treeAmount] = 100;
        Bush_Refresh(id);

        mysql_tquery(g_iHandle, sprintf("INSERT INTO `bush_forager` (`Type`) VALUES ('%d')",TreeData[id][treeType]), "OnTreeCreated", "d", id);

        return id;
    }
    return cellmin;
}

Function:OnTreeCreated(id) {
    if (!Iter_Contains(TreeForager, id))
        return 0;

    TreeData[id][treeID] = cache_insert_id();
    Bush_Save(id);
    return 1;
}

Bush_Delete(id) {
    if (!Iter_Contains(TreeForager, id))
        return 0;
    
    if (IsValidDynamicObject(TreeData[id][treeObject]))
        DestroyDynamicObject(TreeData[id][treeObject]);
    
    TreeData[id][treeObject] = INVALID_STREAMER_ID;
    TreeData[id][treePos][0] = TreeData[id][treePos][1] = TreeData[id][treePos][2] = 0.0;
    TreeData[id][treeRot][0] = TreeData[id][treeRot][1] = TreeData[id][treeRot][2] = 0.0;
    mysql_tquery(g_iHandle, sprintf("DELETE FROM `bush_forager` WHERE `ID` = '%d'",TreeData[id][treeID]));
    Iter_Remove(TreeForager, id);
    return 1;
}

Bush_Save(id) {
    if (!Iter_Contains(TreeForager, id))
        return 0;
    
    new query[256];
    mysql_format(g_iHandle, query, sizeof(query), "UPDATE `bush_forager` SET `Type`='%d', `Amount`='%d', `Position`='%.2f|%.2f|%.2f', `Rotation`='%.2f|%.2f|%.2f' WHERE `ID`='%d'",
    TreeData[id][treeType],
    TreeData[id][treeAmount],
    TreeData[id][treePos][0],
    TreeData[id][treePos][1],
    TreeData[id][treePos][2],
    TreeData[id][treeRot][0],
    TreeData[id][treeRot][1],
    TreeData[id][treeRot][2],
    TreeData[id][treeID]);
    return mysql_tquery(g_iHandle, query);
}

Bush_Nearest(playerid) {
    foreach (new id : TreeForager) if (IsPlayerInRangeOfPoint(playerid, 3.0, TreeData[id][treePos][0], TreeData[id][treePos][1], TreeData[id][treePos][2])) {
        if (GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0) return id;
    }
    return -1;
}

Bush_GetName(id) {
    new name[15];
    switch (TreeData[id][treeType]) {
        case 14469: format(name, sizeof(name), "Orange");
        case 14402: format(name, sizeof(name), "Tomato");
        default: format(name,sizeof(name),"Unknown");
    }
    return name;
}

CMD:aforager(playerid, params[]) {
    if (CheckAdmin(playerid, 7))
        return PermissionError(playerid);
    
    new option[24], value[32];
    if (sscanf(params,"s[24]S()[32]",option,value))
        return SendSyntaxMessage(playerid,"/aforager [option]"),SendClientMessage(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"create, delete, edit, amount, type, goto");
    
    new id;
    if (!strcmp(option,"create",true)) {
        new type[12], Float:pos[3];
        if (sscanf(value,"s[12]",type))
            return SendSyntaxMessage(playerid, "/aforager create [type]"),SendClientMessage(playerid,X11_YELLOW_2,"[TYPES]: "WHITE"orange, tomato");

        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
        
        if (!strcmp(type,"orange",true)) {
            id = Bush_Create(14469, pos[0], pos[1], pos[2]-0.5);

            if (id == cellmin)
                return SendErrorMessage(playerid, "Failed to create tree forager");
            
            SendCustomMessage(playerid,"FORAGER","You've created a orange tree forager ID: %d",id);
        } else if (!strcmp(type,"tomato",true)) {
            id = Bush_Create(14402, pos[0], pos[1], pos[2]-0.5);

            if (id == cellmin)
                return SendErrorMessage(playerid, "Failed to create tree forager");
            
            SendCustomMessage(playerid,"FORAGER","You've created a tomato tree forager ID: %d",id);
        } else return SendSyntaxMessage(playerid, "/aforager create [type]"),SendClientMessage(playerid,X11_YELLOW_2,"[TYPES]: "WHITE"orange, tomato");
    } else if (!strcmp(option,"delete",true)) {
        if (sscanf(value,"d",id))
            return SendSyntaxMessage(playerid,"/aforager delete [tree id]");
        
        if (!Iter_Contains(TreeForager, id))
            return SendErrorMessage(playerid, "Invalid tree id");
        
        Bush_Delete(id);
        SendCustomMessage(playerid,"FORAGER","You've deleted tree forager ID: %d",id);
    } else if (!strcmp(option,"edit",true)) {
        if (sscanf(value,"d",id))
            return SendSyntaxMessage(playerid,"/aforager edit [tree id]");
        
        if (!Iter_Contains(TreeForager, id))
            return SendErrorMessage(playerid, "Invalid tree id");

        EditTreeForager[playerid] = id;
        EditDynamicObject(playerid, TreeData[id][treeObject]);
        SendCustomMessage(playerid,"FORAGER","You're now editing tree forager ID: %d",id);
    } else if (!strcmp(option,"amount",true)) {
        new amount;
        if (sscanf(value,"dd",id,amount))
            return SendSyntaxMessage(playerid,"/aforager amount [tree id] [amount]");
        
        if (amount < 1)
            return SendErrorMessage(playerid, "Invalid amount");
        
        if (!Iter_Contains(TreeForager, id))
            return SendErrorMessage(playerid, "Invalid tree id");
        
        TreeData[id][treeAmount] = amount;
        Bush_Save(id);

        SendCustomMessage(playerid,"FORAGER","You've edited amount of tree forager ID: %d, to %d",id,amount);
    } else if (!strcmp(option,"type",true)) {
        new type[12];
        if (sscanf(value,"ds[12]",id,type))
            return SendSyntaxMessage(playerid,"/aforager type [tree id] [type]"),SendClientMessage(playerid,X11_YELLOW_2,"[TYPES]: "WHITE"orange, tomato");
        
        if (!Iter_Contains(TreeForager, id))
            return SendErrorMessage(playerid, "Invalid tree id");

        if (!strcmp(type,"orange",true)) {
            TreeData[id][treeType] = 14469;
            Bush_Refresh(id);
            Bush_Save(id);
            SendCustomMessage(playerid,"FORAGER","You've edited type of tree forager ID: %d, to orange",id);
        } else if (!strcmp(type,"tomato",true)) {
            TreeData[id][treeType] = 14402;
            Bush_Refresh(id);
            Bush_Save(id);
            SendCustomMessage(playerid,"FORAGER","You've edited type of tree forager ID: %d, to tomato",id);
        } else return SendSyntaxMessage(playerid, "/aforager type [tree id] [type]"),SendClientMessage(playerid,X11_YELLOW_2,"[TYPES]: "WHITE"orange, tomato");
    } else if (!strcmp(option,"goto",true)) {
        if (sscanf(value,"d",id))
            return SendSyntaxMessage(playerid,"/aforager goto [tree id]");
        
        if (!Iter_Contains(TreeForager, id))
            return SendErrorMessage(playerid, "Invalid tree id");
        
        SetPlayerPos(playerid,TreeData[id][treePos][0],TreeData[id][treePos][1],TreeData[id][treePos][2]+0.5);
        SendCustomMessage(playerid,"FORAGER","You've teleported to tree forager ID: %d",id);
    } else SendSyntaxMessage(playerid,"/aforager [option]"),SendClientMessage(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"create, delete, edit, amount, type");
    return 1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if((newkeys & KEY_WALK) && !(oldkeys & KEY_WALK) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
        new id = -1;
        if ((id = Bush_Nearest(playerid)) != -1) {
            if(PlayerData[playerid][pDelayForager])
                return SendErrorMessage(playerid, "You must wait for %d minute(s)", (PlayerData[playerid][pDelayForager]/60));

            if (TreeData[id][treeAmount] < 2)
                return SendErrorMessage(playerid, "There are no %s left to forage", Bush_GetName(id));
            
            if (Inventory_Count(playerid, Bush_GetName(id)) >= Inventory_MaxCount(Bush_GetName(id)))
                return SendErrorMessage(playerid, "You can't carry any more %s", Bush_GetName(id));
            
            if (PlayerData[playerid][pForaging])
                return SendErrorMessage(playerid, "You're being foraging");

            SetPVarInt(playerid, "nearTreeForager", id);
            ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 1, 0, 0, 1, 0, 1);
            PlayerData[playerid][pForager] = 0;
            PlayerData[playerid][pForaging] = 1;
            PlayerData[playerid][pForagerTimer] = repeat StartForaging(playerid);
        }
    }
    return 1;
}


hook OnPlayerUpdate(playerid) {
    new id = -1;
    if ((id = Bush_Nearest(playerid)) != -1) {
        if (TreeData[id][treeAmount] < 2)
            GameTextForPlayer(playerid, sprintf("~y~%s Bush~n~~r~There are no %s left in this bush",Bush_GetName(id),Bush_GetName(id)), 1000, 4);
        else
            GameTextForPlayer(playerid, sprintf("~y~%s Bush~n~~w~Press key '~r~ALT~w~' to forage this bush",Bush_GetName(id)), 1000, 4);
    }
    return 1;
}

task BushUpdate[600000]() 
{
    foreach (new id : TreeForager) if (TreeData[id][treeAmount] < 100) {
        TreeData[id][treeAmount] += 10;
        if (TreeData[id][treeAmount] > 100) TreeData[id][treeAmount] = 100;
    }
    return 1;
}

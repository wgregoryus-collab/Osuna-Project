#define MAX_EDITING_OBJECT		500
#define MAX_OBJECT_MATERIAL_SLOT	10

#define MATERIAL_TYPE_NONE		0
#define MATERIAL_TYPE_TEXTURE	1
#define MATERIAL_TYPE_MESSAGE	2

#define OBJECT_SELECT_EDITOR	1
#define OBJECT_SELECT_DELETE	2
#define OBJECT_SELECT_PAINT		3
#define OBJECT_SELECT_CLEAN		4

new Iterator:DynamicObjects<MAX_EDITING_OBJECT>;
new DynamicObject[MAX_EDITING_OBJECT];
new ObjectEditor[MAX_EDITING_OBJECT];
new DynamicObjectMaterial[MAX_EDITING_OBJECT][MAX_OBJECT_MATERIAL_SLOT];
new DynamicObjectPriority[MAX_EDITING_OBJECT];
new SelectObjectType[MAX_PLAYERS];

new const WinFonts[15][20] = {
{"Arial"},
{"Calibri"},
{"Comic Sans MS"},
{"Georgia"},
{"Times New Roman"},
{"Consolas"},
{"Constantia"},
{"Corbel"},
{"Courier New"},
{"Impact"},
{"Lucida Console"},
{"Palatino Linotype"},
{"Tahoma"},
{"Trebuchet MS"},
{"Verdana"}
};

GetXYLeftOfPoint(Float:x,Float:y,&Float:x2,&Float:y2,Float:A,Float:distance)
{
	x2 = x - (distance * floatsin(-A-90.0,degrees));
	y2 = y - (distance * floatcos(-A-90.0,degrees));
}
GetXYRightOfPoint(Float:x,Float:y,&Float:x2,&Float:y2,Float:A,Float:distance)
{
	x2 = x - (distance * floatsin(-A+90.0,degrees));
	y2 = y - (distance * floatcos(-A+90.0,degrees));
}
GetXYInFrontOfPoint(Float:x,Float:y,&Float:x2,&Float:y2,Float:A,Float:distance)
{
	x2 = x + (distance * floatsin(-A,degrees));
	y2 = y + (distance * floatcos(-A,degrees));
}
GetXYBehindPoint(Float:x,Float:y,&Float:x2,&Float:y2,Float:A,Float:distance)
{
	x2 = x - (distance * floatsin(-A,degrees));
	y2 = y - (distance * floatcos(-A,degrees));
}
MoveDynamicObjectEx(objectid,Float:x,Float:y,Float:z,Float:speed)
{
	if(IsDynamicObjectMoving(objectid)) StopDynamicObject(objectid);
	return MoveDynamicObject(objectid,x,y,z,speed);
}

#include <YSI\y_hooks>
hook OnGameModeExit()
{
	foreach(new slot : DynamicObjects)
	{
	    DestroyDynamicObject(DynamicObject[slot]);
	}
	Iter_Clear(DynamicObjects);
	return 1;
}


hook OnPlayerDisconnectEx(playerid)
{
	if(GetPVarType(playerid,"EditingObject") > 0)
	{
	    new slot = GetPVarInt(playerid,"EditingObject");
		DeletePVar(playerid,"EditingObject");
	    ObjectEditor[slot] = INVALID_PLAYER_ID;
	}
	return 1;
}

public OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z)
{
    new string[144];
	foreach(new slot : DynamicObjects)
	{
	    if(DynamicObject[slot] == objectid)
	    {
	    	if(SelectObjectType[playerid] == OBJECT_SELECT_EDITOR)
	    	{
	    		if((ObjectEditor[slot] != INVALID_PLAYER_ID) && (GetPVarInt(ObjectEditor[slot],"EditingObject") == slot))
		        {
		            new playername[MAX_PLAYER_NAME];
		            GetPlayerName(ObjectEditor[slot],playername,sizeof(playername));
					return SendErrorMessage(playerid,""RED"%s "GRAY"is currently editing this object!",playername);
		        }
		        format(string,sizeof(string),"<OBJECT> : "WHITE"Selected object with "YELLOW"id %d",slot);
				ObjectEditor[slot] = playerid;
		        SetPVarInt(playerid,"EditingObject",slot);
		    	EditDynamicObject(playerid,objectid);
		    	SendClientMessage(playerid,X11_LIGHTBLUE,string);
	    	}
	    	else if(SelectObjectType[playerid] == OBJECT_SELECT_DELETE)
	    	{
	    		new next;
		        if(ObjectEditor[slot] != INVALID_PLAYER_ID)
                {
                    new editor = ObjectEditor[slot];
					if(GetPVarInt(editor,"EditingObject") == slot)
					{
						new playername[MAX_PLAYER_NAME];
			            GetPlayerName(ObjectEditor[slot],playername,sizeof(playername));
						return SendErrorMessage(playerid,""RED"%s "GRAY"is currently editing this object!",playername);
					}
                }
                DestroyDynamicObject(DynamicObject[slot]);
				Loop(i,MAX_OBJECT_MATERIAL_SLOT)
				{
					DynamicObjectMaterial[slot][i] = MATERIAL_TYPE_NONE;
				}
				Iter_SafeRemove(DynamicObjects,slot,next);
                format(string,sizeof(string),"<OBJECT> : Object with ID %d has been deleted, total object: %d",slot,Iter_Count(DynamicObjects));
                slot = next;
                SendClientMessage(playerid,X11_YELLOW,string);
	    	}
	    	else if(SelectObjectType[playerid] == OBJECT_SELECT_PAINT)
	    	{
	    		new index,model,txdname[32],texture[32],color;
		        GetPVarString(playerid,"PaintParam",string,sizeof(string));
		        unformat(string,"p<|>dds[32]s[32]d",index,model,txdname,texture,color);
		        SetDynamicObjectMaterial(DynamicObject[slot],index,model,txdname,texture,color);
				DynamicObjectMaterial[slot][index] = MATERIAL_TYPE_TEXTURE;
		        break;
	    	}
	    	else if(SelectObjectType[playerid] == OBJECT_SELECT_CLEAN)
	    	{
	    		new model,Float:oPos[3],Float:oRot[3];
				model = Streamer_GetIntData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_MODEL_ID);
				Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_X,oPos[0]);
				Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Y,oPos[1]);
				Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Z,oPos[2]);
				Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_X,oRot[0]);
				Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_Y,oRot[1]);
				Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_Z,oRot[2]);
                DestroyDynamicObject(DynamicObject[slot]);
				Loop(index,MAX_OBJECT_MATERIAL_SLOT)
				{
					DynamicObjectMaterial[slot][index] = MATERIAL_TYPE_NONE;
				}
				DynamicObject[slot] = CreateDynamicObject(model,oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2]);
				Streamer_Update(playerid);
				break;
	    	}
	        break;
	    }
	}
	return 1;
}

SSCANF:objectmenu(string[])
{
	if(!strcmp(string,"create",true)) return 1;
	else if(!strcmp(string,"add",true)) return 1;
	else if(!strcmp(string,"delete",true)) return 2;
	else if(!strcmp(string,"destroy",true)) return 2;
	else if(!strcmp(string,"remove",true)) return 2;
	else if(!strcmp(string,"clear",true)) return 3;
	else if(!strcmp(string,"reset",true)) return 3;
	else if(!strcmp(string,"copy",true)) return 4;
	else if(!strcmp(string,"duplicate",true)) return 4;
	else if(!strcmp(string,"move",true)) return 5;
	else if(!strcmp(string,"rot",true)) return 6;
	else if(!strcmp(string,"rotate",true)) return 6;
	else if(!strcmp(string,"select",true)) return 7;
	else if(!strcmp(string,"control",true)) return 7;
	else if(!strcmp(string,"tele",true)) return 10;
	else if(!strcmp(string,"goto",true)) return 10;
	else if(!strcmp(string,"mgethere",true)) return 11;
	else if(!strcmp(string,"mmove",true)) return 12;
	else if(!strcmp(string,"export",true)) return 13;
	else if(!strcmp(string,"model",true)) return 14;
	else if(!strcmp(string,"attach",true)) return 15;
	else if(!strcmp(string,"gethere",true)) return 16;
	else if(!strcmp(string,"material",true)) return 18;
	else if(!strcmp(string,"import",true)) return 19;
	else if(!strcmp(string,"textprop",true)) return 20;
	else if(!strcmp(string,"resetmaterial",true)) return 21;
	else if(!strcmp(string,"clearmaterial",true))	return 21;
	else if(!strcmp(string,"deletemode",true)) return 22;
	else if(!strcmp(string,"rdelete",true)) return 23;
	else if(!strcmp(string,"rremove",true)) return 23;
	else if(!strcmp(string,"rdestroy",true)) return 23;
	else if(!strcmp(string,"paintbrush",true)) return 24;
	else if(!strcmp(string,"cleanbrush",true)) return 25;
	else if(!strcmp(string,"setpriority",true)) return 26;
	else if(!strcmp(string,"priority",true)) return 26;
	return 0;
}

SSCANF:colour(string[])
{
	new color = 0;
	new red,green,blue,alpha;
	if(!sscanf(string,"dddD(255)",red,green,blue,alpha))
	{
		color = RGBAToInt(red,green,blue,alpha);
	}
	else
	{
		color = GetColour(string,0xFF);
	}
	return color;
}

CMD:object(playerid,params[])
{
    if (CheckAdmin(playerid, 6))
        return PermissionError(playerid);

	new string[256],item,subparam[96];
	sscanf(params,"K<objectmenu>(0)S()[96]",item,subparam);
	switch(item)
	{
		case 1:
		{
			if(!isnull(subparam))
			{
				new model = strval(subparam);
				new slot = Iter_Free(DynamicObjects);
				if(slot != cellmin)
				{
					new Float:oPos[3];
					GetPlayerPos(playerid,oPos[0],oPos[1],oPos[2]);
					DynamicObject[slot] = CreateDynamicObject(model,oPos[0],oPos[1],oPos[2],0.0,0.0,0.0);
					DynamicObjectPriority[slot] = 0;
					ObjectEditor[slot] = INVALID_PLAYER_ID;
					Iter_Add(DynamicObjects,slot);
					Streamer_Update(playerid);
					format(string,144,"<OBJECT> : "WHITE"Object created with "YELLOW"ID %d"WHITE", total objects: "GREEN"%d",slot,Iter_Count(DynamicObjects));
					SendClientMessage(playerid,X11_LIGHTBLUE,string);
				}
				else SendErrorMessage(playerid,"Full slot!");
			}
			else SendSyntaxMessage(playerid,"/object create [object model id]");
		}
		case 2:
		{
			if(!isnull(subparam))
			{
				new slot = strval(subparam);
				if(Iter_Contains(DynamicObjects,slot))
				{
					Iter_Remove(DynamicObjects,slot);
					DestroyDynamicObject(DynamicObject[slot]);
					Loop(i,MAX_OBJECT_MATERIAL_SLOT)
					{
						DynamicObjectMaterial[slot][i] = MATERIAL_TYPE_NONE;
					}
					format(string,144,"<OBJECT> : "WHITE"Object with "YELLOW"ID %d "WHITE"has been deleted, total objects: "GREEN"%d",slot,Iter_Count(DynamicObjects));
					SendClientMessage(playerid,X11_LIGHTBLUE,string);
				}
				else SendErrorMessage(playerid,"Invalid objectid!");
			}
			else SendSyntaxMessage(playerid,"/object delete [object id]");
		}
		case 3:
		{
			if((!isnull(subparam)) && (!strcmp(subparam,"confirm",true)))
			{
				foreach(new slot : DynamicObjects)
				{
					DestroyDynamicObject(DynamicObject[slot]);
					Loop(i,MAX_OBJECT_MATERIAL_SLOT)
					{
						DynamicObjectMaterial[slot][i] = MATERIAL_TYPE_NONE;
					}
				}
				format(string,144,"<OBJECT> : "YELLOW"%d objects "WHITE"have been cleared",Iter_Count(DynamicObjects));
				Iter_Clear(DynamicObjects);
				SendClientMessage(playerid,X11_LIGHTBLUE,string);
			}
			else SendErrorMessage(playerid,"WARNING: Are you sure you want to clear all the objects ? (/object clear confirm)");
		}
		case 4:
		{
			if(!isnull(subparam))
			{
				new slot = strval(subparam);
				if(Iter_Contains(DynamicObjects,slot))
				{
					new slot2 = Iter_Free(DynamicObjects);
					if(slot2 != cellmin)
					{
						new model,Float:oPos[3],Float:oRot[3];
						model = Streamer_GetIntData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_MODEL_ID);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_X,oPos[0]);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Y,oPos[1]);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Z,oPos[2]);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_X,oRot[0]);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_Y,oRot[1]);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_Z,oRot[2]);
						DynamicObject[slot2] = CreateDynamicObject(model,oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2]);
						DynamicObjectPriority[slot2] = 0;
						Iter_Add(DynamicObjects,slot2);
						Loop(index,MAX_OBJECT_MATERIAL_SLOT)
						{
							if(DynamicObjectMaterial[slot][index] == MATERIAL_TYPE_TEXTURE)
							{
								new modelid,txdname[32],texturename[32],color;
								GetDynamicObjectMaterial(DynamicObject[slot],index,modelid,txdname,texturename,color);
								SetDynamicObjectMaterial(DynamicObject[slot2],index,modelid,txdname,texturename,color);
								DynamicObjectMaterial[slot2][index] = MATERIAL_TYPE_TEXTURE;
							}
							else if(DynamicObjectMaterial[slot][index] == MATERIAL_TYPE_MESSAGE)
							{
								new text[128],resolution,font[20],size,bold,fcolor,bcolor,alignment;
								GetDynamicObjectMaterialText(DynamicObject[slot],index,text,resolution,font,size,bold,fcolor,bcolor,alignment);
								SetDynamicObjectMaterialText(DynamicObject[slot2],index,text,resolution,font,size,bold,fcolor,bcolor,alignment);
								DynamicObjectMaterial[slot2][index] = MATERIAL_TYPE_MESSAGE;
							}
						}
						ObjectEditor[slot2] = INVALID_PLAYER_ID;
						Streamer_Update(playerid);
						format(string,144,"<OBJECT> : "WHITE"Duplicated object with "YELLOW"ID %d "WHITE" to "YELLOW"ID %d"WHITE", total objects: "GREEN"%d",slot,slot2,Iter_Count(DynamicObjects));
						SendClientMessage(playerid,X11_LIGHTBLUE,string);
					}
					else SendErrorMessage(playerid,"Full slot!");
				}
				else SendErrorMessage(playerid,"Invalid objectid!");
			}
			else SendSyntaxMessage(playerid,"/object copy [object id]");
		}
		case 5:
		{
			new slot,direction,Float:amount,Float:speed;
			if(!sscanf(subparam,"dcfF(5.0)",slot,direction,amount,speed))
			{
				if(floatround(speed) <= 0) return SendErrorMessage(playerid,"Speed cannot go below 1!");
				if(Iter_Contains(DynamicObjects,slot))
				{
					new Float:oPos[4];
					GetDynamicObjectPos(DynamicObject[slot],oPos[0],oPos[1],oPos[2]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_Z,oPos[3]);
					switch(direction)
					{
						case 'N','n': oPos[1] += amount;
						case 'S','s': oPos[1] -= amount;
						case 'E','e': oPos[0] += amount;
						case 'W','w': oPos[0] -= amount;
						case 'U','u': oPos[2] += amount;
						case 'D','d': oPos[2] -= amount;
						case 'L','l': GetXYLeftOfPoint(oPos[0],oPos[1],oPos[0],oPos[1],oPos[3],amount);
						case 'R','r': GetXYRightOfPoint(oPos[0],oPos[1],oPos[0],oPos[1],oPos[3],amount);
						case 'F','f': GetXYInFrontOfPoint(oPos[0],oPos[1],oPos[0],oPos[1],oPos[3],amount);
						case 'B','b': GetXYBehindPoint(oPos[0],oPos[1],oPos[0],oPos[1],oPos[3],amount);
						default: return SendErrorMessage(playerid,"Invalid direction!");
					}
					MoveDynamicObjectEx(DynamicObject[slot],oPos[0],oPos[1],oPos[2],speed);
				}
				else SendErrorMessage(playerid,"Invalid objectid!");
			}
			else SendSyntaxMessage(playerid,"/object move [object id] [directoion (N/S/E/W/U(p)/D(own))] [amount] [opt:speed = 5.0]");
		}
		case 6:
		{
			new slot,Float:oRot[3];
			if(!sscanf(subparam,"dfff",slot,oRot[0],oRot[1],oRot[2]))
			{
				if(Iter_Contains(DynamicObjects,slot))
				{
					SetDynamicObjectRot(DynamicObject[slot],oRot[0],oRot[1],oRot[2]);
				}
			}
			else SendSyntaxMessage(playerid,"/object rotate [object id] [rotation X] [rotation Y] [rotation Z]");
		}
		case 7:
		{
			if(GetPVarType(playerid,"EditingObject") > 0) return SendErrorMessage(playerid,"You must first release your current object!");
			if(!isnull(subparam))
			{
				new slot = strval(subparam);
				if(Iter_Contains(DynamicObjects,slot))
				{
					if(ObjectEditor[slot] != INVALID_PLAYER_ID)
					{
						new editor = ObjectEditor[slot];
						if(GetPVarType(editor,"EditingObject") == slot)
						{
							return SendErrorMessage(playerid,"%s is currently editing this object!",ReturnPlayerName(editor));
						}
					}
					format(string,sizeof(string),"<OBJECT> : "WHITE"Selected object "YELLOW"id %d",slot);
					ObjectEditor[slot] = playerid;
					SetPVarInt(playerid,"EditingObject",slot);
					EditDynamicObject(playerid,DynamicObject[slot]);
					SendClientMessage(playerid,X11_LIGHTBLUE,string);
				}
				else SendErrorMessage(playerid,"Invalid object id!");
			}
			else 
			{
				SelectObjectType[playerid] = OBJECT_SELECT_EDITOR;
				SelectObject(playerid);
			}
		}
		case 10:
		{
			if(!isnull(subparam))
			{
				new slot = strval(subparam);
				if(Iter_Contains(DynamicObjects,slot))
				{
					new Float:oPos[3];
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_X,oPos[0]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Y,oPos[1]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Z,oPos[2]);
					SetPlayerPos(playerid,oPos[0],oPos[1],oPos[2]);
					format(string,144,"<OBJECT> : "WHITE"Teleported to object "YELLOW"id %d",slot);
					SendClientMessage(playerid,X11_LIGHTBLUE,string);
				}
			}
		}
		case 11:
		{
			if((!isnull(subparam)) && (!strcmp(subparam,"confirm",true)))
			{
				new Float:myPos[3],Float:Pos1[3],Float:Pos2[3],Float:newPos[3];
				GetPlayerPos(playerid,myPos[0],myPos[1],myPos[2]);
				foreach(new slot : DynamicObjects)
				{
					if(slot == 0)
					{
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_X,Pos1[0]);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Y,Pos1[1]);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Z,Pos1[2]);
						SetDynamicObjectPos(DynamicObject[slot],myPos[0],myPos[1],myPos[2]);
					}
					else
					{
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_X,Pos2[0]);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Y,Pos2[1]);
						Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Z,Pos2[2]);
						newPos[0] = (myPos[0]+(Pos2[0]-Pos1[0]));
						newPos[1] = (myPos[1]+(Pos2[1]-Pos1[1]));
						newPos[2] = (myPos[2]+(Pos2[2]-Pos1[2]));
						SetDynamicObjectPos(DynamicObject[slot],newPos[0],newPos[1],newPos[2]);
					}
				}
				format(string,144,"<OBJECT> : "YELLOW"%d objects "WHITE"has been teleported to your location!",Iter_Count(DynamicObjects));
				SendClientMessage(playerid,X11_LIGHTBLUE,string);
			}
			else SendErrorMessage(playerid,"WARNING: Are you sure you want to teleport all the objects to your location ? (/object mgethere confirm)");
		}
		case 12:
		{
			new direction,Float:amount,Float:speed;
			if(!sscanf(subparam,"cfF(5.0)",direction,amount,speed))
			{
				if(floatround(speed) <= 0) return SendErrorMessage(playerid,"Speed cannot go below 1!");
				foreach(new slot : DynamicObjects)
				{
					new Float:oPos[3];
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_X,oPos[0]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Y,oPos[1]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Z,oPos[2]);
					switch(direction)
					{
						case 'N','n': oPos[1] += amount;
						case 'S','s': oPos[1] -= amount;
						case 'E','e': oPos[0] += amount;
						case 'W','w': oPos[0] -= amount;
						case 'U','u': oPos[2] += amount;
						case 'D','d': oPos[2] -= amount;
						default: return SendErrorMessage(playerid,"Invalid direction!");
					}
					MoveDynamicObjectEx(DynamicObject[slot],oPos[0],oPos[1],oPos[2],speed);
				}
				format(string,144,"<OBJECT> : "YELLOW"%d objects "WHITE"have been moved",Iter_Count(DynamicObjects));
				SendClientMessage(playerid,X11_LIGHTBLUE,string);
			}
			else SendSyntaxMessage(playerid,"/object mmove [directoion (N/S/E/W/U(p)/D(own))] [amount] [opt:speed = 5.0]");
		}
		case 13:
		{
			if(!isnull(subparam))
			{
				new name[64];
				format(name,sizeof(name),"objects/output/%s",subparam);
				if(Iter_Count(DynamicObjects) != 0)
				{
					new File:hFile = fopen(name,io_write);
					new model,Float:oPos[3],Float:oRot[3];
					foreach(new slot : DynamicObjects)
					{
						model = Streamer_GetIntData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_MODEL_ID);
						if(Streamer_GetIntData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_ATTACHED_VEHICLE) != INVALID_VEHICLE_ID)
						{
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_ATTACH_OFFSET_X,oPos[0]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_ATTACH_OFFSET_Y,oPos[1]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_ATTACH_OFFSET_Z,oPos[2]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_ATTACH_R_X,oRot[0]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_ATTACH_R_Y,oRot[1]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_ATTACH_R_Z,oRot[2]);
							format(string,sizeof(string),"AttachObjectToVehicle(%d,vehicleid,%f,%f,%f,%f,%f,%f);\r\n",model,oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2]);
						}
						else
						{
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_X,oPos[0]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Y,oPos[1]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Z,oPos[2]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_X,oRot[0]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_Y,oRot[1]);
							Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_Z,oRot[2]);
							format(string,sizeof(string),"CreateObject(%d,%f,%f,%f,%f,%f,%f);\r\n",model,oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2]);
						}
						fwrite(hFile,string);
					}
					fclose(hFile);
					format(string,144,"<OBJECT> : "YELLOW"%d objects "WHITE"saved to file "GREEN"%s",Iter_Count(DynamicObjects),name);
					SendClientMessage(playerid,X11_LIGHTBLUE,string);
				}
			}
            else SendSyntaxMessage(playerid, "/object export [name]");
		}
		case 14:
		{
			new slot,newmodel;
			if(!sscanf(subparam,"dd",slot,newmodel))
			{
				if(Iter_Contains(DynamicObjects,slot))
				{
					Streamer_SetIntData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_MODEL_ID,newmodel);
					Streamer_Update(playerid);
				}
				else SendErrorMessage(playerid,"Invalid object slot!");
			}
			else SendSyntaxMessage(playerid,"/object model [object id] [object model]");
		}
		case 15:
		{
			new slot,vid,Float:offsetx,Float:offsety,Float:offsetz,Float:rotX,Float:rotY,Float:rotZ;
			if(!sscanf(subparam,"ddF(0.0)F(0.0)F(0.0)F(0.0)F(0.0)F(0.0)",slot,vid,offsetx,offsety,offsetz,rotX,rotY,rotZ))
			{
				if(Iter_Contains(DynamicObjects,slot))
				{
					if(GetVehicleModel(vid) > 0)
					{
						AttachDynamicObjectToVehicle(DynamicObject[slot],vid,offsetx,offsety,offsetz,rotX,rotY,rotZ);
					}
					else
					{
						Streamer_SetIntData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_ATTACHED_VEHICLE,INVALID_VEHICLE_ID);
					}
				}
				else SendErrorMessage(playerid,"Invalid object slot!");
			}
			else SendSyntaxMessage(playerid,"/object attach [object id] [offset X] [offset Y] [offset Z] [rotation X] [rotation Y] [rotation Z]");
		}
		case 16:
		{
			if(!isnull(subparam))
			{
				new slot = strval(subparam);
				if(Iter_Contains(DynamicObjects,slot))
				{
					new Float:oPos[3];
					GetPlayerPos(playerid,oPos[0],oPos[1],oPos[2]);
					SetDynamicObjectPos(DynamicObject[slot],oPos[0],oPos[1],oPos[2]);
					format(string,144,"<OBJECT> : Teleported object id %d to your location!",slot);
					SendClientMessage(playerid,X11_YELLOW,string);
				}
			}
            else SendSyntaxMessage(playerid, "/object gethere [object id]");
		}
		case 18:
		{
			new slot,index,model,txdname[32],texture[32],color[4];
			if(!sscanf(subparam,"ddds[32]s[32]D(0)D(0)D(0)D(0)",slot,index,model,txdname,texture,color[0],color[1],color[2],color[3]))
			{
				if((index >= MAX_OBJECT_MATERIAL_SLOT) || (index < 0)) return SendErrorMessage(playerid,"index cannot go below 0 or over 9!");
				if(Iter_Contains(DynamicObjects,slot))
				{
					if(model == 0)
					{
						model = Streamer_GetIntData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_MODEL_ID);
					}
					SetDynamicObjectMaterial(DynamicObject[slot],index,model,txdname,texture,RGBAToInt(color[0],color[1],color[2],color[3]));
					DynamicObjectMaterial[slot][index] = MATERIAL_TYPE_TEXTURE;
				}
				else SendErrorMessage(playerid,"Invalid object slot!");
			}
			else SendSyntaxMessage(playerid,"/object material [object id] [index] [model] [txdname] [texture] [opt: alpha] [opt: red]  [opt: green]  [opt: blue]");
		}
		case 19:
		{
			new name[32],confirm[10];
			if(!sscanf(subparam,"s[32]S()[10]",name,confirm))
			{   
				if(isnull(confirm)) return SendErrorMessage(playerid,"WARNING: Are you sure you wanto to import this map ? (/object import [name] confirm)");
				if(Iter_Count(DynamicObjects) == 0)
				{
					new dir[64],model,Float:oPos[3],Float:oRot[3],loaded;
					format(dir,sizeof(dir),"objects/mta/%s.map",name);
					if(fexist(dir))
					{
						new File:hFile = fopen(dir,io_read);
						while(fread(hFile,string,sizeof(string)) > 0)
						{
							if(!sscanf(string,"p<\">'object''model='d'posX='f'posY='f'posZ='f'rotX='f'rotY='f'rotZ='f",model,oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2])) // "
							{
								new slot = Iter_Free(DynamicObjects);
								if(slot == cellmin) break;
								Iter_Add(DynamicObjects,slot);
								DynamicObject[slot] = CreateDynamicObject(model,oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2]);
								ObjectEditor[slot] = INVALID_PLAYER_ID;
								loaded++;
							}
						}
						fclose(hFile);
					}
					else
					{
						format(dir,sizeof(dir),"objects/samp/%s.pwn",name);
						if(fexist(dir))
						{
							new File:hFile = fopen(dir,io_read);
							new pos1,pos2,lastSlot;
							while(fread(hFile,string,sizeof(string)) > 0)
							{
								pos1 = strfind(string,"(",false);
								pos2 = strfind(string,")",false);
								if((pos1 != -1) && (pos2 != -1))
								{
									if((strfind(string,"CreateObject",false) != -1) || (strfind(string,"CreateDynamicObject",false) != -1))
									{
										strmid(string,string,(pos1+1),pos2,sizeof(string));
										if(!unformat(string,"p<,>dffffff",model,oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2]))
										{
											new slot = lastSlot = Iter_Free(DynamicObjects);
											if(slot == cellmin) break;
											Iter_Add(DynamicObjects,slot);
											DynamicObject[slot] = CreateDynamicObject(model,oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2]);
											ObjectEditor[slot] = INVALID_PLAYER_ID;
											loaded++;
										}
									}
									else if((strfind(string,"SetObjectMaterial",false) != -1) || (strfind(string,"SetDynamicObjectMaterial",false) != -1))
									{
										new index,txdname[32],texture[32],color;
										strmid(string,string,(pos1+1),pos2,sizeof(string));
										if(!unformat(string,"p<,>{s[32]}dds[32]s[32]D(-1)",index,model,txdname,texture,color))
										{
											if(MAX_OBJECT_MATERIAL_SLOT > index >= 0)
											{
												SetDynamicObjectMaterial(DynamicObject[lastSlot],index,model,txdname,texture,color);
												DynamicObjectMaterial[lastSlot][index] = MATERIAL_TYPE_TEXTURE;
											}
										}
									}
									else if((strfind(string,"SetObjectMaterialText",false) != -1) || (strfind(string,"SetDynamicObjectMaterialText",false) != -1))
									{
										new index,text[128],resolution,font[32],fontsize,bold,fontcolor,color,alignment;
										strmid(string,string,(pos1+1),pos2,sizeof(string));
										if(!unformat(string,"p<,>{s[32]}ds[128]ds[32]D(24)D(1)D(-1)D(-16777216)D(1)",index,text,resolution,font,fontsize,bold,fontcolor,color,alignment))
										{
											if(MAX_OBJECT_MATERIAL_SLOT > index >= 0)
											{
												SetDynamicObjectMaterialText(DynamicObject[lastSlot],index,text,resolution,font,fontsize,bold,fontcolor,color,alignment);
												DynamicObjectMaterial[lastSlot][index] = MATERIAL_TYPE_MESSAGE;
											}
											
										}
									}
								}
							}
							fclose(hFile);
						}
					}
					format(string,144,"<OBJECT> : "YELLOW"%d objects "WHITE"loaded from file '"GREEN"%s"WHITE"'",loaded,dir);
					SendClientMessage(playerid,X11_LIGHTBLUE,string);
				}
				else SendErrorMessage(playerid,"You must first clear your current map!");
			}
			else SendSyntaxMessage(playerid,"/object import [name] [confirm]");
		}
		case 20:
		{
			new slot,index;
			if(!sscanf(subparam,"dD(0)",slot,index))
			{
				if((index >= MAX_OBJECT_MATERIAL_SLOT) || (index < 0)) return SendErrorMessage(playerid,"index cannot go below 0 or over 9!");
				if(Iter_Contains(DynamicObjects,slot))
				{
					if(DynamicObjectMaterial[slot][index] != MATERIAL_TYPE_MESSAGE)
					{
						SetDynamicObjectMaterialText(DynamicObject[slot],index,"Text Here",OBJECT_MATERIAL_SIZE_256x128,"Arial",24,1,0xFFFFFFFF,0xFF000000);
						DynamicObjectMaterial[slot][index] = MATERIAL_TYPE_MESSAGE;
					}
					SetPVarInt(playerid,"EditingObject",slot);
					SetPVarInt(playerid,"EditingIndex",index);
					Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
				}
				else SendErrorMessage(playerid,"Invalid object slot!");
			}
			else SendSyntaxMessage(playerid,"/object textprop [object id] [index]");
		}
		case 21:
		{
			if(!isnull(subparam))
			{
				new slot = strval(subparam);
				if(Iter_Contains(DynamicObjects,slot))
				{
					new model,Float:oPos[3],Float:oRot[3];
					model = Streamer_GetIntData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_MODEL_ID);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_X,oPos[0]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Y,oPos[1]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_Z,oPos[2]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_X,oRot[0]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_Y,oRot[1]);
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_R_Z,oRot[2]);
					DestroyDynamicObject(DynamicObject[slot]);
					Loop(index,MAX_OBJECT_MATERIAL_SLOT)
					{
						DynamicObjectMaterial[slot][index] = MATERIAL_TYPE_NONE;
					}
					DynamicObject[slot] = CreateDynamicObject(model,oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2]);
					Streamer_Update(playerid);
				}
				else SendErrorMessage(playerid,"Invalid objectid!");
			}
			else SendSyntaxMessage(playerid,"/object resetmaterial [object id]");
		}
		case 22:
		{
			SelectObjectType[playerid] = OBJECT_SELECT_DELETE;
			SendClientMessage(playerid,X11_LIGHTBLUE,"<OBJECT> : "YELLOW"Click an object to delete it!");
			SelectObject(playerid);
		}
		case 23:
		{
			new Float:radius;
			if(!sscanf(subparam,"f",radius))
			{
				new Float:oPos[3];
				new count = 0;
				radius = floatabs(radius);
				foreach(new slot : DynamicObjects)
				{
					GetDynamicObjectPos(DynamicObject[slot],oPos[0],oPos[1],oPos[2]);
					if(IsPlayerInRangeOfPoint(playerid,radius,oPos[0],oPos[1],oPos[2]))
					{
						new next;
						DestroyDynamicObject(DynamicObject[slot]);
						Loop(i,MAX_OBJECT_MATERIAL_SLOT)
						{
							DynamicObjectMaterial[slot][i] = MATERIAL_TYPE_NONE;
						}
						Iter_SafeRemove(DynamicObjects,slot,next);
						slot = next;
						count++;
					}
				}
				format(string,144,"<OBJECT> : "YELLOW"%d objects "WHITE"has been deleted, total objects: "GREEN"%d",count,Iter_Count(DynamicObjects));
				SendClientMessage(playerid,X11_LIGHTBLUE,string);
			}
			else SendSyntaxMessage(playerid,"/object rdelete [radius]");
		}
		case 24:
		{
			new index,model,txdname[32],texture[32],color[4];
			if(!sscanf(subparam,"dds[32]s[32]D(0)D(0)D(0)D(0)",index,model,txdname,texture,color[0],color[1],color[2],color[3]))
			{
				if((index >= MAX_OBJECT_MATERIAL_SLOT) || (index < 0)) return SendErrorMessage(playerid,"index cannot go below 0 or over 9!");
				format(string,sizeof(string),"%d|%d|%s|%s|%d",index,model,txdname,texture,RGBAToInt(color[0],color[1],color[2],color[3]));
				SetPVarString(playerid,"PaintParam",string);
				SelectObjectType[playerid] = OBJECT_SELECT_PAINT;
				SendClientMessage(playerid,X11_LIGHTBLUE,"<EDITOR> : "YELLOW"Click an object to paint it!");
				SelectObject(playerid);
			}
			else SendSyntaxMessage(playerid,"/object paintbrush [index] [model] [txdname] [texture] [opt: alpha] [opt: red]  [opt: green]  [opt: blue]");
		}
		case 25:
		{
			SelectObjectType[playerid] = OBJECT_SELECT_CLEAN;
			SendClientMessage(playerid,X11_LIGHTBLUE,"<EDITOR> : "YELLOW"Click an object to clean it!");
			SelectObject(playerid);
		}
		case 26:
		{
			new slot,priority;
			if(sscanf(params,"dd",slot,priority)) return SendSyntaxMessage(playerid,"/object priority [slot] [priority]");
			if(Iter_Contains(DynamicObjects,slot))
			{
				if(priority > 5 || priority < 0) return SendErrorMessage(playerid,"Priority cannot go over 5 or below 0!");
				format(string,144,"<OBJECT> : "WHITE"Object "YELLOW"slot %d "WHITE"priority is set to "GREEN"%d "WHITE"from "RED"%d",slot,priority,DynamicObjectPriority[slot]);
				DynamicObjectPriority[slot] = priority;
				SendClientMessage(playerid,X11_LIGHTBLUE,string);
			}
		}
		default:
		{
			SendSyntaxMessage(playerid,"/object [option]");
			SendClientMessageEx(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"create, remove, clear, copy, move, rotate, select, tele, mgethere, mmove");
			SendClientMessageEx(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"export, model, attach, gethere, material, import, textprop, resetmaterial, deletemode, rdelete");
			SendClientMessageEx(playerid, X11_YELLOW_2, "[OPTIONS]: "WHITE"paintbrush, cleanbrush, priority");
		}
	}
	return 1;
}

Dialog:Object_TextMenu(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				Dialog_Show(playerid,Object_TextSetMessage,DIALOG_STYLE_INPUT,"Material Text: Set Text","Input text: (max length = 255 characters)","Set","Back");
				return 1;
			}
			case 1:
			{
				Dialog_Show(playerid,Object_TextSetResolution,DIALOG_STYLE_LIST,"Material Text: Set Resolution","32x32\n64x32\n64x64\n128x32\n128x64\n128x128\n256x32\n256x64\n256x128\n256x256\n512x64\n512x128\n512x256\n512x512","Set","Back");
				return 1;
			}
			case 2:
			{
				new fonts[256];
				Loop(i,sizeof(WinFonts))
				{
					strcat(fonts,WinFonts[i],sizeof(fonts));
					strcat(fonts,"\n",sizeof(fonts));
				}
                strcat(fonts,"Custom",sizeof(fonts));
				Dialog_Show(playerid,Object_TextSetFont,DIALOG_STYLE_LIST,"Material Text: Set Font",fonts,"Set","Back");
				return 1;
			}
			case 3:
			{
				Dialog_Show(playerid,Object_TextSetFontSize,DIALOG_STYLE_INPUT,"Material Text: Set Font Size","Input font size: (1-255)","Set","Back");
				return 1;
			}
			case 4:
			{
				new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
				new slot = GetPVarInt(playerid,"EditingObject"),
			    	index = GetPVarInt(playerid,"EditingIndex");
			    GetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
			    SetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,((bold == 1) ? 0 : 1),fcolor,bcolor,alignment);
			    Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
			    return 1;
			}
			case 5:
			{
				Dialog_Show(playerid,Object_TextSetFontColor,DIALOG_STYLE_INPUT,"Material Text: Set Font Color","Input color in RGBA format: (ex 255 0 0 255 = yellow)","Set","Back");
				return 1;
			}
			case 6:
			{
				Dialog_Show(playerid,Object_TextSetColor,DIALOG_STYLE_INPUT,"Material Text: Set Background Color","Input color in RGBA format: (ex 255 0 0 255 = yellow)","Set","Back");
				return 1;
			}
			case 7:
			{
				Dialog_Show(playerid,Object_TextSetAlignment,DIALOG_STYLE_LIST,"Material Text: Set Alignment","Left\nCenter\nRight","Set","Back");
				return 1;
			}
			case 8:
			{
				new Float:oPos[3],Float:oRot[3],
					slot = GetPVarInt(playerid,"EditingObject"),
					index = GetPVarInt(playerid,"EditingIndex");
				GetDynamicObjectPos(DynamicObject[slot],oPos[0],oPos[1],oPos[2]);
				GetDynamicObjectRot(DynamicObject[slot],oRot[0],oRot[1],oRot[2]);
				new temp = CreateDynamicObject(Streamer_GetIntData(STREAMER_TYPE_OBJECT,DynamicObject[slot],E_STREAMER_MODEL_ID),oPos[0],oPos[1],oPos[2],oRot[0],oRot[1],oRot[2]);
				DynamicObjectMaterial[slot][index] = 0;
				Loop(i,MAX_OBJECT_MATERIAL_SLOT)
				{
					if(DynamicObjectMaterial[slot][i] == MATERIAL_TYPE_TEXTURE)
					{
						new modelid,txdname[32],texturename[32],color;
						GetDynamicObjectMaterial(DynamicObject[slot],i,modelid,txdname,texturename,color);
						SetDynamicObjectMaterial(temp,i,modelid,txdname,texturename,color);
					}
					else if(DynamicObjectMaterial[slot][i] == MATERIAL_TYPE_MESSAGE)
					{
						new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
						GetDynamicObjectMaterialText(DynamicObject[slot],i,text,size,font,fsize,bold,fcolor,bcolor,alignment);
					    SetDynamicObjectMaterialText(temp,i,text,size,font,fsize,bold,fcolor,bcolor,alignment);
					}
				}
				DestroyDynamicObject(DynamicObject[slot]);
				DynamicObject[slot] = temp;
				Streamer_Update(playerid,STREAMER_TYPE_OBJECT);
			}
		}
	}
	DeletePVar(playerid,"EditingObject");
	DeletePVar(playerid,"EditingIndex");
	return 1;
}
Dialog:Object_TextSetMessage(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
		new slot = GetPVarInt(playerid,"EditingObject"),
	    	index = GetPVarInt(playerid,"EditingIndex");
	    GetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
	    SetDynamicObjectMaterialText(DynamicObject[slot],index,((isnull(inputtext)) ? (text) : (inputtext)),size,font,fsize,bold,fcolor,bcolor,alignment);
	}
	Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
	return 1;
}
Dialog:Object_TextSetResolution(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
		new slot = GetPVarInt(playerid,"EditingObject"),
	    	index = GetPVarInt(playerid,"EditingIndex");
	    GetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
	    size = ((listitem+1)*10);
	    SetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
	}
	Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
	return 1;
}
Dialog:Object_TextSetFont(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(listitem < sizeof(WinFonts))
		{
			new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
			new slot = GetPVarInt(playerid,"EditingObject"),
		    	index = GetPVarInt(playerid,"EditingIndex");
		    GetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
		    SetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,WinFonts[listitem],fsize,bold,fcolor,bcolor,alignment);
		}
		else
		{
			Dialog_Show(playerid,Object_TextSetCustomFont,DIALOG_STYLE_INPUT,"Material Text: Set Custom Font","Input font name:","Input","Back");
		}
	}
	Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
	return 1;
}
Dialog:Object_TextSetCustomFont(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
		new slot = GetPVarInt(playerid,"EditingObject"),
	    	index = GetPVarInt(playerid,"EditingIndex");
	    GetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
	    SetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,((isnull(inputtext)) ? (text) : (inputtext)),fsize,bold,fcolor,bcolor,alignment);
	}
	Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
	return 1;
}
Dialog:Object_TextSetFontSize(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
		new slot = GetPVarInt(playerid,"EditingObject"),
	    	index = GetPVarInt(playerid,"EditingIndex");
	    GetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
	    SetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,((isnull(inputtext)) ? strval(inputtext) : fsize),bold,fcolor,bcolor,alignment);
	}
	Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
	return 1;
}
Dialog:Object_TextSetFontColor(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new alpha,red,green,blue;
		if(!sscanf(inputtext,"dddD(255)",red,green,blue,alpha))
		{
			new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
			new slot = GetPVarInt(playerid,"EditingObject"),
		    	index = GetPVarInt(playerid,"EditingIndex");
		    GetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
		    fcolor = RGBAToInt(alpha,red,green,blue);
		    SetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
		}
	}
	Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
	return 1;
}
Dialog:Object_TextSetColor(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new alpha,red,green,blue;
		if(!sscanf(inputtext,"dddD(255)",red,green,blue,alpha))
		{
			new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
			new slot = GetPVarInt(playerid,"EditingObject"),
		    	index = GetPVarInt(playerid,"EditingIndex");
		    GetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
		    bcolor = RGBAToInt(alpha,red,green,blue);
		    SetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
		}
	}
	Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
	return 1;
}
Dialog:Object_TextSetAlignment(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new text[256],size,font[32],fsize,bold,fcolor,bcolor,alignment;
		new slot = GetPVarInt(playerid,"EditingObject"),
	    	index = GetPVarInt(playerid,"EditingIndex");
	    GetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,alignment);
	    SetDynamicObjectMaterialText(DynamicObject[slot],index,text,size,font,fsize,bold,fcolor,bcolor,listitem);
	}
	Dialog_Show(playerid,Object_TextMenu,DIALOG_STYLE_LIST,"Material Text","Text\nResolution\nFont\nFont Size\nToggle Bold\nFont Color\nBackground Color\nText Alignment\nReset","Select","Close");
	return 1;
}
#define MAX_MAP (500)

enum e_map {
  eID,
  eName[64]
};
new MapData[MAX_MAP][e_map],
  Iterator:Maps<MAX_MAP>;

#include <YSI\y_hooks>
hook OnGameModeInitEx() {
  mysql_tquery(g_iHandle, "SELECT * FROM `maps`", "Maps_Load", "");
  return 1;
}

hook OnGameModeExit() {
  Iter_Clear(Maps);
  return 1;
}

CMD:loadmap(playerid, params[]) {
  if (CheckAdmin(playerid, 5))
    return PermissionError(playerid);

  new mapname[64], world, interior, houseid, bizid;
  if (sscanf(params, "s[64]ddD(-1)D(-1)", mapname, world, interior, houseid, bizid))
    return SendSyntaxMessage(playerid, "/loadmap [map name] [world] [interior] [opt: house id] [opt: biz id]");

  new id = cellmin;
  if ((id = Iter_Free(Maps)) != cellmin) {
    if (bizid != -1 && !BusinessData[bizid][bizExists])
      return SendErrorMessage(playerid, "Invalid biz id!");
    
    if (houseid != -1 && !Iter_Contains(Houses, houseid))
      return SendErrorMessage(playerid, "Invalid house id!");

    Iter_Add(Maps, id);
    Map_Import(playerid, mapname, world, interior, houseid, bizid);
    format(MapData[id][eName], 64, "%s", mapname);

    mysql_tquery(g_iHandle, sprintf("INSERT INTO `maps` (`Name`) VALUES ('%s')", SQL_ReturnEscaped(mapname)), "OnMapCreated", "d", id);
  } else SendErrorMessage(playerid, "Server has reached the maximum of maps (MAX: %d).", MAX_MAP);
  return 1;
}

Function:OnMapCreated(id) {
  MapData[id][eID] = cache_insert_id();
  mysql_tquery(g_iHandle, sprintf("UPDATE `maps` SET `Name`='%s' WHERE `ID`='%d'",MapData[id][eName],MapData[id][eID]));
  return 1;
}

Map_Import(playerid, name[], world, interior, houseid = -1, bizid = -1) {
  new string[512],dir[64],model,Float:pos[3],Float:rot[3],loaded,tmp[32],templastid[32],slot;

  format(dir,sizeof(dir),"maps/%s.pwn",name);
  if(fexist(dir))
  {
    new File:hFile = fopen(dir,io_read);
    while(fread(hFile,string,sizeof(string)))
    {
      strtrim(string);

      new type;
      if(strfind(string, "CreateObject(", true) != -1) type = 1;
      else if(strfind(string, "CreateDynamicObject(", true) != -1) type = 1;
      else if(strfind(string, "SetObjectMaterial(", true) != -1) type = 3;
      else if(strfind(string, "SetDynamicObjectMaterial(", true) != -1) type = 3;
      else if(strfind(string, "SetObjectMaterialText(", true) != -1) type = 4;
      else if(strfind(string, "SetDynamicObjectMaterialText(", true) != -1) type = 5;
      else continue;
      
      new assignment = strfind(string, "="); 
      if(assignment != -1) {
        strmid(templastid, string, 0, assignment);
        strtrim(templastid);
      }
      
      strmid(string, string, strfind(string, "(") + 1, strfind(string, ");"), sizeof(string));

      if (type == 1) {
        if(!sscanf(string,"p<,>dffffff",model,pos[0],pos[1],pos[2],rot[0],rot[1],rot[2])) {
          slot = Object_Create(model, pos[0], pos[1], pos[2], rot[0], rot[1], rot[2], world, interior);
          if(slot == cellmin) break;
          if (houseid != -1) ObjData[slot][oHouse] = HouseData[houseid][houseID];
          if (bizid != -1) ObjData[slot][oBiz] = BusinessData[bizid][bizID];
          loaded++;
        }
      }
      if (type == 3) {
        strreplace(string, "\"", "");
        new index,txdname[32],texture[32],color;
        if (!sscanf(string,"p<,>s[32]iis[32]s[32]h",tmp,index,model,txdname,texture,color)) {
          if(!strcmp(tmp, templastid)) {
            ObjData[slot][oMatsColor][index] = color;
            for(new i = 0; i < sizeof(ObjectTextures); i++) {
              if(!strcmp(ObjectTextures[i][TextureName], texture)) {
                ObjData[slot][oMaterials][index] = i;
                break;
              }
            }
            Object_Refresh(slot);
            Object_Save(slot);
          }
        }
      }
      if (type == 4) {
        strreplace(string, "\"", "");
        new text[128],index,resolution,font[32],fontsize,bold,fontcolor,backcolor,alignment;
        if (!sscanf(string, "p<,>s[32]s[128]iis[32]iihhi",tmp,text,index,resolution,font,fontsize,bold,fontcolor,backcolor,alignment)) {
          if (!strcmp(tmp, templastid)) {
            ObjData[slot][oMatsText] = 1;
            ObjData[slot][oMatsTextIndex] = index;
            format(ObjData[slot][oText], 128, "%s", text);
            ObjData[slot][oMatsTextSize] = resolution;
            format(ObjData[slot][oMatsTextFont], 32, "%s", font);
            ObjData[slot][oMatsTextFontSize] = fontsize;
            ObjData[slot][oMatsTextBold] = bold;
            ObjData[slot][oMatsTextColor] = fontcolor;
            ObjData[slot][oMatsTextBackColor] = backcolor;
            ObjData[slot][oMatsTextAlignment] = alignment;
            
            Object_Refresh(slot);
            Object_Save(slot);
          }
        }
      }
      if (type == 5) {
        strreplace(string, "\"", "");
        new index,text[128],resolution,font[32],fontsize,bold,fontcolor,color,alignment;
        if(!sscanf(string,"p<,>s[32]is[128]is[32]iihhi",tmp,index,text,resolution,font,fontsize,bold,fontcolor,color,alignment)) {
          if(!strcmp(tmp, templastid)) {
            ObjData[slot][oMatsText] = 1;
            ObjData[slot][oMatsTextIndex] = index;
            format(ObjData[slot][oText], 128, "%s", text);
            ObjData[slot][oMatsTextSize] = resolution;
            format(ObjData[slot][oMatsTextFont], 32, "%s", font);
            ObjData[slot][oMatsTextFontSize] = fontsize;
            ObjData[slot][oMatsTextBold] = bold;
            ObjData[slot][oMatsTextColor] = fontcolor;
            ObjData[slot][oMatsTextBackColor] = color;
            ObjData[slot][oMatsTextAlignment] = alignment;
            
            Object_Refresh(slot);
            Object_Save(slot);
          }
        }
      }
    }
    fclose(hFile);
    SendCustomMessage(playerid, "OBJECT", YELLOW"%d objects "WHITE"loaded from file '"GREEN"%s"WHITE"'",loaded,dir);
  } else SendErrorMessage(playerid, "The file doesn't exists!");
  return 1;
}

Function:Maps_Load() {
  new rows = cache_num_rows();

  for (new i = 0; i < rows; i ++) {
    Iter_Add(Maps, i);
    cache_get_value_int(i, "ID", MapData[i][eID]);
    cache_get_value(i, "Name", MapData[i][eName]);
  }
  return 1;
}

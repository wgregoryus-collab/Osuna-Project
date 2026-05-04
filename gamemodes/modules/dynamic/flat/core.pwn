#define MAX_FLAT (30)
#define MAX_FLAT_ROOM (MAX_FLAT*20)

enum flatData {
  flatID,
  flatName[32],
  flatType,
  flatInterior,
  flatWorld,
  flatIntWorld,
  flatIntInterior,
  Float:flatPos[3],
  Float:flatIntPos[3],
  Float:flatGaragePos[3],
  flatCPExt,
  flatCPInt,
  flatPickup,
  Text3D:flatText,
  flatGaragePickup,
  Text3D:flatGarageText
};
new FlatData[MAX_FLAT][flatData],
  Iterator:Flat<MAX_FLAT>;

enum flatRoom {
  flatRoomID,
  flatID,
  flatRoomOwner,
  flatRoomLocked,
  flatRoomPrice,
  flatRoomSeal,
  Float:flatRoomPos[3],
  Float:flatRoomAreaPos[5],
  flatRoomWeapon[3],
  flatRoomAmmo[3],
  flatRoomDurability[3],
  flatRoomMoney,
  flatRoomWorld,
  flatRoomInterior,
  flatRoomBuilder,
  flatRoomBuilderTime,
  flatRoomLastVisited,
  flatRoomPickup,
  Text3D:flatRoomText,
  flatRoomArea
};
new FlatRoom[MAX_FLAT_ROOM][flatRoom],
  Iterator:FlatRooms<MAX_FLAT_ROOM>;

enum
{
	FLAT_TYPE_NONE = 0,
	FLAT_TYPE_LOW,
	FLAT_TYPE_MEDIUM,
	FLAT_TYPE_HIGH
}

#define MAX_FLAT_STRUCTURE (100)
#define MAX_STATIC_STRUCTURE (50)

enum structEnum {
  structID,
  structModel,
  Float:structPos[3],
  Float:structRot[3],
  structMaterial,
  structColor,
  structObject
};
new FlatStructure[MAX_FLAT_ROOM][MAX_FLAT_STRUCTURE][structEnum],
  Iterator:FlatStructures[MAX_FLAT_ROOM]<MAX_FLAT_STRUCTURE>;

new FlatStaticStruct[MAX_FLAT_ROOM][MAX_STATIC_STRUCTURE][structEnum],
  Iterator:FlatStaticStructs[MAX_FLAT_ROOM]<MAX_STATIC_STRUCTURE>;

new ListedFlatStructures[MAX_PLAYERS][MAX_FLAT_STRUCTURE+MAX_STATIC_STRUCTURE] = {-1, ...};

enum {
  SAVE_STRUCTURE_ALL = 0,
  SAVE_STRUCTURE_MATERIAL,
  SAVE_STRUCTURE_MODEL,
  SAVE_STRUCTURE_POS
}

#define MAX_FLAT_FURNITURE (100)

enum flatFurniture {
  furnID,
  furnModel,
  furnName[32],
  Float:furnPos[3],
  Float:furnRot[3],
  furnMaterials[MAX_MATERIALS],
  furnObject,
  furnUnused
};
new FlatFurniture[MAX_FLAT_ROOM][MAX_FLAT_FURNITURE][flatFurniture],
  Iterator:FlatFurnitures[MAX_FLAT_ROOM]<MAX_FLAT_FURNITURE>;

new ListedFlatFurnitures[MAX_PLAYERS][MAX_FLAT_FURNITURE];
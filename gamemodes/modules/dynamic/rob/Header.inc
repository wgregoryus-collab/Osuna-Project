#include <YSI\y_hooks>


#define MAX_ROB_POINTS 5

enum robPoint {
  robID,
  Float:robPos[3],
  Text3D:robLabel,
  robWorld,
  robInt,
  robAmountMoney,
  robRobbed,
  rob
};

new RobPoint[MAX_ROB_POINTS][robPoint],
    Iterator:Rob<MAX_ROB_POINTS>;

new Warn = 0;
#include <YSI\y_hooks>
hook OnGameModeInitEx() {
  mysql_tquery(g_iHandle, "SELECT * FROM `robpoint`", "RobPoint_Load", "");
  return 1;
}


hook OnGameModeExit() {
  foreach (new i : Rob) if (Iter_Contains(Rob, i)) {
    RobPoint_Save(i);
  }
  Iter_Clear(Rob);
  return 1;
}
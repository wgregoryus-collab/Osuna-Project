#include <YSI\y_hooks>

hook OnGameModeInitEx() {
  CreateDynamic3DTextLabel("[Mining]\n"WHITE"Type "YELLOW"/mine "WHITE"to begin mining.", COLOR_CLIENT, JobData[jobid][jobPoint][0], JobData[jobid][jobPoint][1], JobData[jobid][jobPoint][2]+0.5, 7.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, JobData[jobid][jobPointWorld], JobData[jobid][jobPointInt]);
  CreateDynamicPickup(1239, 23, JobData[jobid][jobPoint][0], JobData[jobid][jobPoint][1], JobData[jobid][jobPoint][2], JobData[jobid][jobPointWorld], JobData[jobid][jobPointInt]);

  CreateDynamic3DTextLabel("[Mining]\n"WHITE"Deliver your mining rocks at this spot.", COLOR_CLIENT, JobData[jobid][jobDeliver][0], JobData[jobid][jobDeliver][1], JobData[jobid][jobDeliver][2]+0.5, 7.5,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1);
  CreateDynamicPickup(1239, 23, JobData[jobid][jobDeliver][0], JobData[jobid][jobDeliver][1], JobData[jobid][jobDeliver][2]);
  return 1;
}
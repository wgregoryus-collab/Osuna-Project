#include <YSI\y_hooks>

new
		tick_CrouchKey[MAX_PLAYERS],
Timer:	SitDownTimer[MAX_PLAYERS];

#define MAX_ANIMS (1811)

forward Float:GetPlayerTotalVelocity(playerid);
Float:GetPlayerTotalVelocity(playerid)
{
    if(!SQL_IsLogged(playerid))
        return 0.0;

    new Float:velocity,
        Float:vx,
        Float:vy,
        Float:vz;

    GetPlayerVelocity(playerid, vx, vy, vz);
    velocity = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;

    return velocity;
}

timer SitLoop[1900](playerid)
{
	ApplyAnimation(playerid, "BEACH", "PARKSIT_M_LOOP", 4.0, 1, 0, 0, 0, 0);
}

timer SitDown[800](playerid)
{
	ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_IN", 4.0, 0, 0, 0, 0, 0);
	defer SitLoop(playerid);
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid) && !PlayerData[playerid][pInjured])
	{
		if(GetPlayerTotalVelocity(playerid) == 0.0)
		{
			if(newkeys == KEY_CROUCH)
			{
				tick_CrouchKey[playerid] = GetTickCount();
				SitDownTimer[playerid] = defer SitDown(playerid);
			}

			if(oldkeys == KEY_CROUCH)
			{
				if(GetTickCountDifference(GetTickCount(), tick_CrouchKey[playerid]) < 250)
				{
					stop SitDownTimer[playerid];
				}
			}

			if(newkeys & KEY_SPRINT && newkeys & KEY_CROUCH)
			{
				if(GetPlayerAnimationIndex(playerid) == 1381)
				{
					ClearAnimations(playerid);
				}
				else
				{
					ApplyAnimation(playerid, "ROB_BANK", "SHP_HandsUp_Scr", 4.0, 0, 1, 1, 1, 0);
				}
			}
		}
		if(newkeys & KEY_CROUCH || newkeys & KEY_SPRINT || newkeys & KEY_JUMP)
		{
			if(GetPlayerAnimationIndex(playerid) == 43 || GetPlayerAnimationIndex(playerid) == 1497)
			{
				ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
			}
		}
		if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP) && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
		{
			if(random(100) < 60)
				ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff", 4.1, 0, 1, 1, 0, 0);
		}
	}

	return 1;
}

CMD:anim(playerid, params[])
{
	new
		animlib[32],
		animname[32],
		index;

	if (sscanf(params, "d", index)) return SendSyntaxMessage(playerid, "/anim [index 1-1811]");

	if(!AnimationCheck(playerid))
        return SendErrorMessage(playerid, "You can't perform animations at the moment.");

	if(index < 1 || index > MAX_ANIMS) return SendErrorMessage(playerid, "Invalid index!");
	else
	{
		GetAnimationName(index, animlib, 32, animname, 32);
		ApplyAnimationEx(playerid, animlib, animname, 4.1, 1, 0, 0, 1, 0, 1);
	}
	return 1;
}

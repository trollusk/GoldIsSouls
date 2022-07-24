Scriptname aaaGoldXPPlayerEffect extends activemagiceffect  

import Debug

;;
;; script attached to active magic effect of same name
;; that effect is applied (constant effect) to player alias in quest aaaGoldXPEffectQuest
;;

aaaGoldXPUtilityQuest Property UtilityQuest auto
aaaGoldXPMenuQuest property mcmOptions auto

MiscObject Property GoldBase auto
{This is a reference to the base type of gold}


Event OnInit()
	RegisterForSleep()
EndEvent


Event OnPlayerLoadGame()
	RegisterForSleep()
EndEvent


Event OnSleepStop(bool abInterrupted)
	Actor player = Game.GetPlayer()
	
	if !abInterrupted
		if mcmOptions.enableGoldIsSouls
			int lowestCost = UtilityQuest.GoldToLevelSkill(UtilityQuest.getLowestSkillValue())
			if Game.GetPlayerExperience() >= Game.GetExperienceForLevel(player.GetLevel())
				messagebox("You need to level up in the Skills and Perks menu\nbefore you can gain further skills.")
			elseif (player.GetGoldAmount() < lowestCost)
				notification("To increase your skills, you need at least " + lowestCost + " gold.")
			else
				;UtilityQuest.LevelSkills()
                UtilityQuest.LevelSkills_UIExt()
			endif
		endif
	endif
	
	; incrementSkill preserves the xp to level value.  So effectively you are gaining skillXP, 
	; not simply a skill point.  This removes that gained xp.
	UtilityQuest.SetAllVanillaSkillXPToZero()	
EndEvent



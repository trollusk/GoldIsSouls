Scriptname aaaGoldIsSoulsPlayerScript extends ReferenceAlias  

; script is attached to player alias belonging to aaaGoldXPEffectQuest

import debug

aaaGoldXPUtilityQuest Property UtilityQuest auto
aaaGoldXPMenuQuest property mcmOptions auto
aaaGoldXPEffectQuest property EffectQuest auto


Event OnInit()
	RegisterForSleep()
EndEvent


; OnPlayerLoadGame events are only sent to the PLAYER (or aliases)
Event OnPlayerLoadGame()
	RegisterForSleep()
	EffectQuest.maintenance()
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
				UtilityQuest.LevelSkills_UIExt()
			endif
		endif
	endif
	
	; incrementSkill preserves the xp to level value.  So effectively you are gaining skillXP, 
	; not simply a skill point.  This removes that gained xp.
	UtilityQuest.SetAllVanillaSkillXPToZero()	
EndEvent



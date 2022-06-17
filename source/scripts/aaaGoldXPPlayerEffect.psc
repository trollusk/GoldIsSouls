Scriptname aaaGoldXPPlayerEffect extends activemagiceffect  


aaaGoldXPUtilityQuest Property UtilityQuest auto

MiscObject Property GoldBase auto
{This is a reference to the base type of gold}

MiscObject Property GoldToken auto
{What to add to a container to keep track of how much gold the player has added}

Message Property UnsupportedContainer auto
{Display when a container that we are putting gold into isn't supported}


;=====================================================Maintenance=============================================================

Event OnInit()
	Maintenance()
	
EndEvent


Event OnPlayerLoadGame()
	Maintenance()
EndEvent


function Maintenance()

	;register for gold events
	;AddInventoryEventFilter(GoldBase);register for updates
	; register to receive 'onsleepstart' and 'onsleepstop' events
	RegisterForSleep()
endfunction

;============================================================Events===============================================




Event OnSleepStop(bool abInterrupted)
	;Debug.Notification("Done Sleeping")
	
	if(!abInterrupted)

		; Not clear when we should show the skill levelling dialogue, as we want to be able to raise
		; skills at will if we have enough gold.
		int lowestCost = UtilityQuest.GoldToLevelSkill(UtilityQuest.getLowestSkillValue())
		;debug.notification("Cost to level lowest skill (" + UtilityQuest.getLowestSkillValue() + "): " + lowestCost)
		if (Game.GetPlayer().GetGoldAmount() >= lowestCost)
			UtilityQuest.LevelSkills()
		endif
		
		; if(!UtilityQuest.snooze)
			; UnregisterForSleep()
		; else
		RegisterForSleep()
		; endif
	endif
	
	UtilityQuest.SetAllVanillaSkillXPToZero(); incrementSkill preserves the xp to level value.  So effectively you are gaining skillXP, not simply a skill point.  This removes that gained xp.
	
EndEvent

event OnDying(Actor Killer)
	cleanup()
	goToState("dead")
	
EndEvent

;=========================================================================States==================================================================================================

state dead

endstate

;======================================================================Utility Functions ===========================================================================



function cleanup()
	;removeAllInventoryEventFilters()
	unregisterForSleep()
endFunction

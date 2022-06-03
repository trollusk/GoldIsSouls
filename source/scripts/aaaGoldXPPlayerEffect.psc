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
	AddInventoryEventFilter(GoldBase);register for updates

endfunction

;============================================================Events===============================================


Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)

	if(UI.isMenuOpen("BarterMenu"))
		UtilityQuest.gainGoldXP(aiItemCount)
	elseif(akSourceContainer != None)
	
		if(UtilityQuest.isContainerTrackable(akSourceContainer))
			int GoldTokenCount = akSourceContainer.getItemCount(GoldToken)
			
			int GoldTokenCountPlayer = getTargetActor().getItemCount(GoldToken);
			
			if(GoldTokenCountPlayer > 0)
				;debug.notification("mass inventory transfer detected")
				getTargetActor().removeItem(GoldToken, GoldTokenCountPlayer)
				return
			endif
			
			if(goldTokenCount > 0) ;need to make sure we don't gain gold xp for gold we added to containers
			
				if(aiItemCount > goldTokenCount)
				
					akSourceContainer.removeItem(goldToken, goldTokenCount)
					
					UtilityQuest.gainGoldXP(aiItemCount - goldTokenCount)
					
				else
					akSourceContainer.removeItem(goldToken, goldTokenCount - aiItemCount)
				endif
			else
				UtilityQuest.gainGoldXP(aiItemCount)
				
			endif
		else
			UnsupportedContainer.show()
		endif
		
	else
	
		UtilityQuest.gainGoldXP(aiItemCount)
		
	endif
	
	
	RegisterForSleep()
	
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	
	;If the player gives gold
	if(UI.isMenuOpen("BarterMenu"))
		;just a shopkeeper continue, Gold Is XP is already broken if a player can access a shop keeper's inventory directly
	else
		if(akDestContainer != None)
			if(UtilityQuest.isContainerTrackable(akDestContainer))
				akDestContainer.addItem(GoldToken, aiItemCount)
			else
				UnsupportedContainer.show()
			endif
		else
			;triggers on paying for rooms, just let the drop exploit exist
			;aaaGoldXPBuffered.setValue(aaaGoldXPBuffered.getValue() - getXP(aiItemCount))
		endif
	endif

EndEvent



Event OnSleepStop(bool abInterrupted)
	;Debug.Notification("Done Sleeping")
	
	
	if(!abInterrupted)
	
		int numLevels = UtilityQuest.GainBufferedXP()
		if(numLevels > 0 || UtilityQuest.snooze)
			;we leveled
			UtilityQuest.snooze = UtilityQuest.LevelSkills()
		else
			
		endif
		
		if(!UtilityQuest.snooze)
			UnregisterForSleep()
		else
			RegisterForSleep()
		endif
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
	removeAllInventoryEventFilters()
	unregisterForSleep()
endFunction

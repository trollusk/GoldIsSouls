Scriptname aaaGoldIsSoulsKillQuest extends Quest

;;
;;  script for quest that is run when story manager sends KillActor event
;;

aaaGoldXPMenuQuest property mcmOptions auto
MiscObject property goldBase Auto


Event OnStoryKillActor (ObjectReference victimref, ObjectReference killer, Location aklocation, Int crimeStatus, Int relStatus)
	if mcmOptions.enableGoldIsSouls
		Actor victim = (victimref as Actor)
		
		int goldToAdd = Math.Floor(mcmOptions.GetToughness(victim) * 0.5 * mcmOptions.npcGoldScalingFactor)
		
		if mcmOptions.giveGoldToKilledNPCs && victim.GetLevel() >= mcmOptions.minimumNPCLevel
		
			;debug.notification("Give " + goldToAdd + " gold to " + victim.GetName())
			if victim.GetGoldAmount() < goldToAdd
				victim.AddItem(goldBase, goldToAdd - victim.GetGoldAmount(), false)
			endif
			
		endif
	endif
	self.Stop()
EndEvent



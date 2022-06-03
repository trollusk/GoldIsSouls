scriptname aaaGoldXPMaintenanceQuest extends activemagiceffect

aaaGoldXPUtilityQuest Property UtilityQuest auto
aaaGoldXPEffectQuest Property EffectQuest auto

Event OnInit()
	UtilityQuest.maintenance()
	EffectQuest.maintenance()
endEvent

Event OnPlayerLoadGame()
	UtilityQuest.maintenance()
	EffectQuest.maintenance()
endEvent

Scriptname aaaGoldXPMenuQuest extends SKI_ConfigBase  

aaaGoldXPUtilityQuest Property UtilityQuest auto
aaaGoldXPEffectQuest  Property EffectQuest auto
aaaGoldIsSoulsKillQuest property KillQuest auto
String Property IconLocation auto

LocationRefType property locRefTypeBoss auto
LocationRefType property locRefTypeDLC2Boss1 auto
bool property enableGoldIsSouls auto
Float property npcGoldScalingFactor auto
bool property giveGoldToKilledNPCs  auto

;
bool _enablemod
bool _givegoldtonpcs
float _goldscalingfactor

; IDs of entries in MCM
;int ToggleGoldXPEnableID
int ToggleGiveGoldToNPCsID
int EnableModID
;int UninstallID
int GoldScalingFactorID


Event OnConfigInit()
	_enablemod = enableGoldIsSouls
	_givegoldtonpcs = giveGoldToKilledNPCs
	_goldscalingfactor = npcGoldScalingFactor
EndEvent


Event OnPageReset(string page)
	Actor npc = (Game.GetCurrentCrosshairRef() as Actor)

	if(page == "")
		LoadCustomContent(IconLocation, 50, 50)
		return
	endif
	
	UnloadCustomContent()

	if(page == "Settings")
		
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)		; top of left column
				
		AddHeaderOption("Mod settings")
		EnableModID			= AddToggleOption("Enable mod", enableGoldIsSouls, OPTION_FLAG_NONE)
		;UninstallID = AddTextOption("Uninstall Gold Is Souls", none, OPTION_FLAG_NONE)
		AddEmptyOption()
		ToggleGiveGoldToNPCsID			= AddToggleOption("Killed NPCs drop extra gold", giveGoldToKilledNPCs, OPTION_FLAG_NONE)
		GoldScalingFactorID 			= AddSliderOption("Scale extra gold by:", npcGoldScalingFactor, "{1}x", OPTION_FLAG_NONE)
		
		SetCursorPosition(1)		; top of right column
		AddHeaderOption("Debug info")
		AddTextOption("Gold in inventory", Game.GetPlayer().GetGoldAmount() as int, OPTION_FLAG_DISABLED)
		AddTextOption("Cost to increase lowest skill", (UtilityQuest.GoldToLevelSkill(UtilityQuest.getLowestSkillValue())) as int, OPTION_FLAG_DISABLED)
		AddTextOption("Cost to increase highest skill", (UtilityQuest.GoldToLevelSkill(UtilityQuest.getHighestSkillValue())) as int, OPTION_FLAG_DISABLED)
		AddTextOption("Progress towards next level", (UtilityQuest.skillIncreases as int) + "/10", OPTION_FLAG_DISABLED)
		if npc
			float damageReduction = (0.12 * npc.GetActorValue("DamageResist")) / 100.0
			if damageReduction > 0.8
				damageReduction = 0.8
			endif
			AddEmptyOption()
			AddTextOption("Targeted NPC", npc.GetDisplayName(), OPTION_FLAG_DISABLED)
			AddTextOption("Damage resist", (0.12 * npc.GetActorValue("DamageResist"))/100, OPTION_FLAG_DISABLED)
			AddTextOption("Effective Max Health", (npc.GetActorValueMax("health") / (1 - damageReduction)), OPTION_FLAG_DISABLED)
			AddTextOption("Toughness", (GetToughness(npc)), OPTION_FLAG_DISABLED)
			AddTextOption("Gold scaling factor", npcGoldScalingFactor, OPTION_FLAG_DISABLED)
			AddTextOption("Gold on Death", (GetToughness(npc) * 0.5 * npcGoldScalingFactor), OPTION_FLAG_DISABLED)
		endif
	endif
	
EndEvent


Event OnOptionSelect(int option)
	
	if option == EnableModID
		if !enableGoldIsSouls
			enableGoldIsSouls = true
			_enablemod = true
			SetToggleOptionValue(EnableModID, _enablemod)
			EffectQuest.SetEnabledState(true)
			debug.messagebox("Gold Is Souls activated!")
		else	
			enableGoldIsSouls = false
			_enablemod = false
			SetToggleOptionValue(EnableModID, _enablemod)
			EffectQuest.SetEnabledState(false)
			debug.messagebox("Gold Is Souls has been disabled.")
		endif
	; elseif option == UninstallID
		; EffectQuest.revertGameSettings()
		; debug.messagebox("Gold Is Souls has been uninstalled. Now save, quit and disable the .esp.")
	elseif option == ToggleGiveGoldToNPCsID
		giveGoldToKilledNPCs = !giveGoldToKilledNPCs
		_givegoldtonpcs = giveGoldToKilledNPCs
		SetToggleOptionValue(ToggleGiveGoldToNPCsID, _givegoldtonpcs)
	endif
EndEvent


Event OnOptionSliderOpen(int option)
	if option == GoldScalingFactorID
		SetSliderDialogStartValue(npcGoldScalingFactor)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 5.0)
		SetSliderDialogInterval(0.1)
	endif
EndEvent


Event OnOptionSliderAccept(int option, float value)
	if option == GoldScalingFactorID
		npcGoldScalingFactor = value
		_goldscalingfactor = value
		SetSliderOptionValue(GoldScalingFactorID, npcGoldScalingFactor)
	endif
EndEvent


Event OnOptionHighlight(int option)
	if(option == EnableModID)
		SetInfoText("Enable or disable Gold Is Souls.")
	; elseif(option == UninstallID)
		; SetInfoText("Uninstall the mod and restore the normal Skyrim leveling system.")
	elseif option == GoldScalingFactorID
		SetInfoText("Multiply the amount of extra gold given to NPCs by this number.")
	elseif option == ToggleGiveGoldToNPCsID
		SetInfoText("Add some extra gold to the inventory of killed NPCs. The amount is roughly based on the challenge posed by the NPC.")
	endif
EndEvent


Float Function GetToughness(Actor npc)
	float health = npc.GetActorValueMax("health")
	;float level = npc.GetActorValue("level")
	float damageMult = npc.GetActorValue("attackdamagemult")
	float weaponSpeedMult = npc.GetActorValue("weaponspeedmult")
	;float meleeDamage = npc.GetActorValue("meleedamage")
	;float unarmedDamage = npc.GetActorValue("unarmeddamage")
	float armorRating = npc.GetActorValue("DamageResist")
	float damRes = (0.12 * armorRating)/100
	int spellCount = npc.GetLeveledActorBase().GetSpellCount()
	bool isBoss = (npc.HasRefType(locRefTypeBoss)) || (npc.HasRefType(locRefTypeDLC2Boss1))
	
	if damRes > 0.8
		damRes = 0.8
	endif
	if damageMult < 1.0
		damageMult += 1.0
	endif
	if weaponSpeedMult < 1.0
		weaponSpeedMult += 1.0
	endif
	
	int eHP = Math.Floor(health / (1 - damRes))
	
	float toughness = eHP * damageMult * weaponSpeedMult
	if spellCount > 1
		toughness *= 1.8
	elseif spellCount > 0
		toughness *= 1.2
	endif
	
	if isBoss
		toughness *= 5.0
	endif
	
	return toughness
EndFunction

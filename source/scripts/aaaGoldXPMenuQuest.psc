Scriptname aaaGoldXPMenuQuest extends SKI_ConfigBase  

;;
;; script for quest that controls MCM for Gold Is Souls
;;

aaaGoldXPUtilityQuest Property UtilityQuest auto
aaaGoldXPEffectQuest  Property EffectQuest auto
aaaGoldIsSoulsKillQuest property KillQuest auto
String Property IconLocation auto

LocationRefType property locRefTypeBoss auto
LocationRefType property locRefTypeDLC2Boss1 auto
bool property enableGoldIsSouls auto
Float property npcGoldScalingFactor auto
int property minimumNPCLevel auto
bool property giveGoldToKilledNPCs  auto

;
bool _enablemod
bool _givegoldtonpcs
float _goldscalingfactor
int _minlevel

; IDs of entries in MCM
;int ToggleGoldXPEnableID
int ToggleGiveGoldToNPCsID
int EnableModID
;int UninstallID
int GoldScalingFactorID
int MinNPCLevelID


Event OnConfigInit()
	_enablemod = enableGoldIsSouls
	_givegoldtonpcs = giveGoldToKilledNPCs
	_goldscalingfactor = npcGoldScalingFactor
	_minlevel = minimumNPCLevel
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
		AddEmptyOption()
		ToggleGiveGoldToNPCsID			= AddToggleOption("Killed NPCs drop extra gold", giveGoldToKilledNPCs, OPTION_FLAG_NONE)
		GoldScalingFactorID 			= AddSliderOption("Scale extra gold by:", npcGoldScalingFactor, "{1}x", OPTION_FLAG_NONE)
		MinNPCLevelID					= AddSliderOption("Minimum NPC level:", minimumNPCLevel, "{0}", OPTION_FLAG_NONE)
		
		SetCursorPosition(1)		; top of right column
		AddHeaderOption("Debug info")
		AddTextOption("Mod enabled?", enableGoldIsSouls, OPTION_FLAG_DISABLED)
		AddTextOption("EffectQuest running?", EffectQuest.IsRunning(), OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddTextOption("Gold in inventory", Game.GetPlayer().GetGoldAmount() as int, OPTION_FLAG_DISABLED)
		AddTextOption("Cost to increase lowest skill", (UtilityQuest.GoldToLevelSkill(UtilityQuest.getLowestSkillValue())) as int, OPTION_FLAG_DISABLED)
		AddTextOption("Cost to increase highest skill", (UtilityQuest.GoldToLevelSkill(UtilityQuest.getHighestSkillValue())) as int, OPTION_FLAG_DISABLED)
		AddTextOption("Progress towards next level", (UtilityQuest.skillIncreases as int) + "/10", OPTION_FLAG_DISABLED)
		if npc
			float damageReduction = (0.12 * npc.GetActorValue("DamageResist")) / 100.0
			float avgRes = GetAverageNonPhysicalResists(npc)
			if damageReduction > 0.8
				damageReduction = 0.8
			endif
			AddEmptyOption()
			AddTextOption("Targeted NPC", npc.GetDisplayName(), OPTION_FLAG_DISABLED)
			AddTextOption("Spell count", npc.GetSpellCount(), OPTION_FLAG_DISABLED)
			AddTextOption("Caster type", GetCasterType(npc), OPTION_FLAG_DISABLED)
			AddTextOption("Damage resist", (0.12 * npc.GetActorValue("DamageResist"))/100, OPTION_FLAG_DISABLED)
			AddTextOption("Average nonphysical resist", avgRes, OPTION_FLAG_DISABLED)
			AddTextOption("Effective Max Health", GetEffectiveMaxHealth(npc), OPTION_FLAG_DISABLED)
			AddTextOption("Toughness", GetToughness(npc), OPTION_FLAG_DISABLED)
			AddTextOption("Gold scaling factor", npcGoldScalingFactor, OPTION_FLAG_DISABLED)
			if npc.GetLevel() >= minimumNPCLevel
				AddTextOption("Gold on Death", (GetToughness(npc) * 0.5 * npcGoldScalingFactor), OPTION_FLAG_DISABLED)
			else
				AddTextOption("Gold on Death", " 0 (LVL<MIN)", OPTION_FLAG_DISABLED)
			endif
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
	elseif option == MinNPCLevelID
		SetSliderDialogStartValue(minimumNPCLevel)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(1.0, 100.0)
		SetSliderDialogInterval(1.0)
	endif
EndEvent


Event OnOptionSliderAccept(int option, float value)
	if option == GoldScalingFactorID
		npcGoldScalingFactor = value
		_goldscalingfactor = value
		SetSliderOptionValue(GoldScalingFactorID, npcGoldScalingFactor)
	elseif option == MinNPCLevelID
		minimumNPCLevel = Math.Floor(value)
		_minlevel = Math.Floor(value)
		SetSliderOptionValue(MinNPCLevelID, minimumNPCLevel)
	endif
EndEvent


Event OnOptionHighlight(int option)
	if(option == EnableModID)
		SetInfoText("Enable or disable Gold Is Souls.")
	; elseif(option == UninstallID)
		; SetInfoText("Uninstall the mod and restore the normal Skyrim leveling system.")
	elseif option == GoldScalingFactorID
		SetInfoText("Multiply the amount of extra gold given to NPCs by this number.")
	elseif option == MinNPCLevelID
		SetInfoText("Only give extra gold if NPC is of this level or higher.")
	elseif option == ToggleGiveGoldToNPCsID
		SetInfoText("Add some extra gold to the inventory of killed NPCs. The amount is roughly based on the challenge posed by the NPC.")
	endif
EndEvent


Float Function GetToughness(Actor npc)
	float damageMult = npc.GetActorValue("attackdamagemult")
	float weaponSpeedMult = npc.GetActorValue("weaponspeedmult")
	int casterType = GetCasterType(npc)
	bool isBoss = (npc.HasRefType(locRefTypeBoss)) || (npc.HasRefType(locRefTypeDLC2Boss1))
	
	if damageMult < 1.0
		damageMult += 1.0
	endif
	if weaponSpeedMult < 1.0
		weaponSpeedMult += 1.0
	endif
	
	float toughness = GetEffectiveMaxHealth(npc) * damageMult * weaponSpeedMult
	
	if casterType > 1
		toughness *= 1.8
	elseif casterType > 0
		toughness *= 1.2
	endif
	
	if isBoss
		toughness *= 5.0
	endif
	
	return toughness
EndFunction


Float Function GetEffectiveMaxHealth(Actor npc)
	float health = npc.GetActorValueMax("health")
	float armorRating = npc.GetActorValue("DamageResist")
	float damRes = (0.12 * armorRating)/100
	
	damRes += GetAverageNonPhysicalResists(npc)
	if damRes > 0.8
		damRes = 0.8
	endif
	
	return Math.Floor(health / (1 - damRes))
EndFunction


; Return values:
;	0	no spells
;	1	has 1 spell that is targeted at self or touch, so not much of a caster
;	2	has > 1 spell, or a ranged spell
int Function GetCasterType(Actor npc)
	int spellCount = npc.GetLeveledActorBase().GetSpellCount()
	
	if spellCount > 1
		return 2
	elseif spellCount > 0
		Spell firstSpell = npc.GetNthSpell(0)
		if firstSpell.GetNumEffects() > 0
			MagicEffect effect = firstSpell.GetNthEffectMagicEffect(0)
			if effect.GetDeliveryType() > 1
				; this is a ranged spell of some kind (aimed=2, target actor=3, target loc=4)
				return 2
			else
				; only one spell, and its target is self or touch
				return 1
			endif
		endif
	else
		return 0
	endif	
EndFunction


Float Function GetAverageNonPhysicalResists(Actor npc)
	float poisonRes = npc.GetActorValue("PoisonResist")
	float fireRes = npc.GetActorValue("FireResist")
	float shockRes = npc.GetActorValue("ElectricResist")
	float frostRes = npc.GetActorValue("FrostResist")
	float magicRes = npc.GetActorValue("MagicResist")
	; there is also diseaseresist but we ignore it
	
	return (poisonRes + fireRes + shockRes + frostRes + magicRes) / 5 * 0.01
EndFunction

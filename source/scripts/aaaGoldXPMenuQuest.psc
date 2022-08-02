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
Float property costScalingFactor auto
Float property npcGoldScalingFactor auto
int property minimumNPCLevel auto
bool property giveGoldToKilledNPCs  auto
bool property normalXPFromSkills auto
;
bool _enablemod
bool _givegoldtonpcs
float _goldscalingfactor
int _minlevel
float _costfactor
bool _normalXPfromskills
int _skillincreasesperlevel

; IDs of entries in MCM
;int ToggleGoldXPEnableID
int ToggleGiveGoldToNPCsID
int EnableModID
;int UninstallID
int GoldScalingFactorID
int MinNPCLevelID
int CostScalingFactorID
int NormalXPFromSkillsID
int SkillIncreasesPerLevelID


Event OnConfigInit()
	_enablemod = enableGoldIsSouls
	_givegoldtonpcs = giveGoldToKilledNPCs
	_goldscalingfactor = npcGoldScalingFactor
	_minlevel = minimumNPCLevel
	_costfactor = costScalingFactor
    _normalXPfromskills = normalXPFromSkills
    _skillincreasesperlevel = UtilityQuest.MaxSkillIncreasesPerLevel
EndEvent


Event OnPageReset(string page)
	Actor npc = (Game.GetCurrentCrosshairRef() as Actor)
	ActorValueInfo avi = actorvalueinfo.GetActorValueInfoByName("Alchemy")

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
		CostScalingFactorID				= AddSliderOption("Multiply skill cost by:", costScalingFactor, "{2}x", OPTION_FLAG_NONE)
		NormalXPFromSkillsID            = AddToggleOption("Normal XP from skills", normalXPFromSkills, OPTION_FLAG_NONE)
        SkillIncreasesPerLevelID        = AddSliderOption("Skill points to gain 1 level:", UtilityQuest.MaxSkillIncreasesPerLevel, "{0}", OPTION_FLAG_NONE)
        AddEmptyOption()
		ToggleGiveGoldToNPCsID			= AddToggleOption("Killed NPCs drop extra gold", giveGoldToKilledNPCs, OPTION_FLAG_NONE)
		GoldScalingFactorID 			= AddSliderOption("Scale extra gold by:", npcGoldScalingFactor, "{1}x", OPTION_FLAG_NONE)
		MinNPCLevelID					= AddSliderOption("Minimum NPC level:", minimumNPCLevel, "{0}", OPTION_FLAG_NONE)
		
		SetCursorPosition(1)		; top of right column
		AddHeaderOption("Debug info")
		AddTextOption("Mod enabled?", enableGoldIsSouls, OPTION_FLAG_DISABLED)
		AddTextOption("EffectQuest running?", EffectQuest.IsRunning(), OPTION_FLAG_DISABLED)
		AddTextOption("fXPPerSkillRank", Game.GetGameSettingFloat("fXPPerSkillRank"), OPTION_FLAG_DISABLED)
		AddTextOption("SkillUseMult", avi.GetSkillUseMult(), OPTION_FLAG_DISABLED)
		AddTextOption("SkillOffsetMult", avi.GetSkillOffsetMult(), OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddTextOption("Gold in inventory", Game.GetPlayer().GetGoldAmount() as int, OPTION_FLAG_DISABLED)
		AddTextOption("Cost to increase lowest skill", (UtilityQuest.GoldToLevelSkill(UtilityQuest.getLowestSkillValue())) as int, OPTION_FLAG_DISABLED)
		AddTextOption("Cost to increase highest skill", (UtilityQuest.GoldToLevelSkill(UtilityQuest.getHighestSkillValue())) as int, OPTION_FLAG_DISABLED)
		if normalXPFromSkills
            AddTextOption("Progress towards next level", (Game.GetPlayerExperience() as int) + "/" + (Game.GetExperienceForLevel(Game.GetPlayer().GetLevel()) as int), OPTION_FLAG_DISABLED)
        else
            AddTextOption("Progress towards next level", (UtilityQuest.skillIncreases as int) + "/" + UtilityQuest.MaxSkillIncreasesPerLevel, OPTION_FLAG_DISABLED)
		endif
        if npc
			float damageReduction = (0.12 * npc.GetActorValue("DamageResist")) / 100.0
			float avgRes = GetAverageNonPhysicalResists(npc)
			if damageReduction > 0.8
				damageReduction = 0.8
			endif
			AddEmptyOption()
			AddTextOption("Targeted NPC", npc.GetDisplayName(), OPTION_FLAG_DISABLED)
			AddTextOption("Num. targeted spells", GetNonSelfSpellCount(npc), OPTION_FLAG_DISABLED)
			AddTextOption("Damage resist", (0.12 * npc.GetActorValue("DamageResist"))/100, OPTION_FLAG_DISABLED)
			AddTextOption("Average nonphysical resist", avgRes, OPTION_FLAG_DISABLED)
			AddTextOption("Max Health", npc.GetActorValueMax("health"), OPTION_FLAG_DISABLED)
			AddTextOption("Effective HP   health/(1-resist)", GetEffectiveMaxHealth(npc), OPTION_FLAG_DISABLED)
			AddTextOption("Damage Mult", GetDamageMult(npc), OPTION_FLAG_DISABLED)
			AddTextOption("Weapon Speed Mult", GetWeaponSpeedMult(npc), OPTION_FLAG_DISABLED)
			AddTextOption("Toughness   (ehp * wpnSpeed * dmgMult)", GetToughness(npc), OPTION_FLAG_DISABLED)
			AddTextOption("  Caster?   (x1.8)", GetNonSelfSpellCount(npc) > 0, OPTION_FLAG_DISABLED)
			AddTextOption("  Boss?   (x5)", NPCIsBoss(npc), OPTION_FLAG_DISABLED)
			
			if npc.GetLevel() >= minimumNPCLevel
				AddTextOption("Gold on Death", (GetToughness(npc) * 0.5 * npcGoldScalingFactor), OPTION_FLAG_DISABLED)
			else
				AddTextOption("Gold on Death", "N/A", OPTION_FLAG_DISABLED)
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
	elseif option == NormalXPFromSkillsID
		normalXPFromSkills = !normalXPFromSkills
		_normalXPfromskills = normalXPFromSkills
		SetToggleOptionValue(NormalXPFromSkillsID, _normalXPfromskills)
        ; if toggled on, restore fXPPerSkillRank
        ; if toggled off, zero it
        if normalXPFromSkills
            Game.SetGameSettingFloat("fXPPerSkillRank", EffectQuest.SavedfXPPerSkillRank)
        else
            EffectQuest.SavedfXPPerSkillRank = Game.getGameSettingFloat("fXPPerSkillRank")
            Game.SetGameSettingFloat("fXPPerSkillRank", 0.0)
        endif
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
	elseif option == CostScalingFactorID
		SetSliderDialogStartValue(costScalingFactor)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.05, 10.0)
		SetSliderDialogInterval(0.05)
	elseif option == SkillIncreasesPerLevelID
		SetSliderDialogStartValue(UtilityQuest.MaxSkillIncreasesPerLevel)
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(3.0, 50.0)
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
	elseif option == CostScalingFactorID
		costScalingFactor = value
		_costfactor = value
		SetSliderOptionValue(CostScalingFactorID, costScalingFactor)
	elseif option == SkillIncreasesPerLevelID
		UtilityQuest.MaxSkillIncreasesPerLevel = (value as int)
		_skillincreasesperlevel = (value as int)
		SetSliderOptionValue(SkillIncreasesPerLevelID, UtilityQuest.MaxSkillIncreasesPerLevel)
	endif
	ForcePageReset()
EndEvent


Event OnOptionHighlight(int option)
	if(option == EnableModID)
		SetInfoText("Enable or disable Gold Is Souls.")
	elseif option == CostScalingFactorID
		SetInfoText("Multiply the gold cost of each skill point by this number.")
	elseif option == GoldScalingFactorID
		SetInfoText("Multiply the amount of extra gold given to NPCs by this number.")
	elseif option == MinNPCLevelID
		SetInfoText("Only give extra gold if NPC is of this level or higher.")
	elseif option == NormalXPFromSkillsID
		SetInfoText("Instead of gaining a level for every " + UtilityQuest.MaxSkillIncreasesPerLevel + " skill points, use the original Skyrim system, where the number of skill points required to gain a level increases as the player's level increases.")
	elseif option == ToggleGiveGoldToNPCsID
		SetInfoText("Add some extra gold to the inventory of killed NPCs. The amount is roughly based on the challenge posed by the NPC.")
	elseif option == SkillIncreasesPerLevelID
		SetInfoText("The number of skill points the player must gain in order to gain one level, if 'normal XP from skills' is false.")
	endif
EndEvent


Float Function GetToughness(Actor npc)
	float damageMult = GetDamageMult(npc)
	float weaponSpeedMult = GetWeaponSpeedMult(npc)
	int spells = GetNonSelfSpellCount(npc)
	bool isBoss = NPCIsBoss(npc)
	
	float toughness = GetEffectiveMaxHealth(npc) * damageMult * weaponSpeedMult
	
	if spells > 0
		toughness *= 1.8
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


float Function GetDamageMult (Actor npc)
	float mult = npc.GetActorValue("attackdamagemult")
	if mult < 1.0
		mult += 1.0
	endif
	return mult
EndFunction


float Function GetWeaponSpeedMult (Actor npc)
	float mult = npc.GetActorValue("weaponspeedmult")
	if mult < 1.0
		mult += 1.0
	endif
	return mult
EndFunction



int Function GetNonSelfSpellCount(Actor npc)
	; must use ActorBase - this stuff does not work on npc
	int spellCount = npc.GetLeveledActorBase().GetSpellCount()
	int nonSelfSpells = 0
	while spellCount > 0
		spellCount -= 1
		Spell sp = npc.GetLeveledActorBase().GetNthSpell(spellCount)
		MagicEffect effect = sp.GetNthEffectMagicEffect(0)
		if (effect.GetCastingType() > 0) && (effect.GetDeliveryType() > 0)
			; not constant effect, not self targeted
			nonSelfSpells += 1
		endif
	endwhile

	return nonSelfSpells
EndFunction


float Function Minimum(float a, float b)
	if a > b
		return b
	else
		return a
	endif
EndFunction


Float Function GetAverageNonPhysicalResists(Actor npc)
	float poisonRes = Minimum(npc.GetActorValue("PoisonResist"), 100)
	float fireRes = Minimum(npc.GetActorValue("FireResist"), 100)
	float shockRes = Minimum(npc.GetActorValue("ElectricResist"), 100)
	float frostRes = Minimum(npc.GetActorValue("FrostResist"), 100)
	float magicRes = Minimum(npc.GetActorValue("MagicResist"), 100)
	; there is also diseaseresist but we ignore it
	
	; it seems that NPCs who are "immune" to a damage type, have resist of 1000
	; hence we need to cap each resist at 100%, otherwise average resist will be inflated
	
	return (poisonRes + fireRes + shockRes + frostRes + magicRes) / 5 * 0.01
EndFunction


bool Function NPCIsBoss (Actor npc)
	; aggression=0 for peaceful NPCs such as townsfolk. For some reason a lot of them have the "boss" reftype despite
	; being harmless.
	return (npc.GetActorValue("aggression") > 0) && ((npc.HasRefType(locRefTypeBoss)) || (npc.HasRefType(locRefTypeDLC2Boss1)))
EndFunction


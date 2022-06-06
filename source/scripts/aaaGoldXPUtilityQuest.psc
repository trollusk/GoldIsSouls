scriptname aaaGoldXPUtilityQuest extends quest

Message Property SKSENotInstalled auto
{Message to display when SKSE is not installed}

Message Property SkillXPUpdated auto
{Message when Skill XP is updated}


float Property  ReductionMult auto
float Property  SkillXPCoefficient auto
float Property  SkillXPConstant auto
float Property  SkillXPGainCoefficient auto
float Property  SkillXPGainConstant auto
float Property  ExponentialBase auto
float Property  ExponentialConstant auto
float Property  ExponentialCoefficient auto
int Property  MaxSkillIncreasesPerLevel auto

float Property  ReductionMultDefault auto
float Property  SkillXPCoefficientDefault auto
float Property  SkillXPConstantDefault auto
float Property  SkillXPGainCoefficientDefault auto
float Property  SkillXPGainConstantDefault auto
float Property  ExponentialBaseDefault auto
float Property  ExponentialConstantDefault auto
float Property  ExponentialCoefficientDefault auto
int Property  MaxSkillIncreasesPerLevelDefault auto

bool Property  ExponentialEnable auto
bool Property	ExponentialEnableDefault auto

bool Property consumeGold auto
Message Property ConfirmRaiseSkillMessage  Auto  


;bool Property EnableUtilityQuest auto

; xxx We increment this variable each time a skill point is gained through spending gold. 
; Once 10 skill points have been gained, gain a level and reset count to 0.
int skillIncreases = 0


Message Property InitializeMessage auto
{Message to display on initialization}



MiscObject Property TrackableToken auto
{Test if a container is trackable}



MiscObject Property GoldBase auto
{This is a reference to the base type of gold}

Message Property MagicSkillMenu auto
{Menu to display on leveling Magic skills}

Message Property WarriorSkillMenu auto
{Menu to display on leveling Warrior Skills}

Message Property ThiefSkillMenu auto
{Menu to display on leveling Thief Skills}

Message Property SkillXPMenuExceedCost auto
{Message to display when the player attempts to increase a skill without the necessary SkillXP}

Message Property SkillXPMenuExceedNumLevel auto
{Message to display when the player attempts to increase a skill more times than they are allowed to per level}


Message Property SkillXPMenuCapReached auto
{Message to display when the player can't level a skill due to the cap}


float property PI_CONSTANT = 3.1415926535 autoreadonly

;vars need to be global so that menu scripts and event scripts operate on the same config

GlobalVariable Property aaaGoldXPBuffered auto
GlobalVariable Property aaaGoldXPSkillXPBuffered auto

; these variables exist purely so that skill values can be included in the "level up" menus
; GlobalVariable Property aaaGoldXPAlchemySkill auto
; GlobalVariable Property aaaGoldXPAlterationSkill auto
; GlobalVariable Property aaaGoldXPArcherySkill auto
; GlobalVariable Property aaaGoldXPBlockSkill auto
; GlobalVariable Property aaaGoldXPConjurationSkill auto
; GlobalVariable Property aaaGoldXPDestructionSkill auto
; GlobalVariable Property aaaGoldXPEnchantSkill auto
; GlobalVariable Property aaaGoldXPHeavyArmorSkill auto
; GlobalVariable Property aaaGoldXPIllusionSkill auto
; GlobalVariable Property aaaGoldXPLightArmorSkill auto
; GlobalVariable Property aaaGoldXPLockpickingSkill auto
; GlobalVariable Property aaaGoldXPOneHandedSkill auto
; GlobalVariable Property aaaGoldXPPickpocketSkill auto
; GlobalVariable Property aaaGoldXPRestorationSkill auto
; GlobalVariable Property aaaGoldXPSmithingSkill auto
; GlobalVariable Property aaaGoldXPSneakSkill auto
; GlobalVariable Property aaaGoldXPSpeechSkill auto
; GlobalVariable Property aaaGoldXPTwoHandedSkill auto

;Allow indexing of skill names.
String[] property SkillNames auto

;keep track of player skill levels to detect when skills are gained from quests and books
Int[] Property LastSkillGains auto

;keep track of how many times external events have increased your base skills.  
int[] Property ExternalSkillGains auto

;track the base skill values 
int[] Property SkillCaps auto

bool property snooze = false auto

;===========================================Maintenance=====================================


Function maintenance()
		
	bool arraysUninitialized = LastSkillGains[0] ==  0 ;test if arrays have been setup
	
	;/
	if(SkillNames.length == 0);array is not initialized
		;Debug.notification("initializing SkillNames")
		SkillNames = new String[18]
		SkillNames[0] = "Alteration"
		SkillNames[1] = "Conjuration"
		SkillNames[2] = "Destruction"
		SkillNames[3] = "Enchanting"
		SkillNames[4] = "Illusion"
		SkillNames[5] = "Restoration"
		SkillNames[6] = "Alchemy"
		SkillNames[7] = "LightArmor"
		SkillNames[8] = "Lockpicking"
		SkillNames[9] = "Pickpocket"
		SkillNames[10] = "Sneak"
		SkillNames[11] = "Speechcraft"
		SkillNames[12] = "Marksman"
		SkillNames[13] = "Block"
		SkillNames[14] = "HeavyArmor"
		SkillNames[15] = "OneHanded"
		SkillNames[16] = "Smithing"
		SkillNames[17] = "TwoHanded"
		
	endif
	
	;if(ExternalSkillGains.length == 0)
		;Debug.notification("initializing ExternalSkillGains")
	;	ExternalSkillGains = new int[18]
	;EndIf
	
	;installed on a previously started save.  Skill gains from race and previous skill books are ignored
	if(LastSkillGains.length == 0)
		LastSkillGains = new int[18]
	endif
	
	/;
	
	if(arraysUninitialized)
		
		RegisterForSingleUpdate(3)	;new game
	endif
	
EndFunction


Event OnUpdate()
	deferedInit()
	InitializeMessage.show()
EndEvent


function deferedInit()
	if(game.getPlayer().getLevel() == 1.0)
		;debug.notification("new game detected")
		;We should determine the unmodified starting skill, some mods change this so we don't know if it's 15 or not.
		fillIntArray(LastSkillGains, getLowestSkillValue())
	else
		UpdateLastSkillGains();we are loaded into an ongoing game.  There's no way to determine starting skill boosts or how many skill books plus level increase quests the player has taken.
	endif
	
	
	
endFunction




;===========================================Utility Functions==========================================================================================================

function copyArrayInt(int[] dest, int[] src)

	int minLength

	if(src.length < dest.length)
		minLength = src.length
	else
		minLength = dest.length
	endif
	
	int count = 0
	
	while (count < minLength)
		
		dest[count] = src[count]
		count +=1
	endwhile


endFunction



;Called to set skill xp to 0.  This is runs on all skills to prevent players from dying from OCD when they use a skill book and it looks like they're gaining skill because of how incrementskill works.
function SetAllVanillaSkillXPToZero()
	int count = 0
	
	while(count < SkillNames.Length)
		;set the skill xp to 0
		actorvalueinfo.GetActorValueInfoByName(SkillNames[count]).SetSkillExperience(0.0)
		count += 1
	endWhile
EndFunction

Function UpdateLastSkillGains()
	int i = 0
		
		While(i < LastSkillGains.Length)
			LastSkillGains[i] = game.getPlayer().getBaseActorValue(SkillNames[i]) as int
		
			i += 1
		endWhile
EndFunction

; Function CheckExternalSkillGains()
	
	; int i = 0
	
	; while(i < SkillNames.Length)
	
		; int currentSkill = game.getPlayer().getBaseActorValue(SkillNames[i]) as int
		; if (LastSkillGains[i] < currentSkill) ;this skill has increased since the previous level-up
			; ;debug.notification("Detected external skill increase")
			; ;debug.notification("Skill name: " + skillnames[i])
			; ;debug.notification("External Levels" + (currentSkill - LastSkillGains[i]))
		
		
			; ExternalSkillGains[i] = ExternalSkillGains[i] + (currentSkill - LastSkillGains[i])
		; endif
	
		; i += 1
	; EndWhile
	
	
; EndFunction

;Repeatibly displays message menus until player is done leveling skills.
bool Function LevelSkills()

	int levelsToGain = 0
	int currentMenu = 0; 0 - Mage, 1 - Thief, 2 - Warrior
	;track skills leveled-up this session
	;CheckExternalSkillGains(); see if there were any external skill gains pre-level
	
	int option = DisplaySkillMenu(currentMenu)
	
	while(option >= 0 && option < 8)	;didn't exit
	
		;switchmenu options
		if(option == 0)
			currentMenu -= 1
			if (currentMenu < 0)
				currentMenu = 2
			endif
		elseif (option == 7)
			currentMenu += 1
			if (currentMenu > 2)
				currentMenu = 0
			endif
		
		else
			;handle the level up
			int cost = CostToLevelSkillbyIndex(GetSkillNameIndex(currentMenu, option))
			int remainder = Game.GetPlayer().GetGoldAmount() - cost
			
			if(remainder < 0)
				SkillXPMenuExceedCost.show(cost)
			elseif (ConfirmRaiseSkillMessage.show(Game.GetPlayer().GetGoldAmount(), cost) > 0)
				; do nothing - player chose not to spend the gold
			else
				
				int current_skill = game.getPlayer().getBaseActorValue(SkillNames[GetSkillNameIndex(currentMenu, option)]) as int; 
				game.IncrementSkill(SkillNames[GetSkillNameIndex(currentMenu, option)]) ;we have to check if this hit the cap
				
				int raised_skill = game.getPlayer().getBaseActorValue(SkillNames[GetSkillNameIndex(currentMenu, option)]) as int; 
				
				if(current_skill < raised_skill)
					; skill was incremented successfully
					Game.GetPlayer().RemoveItem(GoldBase, (cost as int))
					; xxx Count all skill increases, level up when >= 10
					skillIncreases += 1
					if (skillIncreases >= 10)
						skillIncreases = 0
						levelsToGain += 1
					else
						; set XP to correct "proportion" of progress to next level, based on number of skill
						; points gained so far
						Game.SetPlayerExperience(Game.GetExperienceForLevel(Game.GetPlayer().GetLevel() + levelsToGain ) * skillIncreases / 10.0)
					endif
				else
					SkillXPMenuCapReached.show()
					
				endif
				
				
				
				;TODO Is there a way to prevent notifications?
			endif
		endif
	
		option = DisplaySkillMenu(currentMenu)
	
	endWhile

	while levelsToGain > 0
		GainLevel()
		levelsToGain -= 1
	endwhile
	
	UpdateLastSkillGains();we just leveled so update LastSkillGains so we catch the next set of external skill increases at next level-up
	
	return option == 9;If we snoozed return true
EndFunction


int function GetSkillNameIndex(int menu, int option)
	return option - 1 + menu * 6; option - 1 aligns index, currentMenu*6 points to the right block in SkillNames
endFunction


int Function DisplaySkillMenu(int menu)

	;get skill levels
	float[] SkillLevels = new float[6]
	int count = 0
	int returnValue = 0
	
	while (count < 6)
		SkillLevels[count] = Game.GetPlayer().GetBaseActorValue(SkillNames[count + menu * 6])
		count += 1
	endwhile
	
	if(menu == 0)
		; UpdateCurrentInstanceGlobal(aaaGoldXPAlterationSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPConjurationSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPDestructionSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPEnchantSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPIllusionSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPRestorationSkill)
		returnValue = MagicSkillMenu.show(Game.GetPlayer().GetGoldAmount(), SkillLevels[0], SkillLevels[1], SkillLevels[2], SkillLevels[3], SkillLevels[4], SkillLevels[5])
	elseif(menu == 1)
		; UpdateCurrentInstanceGlobal(aaaGoldXPAlchemySkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPLightArmorSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPLockpickingSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPPickpocketSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPSneakSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPSpeechSkill)
		returnValue = ThiefSkillMenu.show(Game.GetPlayer().GetGoldAmount(), SkillLevels[0], SkillLevels[1], SkillLevels[2], SkillLevels[3], SkillLevels[4], SkillLevels[5])
	else
		; UpdateCurrentInstanceGlobal(aaaGoldXPArcherySkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPBlockSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPHeavyArmorSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPOneHandedSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPSmithingSkill)
		; UpdateCurrentInstanceGlobal(aaaGoldXPTwoHandedSkill)
		returnValue = WarriorSkillMenu.show(Game.GetPlayer().GetGoldAmount(), SkillLevels[0], SkillLevels[1], SkillLevels[2], SkillLevels[3], SkillLevels[4], SkillLevels[5])
	endif
	
	return returnValue
EndFunction


;Adds all buffered xp to player, can cause level-ups, clears buffer and handles next level calculations
;returns the number of levels gained
; int function GainBufferedXP()
	
	; ;debug.notification("gain buffered xp")
	; int playerLevel = Game.GetPlayer().GetLevel() 
	; int originalPlayerLevel = playerLevel
	; ;The engine does not register changes by game.setplayerexperience() during events
	; ;This means that all of the vanilla xp needed for multiple level-ups needs to be saved to a buffer, then added via setplayerexperience at the end.
	; ;a consequence of this is that game.getplayer().getlevel() does not increment until the event has finished.
	; float bufferedGameXP = 0.0
	; int numLevels = 0
	
	; while (aaaGoldXPBuffered.GetValue() >= GoldXPToLevel(playerLevel))
		; ;subtract xp from buffer
		; aaaGoldXPBuffered.SetValue(aaaGoldXPBuffered.GetValue() - GoldXPToLevel(playerLevel))
		; ;add skillXP
		; ;aaaGoldXPSkillXPBuffered.SetValue(aaaGoldXPSkillXPBuffered.GetValue() + SkillXPOnLevel(playerLevel))
		
		; ;cause vanilla level-up
		; bufferedGameXP += Game.GetExperienceForLevel(playerLevel)
		
		; ;increment player level
		; playerLevel += 1
		; numLevels += 1
		
	; EndWhile
		
	; ;Set Vanilla Level bar to represent player progress
	; Float progressDecimal = aaaGoldXPBuffered.GetValue() / GoldXPToLevel(playerLevel)
	; Game.SetPlayerExperience(bufferedGameXP + Game.GetExperienceForLevel(playerLevel) * progressDecimal) ;game can't handle XP gain during events so we add it all at the end and don't rely on the level increasing during the event
	
	
	; return numLevels
; EndFunction


Function GainLevel()
	Game.SetPlayerExperience(Game.GetExperienceForLevel(Game.GetPlayer().GetLevel()) + 10)
	;Game.SetPlayerLevel(Game.GetPlayer().GetLevel()+1)
	debug.notification("Leveled up!")
EndFunction


;Returns the amount of Gold needed to go from character level currentLevel to currentLevel+1
int Function GoldToLevel (int currentLevel)
	; same formula as Dark Souls: cubic formula starting at level 12, linear below that
	if currentLevel < 12
		return 656 + currentLevel*17
	else
		return (0.02*Math.Pow(currentLevel, 3) + 3.06*Math.Pow(currentLevel, 2) + 105.6*currentLevel - 895) as int
	endif
EndFunction


int Function GoldToLevelSkill (int skillLevel)
	; currentSkill = current level of the skill (0-100)
	if (skillLevel >= 5)
		return GoldToLevel(skillLevel - 4) / 10
	else
		return GoldToLevel(1) / 10
	endif
EndFunction


; Every 10 skill increases = 1 level-up, therefore the cost of levelling a skill is 1/10 of a level up.
; skills generally start at 5, so we convert this to 1
int Function CostToLevelSkillbyIndex(int skillIndex)
	int skillLevel = Game.GetPlayer().GetBaseActorValue(SkillNames[skillIndex]) as int
	return GoldToLevelSkill(skillLevel)
EndFunction


int function getLowestSkillValue()

	int lowest = 10000
	int i = 0
	
	while(i < SkillNames.Length)
		int skillLevel = Game.GetPlayer().GetBaseActorValue(SkillNames[i]) as int
		if (skillLevel < lowest)
			lowest = skillLevel
		endIf
		
		i += 1
	EndWhile
	
	return lowest

endFunction


int function getHighestSkillValue()

	

	int highest = 0
	int i = 0
	
	while(i < SkillNames.Length)
		int skillLevel = Game.GetPlayer().GetBaseActorValue(SkillNames[i]) as int
		if (skillLevel > highest)
			highest = skillLevel
		endIf
		
		i += 1
	EndWhile
	
	return highest

endFunction




function fillIntArray(int[] intArray, int value)
	int i = 0
	
	while(i < intArray.length)
		intArray[i] = value
		
		i += 1
	endWhile
endFunction


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

;bool Property EnableUtilityQuest auto


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
	
	if(ExternalSkillGains.length == 0)
		;Debug.notification("initializing ExternalSkillGains")
		ExternalSkillGains = new int[18]
	EndIf
	
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




int function getLowestSkillValue()

	

	int lowest = 100
	int i = 0
	
	while(i < SkillNames.Length)
		int skillLevel = game.getPlayer().getBaseActorValue(SkillNames[i]) as int
		if (skillLevel < lowest)
			lowest = skillLevel
		endIf
		
		i += 1
	EndWhile
	
	return lowest

endFunction


;checks whether or not we can add tokens to the provided container
bool function IsContainerTrackable(ObjectReference destContainer)

	if(destContainer.getItemCount(TrackableToken) > 0)
		return true
	else
		destContainer.addItem(TrackableToken)
		
		return destContainer.getItemCount(TrackableToken) > 0
	endif	
endfunction

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

Function CheckExternalSkillGains()
	
	int i = 0
	
	while(i < SkillNames.Length)
	
		int currentSkill = game.getPlayer().getBaseActorValue(SkillNames[i]) as int
		if (LastSkillGains[i] < currentSkill) ;this skill has increased since the previous level-up
			;debug.notification("Detected external skill increase")
			;debug.notification("Skill name: " + skillnames[i])
			;debug.notification("External Levels" + (currentSkill - LastSkillGains[i]))
		
		
			ExternalSkillGains[i] = ExternalSkillGains[i] + (currentSkill - LastSkillGains[i])
		endif
	
		i += 1
	EndWhile
	
	
EndFunction

;Repeatibly displays message menus until player is done leveling skills.
bool Function LevelSkills()
	
	;debug.notification("level skills begin")
	
	int currentMenu = 0; 0 - Mage, 1 - Thief, 2 - Warrior
	;track skills leveled-up this session
	CheckExternalSkillGains(); see if there were any external skill gains pre-level
	
	;debug.notification("check external skill gains")
	
	;Int[] SkillIncreasesThisLevel = new int[18]; track the skills that were raised this level.  Only used to prevent power leveling early on.
	
	int option = DisplaySkillMenu(currentMenu)
	
	
	;debug.notification("display skill menu")
	
	while(option >= 0 && option < 8);didn't exit
	
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
		;Check if the player has increased a skill more than MaxSkillIncreasesPerLevel * num levels.  Multiple levels are handled all at once.
		elseif(SkillCaps[GetSkillNameIndex(currentMenu, option)] <= 0)
			
			SkillXPMenuExceedNumLevel.show()
			
		;handle the level up
		else
			float cost = CostToLevelSkill(GetSkillNameIndex(currentMenu, option))
			
			;debug.notification("Cost to level skill: " + cost)
			
			float remainder = aaaGoldXPSkillXPBuffered.GetValue() - cost
			
			if(remainder < 0)
				SkillXPMenuExceedCost.show()
			else
				
				int current_skill = game.getPlayer().getBaseActorValue(SkillNames[GetSkillNameIndex(currentMenu, option)]) as int; 
				game.IncrementSkill(SkillNames[GetSkillNameIndex(currentMenu, option)]) ;we have to check if this hit the cap
				
				int raised_skill = game.getPlayer().getBaseActorValue(SkillNames[GetSkillNameIndex(currentMenu, option)]) as int; 
				
				if(current_skill < raised_skill)
					SkillCaps[GetSkillNameIndex(currentMenu, option)] = SkillCaps[GetSkillNameIndex(currentMenu, option)] - 1; count times raised.
					aaaGoldXPSkillXPBuffered.SetValue(remainder) ;remove skillxp used
				else
					SkillXPMenuCapReached.show()
					
				endif
				
				
				
				;TODO Is there a way to prevent notifications?
			endif
		endif
	
		option = DisplaySkillMenu(currentMenu)
	
	endWhile
	
	
	
	UpdateLastSkillGains();we just leveled so update LastSkillGains so we catch the next set of external skill increases at next level-up
	
	;debug.notification("option: " + option)
	
	return option == 9;If we snoozed return true
EndFunction

int function GetSkillNameIndex(int menu, int option)
	return option - 1 + menu * 6; option - 1 alligns index, currentMenu*6 points to the right block in SkillNames
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
		returnValue = MagicSkillMenu.show(aaaGoldXPSkillXPBuffered.GetValue(), SkillLevels[0], SkillLevels[1], SkillLevels[2], SkillLevels[3], SkillLevels[4], SkillLevels[5])
	elseif(menu == 1)
		returnValue = ThiefSkillMenu.show(aaaGoldXPSkillXPBuffered.GetValue(), SkillLevels[0], SkillLevels[1], SkillLevels[2], SkillLevels[3], SkillLevels[4], SkillLevels[5])
	else
		returnValue = WarriorSkillMenu.show(aaaGoldXPSkillXPBuffered.GetValue(), SkillLevels[0], SkillLevels[1], SkillLevels[2], SkillLevels[3], SkillLevels[4], SkillLevels[5])
	endif
	
	return returnValue
EndFunction

;TODO factor in modifiers on skill leveling speed
Float Function CostToLevelSkill(int i)
	float skillLevel = Game.GetPlayer().GetBaseActorValue(SkillNames[i])
	;linear cost function, where cost is adjusted down the number of external skill levels gained.  This makes it so there is no long term benefit for hoarding your books and leveling quests
	return SkillXPConstant + SkillXPCoefficient * (skillLevel - ExternalSkillGains[i])
EndFunction

Function GainGoldXP(int goldValue)
	
	
		
	aaaGoldXPBuffered.SetValue(aaaGoldXPBuffered.GetValue() + getXP(goldValue))
	
EndFunction



Function RemoveGoldXP(int goldValue)
	float remainder = aaaGoldXPBuffered.GetValue() - goldValue
	
	if (remainder < 0)
		remainder = 0
	endif
	aaaGoldXPBuffered.SetValue(remainder)

endFunction

float function getXP(int goldValue)
	;Simpler function
	
	if(ReductionMult > 0)
	
		int currentLevel = game.getPlayer().getLevel()
	
		float maxGain = ReductionMult * GoldXPToLevel(currentLevel)
		
		;debug.notification("max gain: " + maxgain)
		;debug.notification("gold value: " + goldvalue)
		
		float xp = (maxGain / 90) * Math.atan(goldValue * (PI_CONSTANT / 2) / (maxGain))
		
		;Debug.notification("xp gained : " + xp)
		
		return xp
		
	else
		return goldValue
	endif
	
	;debug.notification("Gold XP to gain: " + goldXP)

endfunction


;Adds all buffered xp to player, can cause level-ups, clears buffer and handles next level calculations
;returns the number of levels gained
int function GainBufferedXP()
	
	;debug.notification("gain buffered xp")
	int playerLevel = Game.GetPlayer().GetLevel() 
	int originalPlayerLevel = playerLevel
	;The engine does not register changes by game.setplayerexperience() during events
	;This means that all of the vanilla xp needed for multiple level-ups needs to be saved to a buffer, then added via setplayerexperience at the end.
	;a consequence of this is that game.getplayer().getlevel() does not increment until the event has finished.
	float bufferedGameXP = 0.0
	int numLevels = 0
	
	while (aaaGoldXPBuffered.GetValue() >= GoldXPToLevel(playerLevel))
		;subtract xp from buffer
		aaaGoldXPBuffered.SetValue(aaaGoldXPBuffered.GetValue() - GoldXPToLevel(playerLevel))
		;add skillXP
		aaaGoldXPSkillXPBuffered.SetValue(aaaGoldXPSkillXPBuffered.GetValue() + SkillXPOnLevel(playerLevel))
		
		;cause vanilla level-up
		bufferedGameXP += Game.GetExperienceForLevel(playerLevel)
		
		;increment player level
		playerLevel += 1
		numLevels += 1
		
	EndWhile
	
	
	if(numLevels >= 0)
		updateSkillCaps(numLevels)
	endif
	
	;Set Vanilla Level bar to represent player progress
	Float progressDecimal = aaaGoldXPBuffered.GetValue() / GoldXPToLevel(playerLevel)
	Game.SetPlayerExperience(bufferedGameXP + Game.GetExperienceForLevel(playerLevel) * progressDecimal) ;game can't handle XP gain during events so we add it all at the end and don't rely on the level increasing during the event
	
	
	return numLevels
EndFunction

function updateSkillCaps(int numLevels)

	int count = 0
	
	while(count < SkillCaps.length)
		SkilLCaps[count] = SkillCaps[count] + numLevels * MaxSkillIncreasesPerLevel
		count += 1
		
	endWhile

endFunction

;Returns the amount of GoldXP to level
Float Function GoldXPToLevel(int currentLevel)
	;constant + coefficient*base^currentLevel
	
	if(ExponentialEnable)
		return (ExponentialConstant + ExponentialCoefficient * Math.Pow(ExponentialBase, currentLevel))
	else
		return ExponentialConstant + ExponentialCoefficient * currentLevel
	endif
EndFunction

;Returns the ammount of SkillXP gained on level-ups
Float Function SkillXPOnLevel(int Level)
	return SkillXPGainConstant + SkillXPGainCoefficient * level
EndFunction

function fillIntArray(int[] intArray, int value)
	int i = 0
	
	while(i < intArray.length)
		intArray[i] = value
		
		i += 1
	endWhile
endFunction
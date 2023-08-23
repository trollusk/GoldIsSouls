scriptname aaaGoldXPUtilityQuest extends quest

Message Property SKSENotInstalled auto
{Message to display when SKSE is not installed}

Message Property SkillXPUpdated auto
{Message when Skill XP is updated}

aaaGoldXPMenuQuest property mcmOptions auto

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

; We increment this variable each time a skill point is gained through spending gold. 
; Once MaxSkillIncreasesPerLevel skill points (default 10) have been gained, gain a level and reset count to 0.
int property skillIncreases auto


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

;keep track of how many times external events have increased your base skills.  
int[] Property ExternalSkillGains auto

;track the base skill values 
int[] Property SkillCaps auto

bool property snooze = false auto


;===========================================Utility Functions============================================

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


;Repeatibly displays message menus until player is done leveling skills.
Function LevelSkills()

	;int levelsToGain = 0
	int option
	int currentMenu = 0			; 0 - Mage, 1 - Thief, 2 - Warrior
	Actor player = Game.GetPlayer()
	int levelsToGain = 0
	
	option = DisplaySkillMenu(currentMenu)
	
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
			int remainder = player.GetGoldAmount() - cost
			
			if(remainder < 0)
				SkillXPMenuExceedCost.show(cost)
			elseif (ConfirmRaiseSkillMessage.show(player.GetGoldAmount(), cost) > 0)
				; do nothing - player chose not to spend the gold
			else
				string skillName = SkillNames[GetSkillNameIndex(currentMenu, option)]
                if TryToRaiseSkill(skillName)
                    ; successfully raised skill by 1
                    if !mcmOptions.normalXPFromSkills
                        skillIncreases += 1
                        if (skillIncreases >= MaxSkillIncreasesPerLevel)
                            skillIncreases = 0
                            ;GainLevel()
                            levelsToGain += 1
                            ;Game.SetPlayerExperience(0)
                        else
                            ; set XP to correct "proportion" of progress to next level, based on number of skill
                            ; points gained so far
                            ; Game.SetPlayerExperience(Game.GetExperienceForLevel(Game.GetPlayer().GetLevel()) * skillIncreases / 10.0)
                        endif
                    endif
                else
                    ; failed to raise skill (because of caps, etc)
                    SkillXPMenuCapReached.show()
                endif
			endif
		endif
	
		option = DisplaySkillMenu(currentMenu)
	
	endWhile

    if !mcmOptions.normalXPFromSkills
        float xpToGain = Game.GetExperienceForLevel(Game.GetPlayer().GetLevel() + levelsToGain) * skillIncreases / MaxSkillIncreasesPerLevel
        while levelsToGain > 0
            ;xpToGain += Game.GetExperienceForLevel(player.GetLevel() + levelsToGain - 1) + 1
            xpToGain += Game.GetExperienceForLevel(player.GetLevel() + levelsToGain - 1)
            levelsToGain -= 1
        endwhile
        
        Game.SetPlayerExperience(xpToGain + 1)
    endif
EndFunction


; Experimental: use UIExtensions ListMenu to increase skills. 
function LevelSkills_UIExt()
	UIListMenu menu=UIExtensions.GetMenu("UIListMenu") as UIListMenu
	Actor player = Game.GetPlayer()
	int levelsToGain = 0
    bool bLoop = true

	while bLoop
        int menuLine = 0
        int index = 0
        string[] entries = new string[24]
        entries[0] = "ZZZZZ"     ; to ensure it's sorted to the bottom
        menuLine += 1

        while index < skillNames.Length
            int cost = CostToLevelSkillByIndex(index)
            int skillPoints = (player.GetActorValue(skillNames[index])) as int
            string skillPointsStr = skillPoints as string

            ; pad with leading spaces
            if skillPoints < 100
                skillPointsStr = " " + skillPointsStr
            endif
            if skillPoints < 10
                skillPointsStr = " " + skillPointsStr
            endif

            entries[menuLine] = skillPoints + "  " + skillNames[index] + " (cost " + cost + ")" + "    ;;-1;;" + index + ";;0;;0"
            menuLine += 1
            index += 1
        endwhile

        ; Sort the list by skillpoints, so skills with highest investments appear first.
        entries = PO3_SKSEFunctions.SortArrayString(entries)
        ReverseStringArray(entries)

        entries[0] = "--- Increase Which Skill? (" + player.GetGoldAmount() + " gold) ---;;-1;;0;;-2;;0"
        entries[19] = " ;;-1;;-2;;0;;0"
        entries[20] = "=== Done ===;;-1;;0;;999;;0"
        ; the 4 numbers separated by ";;" seem to be: parent, id, callback, haschildren


        menu.ResetMenu()
		menu.SetPropertyStringA("appendEntries", entries)
		menu.OpenMenu()

		int selected = menu.GetResultFloat() as int
		if selected == 999 || selected == -1
			;consoleutil.printmessage("Exited ListMenu")
		    bLoop = false
		elseif selected >= 0 
			;consoleutil.printmessage("ListMenu: selected " + selected + " (" + skillNames[selected] + ")")
			int cost = CostToLevelSkillByIndex(selected)
            int remainder = player.GetGoldAmount() - cost
			; level up skill # selected
			;handle the level up
			
			if(remainder < 0)
				SkillXPMenuExceedCost.show(cost)
			elseif (ConfirmRaiseSkillMessage.show(player.GetGoldAmount(), cost) > 0)
				; do nothing - player chose not to spend the gold
			else
				string skillName = SkillNames[selected]
                if TryToRaiseSkill(skillName)
                    ; update title, since player gold will have changed
                    entries[0] = "--- Increase Which Skill? (" + player.GetGoldAmount() + " gold remaining) ---;;-1;;0;;0;;0"
                    ; successfully raised skill by 1
                    ; xxx Count all skill increases, level up when >= MaxSkillIncreasesPerLevel
                    if !mcmOptions.normalXPFromSkills
                        skillIncreases += 1
                        if (skillIncreases >= MaxSkillIncreasesPerLevel)
                            skillIncreases = 0
                            ;GainLevel()
                            levelsToGain += 1
                            ;Game.SetPlayerExperience(0)
                        else
                            ; set XP to correct "proportion" of progress to next level, based on number of skill
                            ; points gained so far
                            ; Game.SetPlayerExperience(Game.GetExperienceForLevel(Game.GetPlayer().GetLevel()) * skillIncreases / 10.0)
                        endif
                    endif
                else
                    ; failed to raise skill (because of caps, etc)
                    SkillXPMenuCapReached.show()
                endif
			endif
		; update line (cost, etc)
		entries[selected+1] = skillNames[selected] + " (Lv " + (player.GetActorValue(skillNames[selected]) as int) + ", cost " + cost + ")" + ";;-1;;" + selected + ";;0;;0"
		endif
	endwhile

    if !mcmOptions.normalXPFromSkills
        float xpToGain = Game.GetExperienceForLevel(player.GetLevel() + levelsToGain) * skillIncreases / MaxSkillIncreasesPerLevel
        while levelsToGain > 0
            ;xpToGain += Game.GetExperienceForLevel(player.GetLevel() + levelsToGain - 1) + 1
            xpToGain += Game.GetExperienceForLevel(player.GetLevel() + levelsToGain - 1)
            levelsToGain -= 1
        endwhile
        
        Game.SetPlayerExperience(xpToGain + 1)
    endif
endfunction


; Try to raise the given skill by 1 point. If successful, deduct the gold cost. Return true if
; successful, false if not.
bool function TryToRaiseSkill(string skillName)
    Actor player = Game.GetPlayer()
    int cost = CostToLevelSkillbyName(skillName)
    int current_skill = player.getBaseActorValue(skillName) as int
    game.IncrementSkill(skillName)      ; we have to check if this hit the cap
    
    int raised_skill = player.getBaseActorValue(skillName) as int; 
    
    if(current_skill < raised_skill)
        ; skill was incremented successfully
        player.RemoveItem(GoldBase, cost)
        return true
    else
        return false
    endif			
endfunction



function ReverseStringArray(string[] strings)
    int len = strings.Length
    int index = 0
    while index < Math.Floor(len/2.0)
        string str = strings[index]
        strings[index] = strings[len - index - 1]
        strings[len - index - 1] = str
        index += 1
    endwhile
endFunction


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
		returnValue = MagicSkillMenu.show(Game.GetPlayer().GetGoldAmount(), SkillLevels[0], SkillLevels[1], SkillLevels[2], SkillLevels[3], SkillLevels[4], SkillLevels[5])
	elseif(menu == 1)
		returnValue = ThiefSkillMenu.show(Game.GetPlayer().GetGoldAmount(), SkillLevels[0], SkillLevels[1], SkillLevels[2], SkillLevels[3], SkillLevels[4], SkillLevels[5])
	else
		returnValue = WarriorSkillMenu.show(Game.GetPlayer().GetGoldAmount(), SkillLevels[0], SkillLevels[1], SkillLevels[2], SkillLevels[3], SkillLevels[4], SkillLevels[5])
	endif
	
	return returnValue
EndFunction



; Function GainLevel()
; 	;Game.SetPlayerExperience(Game.GetExperienceForLevel(Game.GetPlayer().GetLevel()) + 1)
; 	Game.SetPlayerExperience(Game.GetExperienceForLevel(Game.GetPlayer().GetLevel()) * 10)
; 	;Game.SetPlayerLevel(Game.GetPlayer().GetLevel()+1)
; 	debug.notification("Leveled up!")
; EndFunction


; Returns the amount of Gold needed to go from character level currentLevel to currentLevel+1
; same formula as Dark Souls: cubic formula starting at level 12, linear below that
int Function GoldToLevel (int currentLevel)
	float cost 
	if currentLevel < 12
		cost = 656 + currentLevel*17
	else
		cost = (0.02*Math.Pow(currentLevel, 3) + 3.06*Math.Pow(currentLevel, 2) + 105.6*currentLevel - 895)
	endif
	return (cost * mcmOptions.costScalingFactor) as int
EndFunction


int Function GoldToLevelSkill (int skillLevel)
	; currentSkill = current level of the skill (0-100)
	if (skillLevel >= 5)
		return GoldToLevel(skillLevel - 4) / MaxSkillIncreasesPerLevel
	else
		return GoldToLevel(1) / MaxSkillIncreasesPerLevel
	endif
EndFunction


; Every 10 skill increases = 1 level-up, therefore the cost of levelling a skill is 1/10 of a level up.
; skills generally start at 5, so we convert this to 1
int Function CostToLevelSkillbyIndex(int skillIndex)
	return CostToLevelSkillbyName(SkillNames[skillIndex])
EndFunction


int Function CostToLevelSkillbyName(string skillName)
	int skillLevel = Game.GetPlayer().GetBaseActorValue(skillName) as int
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

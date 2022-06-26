scriptname aaaGoldXPEffectQuest extends Quest

bool                    property EnableQuest auto
aaaGoldXPUtilityQuest   property utilityquest auto
aaaGoldXPMenuQuest		property mcmOptions auto

string                  property fXPPerSkillRank                = "fXPPerSkillRank" autoreadonly
string                  property iTrainingNumAllowedPerLevel    = "iTrainingNumAllowedPerLevel" autoreadonly

float[]                 property SavedSkillUseMult  auto
float[]                 Property SavedSkillOffsetMult  auto
float                   Property SavedfXPPerSkillRank auto
int                     Property SavediTrainingNumAllowedPerLevel auto

Quest property trainerQuest auto
bool property trainerQuestSuspended auto


function maintenance()

	;if EnableQuest
		if game.getGameSettingFloat(fXPPerSkillRank) > 0.0
			saveGameSettings()
			debug.notification("Starting Gold Is Souls...")
		endif
		zeroGameSettings()
	;endif
	
endFunction

function SetEnabledState(bool enable)

    ; EnableQuest = enable
    
    if enable && !mcmOptions.enableGoldIsSouls
		;debug.notification("Starting Gold Is Souls...")
		mcmOptions.enableGoldIsSouls = true
		saveGameSettings()
		zeroGameSettings()
		start()
	elseif !enable && mcmOptions.enableGoldIsSouls
		;debug.notification("Stopping Gold Is Souls...")
		mcmOptions.enableGoldIsSouls = false
		revertGameSettings()
		stop()
	endif
endFunction


function zeroGameSettings()
    int i = 0
        
    while ( i < utilityquest.SkillNames.Length)
        ActorValueInfo avi = actorvalueinfo.GetActorValueInfoByName(utilityquest.SkillNames[i])
        avi.SetSkillUseMult(0.0)
        avi.SetSkillOffsetMult(0.0)
        i += 1
    EndWhile
    
    Game.SetGameSettingFloat(fXPPerSkillRank, 0.0)
    Game.SetGameSettingInt(iTrainingNumAllowedPerLevel, 0)
	
	; set skillIncreases so it captures player's progress to next level
	utilityquest.skillIncreases = Math.Floor((Game.GetPlayerExperience() * 10.0) / Game.GetExperienceForLevel(Game.GetPlayer().GetLevel()))
	
	if trainerQuest.IsRunning()
		trainerQuest.Stop()
		trainerQuestSuspended = true
	endif

endFunction



function saveGameSettings()
    int i = 0
    
    while(i < UtilityQuest.SkillNames.length)
        ActorValueInfo avi = actorvalueinfo.GetActorValueInfoByName(utilityquest.SkillNames[i])
            
        SavedSkillUseMult[i]    = avi.getSkillUseMult()
        SavedSkillOffsetMult[i] = avi.getSkillOffsetMult()
        
        i += 1
    endWhile
    
    SavediTrainingNumAllowedPerLevel    = game.getGameSettingInt(iTrainingNumAllowedPerLevel)
    SavedfXPPerSkillRank                = game.getGameSettingFloat(fXPPerSkillRank)
    

endFunction

function revertGameSettings()
    int i = 0
    
    while(i < UtilityQuest.SkillNames.length)
        ActorValueInfo avi = actorvalueinfo.GetActorValueInfoByName(utilityquest.SkillNames[i])
            
        avi.setSkillUseMult(SavedSkillUseMult[i])
        avi.setSkillOffsetMult(SavedSkillOffsetMult[i])
        
        i += 1
    endWhile
    
    game.setGameSettingInt(iTrainingNumAllowedPerLevel, SavediTrainingNumAllowedPerLevel)
    game.setGameSettingFloat(fXPPerSkillRank, SavedfXPPerSkillRank)
	
	if trainerQuestSuspended && !(trainerQuest.IsRunning())
		trainerQuest.Start()
		trainerQuestSuspended = false
	endif

endFunction


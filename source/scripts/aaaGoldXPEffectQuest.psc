scriptname aaaGoldXPEffectQuest extends Quest

;;
;;  script for quest of same name, always running
;;  that quest also has a player alias with a constant active magic effect 'aaagoldxpplayereffect' which receives
;;  onsleepstop events
;;

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


Event OnInit()
	maintenance()
endEvent


Event OnPlayerLoadGame()
	maintenance()
endEvent


function maintenance()

	if mcmOptions.enableGoldIsSouls
		if game.getGameSettingFloat(fXPPerSkillRank) > 0.0
			debug.notification("Starting Gold Is Souls...")
			SetEnabledState(true)
		else
			; Mod already started in this savegame
			zeroGameSettings()
		endif
	endif
	
endFunction


function SetEnabledState(bool enable)
    
    if enable 
		;debug.notification("Starting Gold Is Souls...")
		mcmOptions.enableGoldIsSouls = true
		saveGameSettings()
		zeroGameSettings()
		;self.start()
	else
		;debug.notification("Stopping Gold Is Souls...")
		mcmOptions.enableGoldIsSouls = false
		revertGameSettings()
		;self.stop()
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


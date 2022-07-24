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


; OnPlayerLoadGame events are only sent to the PLAYER (or aliases)


function maintenance()

	;ConsoleUtil.PrintMessage("Called effectquest.maintenance(), enableGoldIsSouls = " + mcmOptions.enableGoldIsSouls)
	if mcmOptions.enableGoldIsSouls
		if game.getGameSettingFloat(fXPPerSkillRank) > 0.0
			debug.notification("Starting Gold Is Souls...")
			;ConsoleUtil.PrintMessage("fXPPerSkillRank > 0, calling SetEnabledState(true)")
			SetEnabledState(true)
		else
			; Mod already started in this savegame
			;ConsoleUtil.PrintMessage("fXPPerSkillRank <= 0, calling zeroGameSettings()")
			zeroGameSettings()
		endif
	endif
	
endFunction


function SetEnabledState(bool enable)
    
	;ConsoleUtil.PrintMessage("Called SetEnabledState(), enableGoldIsSouls = " + mcmOptions.enableGoldIsSouls + ", enable = " + enable)
    if enable 
		; end up here if game started or loaded, and fXPPerSkillRank > 0,
		; therefore mod has not been (properly) enabled
		; Also called when mod enabled in MCM
		mcmOptions.enableGoldIsSouls = true
		saveGameSettings()
		zeroGameSettings()
		;self.start()
	else
		; called when mod disabled in MCM
		mcmOptions.enableGoldIsSouls = false
		revertGameSettings()
		;self.stop()
	endif
endFunction


function zeroGameSettings()
    int i = 0
    
    while ( i < utilityquest.SkillNames.Length)
		;Message("zeroing SkillUseMult for " + utilityquest.SkillNames[i])
        ActorValueInfo avi = actorvalueinfo.GetActorValueInfoByName(utilityquest.SkillNames[i])
        avi.SetSkillUseMult(0.0)
        avi.SetSkillOffsetMult(0.0)
        i += 1
    EndWhile
    
    Game.SetGameSettingFloat(fXPPerSkillRank, 0.0)
    Game.SetGameSettingInt(iTrainingNumAllowedPerLevel, 0)
	;ConsoleUtil.PrintMessage("set fXPPerSkillRank, now = " + Game.GetGameSettingFloat(fXPPerSkillRank))

	; set skillIncreases so it captures player's progress to next level
	utilityquest.skillIncreases = Math.Floor((Game.GetPlayerExperience() * 10.0) / Game.GetExperienceForLevel(Game.GetPlayer().GetLevel()))
	
	if trainerQuest.IsRunning()
		trainerQuest.Stop()
		trainerQuestSuspended = true
	endif

endFunction



function saveGameSettings()
    int i = 0
    
	;Message("Called saveGameSettings()")
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



scriptname aaaGoldXPEffectQuest extends Quest

bool                    property EnableQuest auto
aaaGoldXPUtilityQuest   property utilityquest auto

string                  property fXPPerSkillRank                = "fXPPerSkillRank" autoreadonly
string                  property iTrainingNumAllowedPerLevel    = "iTrainingNumAllowedPerLevel" autoreadonly

float[]                 property SavedSkillUseMult  auto
float[]                 Property SavedSkillOffsetMult  auto
float                   Property SavedfXPPerSkillRank auto
int                     Property SavediTrainingNumAllowedPerLevel auto

function maintenance()

    if(EnableQuest)
        ;Set global settings these are not persistent via saves
        ;Debug.notification("maintenance called")
        saveGameSettings()
        zeroGameSettings()
        
    endif

endFunction

function setState(bool enable = true)

    EnableQuest = enable
    
    if(enable)
		debug.notification("Starting Gold Is XP...")
		saveGameSettings()
		zeroGameSettings()
		start()
	else
		debug.notification("Stopping Gold Is XP...")
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

endFunction


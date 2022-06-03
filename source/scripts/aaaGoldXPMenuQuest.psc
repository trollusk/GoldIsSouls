Scriptname aaaGoldXPMenuQuest extends SKI_ConfigBase  

aaaGoldXPUtilityQuest Property UtilityQuest auto
aaaGoldXPEffectQuest  Property EffectQuest auto

;vars need to be global so that menu scripts and event scripts operate on the same config

GlobalVariable Property aaaGoldXPBuffered auto
GlobalVariable Property aaaGoldXPSkillXPBuffered auto
GlobalVariable Property aaaGoldXPVersion auto


;Text Properties
String Property SliderLabelBase auto
String Property SliderLabelCoefficient auto
String Property SliderLabelConstant auto
String Property SliderLabelSkillCostCoefficient auto
String Property SliderLabelSkillCostConstant auto
String Property SliderLabelSkillGainCoefficient auto
String Property SliderLabelSkillGainConstant auto
String Property SliderLabelSkillIncreasesPerLevel auto
String Property SliderLabelReductionMult auto
String Property SliderLabelVersion auto


String Property SliderLabelDebugCurrentXP auto
String Property SliderLabelDebugSkillXP auto

String Property ToggleLabelExponential auto
String Property ToggleLabelReduction auto
String Property ToggleLabelGoldXPEnable Auto

String Property LabelMenuProfiles auto

String[] Property LabelsMenuProfile auto
String[] Property LabelsMenuProfileFISS auto
String[] LabelsMenuProfileCurrent
String[] Property FISSConfigFiles auto

String Property LabelTextSave auto
String Property LabelTextLoad auto
String Property ValueTextSave auto
String Property ValueTextLoad auto



String Property HighlightXPEquation auto
String Property HighlightSkillEquation auto
String Property HighlightSkillGain auto
String Property HighlightSkillMaxPerLevel auto
String Property HighlightReductionEquation auto
String Property HighlightExponentialEnable auto
String Property HighlightReductionEnable auto
String Property HighlightXPEquationAlt auto
string Property HighlightMenuProfiles auto

String Property HeaderXPSettings auto
String Property HeaderSkillXPSettings auto
String Property HeaderGoldSettings auto

String Property GS_VANILLA_SKILL_GAIN_CONSTANT = "fXPLevelUpBase" auto
String Property GS_VANILLA_SKILL_GAIN_COEFFICIENT = "fXPLevelUpMult" auto

String Property IconLocation auto

int Property IndexProfilesDefault auto
int Property IndexProfilesVanillaSkillGain auto
int Property IndexProfilesVanillaLevelCurve auto
int Property IndexProfilesVanillaSkillGainNLevelCurve auto
int Property IndexProfilesStartCustom auto


int SliderBaseID
int SliderCoefficientID
int SliderConstantID
int SliderSkillCoefficientID
int SliderSkillConstantID
int SliderSkillGainConstantID
int SliderSkillGainCoefficientID
int SliderSkillMaxPerLevelID
int SliderReductionMultID
int MenuProfileID
int TextLoadID
int TextSaveID

int SliderGoldLogPowerID
int ToggleExponentialID
int ToggleReductionID
int ToggleGoldXPEnableID

int IndexProfilesCurrent = 0

Spell Property GoldXPSpell auto


;loadvalues
String Property ValueExponentialEnable 			= "ExponentialEnable" autoreadonly
String Property ValueExponentialBase			= "ExponentialBase" autoreadonly
String Property ValueExponentialCoefficient		= "ExponentialCoefficient" autoreadonly
String Property ValueExponentialConstant		= "ExponentialConstant" autoreadonly
String Property ValueSkillXPCoefficient			= "SkillXPCoefficient" autoreadonly
String Property ValueSkillXPConstant			= "SkillXPConstant" autoreadonly
String Property ValueSkillXPGainCoefficient 	= "SkillXPGainCoefficient" autoreadonly
String Property ValueSkillXPGainConstant		= "SkillXPGainConstnat" autoreadonly
String Property ValueReductionMult				= "ReductionMult" autoreadonly
String Property ValueMaxSkillIncreasesPerLevel	= "MaxSkillIncreasesPerLevel" autoreadonly
; xxx
String Property ValueConsumeGold	 			= "ConsumeGold" autoreadonly

int ToggleConsumeGoldID


Event OnPageReset(string page)
	if(page == "")
		LoadCustomContent(IconLocation)
		return
	endif
	
	UnloadCustomContent()

	if(page == "Settings")
		
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)
		
		FISSInterface fiss = FISSFactory.getFISS()
		int saveFlags = OPTION_FLAG_DISABLED
		
		if(fiss != none)
			if(IndexProfilesCurrent >= IndexProfilesStartCustom)
				saveFlags = OPTION_FLAG_NONE
			endif
			
			LabelsMenuProfileCurrent = LabelsMenuProfileFISS
			
		else
			LabelsMenuProfileCurrent = LabelsMenuProfile
		endif
			
		
		
		MenuProfileID					= AddMenuOption(LabelMenuProfiles, LabelsMenuProfileCurrent[IndexProfilesCurrent])
		TextSaveID						= AddTextOption(LabelTextSave, ValueTextSave, saveFlags)
		TextLoadID						= AddTextOption(LabelTextLoad, ValueTextLoad)
		
		;AddHeaderOption(HeaderXPSettings)
		;ToggleExponentialID				= AddToggleOption(ToggleLabelExponential, UtilityQuest.ExponentialEnable)
		;SliderBaseID 					= AddSliderOption(SliderLabelBase, UtilityQuest.ExponentialBase, "{3}")
		;SliderCoefficientID 			= AddSliderOption(SliderLabelCoefficient, UtilityQuest.ExponentialCoefficient)
		;SliderConstantID				= AddSliderOption(SliderLabelConstant, UtilityQuest.ExponentialConstant)
		
		; xxx
		AddHeaderOption(HeaderGoldSettings)
		ToggleConsumeGoldID				= AddToggleOption("Consume gold", UtilityQuest.consumeGold)
		
		
		;SetCursorPosition(1)
		;AddHeaderOption(HeaderSkillXPSettings)
		;SliderSkillCoefficientID 		= AddSliderOption(SliderLabelSkillCostCoefficient, UtilityQuest.SkillXPCoefficient, "{1}")
		;SliderSkillConstantID			= AddSliderOption(SliderLabelSkillCostConstant, UtilityQuest.SkillXPConstant, "{1}")
		;SliderSkillGainCoefficientID	= AddSliderOption(SliderLabelSkillGainCoefficient, UtilityQuest.SkillXPGainCoefficient, "{1}")
		;SliderSkillGainConstantID		= AddSliderOption(SliderLabelSkillGainConstant, UtilityQuest.SkillXPGainConstant)
		;SliderSkillMaxPerLevelID		= AddSliderOption(SliderLabelSkillIncreasesPerLevel, UtilityQuest.MaxSkillIncreasesPerLevel)
		
		;AddHeaderOption(HeaderGoldSettings)
		;ToggleReductionID				= AddToggleOption(ToggleLabelReduction, UtilityQuest.ReductionMult > 0.0)
		;SliderReductionMultID			= AddSliderOption(SliderLabelReductionMult, UtilityQuest.ReductionMult, "{2}")
		
		
	elseif( page == "Debug")
		SetCursorPosition(0)
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		AddTextOption(SliderLabelVersion, aaaGoldXPVersion.getValue() as int , OPTION_FLAG_DISABLED)
		ToggleGoldXPEnableID			= AddToggleOption(ToggleLabelGoldXPEnable, EffectQuest.EnableQuest)
		SetCursorPosition(1)
		if (UtilityQuest.consumeGold)
			AddTextOption("EffectQuest running?", EffectQuest.IsRunning(), OPTION_FLAG_DISABLED)
			AddTextOption("EffectQuest.EnableQuest", EffectQuest.EnableQuest, OPTION_FLAG_DISABLED)
			AddTextOption("Gold in inventory", Game.GetPlayer().GetGoldAmount() as int, OPTION_FLAG_DISABLED)
			AddTextOption("Cost to increase lowest skill", (UtilityQuest.GoldXPToLevelSkill(UtilityQuest.getLowestSkillValue())) as int, OPTION_FLAG_DISABLED)
			AddTextOption("Cost to increase highest skill", (UtilityQuest.GoldXPToLevelSkill(UtilityQuest.getHighestSkillValue())) as int, OPTION_FLAG_DISABLED)
		;else
		;	AddTextOption(SliderLabelDebugCurrentXP, aaaGoldXPBuffered.getValue() as int, OPTION_FLAG_DISABLED)
		;	AddTextOption(SliderLabelDebugSkillXP, aaaGoldXPSkillXPBuffered.getValue() as int, OPTION_FLAG_DISABLED)
		endif
	endif
	
EndEvent

Event OnOptionMenuOpen(int option)
	if(option == MenuProfileID)
		SetMenuDialogStartIndex(IndexProfilesCurrent)
		SetMenuDialogDefaultIndex(IndexProfilesDefault)
		SetMenuDialogOptions(LabelsMenuProfileCurrent)
	EndIf
EndEvent

Event OnOptionMenuAccept(int option, int index)

	if(option == MenuProfileID)
		IndexProfilesCurrent = index
		SetMenuOptionValue(option, LabelsMenuProfileCurrent[index])
		
		if(IndexProfilesCurrent >= IndexProfilesStartCustom)
			SetOptionFlags(TextSaveID, OPTION_FLAG_NONE)
		else
			SetOptionFlags(TextSaveID, OPTION_FLAG_DISABLED)
		endif
		
	EndIf
		
EndEvent

Event OnOptionSelect(int option)

	if(option == ToggleExponentialID)
		
		UtilityQuest.ExponentialEnable = !UtilityQuest.ExponentialEnable
		
		if(UtilityQuest.ExponentialEnable)
			SetOptionFlags(SliderBaseID, OPTION_FLAG_NONE, true)
		else
			SetOptionFlags(SliderBaseID, OPTION_FLAG_DISABLED, true)
		endif
		
		
		SetToggleOptionValue(option, UtilityQuest.ExponentialEnable)

	; xxx
	elseif(option == ToggleConsumeGoldID)
		
		UtilityQuest.consumeGold = !UtilityQuest.consumeGold
		SetToggleOptionValue(option, UtilityQuest.consumeGold)
		
	elseif(option == ToggleReductionID)
		bool bEnable = UtilityQuest.ReductionMult == 0
		SetToggleOptionValue(option, bEnable, true)
		
		if(bEnable)
			UtilityQuest.ReductionMult = UtilityQuest.ReductionMultDefault
		else
			UtilityQuest.ReductionMult = 0.0 
		endif
		
		SetSliderOptionValue(SliderReductionMultID, UtilityQuest.ReductionMult, "{2}", false)
		
	elseif(option == ToggleGoldXPEnableID)
		bool bEnable = !(EffectQuest.EnableQuest)
		debug.notification("Setting gold is xp to " + bEnable)
		SetToggleOptionValue(option, bEnable)
	
		EffectQuest.SetState(bEnable)
		
	elseif(option == TextSaveID)
		saveProfile(IndexProfilesCurrent)
	elseif(option == TextLoadID)
		loadProfile(IndexProfilesCurrent)
		
	endif
EndEvent

Event OnOptionSliderOpen(int option)

	
	if(option == SliderBaseID)
		SetSliderDialogStartValue(UtilityQuest.ExponentialBase)
		SetSliderDialogDefaultValue(UtilityQuest.ExponentialBaseDefault)
		SetSliderDialogRange(1.001, 1.25)
		SetSliderDialogInterval(0.001)
	elseif(option == SliderCoefficientID)
		SetSliderDialogStartValue(UtilityQuest.ExponentialCoefficient)
		SetSliderDialogDefaultValue(UtilityQuest.ExponentialCoefficientDefault)
		SetSliderDialogRange(0, 2000)
		SetSliderDialogInterval(10)
	elseif(option == SliderConstantID)
		SetSliderDialogStartValue(UtilityQuest.ExponentialConstant)
		SetSliderDialogDefaultValue(UtilityQuest.ExponentialConstantDefault)
		SetSliderDialogRange(0, 2500)
		SetSliderDialogInterval(10)
	elseif(option == SliderSkillCoefficientID)
		SetSliderDialogStartValue(UtilityQuest.SkillXPCoefficient)
		SetSliderDialogDefaultValue(UtilityQuest.SkillXPCoefficientDefault)
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.1)
	elseif(option == SliderSkillConstantID)
		SetSliderDialogStartValue(UtilityQuest.SkillXPConstant)
		SetSliderDialogDefaultValue(UtilityQuest.SkillXPConstantDefault)
		SetSliderDialogRange(0, 20)
		SetSliderDialogInterval(0.1)
	elseif(option == SliderSkillGainCoefficientID)
		SetSliderDialogStartValue(UtilityQuest.SkillXPGainCoefficient)
		SetSliderDialogDefaultValue(UtilityQuest.SkillXPGainCoefficientDefault)
		SetSliderDialogRange(0, 50)
		SetSliderDialogInterval(0.1)
	elseif(option == SliderSkillGainConstantID)
		SetSliderDialogStartValue(UtilityQuest.SkillXPGainConstant)
		SetSliderDialogDefaultValue(UtilityQuest.SkillXPGainConstantDefault)
		SetSliderDialogRange(0, 1000)
		SetSliderDialogInterval(1)
	elseif(option == SliderSkillMaxPerLevelID)
		SetSliderDialogStartValue(UtilityQuest.MaxSkillIncreasesPerLevel)
		SetSliderDialogDefaultValue(UtilityQuest.MaxSkillIncreasesPerLevelDefault)
		SetSliderDialogRange(2, 25)
		SetSliderDialogInterval(1)
	elseif(option == SliderReductionMultID)
		SetSliderDialogStartValue(UtilityQuest.ReductionMult)
		SetSliderDialogDefaultValue(UtilityQuest.ReductionMultDefault)
		SetSliderDialogRange(0, 5)
		SetSliderDialogInterval(0.01)
	endif
EndEvent

Event OnOptionSliderAccept(int option, float value)


	if(option == SliderBaseID)
		
		UtilityQuest.ExponentialBase = value
		SetSliderOptionValue(option, value, "{3}")
	elseif(option == SliderCoefficientID)
		UtilityQuest.ExponentialCoefficient = value
		SetSliderOptionValue(option, value, "{0}")
	elseif(option == SliderConstantID)
		UtilityQuest.ExponentialConstant = value
		SetSliderOptionValue(option, value, "{0}")
	elseif(option == SliderSkillCoefficientID)
		UtilityQuest.SkillXPCoefficient = value
		SetSliderOptionValue(option, value, "{1}")
	elseif(option == SliderSkillConstantID)
		UtilityQuest.SkillXPConstant = value
		SetSliderOptionValue(option, value, "{1}")
	elseif(option == SliderSkillGainCoefficientID)
		UtilityQuest.SkillXPGainCoefficient = value
		SetSliderOptionValue(option, value, "{1}")
	elseif(option == SliderSkillGainConstantID)
		UtilityQuest.SkillXPGainConstant = value
		SetSliderOptionValue(option, value, "{0}")
	elseif(option == SliderSkillMaxPerLevelID)
		UtilityQuest.MaxSkillIncreasesPerLevel = value as int
		SetSliderOptionValue(option, value, "{0}")
	elseif(option == SliderReductionMultID)
		UtilityQuest.ReductionMult = value
		SetSliderOptionValue(option, value, "{2}", true)
		bool bEnable = value > 0.0
		SetToggleOptionValue(ToggleReductionID, bEnable)
	endif
	
EndEvent

Event OnOptionHighlight(int option)
	if(option == SliderBaseID || option == SliderCoefficientID || option == SliderConstantID)
		if(UtilityQuest.ExponentialBase > 1.0)
			SetInfoText(HighlightXPEquation)
		else	
			SetInfoText(HighlightXPEquationAlt)
		endif
	elseif(option == SliderSkillCoefficientID || option == SliderSkillConstantID)
		SetInfoText(HighlightSkillEquation)
	elseif(option == SliderSkillGainCoefficientID || option == SliderSkillGainConstantID)
		SetInfoText(HighlightSkillGain)
	elseif(option == SliderSkillMaxPerLevelID)
		SetInfoText(HighlightSkillMaxPerLevel)
	elseif(option == SliderReductionMultID)
		SetInfoText(HighlightReductionEquation)
	elseif(option == ToggleExponentialID)
		SetInfoText(HighlightExponentialEnable)
	elseif(option == ToggleReductionID)
		SetInfoText(HighlightReductionEnable)
	elseif(option == ToggleConsumeGoldID)
		SetInfoText("The cost for leveling up a skill must be paid from your carried gold.")
	elseif(option == MenuProfileID)
		SetInfoText(HighlightMenuProfiles)

	endif
EndEvent


;===========================================================Utility Functions=========================================
function loadProfile(int index)
	if(index == IndexProfilesDefault)
		UtilityQuest.ExponentialBase 			= UtilityQuest.ExponentialBaseDefault
		UtilityQuest.ExponentialCoefficient		= UtilityQuest.ExponentialCoefficientDefault
		UtilityQuest.ExponentialConstant 		= UtilityQuest.ExponentialConstantDefault
		UtilityQuest.ExponentialEnable 			= UtilityQuest.ExponentialEnableDefault
		; xxx
		UtilityQuest.consumeGold	 			= false
		
		UtilityQuest.SkillXPCoefficient			= UtilityQuest.SkillXPCoefficientDefault
		UtilityQuest.SkillXPConstant			= UtilityQuest.SkillXPConstantDefault
		UtilityQuest.SkillXPGainCoefficient		= UtilityQuest.SkillXPGainCoefficientDefault
		UtilityQuest.SkillXPGainConstant		= UtilityQuest.SkillXPGainConstantDefault
		
		UtilityQuest.MaxSkillIncreasesPerLevel	= UtilityQuest.MaxSkillIncreasesPerLevelDefault
		UtilityQuest.ReductionMult				= UtilityQuest.ReductionMultDefault
	elseif(index == IndexProfilesVanillaSkillgain)
		UtilityQuest.ExponentialBase 			= UtilityQuest.ExponentialBaseDefault
		UtilityQuest.ExponentialCoefficient		= UtilityQuest.ExponentialCoefficientDefault
		UtilityQuest.ExponentialConstant 		= UtilityQuest.ExponentialConstantDefault
		UtilityQuest.ExponentialEnable 			= UtilityQuest.ExponentialEnableDefault
		UtilityQuest.consumeGold	 			= false
		
		UtilityQuest.SkillXPCoefficient			= 1.0 
		UtilityQuest.SkillXPConstant			= 1.0 
		UtilityQuest.SkillXPGainCoefficient		= game.getGameSettingFloat(GS_VANILLA_SKILL_GAIN_COEFFICIENT)
		UtilityQuest.SkillXPGainConstant		= game.getGameSettingFloat(GS_VANILLA_SKILL_GAIN_CONSTANT)
		
		UtilityQuest.MaxSkillIncreasesPerLevel	= UtilityQuest.MaxSkillIncreasesPerLevelDefault
		UtilityQuest.ReductionMult				= UtilityQuest.ReductionMultDefault
	elseif(index == IndexProfilesVanillaLevelCurve)
		UtilityQuest.ExponentialBase 			= UtilityQuest.ExponentialBaseDefault
		UtilityQuest.ExponentialCoefficient		= 250
		UtilityQuest.ExponentialConstant 		= 750
		UtilityQuest.ExponentialEnable 			= false
		UtilityQuest.consumeGold	 			= false
		
		UtilityQuest.SkillXPCoefficient			= UtilityQuest.SkillXPCoefficientDefault
		UtilityQuest.SkillXPConstant			= UtilityQuest.SkillXPConstantDefault
		UtilityQuest.SkillXPGainCoefficient		= UtilityQuest.SkillXPGainCoefficientDefault
		UtilityQuest.SkillXPGainConstant		= UtilityQuest.SkillXPGainConstantDefault
		
		UtilityQuest.MaxSkillIncreasesPerLevel	= UtilityQuest.MaxSkillIncreasesPerLevelDefault
		UtilityQuest.ReductionMult				= UtilityQuest.ReductionMultDefault
	
	elseif(index == IndexProfilesVanillaSkillGainNLevelCurve)
		UtilityQuest.ExponentialBase 			= UtilityQuest.ExponentialBaseDefault
		UtilityQuest.ExponentialCoefficient		= 250
		UtilityQuest.ExponentialConstant 		= 750
		UtilityQuest.ExponentialEnable 			= false
		UtilityQuest.consumeGold	 			= false
		
		UtilityQuest.SkillXPCoefficient			= 1.0 
		UtilityQuest.SkillXPConstant			= 1.0 
		UtilityQuest.SkillXPGainCoefficient		= game.getGameSettingFloat(GS_VANILLA_SKILL_GAIN_COEFFICIENT)
		UtilityQuest.SkillXPGainConstant		= game.getGameSettingFloat(GS_VANILLA_SKILL_GAIN_CONSTANT)
		
		UtilityQuest.MaxSkillIncreasesPerLevel	= UtilityQuest.MaxSkillIncreasesPerLevelDefault
		UtilityQuest.ReductionMult				= UtilityQuest.ReductionMultDefault
	elseif(index >= IndexProfilesStartCustom && index < LabelsMenuProfileCurrent.length)
	
		FISSInterface fiss = FISSFactory.getFISS()
		
		if(fiss == none)
			loadProfile(IndexProfilesDefault)
			updateMCM()
			return
		endif
		
		fiss.beginLoad(FISSConfigFiles[index - IndexProfilesStartCustom])
	
		UtilityQuest.ExponentialBase 			= fiss.loadFloat(ValueExponentialBase)
		UtilityQuest.ExponentialCoefficient		= fiss.loadFloat(ValueExponentialCoefficient)
		UtilityQuest.ExponentialConstant 		= fiss.loadFloat(ValueExponentialConstant)
		UtilityQuest.ExponentialEnable 			= fiss.loadBool(ValueExponentialEnable)
			
		UtilityQuest.SkillXPCoefficient			= fiss.loadFloat(ValueSkillXPCoefficient)
		UtilityQuest.SkillXPConstant			= fiss.loadFloat(ValueSkillXPConstant)
		UtilityQuest.SkillXPGainCoefficient		= fiss.loadFloat(ValueSkillXPGainCoefficient)
		UtilityQuest.SkillXPGainConstant		= fiss.loadFloat(ValueSkillXPGainConstant)
		
		UtilityQuest.MaxSkillIncreasesPerLevel	= fiss.loadInt(ValueMaxSkillIncreasesPerLevel)
		UtilityQuest.ReductionMult				= fiss.loadFloat(ValueReductionMult)
		
		String err = fiss.endLoad()
		
		if(err != "")
			Debug.notification("FISS load err: " + err)
		endif
		
	endif

	updateMCM()
		
endFunction

function saveProfile(int index)

	if(index < IndexProfilesStartCustom || index >= LabelsMenuProfileCurrent.length)
		return
	else
		FISSInterface fiss = FISSFactory.getFISS()
		
		if(fiss == none)
			return
		endif
		
		fiss.beginSave(FISSConfigFiles[index - IndexProfilesStartCustom], modName)
		
		fiss.saveFloat(ValueExponentialBase, UtilityQuest.ExponentialBase)			
		fiss.saveFloat(ValueExponentialCoefficient, UtilityQuest.ExponentialCoefficient)		
		fiss.saveFloat(ValueExponentialConstant, UtilityQuest.ExponentialConstant)		
		fiss.saveBool(ValueExponentialEnable, UtilityQuest.ExponentialEnable)		
		                                                    	
		fiss.saveFloat(ValueSkillXPCoefficient, UtilityQuest.SkillXPCoefficient)		
		fiss.saveFloat(ValueSkillXPConstant, UtilityQuest.SkillXPConstant)		
		fiss.saveFloat(ValueSkillXPGainCoefficient, UtilityQuest.SkillXPGainCoefficient)	
		fiss.saveFloat(ValueSkillXPGainConstant, UtilityQuest.SkillXPGainConstant)	
		                                                    
		fiss.saveInt(ValueMaxSkillIncreasesPerLevel, UtilityQuest.MaxSkillIncreasesPerLevel)
		fiss.saveFloat(ValueReductionMult, UtilityQuest.ReductionMult)			
		
		string err = fiss.endSave()
		
		if(err != "")
			Debug.notification("FISS save err: " + err)
		endif
	endif
endFunction

function updateMCM()
	SetSliderOptionValue(SliderBaseID, UtilityQuest.ExponentialBase, "{3}", true)
	SetSliderOptionValue(SliderCoefficientID, UtilityQuest.ExponentialCoefficient, "{0}", true)
	SetSliderOptionValue(SliderConstantID, UtilityQuest.ExponentialConstant, "{0}", true)
	SetToggleOptionValue(ToggleExponentialID, UtilityQuest.ExponentialEnable, true)
	; xxx
	SetToggleOptionValue(ToggleConsumeGoldID, UtilityQuest.consumeGold, true)
	
	SetSliderOptionValue(SliderSkillCoefficientID, UtilityQuest.SkillXPCoefficient, "{1}", true)
	SetSliderOptionValue(SliderSkillConstantID, UtilityQuest.SkillXPConstant, "{1}", true)
	SetSliderOptionValue(SliderSkillGainCoefficientID, UtilityQuest.SkillXPGainCoefficient, "{1}", true)
	SetSliderOptionValue(SliderSkillGainConstantID, UtilityQuest.SkillXPGainConstant, "{0}", true)
	
	SetSliderOptionValue(SliderSkillMaxPerLevelID, UtilityQuest.MaxSkillIncreasesPerLevel, "{0}", true)
	SetSliderOptionValue(SliderReductionMultID, UtilityQuest.ReductionMult, "{2}", false)
EndFunction



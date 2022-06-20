Scriptname aaaGoldXPMenuQuest extends SKI_ConfigBase  

aaaGoldXPUtilityQuest Property UtilityQuest auto
aaaGoldXPEffectQuest  Property EffectQuest auto

;vars need to be global so that menu scripts and event scripts operate on the same config

; GlobalVariable Property aaaGoldXPBuffered auto
; GlobalVariable Property aaaGoldXPSkillXPBuffered auto
; GlobalVariable Property aaaGoldXPVersion auto


;Text Properties
; String Property SliderLabelBase auto
; String Property SliderLabelCoefficient auto
; String Property SliderLabelConstant auto
; String Property SliderLabelSkillCostCoefficient auto
; String Property SliderLabelSkillCostConstant auto
; String Property SliderLabelSkillGainCoefficient auto
; String Property SliderLabelSkillGainConstant auto
; String Property SliderLabelSkillIncreasesPerLevel auto
; String Property SliderLabelReductionMult auto
; String Property SliderLabelVersion auto


; String Property SliderLabelDebugCurrentXP auto
; String Property SliderLabelDebugSkillXP auto

; String Property ToggleLabelExponential auto
; String Property ToggleLabelReduction auto
;String Property ToggleLabelGoldXPEnable Auto

; String Property LabelMenuProfiles auto

; String[] Property LabelsMenuProfile auto
; String[] Property LabelsMenuProfileFISS auto
; String[] LabelsMenuProfileCurrent
; String[] Property FISSConfigFiles auto

; String Property LabelTextSave auto
; String Property LabelTextLoad auto
; String Property ValueTextSave auto
; String Property ValueTextLoad auto

; String Property HighlightXPEquation auto
; String Property HighlightSkillEquation auto
; String Property HighlightSkillGain auto
; String Property HighlightSkillMaxPerLevel auto
; String Property HighlightReductionEquation auto
; String Property HighlightExponentialEnable auto
; String Property HighlightReductionEnable auto
; String Property HighlightXPEquationAlt auto
; string Property HighlightMenuProfiles auto

; String Property HeaderXPSettings auto
; String Property HeaderSkillXPSettings auto
String Property HeaderGoldSettings auto

; String Property GS_VANILLA_SKILL_GAIN_CONSTANT = "fXPLevelUpBase" auto
; String Property GS_VANILLA_SKILL_GAIN_COEFFICIENT = "fXPLevelUpMult" auto

String Property IconLocation auto

; int Property IndexProfilesDefault auto
; int Property IndexProfilesVanillaSkillGain auto
; int Property IndexProfilesVanillaLevelCurve auto
; int Property IndexProfilesVanillaSkillGainNLevelCurve auto
; int Property IndexProfilesStartCustom auto


; int SliderBaseID
; int SliderCoefficientID
; int SliderConstantID
; int SliderSkillCoefficientID
; int SliderSkillConstantID
; int SliderSkillGainConstantID
; int SliderSkillGainCoefficientID
; int SliderSkillMaxPerLevelID
; int SliderReductionMultID
; int MenuProfileID
; int TextLoadID
; int TextSaveID

; int SliderGoldLogPowerID
; int ToggleExponentialID
; int ToggleReductionID
int ToggleGoldXPEnableID
int UninstallID

; int IndexProfilesCurrent = 0

; Spell Property GoldXPSpell auto


;loadvalues
; String Property ValueExponentialEnable 			= "ExponentialEnable" autoreadonly
; String Property ValueExponentialBase			= "ExponentialBase" autoreadonly
; String Property ValueExponentialCoefficient		= "ExponentialCoefficient" autoreadonly
; String Property ValueExponentialConstant		= "ExponentialConstant" autoreadonly
; String Property ValueSkillXPCoefficient			= "SkillXPCoefficient" autoreadonly
; String Property ValueSkillXPConstant			= "SkillXPConstant" autoreadonly
; String Property ValueSkillXPGainCoefficient 	= "SkillXPGainCoefficient" autoreadonly
; String Property ValueSkillXPGainConstant		= "SkillXPGainConstnat" autoreadonly
; String Property ValueReductionMult				= "ReductionMult" autoreadonly
; String Property ValueMaxSkillIncreasesPerLevel	= "MaxSkillIncreasesPerLevel" autoreadonly
; xxx
;String Property ValueConsumeGold	 			= "ConsumeGold" autoreadonly

;int ToggleConsumeGoldID


Event OnPageReset(string page)
	if(page == "")
		LoadCustomContent(IconLocation, 50, 50)
		return
	endif
	
	UnloadCustomContent()

	if(page == "Settings")
		
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)
				
		AddHeaderOption(HeaderGoldSettings)
		;ToggleGoldXPEnableID			= AddToggleOption("Enable mod", EffectQuest.EnableQuest, OPTION_FLAG_NONE)
		UninstallID = AddTextOption("Uninstall Gold Is Souls", none, OPTION_FLAG_NONE)
		AddEmptyOption()
		AddHeaderOption("Debug info")
		AddEmptyOption()
		AddTextOption("Gold in inventory", Game.GetPlayer().GetGoldAmount() as int, OPTION_FLAG_DISABLED)
		AddTextOption("Cost to increase lowest skill", (UtilityQuest.GoldToLevelSkill(UtilityQuest.getLowestSkillValue())) as int, OPTION_FLAG_DISABLED)
		AddTextOption("Cost to increase highest skill", (UtilityQuest.GoldToLevelSkill(UtilityQuest.getHighestSkillValue())) as int, OPTION_FLAG_DISABLED)
		AddTextOption("Progress towards next level", UtilityQuest.skillIncreases as int, OPTION_FLAG_DISABLED)
	endif
	
EndEvent


Event OnOptionSelect(int option)
	
	if option == ToggleGoldXPEnableID
		if EffectQuest.EnableQuest
			EffectQuest.EnableQuest = !EffectQuest.EnableQuest
			EffectQuest.saveGameSettings()
			EffectQuest.zeroGameSettings()
			debug.messagebox("Gold Is Souls activated!")
		else	
			EffectQuest.EnableQuest = !EffectQuest.EnableQuest
			EffectQuest.revertGameSettings()
			debug.messagebox("Gold Is Souls has been disabled.")
		endif
	elseif option == UninstallID
		EffectQuest.revertGameSettings()
		debug.messagebox("Gold Is Souls has been uninstalled. Now save, quit and disable the .esp.")
	endif
EndEvent

Event OnOptionSliderOpen(int option)
	;
EndEvent

Event OnOptionSliderAccept(int option, float value)
	;
EndEvent

Event OnOptionHighlight(int option)
	; if(option == SliderBaseID || option == SliderCoefficientID || option == SliderConstantID)
		; if(UtilityQuest.ExponentialBase > 1.0)
			; SetInfoText(HighlightXPEquation)
		; else	
			; SetInfoText(HighlightXPEquationAlt)
		; endif
	; elseif(option == SliderSkillCoefficientID || option == SliderSkillConstantID)
		; SetInfoText(HighlightSkillEquation)
	; elseif(option == SliderSkillGainCoefficientID || option == SliderSkillGainConstantID)
		; SetInfoText(HighlightSkillGain)
	; elseif(option == SliderSkillMaxPerLevelID)
		; SetInfoText(HighlightSkillMaxPerLevel)
	; elseif(option == SliderReductionMultID)
		; SetInfoText(HighlightReductionEquation)
	; elseif(option == ToggleExponentialID)
		; SetInfoText(HighlightExponentialEnable)
	; elseif(option == ToggleReductionID)
		; SetInfoText(HighlightReductionEnable)
	if(option == ToggleGoldXPEnableID)
		SetInfoText("Enable or disable Gold Is Souls.")
	elseif(option == UninstallID)
		SetInfoText("Uninstall the mod and restore the normal Skyrim leveling system.")
	endif
EndEvent


function updateMCM()
	; SetSliderOptionValue(SliderBaseID, UtilityQuest.ExponentialBase, "{3}", true)
	; SetSliderOptionValue(SliderCoefficientID, UtilityQuest.ExponentialCoefficient, "{0}", true)
	; SetSliderOptionValue(SliderConstantID, UtilityQuest.ExponentialConstant, "{0}", true)
	; SetToggleOptionValue(ToggleExponentialID, UtilityQuest.ExponentialEnable, true)
	; 
	;SetToggleOptionValue(ToggleConsumeGoldID, UtilityQuest.consumeGold, true)
	;SetToggleOptionValue(ToggleGoldXPEnableID, EffectQuest.EnableQuest, true)
	
	; SetSliderOptionValue(SliderSkillCoefficientID, UtilityQuest.SkillXPCoefficient, "{1}", true)
	; SetSliderOptionValue(SliderSkillConstantID, UtilityQuest.SkillXPConstant, "{1}", true)
	; SetSliderOptionValue(SliderSkillGainCoefficientID, UtilityQuest.SkillXPGainCoefficient, "{1}", true)
	; SetSliderOptionValue(SliderSkillGainConstantID, UtilityQuest.SkillXPGainConstant, "{0}", true)
	
	; SetSliderOptionValue(SliderSkillMaxPerLevelID, UtilityQuest.MaxSkillIncreasesPerLevel, "{0}", true)
	; SetSliderOptionValue(SliderReductionMultID, UtilityQuest.ReductionMult, "{2}", false)
EndFunction



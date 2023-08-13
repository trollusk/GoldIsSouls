Scriptname aaaGoldWidgetQuest extends ReferenceAlias


iWant_Widgets Property iWidgets Auto
int property widgetID auto
int iconID = 0
MiscObject property goldBase auto
int WIDGET_TRANSPARENCY = 50


Event OnInit()
    RegisterForModEvent("iWantWidgetsReset", "OniWantWidgetsReset")
    RegisterForSingleUpdate(4.0)
EndEvent


Event OnPlayerLoadGame()
    RegisterForModEvent("iWantWidgetsReset", "OniWantWidgetsReset")
    RegisterForSingleUpdate(4.0)
EndEvent


Event OniWantWidgetsReset(String eventName, String strArg, Float numArg, Form sender)
    ; This event will only be called when a new game is created or the game is reloaded from a save.
    If eventName == "iWantWidgetsReset"

        iWidgets = sender as iWant_Widgets
        ; Skyrim screen is always 1280x720 in code, regardless of actual resolution
        int gold = Game.GetPlayer().GetGoldAmount() as int

        widgetID = iWidgets.loadText(gold as string, "$EverywhereFont", 18)
        iWidgets.setPos(widgetID, 1200, 710)     ; 1150,650
        iWidgets.setTransparency(widgetID, WIDGET_TRANSPARENCY)
        iWidgets.setVisible(widgetID, 1)

        iconID = iWidgets.loadWidget("goldwidget.dds", 1170, 708)
        iWidgets.setTransparency(iconID, WIDGET_TRANSPARENCY)
        iWidgets.setZoom(iconID, 14, 14)
        iWidgets.setVisible(iconID, 1)
    EndIf
EndEvent


Event OnUpdate()
    UpdateWidget()
    RegisterForSingleUpdate(4.0)
EndEvent


Function UpdateWidget()
    int gold = Game.GetPlayer().GetGoldAmount() as int
    iWidgets.setText(widgetID, gold as string)
EndFunction

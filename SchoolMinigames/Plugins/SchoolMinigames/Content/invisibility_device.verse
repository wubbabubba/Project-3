
using {/Fortnite.com/Devices}
using {/Fortnite.com/UI}
using {/Fortnite.com/Game}
using {/Fortnite.com/Characters}
using {/Fortnite.com/Playspaces}
using {/Verse.org/Simulation}
using {/Verse.org/Random}
using {/UnrealEngine.com/Temporary/Diagnostics}
using {/UnrealEngine.com/Temporary/UI}
using {/UnrealEngine.com/Temporary/SpatialMath}

invisibility_device := class(creative_device):
    #BELOW IS CARD INVIS STUFF ----------
    @editable
    CardDetector:conditional_button_device = conditional_button_device{}
    #ON BEGIN STARTS WHEN GAME STARTS
    OnBegin<override>()<suspends>:void=
        spawn:
            CheckForCard()
    CheckForCard()<suspends>:void=
         loop:
            Sleep(0.5)
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(IsAgent:agent = agent[Player]):
                    if(CardDetector.IsHoldingItem[IsAgent]): #decide inside brackets []
                        
                        HidePlayer(IsAgent)
                    else:
                        
                        ShowPlayer(IsAgent)
    ShowPlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Show()
    HidePlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Hide()


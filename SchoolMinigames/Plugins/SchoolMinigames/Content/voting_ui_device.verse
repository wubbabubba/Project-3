using { /Verse.org/Assets }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
S2M<localizes>(S:string):message="{S}"
voting_ui_device := class(creative_device):
    @editable StartVotingTrigger : trigger_device = trigger_device{}
    @editable StopVotingTrigger : trigger_device = trigger_device{}

    var VoteInfoPerAgent : [agent]?vote_info = map{}

    @editable VotingCandidates:[]voting_candidate=array:
        #voting_candidate{Texture:=Pump,Name:= "Classic"}
        #voting_candidate{Texture:=Pump, Name:= "Sniper Shootout"}
        #voting_candidate{Texture:=Pump, Name:= "One in the Chamber"}
        #voting_candidate{Texture:=Pump, Name:= "Ghost Boxfights"}
        #voting_candidate{Texture:=Pump, Name:= "Shield Skirmish"}
        #voting_candidate{Texture:=Pump, Name:= "Zone Wars"}
        voting_candidate{Texture:=Pump, Name:= "Mythic Mayhem"}
        voting_candidate{Texture:=Pump, Name:= "Throwable Throwdown"}
        voting_candidate{Texture:=Pump, Name:= "Fish Fight"}
        voting_candidate{Texture:=Pump, Name:= "Blade Blitz"}
        voting_candidate{Texture:=Pump, Name:= "One Shot"}


    @editable var ShuffledArray:[]voting_candidate = array{}


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
       StartVotingTrigger.TriggeredEvent.Subscribe(StartVoting)
       StopVotingTrigger.TriggeredEvent.Subscribe(StopVoting)
    StartVoting(MaybeAgent:?agent):void=

        set ShuffledArray = Shuffle(VotingCandidates)
        #for (Index :=0..ShuffledArray.length - 1):
        #if (ShuffledArray.length := 3):
          #  ShuffledArray.RemoveElement[3]

        Players:=GetPlayers()
        for(P:Players):
            AddUI(P)
    StopVoting(MaybeAgent:?agent):void=
        WinningIndex := Tally()
        Players:=GetPlayers()
        for(P:Players):
            RemoveUI(P)
            if(set VoteInfoPerAgent[P] = false){}
        if(VC:=ShuffledArray[WinningIndex]):
            VC.Activate()
    # Turns string to message
    S2M2<localizes>(S:string):message="{S}"

    Tally():int=
        Votes:=CountVotes()
        var WinningIndexes : []int = array{}
        var WinningScore : int = 0

        for(Index -> Vote:Votes):
            if(Vote>WinningScore):
                set WinningScore = Vote
                set WinningIndexes = array{Index}
            else if(Vote = WinningScore):
                set WinningIndexes += array{Index}

        set WinningIndexes = Shuffle(WinningIndexes)
    
        if(WinningIndex := WinningIndexes[0]):
            return WinningIndex

        return -1

    AddUI(Agent:agent):void=
        if:
            PlayerUI:=GetPlayerUI[player[Agent]]
        then:
            Canvas:=MakeCanvas(Agent)
            PlayerUI.AddWidget(Canvas,player_ui_slot{InputMode:=ui_input_mode.All})

    RemoveUI(Agent:agent):void=
        if(MyVoteInfo:=VoteInfoPerAgent[Agent]?):
            if:
                PlayerUI:=GetPlayerUI[player[Agent]]
                Canvas:=MyVoteInfo.Canvas
            then:
                PlayerUI.RemoveWidget(Canvas)
    
    CountVotes():[]int=
        Players:=GetPlayers()
            
        var IntegerArray : []int=array{}
            
        for(VC:VotingCandidates):
            set IntegerArray += array{0}
            

        for(P:Players):
            if(MyVoteInfo:=VoteInfoPerAgent[P]?):
                if(set IntegerArray[MyVoteInfo.Vote] += 1){}

        return IntegerArray

    GetPlayers():[]player=
        return GetPlayspace().GetPlayers()

    ChangeVote(WM:widget_message):void=
        Print("Changing Vote")
        if(MyVoteInfo:=VoteInfoPerAgent[WM.Player]?):
            for(Index -> B:MyVoteInfo.Buttons):
                if(B = WM.Source):
                    Print("Correct Button Found!")
                    set MyVoteInfo.Vote = Index
        UpdateUI()

    UpdateUI():void=
        Players:=GetPlayers()
        Votes:=CountVotes()
        for(P:Players):
            if(MyVoteInfo:=VoteInfoPerAgent[P]?):
                for(Index -> B:MyVoteInfo.Buttons):
                    if(VoteCount:=Votes[Index]):
                        B.SetText(S2M("Votes: {VoteCount}" ))

    
    SubmitRemoveUI(WM:widget_message):void=
        if(MyVoteInfo:=VoteInfoPerAgent[WM.Player]?):
            if:
                PlayerUI:=GetPlayerUI[player[WM.Player]]
                Canvas:=MyVoteInfo.Canvas
            then:
                PlayerUI.RemoveWidget(Canvas)

    var NumCandidatesToGrab : int = 7
    MakeCanvas(Agent:agent):canvas= 
        MyVoteInfo:=vote_info:

        BackButton:=button_regular{DefaultText:=S2M2("Exit")}
        BackButton.OnClick().Subscribe(SubmitRemoveUI)
        VotingStackBox:=stack_box:
            Orientation:=orientation.Horizontal
        
        for(X:=0..NumCandidatesToGrab-1):
            if(VC:=ShuffledArray[X]):
                MyButton:=VC.GetButton()
                MyButton.OnClick().Subscribe(ChangeVote)
                set MyVoteInfo.Buttons += array{MyButton}
                MyWidget:=VC.GetStackBox(MyButton)
                MySlot:=stack_box_slot:
                    Widget:=MyWidget
                    Padding:=margin{Left:=20.0,Right:=20.0}
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                VotingStackBox.AddWidget(MySlot)


        MyOverlay:=overlay:
            Slots:=array:
                overlay_slot:
                    Widget:=texture_block{DefaultImage:=Border,DefaultDesiredSize:=vector2{X:=750.0,Y:=450.0}}
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                overlay_slot:
                    Widget:=BackButton
                    Padding:=margin{Top:=20.0}
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Bottom
                overlay_slot:
                    Widget:=VotingStackBox
                    Padding:=margin{Bottom:=10.0}
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Top
        MyCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=MyOverlay
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.3875},Maximum:=vector2{X:=0.5,Y:=0.3875}}
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    SizeToContent:= true

        set MyVoteInfo.Canvas = MyCanvas
        
        if(set VoteInfoPerAgent[Agent] = option{MyVoteInfo}){}

        return MyCanvas
vote_info:=class:
    var Vote : int = -1
    var Buttons : []text_button_base = array{}
    var Canvas : canvas = canvas{}

voting_candidate:=class<concrete>:
    Texture:texture=Border
    Name:string=""
    @editable Trigger:trigger_device = trigger_device{}
    Activate():void=
        Trigger.Trigger()

    GetButton():button_loud=
        return button_loud{DefaultText:=S2M("Votes:0")}
    GetStackBox(MyButton:button_loud):stack_box=
        return stack_box:
            Orientation:=orientation.Vertical
            Slots:=array:
                stack_box_slot:
                    Widget:=texture_block:
                        DefaultImage:=Texture
                        DefaultDesiredSize:=vector2{X:=200.0,Y:=200.0}
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                stack_box_slot:
                        Widget:=text_block:
                            DefaultText:=S2M("{Name}")
                            DefaultTextColor:=White
                        HorizontalAlignment:=horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Center
                        Padding:=margin{Top:=10.0,Bottom:=10.0}
                stack_box_slot:
                    Widget:=MyButton
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
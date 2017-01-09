#pragma rtGlobals=1		// Use modern global access method.

Window flowControlPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(552,296,725,490)
	ShowTools/A
	CheckBox channel1,pos={49,41},size={66,14},proc=channelControlCheck,title="Channel 1"
	CheckBox channel1,value= 0
	CheckBox channel2,pos={49,63},size={66,14},proc=channelControlCheck,title="Channel 2"
	CheckBox channel2,value= 0
	CheckBox channel3,pos={49,83},size={66,14},proc=channelControlCheck,title="Channel 3"
	CheckBox channel3,value= 0
	CheckBox channel4,pos={49,103},size={66,14},proc=channelControlCheck,title="Channel 4"
	CheckBox channel4,value= 0
	Button closeAllValves,pos={25,134},size={120,20},proc=closeAllValvesButton,title="Close All Valves"
	Button stopAllChannels,pos={26,164},size={120,20},proc=stopAllChannels,title="Stop All Channels"
	TitleBox titleFlowControl,pos={44,17},size={76,16},title="Turn on Flow",fSize=14
	TitleBox titleFlowControl,frame=0
EndMacro

Function channelControlCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	variable channel
	sscanf ctrlName, "channel %f", channel
	
	if (checked == 0)
		stopValveFlow(channel)
	else
		startFlowValve(channel)
	endif
		
End

Function initValves(ctrlName) : ButtonControl
	String ctrlName
	
	initDOchannels()
	
End

Function closeAllValvesButton(ctrlName) : ButtonControl
	String ctrlName
	
	closeAllValves()

End

Function stopAllChannels(ctrlName) : ButtonControl
	String ctrlName
	
	stopAllFlow()
	
End
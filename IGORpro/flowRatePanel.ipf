#pragma rtGlobals=1		// Use modern global access method.

Window flowRatePanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(886,160,1122,315)
	ShowTools/A
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16
	DrawText 54,31,"Set Flow Rates"
	Button setRate1,pos={14,42},size={100,20},title="Rate 1"
	Button setRate2,pos={14,64},size={100,20},title="Rate 2"
	Button setRate3,pos={14,87},size={100,20},title="Rate 3"
	Button setRate4,pos={14,111},size={100,20},title="Rate 4"
	SetVariable setRateValue1,pos={130,45},size={75,15},value= _NUM:0
	SetVariable setRateValue1,value= root:SRSParameters:flowRateChannel1
	SetVariable setRateValue2,pos={130,66},size={75,15},value= _NUM:0
	SetVariable setRateValue2,value= root:SRSParameters:flowRateChannel2
	SetVariable setRateValue3,pos={131,88},size={75,15},value= _NUM:0
	SetVariable setRateValue3,value= root:SRSParameters:flowRateChannel3
	SetVariable setRateValue4,pos={131,112},size={75,15},value= _NUM:0
	SetVariable setRateValue4,value= root:SRSParameters:flowRateChannel4
EndMacro

Function setFlowRateButton(ctrlName) : ButtonControl
	String ctrlName
	
	variable channel
	sscanf ctrlName, "setRate %f",channel
	
	variable setRateValue1, setRateValue2, setRateValue3,setRateValue4
	//set them eqaul to global variables
	
	if (channel == 1)
		setFlowSpeed(1,setRateValue1)
	elseif (channel == 2)
		setFlowSpeed(2,setRateValue2)
	elseif (channel == 3)
		setFlowSpeed(3,setRateValue3)
	elseif (channel == 4)
		setFlowSpeed(4,setRateValue4)
	endif

End

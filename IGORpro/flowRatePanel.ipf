#pragma rtGlobals=1		// Use modern global access method.

Window flowRatePanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(140,98,496,243)
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16
	DrawText 54,31,"Set Flow Rates"
	Button setRate1,pos={14,43},size={100,20},proc=setFlowRateButton,title="Set"
	Button setRate2,pos={14,64},size={100,20},proc=setFlowRateButton,title="Set"
	Button setRate3,pos={14,87},size={100,20},proc=setFlowRateButton,title="Set"
	Button setRate4,pos={14,111},size={100,20},proc=setFlowRateButton,title="Set"
	SetVariable setRateValue1,pos={131,45},size={200,16}
	SetVariable setRateValue1,value= root:SRSParameters:flowRateChannel1
	SetVariable setRateValue2,pos={130,66},size={200,16}
	SetVariable setRateValue2,value= root:SRSParameters:flowRateChannel2
	SetVariable setRateValue3,pos={131,88},size={200,16}
	SetVariable setRateValue3,value= root:SRSParameters:flowRateChannel3
	SetVariable setRateValue4,pos={131,112},size={200,16}
	SetVariable setRateValue4,value= root:SRSParameters:flowRateChannel4
EndMacro

Function setFlowRateButton(ctrlName) : ButtonControl
	String ctrlName
	
	variable channel
	sscanf ctrlName, "setRate %f",channel
	
	
	NVAR setRateValue1 = root:SRSParameters:flowRateChannel1
	NVAR setRateValue2 = root:SRSParameters:flowRateChannel2
	NVAR setRateValue3 = root:SRSParameters:flowRateChannel3
	NVAR setRateValue4 =  root:SRSParameters:flowRateChannel4
	//set them eqaul to global variables
	
	
	
	if (channel == 1)
		setFlowSpeed(1,setRateValue1)
		print "channel", channel, "set at", setRateValue1, "mL/s"
	elseif (channel == 2)
		setFlowSpeed(2,setRateValue2)
		print "channel", channel, "set at", setRateValue2, "mL/s"
	elseif (channel == 3)
		setFlowSpeed(3,setRateValue3)
		print "channel", channel, "set at", setRateValue3, "mL/s"
	elseif (channel == 4)
		setFlowSpeed(4,setRateValue4)
		print "channel", channel, "set at", setRateValue4, "mL/s"
	endif

End

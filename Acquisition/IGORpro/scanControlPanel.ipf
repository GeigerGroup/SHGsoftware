#pragma rtGlobals=1		// Use modern global access method.

Window scanControl() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(833,66,1004,270)
	Button buttonStartFixedScan,pos={25,15},size={120,20},proc=buttonStartFixedScan,title="Start Fixed Scan"
	Button buttonStartContScan,pos={25,45},size={120,20},proc=buttonStartContScan,title="Start Continous Scan"
	Button buttonPauseScan,pos={25,74},size={120,20},proc=buttonPauseScan,title="Pause Scan"
	Button buttonResumeScan,pos={26,102},size={120,20},proc=buttonResumeScan,title="Resume Scan"
	Button buttonResetScan,pos={26,128},size={120,20},proc=buttonResetScan,title="Stop and Reset Scan"
	SetVariable setvarNextPause,pos={28,159},size={120,16},title="Next Pause"
	SetVariable setvarNextPause,value= root:SRSParameters:nextPause
EndMacro

Function buttonStartFixedScan(ctrlName) : ButtonControl
	String ctrlName
	
	startScan(0)
	
End

Function buttonStartContScan(ctrlName) : ButtonControl
	String ctrlName

	startScan(1)
End

Function buttonPauseScan(ctrlName) : ButtonControl
	String ctrlName
	
	stopScan()
End

Function buttonResumeScan(ctrlName) : ButtonControl
	String ctrlName
	
	resumeScan()

End

Function buttonResetScan(ctrlName) : ButtonControl
	String ctrlName
	
	resetScan()

End

Function buttonSetNextPause(ctrlName) : ButtonControl
	String ctrlName
	
	setNextPause()

End

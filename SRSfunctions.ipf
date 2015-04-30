#pragma rtGlobals=1		// Use modern global access method.

Function startFixedLengthScan()	
	NVAR scanLength = $("root:SRSParameters:scanLength")
	
	sendSRS("DT")
	variable dwellTime = receiveSRS()
	variable timeFactor
	sendSRS("CI2")
	variable timeResponse = receiveSRS()
	if (timeResponse == 0)
		timeFactor = 1e-7
	elseif (timeResponse == 3)
		timeFactor = 1/(3e3) //trig time factor
	endif
	sendSRS("CP2")
	variable tSet = timeFactor*receiveSRS()
	variable localScanLength = 2000
	string AB = "B"
	
	Prompt localScanLength, "Set number of counts (must be integer): "
	Prompt tSet, "Set length of each count (must be between 0.02 and 90000s): "
	Prompt dwellTime, "Set dwell time (must be between 0.002 and 60s): "
	Prompt AB, "Choose A; B; or A and B:", popup "A;B;AB"
	DoPrompt "Enter Scan Parameters", localScanLength, tSet, dwellTime,AB
	if (V_flag)
		return -1
	endif
	
	if ((tSet < 1e-7) || (tSet > 90000))
		Prompt tSet, "tSet must be between 1e-7 and 90000"
		DoPrompt "Reset tSet", tSet
		if (V_flag)
			return -1
		endif
	endif
	
	if ((dwellTime < 0.002) || (dwellTime > 60))
		Prompt dwellTime, "Dwell time must be between 0.002 and 60 s: "
		DoPrompt "Reset Dwell Time", dwellTime 
		if (V_flag)
			return -1
		endif
	endif
	scanLength = localScanLength
	string command
	command = "DT" + num2str(dwellTime)
	sendSRS(command)
	
	command = "CP2," + num2str(tSet/timeFactor)
	sendSRS(command)
		
	startRecordingData(AB)	
	sendSRS("CR")
	sendSRS("CS")
	Print "Fixed length scan started with Scan Length = " +num2str(scanLength) + ", tSet = " + num2str(tSet) + ", and dwellTime = " + num2str(dwellTime) + "."
	
end

Function startContinuousScan()

	NVAR scanLength = $("root:SRSParameters:scanLength")
	scanLength = INF
	
	sendSRS("DT")
	variable dwellTime = receiveSRS()
	variable timeFactor
	sendSRS("CI2")
	variable timeResponse = receiveSRS()
	if (timeResponse == 0)
		timeFactor = 1e-7
	elseif (timeResponse == 3)
		timeFactor = 1/(3e3) //trig time factor
	endif
	sendSRS("CP2")
	variable tSet = timeFactor*receiveSRS()
	string AB = "B"
	
	Prompt tSet, "Set length of each count (must be between 1e-7 and 90000s): "
	Prompt dwellTime, "Set dwell time (must be between 0.002 and 60s): "
	Prompt AB, "Choose A; B; or A and B:", popup "A;B;AB"
	DoPrompt "Enter Scan Parameters", tSet, dwellTime,AB
	if (V_flag)
		return -1
	endif
	
	if ((tSet < 1e-7) || (tSet > 90000))
		Prompt tSet, "tSet must be between 1e-7 and 90000"
		DoPrompt "Reset tSet", tSet
		if (V_flag)
			return -1
		endif
	endif
	
	if ((dwellTime < 0.002) || (dwellTime > 60))
		Prompt dwellTime, "Dwell time must be between 0.002 and 60 s: "
		DoPrompt "Set Dwell Time", dwellTime 
		if (V_flag)
			return -1
		endif
	endif

	
	string command
	command = "DT" + num2str(dwellTime)
	sendSRS(command)
	
	command = "CP2," + num2str(tSet/timeFactor)
	sendSRS(command)
	
	startRecordingData(AB)	
	
	sendSRS("CR")
	sendSRS("CS")
	Print "Continous scan started with tSet = " + num2str(tSet) + " and dwellTime = " + num2str(dwellTime) + "."

End

function resumeScan()
	resumeRecordingData()
	sendSRS("CS")

end
	 

function stopScan()
	sendSRS("CH")
	stopRecordingdata()
end

function resetScan()
	string yesNo = "Yes"
	Prompt yesNo, "Are you sure you want to stop and reset?", popup "Yes;No"
	DoPrompt "Stop and Reset", yesNo
	if (V_flag)
		return -1
	endif
	
	if (stringmatch(yesNo,"Yes"))
	sendSRS("CR")
	stopRecordingData()
	endif
end	
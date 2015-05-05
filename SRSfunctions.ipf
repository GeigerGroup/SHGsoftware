#pragma rtGlobals=1		// Use modern global access method.

Function startScan(fixedCont)
	variable fixedCont //variable to determine fixed or continuous. fixed = 0, continuous = 1
	NVAR scanLength = $("root:SRSParameters:scanLength") //declare global variable for scanlength
	NVAR recordA = $("root:SRSParameters:recordA") 
	NVAR recordB = $("root:SRSParameters:recordB")
	NVAR measurePower = $("root:SRSParameters:measurePower")
	NVAR powerScale = $("root:SRSParameters:powerScale")
	
	if (fixedCont)
		scanLength = INF
	else
		variable localScanLength = 2000 //default scan length
	endif
	
	sendSRS("DT")  //get dwellTime from last scan
	variable dwellTime = receiveSRS()
	
	variable timeFactor //create variable to store different time factors for what T is
	
	sendSRS("CI2") //determine this time factor
	variable timeResponse = receiveSRS()
	if (timeResponse == 0)
		timeFactor = 1e-7
	elseif (timeResponse == 3)
		timeFactor = 1/(4e3) //trig time factor
	endif
	sendSRS("CP2")
	variable tSet = timeFactor*receiveSRS() //get tSet from last scan
	

	string AB = "B" //default channel
	string power = "No"
	
	if (fixedCont == 0) 
		Prompt localScanLength, "Set number of counts (must be integer): "
	endif
	Prompt tSet, "Set length of each count (must be between 0.02 and 90000s): "
	Prompt dwellTime, "Set dwell time (must be between 0.002 and 60s): "
	Prompt AB, "Choose A; B; or A and B:", popup "A;B;AB"
	Prompt power, "Measure Power?", popup "No;NIDAQ;OPAEPM"
	if (fixedCont == 0)
		DoPrompt "Enter Scan Parameters", localScanLength, tSet, dwellTime,AB,power
	else
		DoPrompt "Enter Scan Parameters", tSet,dwellTime,AB,power
	endif
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
	
	if (fixedCont == 0)
	scanLength = localScanLength
	endif
	
	string command
	command = "DT" + num2str(dwellTime)
	sendSRS(command)
	
	command = "CP2," + num2str(tSet/timeFactor)
	sendSRS(command)
	
	strswitch(AB) //set global variables to control which channel(s) the data is read from
		case "A":
			recordA = 1
			recordB = 0
			break
		case "B":
			recordA = 0
			recordB = 1
			break
		case "AB":
			recordA = 1
			recordB = 1
			break
		default:
			Print "Problem with recording selection."
			break
	endswitch

	strswitch(power) //set global variables to control how power is measured
		case "No":
			measurePower = 0
			break
		case "NIDAQ":
			measurePower = 1
			variable localPowerScale = powerScale
			Prompt localPowerScale, "Enter Power Meter Range (in W): "
			DoPrompt "Adjust Power Scale:", localPowerScale
			if (V_flag)
				return -1
			endif
			powerScale = localPowerScale
			break
		case "OPAEPM":
			measurePower = 2
			break
		default:
			Print "Error with power measure control."
			break
	endswitch
		
	startRecordingData()	
	sendSRS("CR")
	sendSRS("CS")
	
	if (fixedCont == 0)
	Print "Fixed length scan started with Scan Length = " +num2str(scanLength) + ", tSet = " + num2str(tSet) + ", and dwellTime = " + num2str(dwellTime) + "."
	else
	Print "Continous scan started with tSet = " + num2str(tSet) + " and dwellTime = " + num2str(dwellTime) + "."
	endif
	
end

function resumeScan()
	NVAR measurePower = $("root:SRSParameters:measurePower")
	resumeRecordingData()
	
	if (measurePower == 1)
	setupFastReadDAQ()
	endif
	
	sendSRS("CS")

end
	 

function stopScan()
	NVAR measurePower = $("root:SRSParameters:measurePower")
	SVAR devName = $("root:SRSParameters:devName")
	sendSRS("CH")
	stopRecordingdata()
	if (measurePower == 1)
	fDAQmx_ScanStop(devName)
	endif
end

function resetScan()
	NVAR measurePower = $("root:SRSParameters:measurePower")
	SVAR devName = $("root:SRSParameters:devName")
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
	
	if (measurePower == 1)
	fDAQmx_ScanStop(devName) 
	endif
end	
#pragma rtGlobals=1		// Use modern global access method.

Function startScan(fixedCont)
	variable fixedCont //variable to determine fixed or continuous. fixed = 0, continuous = 1
	NVAR scanLength = $SRSVar("scanLength") //global variable for scanlength
	NVAR pointNumber =  $SRSVar("pointNumber") //global variable to track point number
	NVAR measurePower =  $SRSVar("measurePower") //global variable to control power recording
	NVAR autoPause = $SRSVar("autoPause") //global variable that controls autopausing

	//choose scan parameters
	if (chooseScanParameters(fixedCont) == -1)
		return -1
	endif
		
	//function to choose wavenames
	if (chooseWaveNames()	== -1)
		return -1
	endif
	
	//start setup NIDAQ if using it	
	if (measurePower == 1)
		setupFastReadDAQ()
	endif	
	pointNumber = 1 //reset point counter
	sendSRS("NE1") //continuous mode for GPC
	sendSRS("CR") //reset scan
	variable waste = querySRS("SS1") //make sure data ready status bit is reset so don't start with 0
	startRecordingData() //start querying for data
	sendSRS("CS")	//start scan
	
	//print what was chosen
	if (fixedCont == 0)
		Print "Fixed length scan."
	else
		Print "Continuous scan started."
	endif
end

function chooseScanParameters(fixedCont)
	variable fixedCont
	NVAR autoPause = $SRSVar("autoPause") //global variable that controls autopausing
	NVAR scanLength = $SRSVar("scanLength") //global variable for scanlength
	
	//set defaults before prompt
	variable localAutoPause = 0
	string AB = setDefaultRecordOption()
	string power = setDefaultPower()
	variable localScanLength = 2000 //default scan length	
	variable dwellTime = querySRS("DT") //get dwellTime from last scan
	variable tSet = gettSetTimeFactor()*querySRS("CP2") //get tSet from last scan
	
	//do the prompt
	if (fixedCont == 0) 
		Prompt localScanLength, "Set number of counts (must be integer): "
	endif
	Prompt tSet, "Set length of each count (must be between 0.02 and 90000s): "
	Prompt dwellTime, "Set dwell time (must be between 0.002 and 60s): "
	Prompt AB, "Choose A; B; or A and B:", popup "A;B;AB"
	Prompt power, "Measure Power?", popup "No;NIDAQ;OPAEPM"
	Prompt localAutoPause, "Autopause? 0 = no, or enter # counts to pause after"
	if (fixedCont == 0)
		DoPrompt "Enter Scan Parameters", localScanLength, tSet, dwellTime,AB,power,localAutoPause
	else
		DoPrompt "Enter Scan Parameters", tSet,dwellTime,AB,power,localAutoPause
	endif
	if (V_flag)
		return -1
	endif
	
	//make sure variables fall within specified values
	checkValues("tSet",tSet,1e-7,90000)
	checkValues("dwellTime",dwellTime,0.002,60)

	//set global variables from local prompts
	autoPause = localAutoPause 	//autopause
	if (fixedCont == 0) //scan length
		scanLength = localScanLength
	else
		scanLength = INF
	endif
	setRecordVar(AB) // control which channel(s) the data is read from
	setPowerVar(power) //control how power is measured
	
	//set dwelll time and tSet on GPC
	sendSRS("DT" + num2str(dwellTime)) 
	sendSRS( "CP2," + num2str(tSet/gettSetTimeFactor()))
	
	//print what was chosen
	Print "tSet = " + num2str(tSet) + " and dwellTime = " + num2str(dwellTime) + "."
end

function chooseWaveNames()
	NVAR measurePower =  $SRSVar("measurePower") //global variable to control power recording
	NVAR recordA =  $SRSVar("recordA") //global variable to tell if recording channel a
	NVAR recordB =  $SRSVar("recordB") //global variable to tell if recording channel b
	NVAR timeInterval =  $SRSVar("timeInterval") //global variable for time spacing
	SVAR waveAname =  $SRSVar("waveAname") //global variable that stores name of waveA
	SVAR waveBname =  $SRSVar("waveBname") //global variable that stores name of waveB
	
	string localAname = "A"
	string localBname = "B"
	string timeControl
	string promptParam = "timeControl"
	

	if (recordA)
		Prompt localAname, "Set name of wave to store data from Channel A:"
	endif
	if (recordB)
		Prompt localBname, "Set name of wave to store data from Channel B:"
	endif	
	Prompt timeControl, "Choose time interval is tSet or tSet + dwell time:",popup "tSet;tSetDT"	
		
	if (recordA)
		if (recordB)
			DoPrompt "Enter Wave Parameters", localAname,localBname,timeControl
		else
			DoPrompt "Enter Wave Parameters", localAname,timeControl
		endif
	else
		DoPrompt "Enter Wave Parameters", localBname,timeControl
	endif	
	if (V_flag)
		return -1
	endif
	
	if (recordA)
		localAname = checkWaveName(localAname)
		waveAname = localAname
		make /O/N=0 $(waveAname)
		wave waveA = $(waveAname)
		print "Data from Channel A recorded in " + waveAname
	endif
	
	if (recordB)
		localBname = checkWaveName(localBname)
		waveBname = localBname
		make /O/N=0 $(waveBname)
		wave waveB = $(waveBname)
		print "Data from Channel B recorded in " + waveBname
	endif
	
	string timeName = includeName(waveAname,recordA) + includeName(waveBname,recordB) + "_time"
	string powerName = includeName(waveAname,recordA) + includeName(waveBname,recordB) + "_power"
	
	make/O/N=0 $timeName
	wave timeWave = $timeName
	Edit timeWave
	
	if (recordA)
		if (recordB)
			AppendtoTable waveA, waveB
			Display waveA, waveB vs timeWave
		else
			AppendtoTable waveA
			Display waveA vs timeWave
		endif
	else
		AppendtoTable waveB
		Display waveB vs timeWave
	endif

	if (measurePower > 0)
		make /O/N=0 $powerName
		wave powerWave = $powerName
		AppendtoTable powerWave
		AppendtoGraph/R powerWave vs timeWave
	endif
		
	variable dwellTime = querySRS("DT") //get dwellTime
	variable tSet = gettSetTimeFactor()*querySRS("CP2") //get tSet	
	
	//set time interval according to choice and parameters
	if (stringmatch(timeControl,"tSet"))
		timeInterval = tSet
	elseif(stringmatch(timeControl,"tSetDT"))
		timeInterval = tSet + dwellTime
	endif
end

//restart paused scan
function resumeScan()
	NVAR measurePower =  $SRSVar("measurePower") //global variable saying if power is recorded
	resumeRecordingData() //start asking if there is new data again
	
	if (measurePower == 1) //check if recording with NIDAQ, restart fast scan if so
		setupFastReadDAQ()
	endif
	
	sendSRS("CS") //tell GPC to start scan
end
	 
//pause scan
function stopScan()
	NVAR measurePower =  $SRSVar("measurePower") //global variable controlling power recording
	
	sendSRS("CH")  //stop scan
	stopRecordingdata() //stop asking if there is new data
	
	if (measurePower == 1)
		stopFastReadDAQ() //if recording with NIDAQ, stop it reading power
	endif
end

//reset scan
function resetScan()
	NVAR measurePower =  $SRSVar("measurePower") //global variable controlling power recording

	string yesNo = "Yes" //make sure want to restart
	Prompt yesNo, "Are you sure you want to stop and reset?", popup "Yes;No"
	DoPrompt "Stop and Reset", yesNo
	if (V_flag)
		return -1
	endif
	
	if (stringmatch(yesNo,"Yes"))
		sendSRS("CR") //stop and reset
		stopRecordingData() //stop asking if there is new data
		
		if (measurePower == 1)
			stopFastReadDAQ() //if recording with NIDAQ, stop it reading power
		endif	
	endif
end	

 //set global variables to control which channel(s) the data is read from
function setRecordVar(AB)
	string AB
	NVAR recordA =  $SRSVar("recordA") //global variable to tell if recording channel a
	NVAR recordB =  $SRSVar("recordB") //global variable to tell if recording channel b
	
	strswitch(AB)
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
end

//check global variables to for default value on scans
function/s setDefaultRecordOption()	
	NVAR recordA =  $SRSVar("recordA") //global variable to tell if recording channel a
	NVAR recordB =  $SRSVar("recordB") //global variable to tell if recording channel b
	
	string  AB
	if (recordA)
		if (recordB)
			AB = "AB"
		else
			AB = "A"
		endif
	else
		if (recordB)
			AB = "B"
		else
			AB = "B" //default case
		endif
	endif
	return AB
end


 //set global variables to control how power is measured
function setPowerVar(power)
	string power
	NVAR measurePower =  $SRSVar("measurePower") //global variable to control power recording
	NVAR powerScale =  $SRSVar("powerScale") //global variable that stores power meter range
	
	strswitch(power)
		case "No":
			measurePower = 0
			break
		case "NIDAQ":
			measurePower = 1
			variable localPowerScale = powerScale
			Prompt localPowerScale, "Enter Power Meter Range (in W): "
			DoPrompt "Adjust Power Scale:", localPowerScale
			powerScale = localPowerScale
			break
		case "OPAEPM":
			measurePower = 2
			break
		default:
			Print "Error with power measure control."
			break
	endswitch
end

//check global variables for default value on scans
function/s SetDefaultPower()
	NVAR measurePower =  $SRSVar("measurePower") //global variable to control power recording
	
	string power
	if (measurePower == 0)
		power = "No"
	elseif(measurePower == 1)
		power = "NIDAQ"
	elseif(measurePower == 2)
		power = "OPAEPM"
	endif
	return power
end

//check so you don't overwrite a wave
function/s checkWaveName(name)
	string name
	if (waveExists($name))
		Prompt name, "Enter altername name or proceed to overwrite: "
		DoPrompt "Wave with the following name already exisits. Do you want to overwrite?", name
	endif
	return name
end

function gettSetTimeFactor()
	variable timeFactor //create variable to store different time factors for what T is
	variable timeResponse = querySRS("CI2") //determine this time factor
	if (timeResponse == 0)
		timeFactor = 1e-7
	elseif (timeResponse == 3)
		timeFactor = 1/(4e3) //trig time factor
	endif
	return timeFactor
end

//check if a variable falls within the proper bounds
function checkValues(name,param,lower,higher)
	string name
	variable &param
	variable lower
	variable higher
	variable localParam = param
		
	if ((param < lower) || (param > higher))
		string promptStr = "Value for " + name + " must be between " + num2str(lower) + " and " + num2str(higher) +  "."
		Prompt localParam,  promptStr
		DoPrompt "Value out of bounds.",localParam
		if (V_flag)
			return -1
		endif
		param = localParam
	endif
end

function/s includeName(nameToInclude,boolCheck)
		string nameToInclude
		variable boolCheck
		
		if (boolCheck)
			return nameToInclude
		else
			return ""
		endif
end
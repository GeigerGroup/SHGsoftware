#pragma rtGlobals=1		// Use modern global access method.


Function startScan(fixedCont)
	variable fixedCont //variable to determine fixed or continuous. fixed = 0, continuous = 1
	NVAR scanLength = $(SRSVar("scanLength")) //global variable for scanlength
	NVAR pointNumber =  $(SRSVar("pointNumber")) //global variable to track point number
	NVAR measurePower =  $(SRSVar("measurePower")) //global variable to control power recording
	NVAR autoPause = $(SRSVar("autoPause")) //global variable that controls autopausing

	
	//set length to INF if continuous or create local variable for scan length prompt
	if (fixedCont)
		scanLength = INF
	else
		variable localScanLength = 2000 //default scan length
	endif
	
	variable dwellTime = querySRS("DT") //get dwellTime from last scan
	
	variable timeFactor //create variable to store different time factors for what T is
	variable timeResponse = querySRS("CI2") //determine this time factor
	if (timeResponse == 0)
		timeFactor = 1e-7
	elseif (timeResponse == 3)
		timeFactor = 1/(4e3) //trig time factor
	endif
	
	variable tSet = timeFactor*querySRS("CP2") //get tSet from last scan
	variable localAutoPause = 0

	string AB = "B" //default channel
	string power = "No"
	
	if (fixedCont == 0) 
		Prompt localScanLength, "Set number of counts (must be integer): "
	endif
	Prompt tSet, "Set length of each count (must be between 0.02 and 90000s): "
	Prompt dwellTime, "Set dwell time (must be between 0.002 and 60s): "
	Prompt AB, "Choose A; B; or A and B:", popup "A;B;AB"
	Prompt power, "Measure Power?", popup "No;NIDAQ;OPAEPM"
	Prompt localAutoPause, "Autopause? 0 turns off feature, or enter # counts to pause after"
	if (fixedCont == 0)
		DoPrompt "Enter Scan Parameters", localScanLength, tSet, dwellTime,AB,power,localAutoPause
	else
		DoPrompt "Enter Scan Parameters", tSet,dwellTime,AB,power,localAutoPause
	endif
	if (V_flag)
		return -1
	endif
	
	//make sure variables are acceptable values
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
	
	//set global variables from local prompts
	autoPause = localAutoPause 
	if (fixedCont == 0)
		scanLength = localScanLength
	endif	

	//set dwelll time and tSet
	sendSRS("DT" + num2str(dwellTime)) 
	sendSRS( "CP2," + num2str(tSet/timeFactor))
	
	//set global variables to control which channel(s) the data is read from
	setRecordVar(AB)
	
	 //set global variables to control how power is measured
	setPowerVar(power)

	//function to choose wavenames
	chooseWaveNames(tSet,dwellTime)

		
	if (measurePower == 1)
		setupFastReadDAQ()
	endif
	
	pointNumber = 1
	
	sendSRS("NE1")
	sendSRS("CR")
	sendSRS("CS")
	
	variable waste = querySRS("SS1") //make sure data ready status bit is reset so don't start with 0
	startRecordingData()	
	
	if (fixedCont == 0)
		Print "Fixed length scan started with Scan Length = " +num2str(scanLength) + ", tSet = " + num2str(tSet) + ", and dwellTime = " + num2str(dwellTime) + "."
	else
		Print "Continous scan started with tSet = " + num2str(tSet) + " and dwellTime = " + num2str(dwellTime) + "."
	endif
	
end


//restart paused scan
function resumeScan()
	NVAR measurePower =  $(SRSVar("measurePower")) //global variable saying if power is recorded
	resumeRecordingData() //start asking if there is new data again
	
	if (measurePower == 1) //check if recording with NIDAQ, restart fast scan if so
		setupFastReadDAQ()
	endif
	
	sendSRS("CS") //tell GPC to start scan
end
	 
//pause scan
function stopScan()
	NVAR measurePower =  $(SRSVar("measurePower")) //global variable controlling power recording
	
	sendSRS("CH")  //stop scan
	stopRecordingdata() //stop asking if there is new data
	
	if (measurePower == 1)
		stopFastReadDAQ() //if recording with NIDAQ, stop it reading power
	endif
end

//reset scan
function resetScan()
	NVAR measurePower =  $(SRSVar("measurePower")) //global variable controlling power recording

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
	NVAR recordA =  $(SRSVar("recordA")) //global variable to tell if recording channel a
	NVAR recordB =  $(SRSVar("recordB")) //global variable to tell if recording channel b
	
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

 //set global variables to control how power is measured
function setPowerVar(power)
	string power
	NVAR measurePower =  $(SRSVar("measurePower")) //global variable to control power recording
	NVAR powerScale =  $(SRSVar("powerScale")) //global variable that stores power meter range
	
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


function/s checkWaveName(name)
	string name
	if (waveExists($(name)))
		Prompt name, "Enter altername name or proceed to overwrite: "
		DoPrompt "Wave with the following name already exisits. Do you want to overwrite?", name
	endif
	return name
end


function chooseWaveNames(tSet,dwellTime)
	variable tSet
	variable dwellTime
	NVAR measurePower =  $(SRSVar("measurePower")) //global variable to control power recording
	NVAR recordA =  $(SRSVar("recordA")) //global variable to tell if recording channel a
	NVAR recordB =  $(SRSVar("recordB")) //global variable to tell if recording channel b
	NVAR timeInterval =  $(SRSVar("timeInterval")) //global variable for time spacing
	SVAR waveAname =  $(SRSVar("waveAname")) //global variable that stores name of waveA
	SVAR waveBname =  $(SRSVar("waveBname")) //global variable that stores name of waveB
	
	string localAname
	string localBname
	string timeControl
	
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
	
	string timeName
	string powerName	
	if (recordA)
		if (recordB)
			timeName = waveAname + waveBname + "_time"
			powerName = waveAname + waveBname + "_power"
		else
			timeName = waveAname + "_time"
			powerName = waveAname + "_power"
		endif
	else
		timeName = waveBname + "_time"
		powerName = waveBname + "_power"
	endif
	
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
		
	
	if (stringmatch(timeControl,"tSet"))
		timeInterval = tSet
	elseif(stringmatch(timeControl,"tSetDT"))
		timeInterval = tSet + dwellTime
	endif
end
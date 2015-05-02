#pragma rtGlobals=1		// Use modern global access method.

function readDataSRS(s)
	STRUCT WMBackgroundStruct &s
	NVAR recordA = $("root:SRSParameters:recordA") 
	NVAR recordB = $("root:SRSParameters:recordB")
	NVAR measurePower = $("root:SRSParameters:measurePower")
	NVAR powerScale = $("root:SRSParameters:powerScale")
	NVAR scanLength = $("root:SRSParameters:scanLength")
	NVAR pointNumber = $("root:SRSParameters:pointNumber")
	NVAR timeInterval = $("root:SRSParameters:timeInterval") 
	SVAR waveAname = $("root:SRSParameters:waveAname")
	SVAR waveBname = $("root:SRSParameters:waveBname")
	
	wave waveA = $(waveAname)
	wave waveB = $(waveBname)
	string timeName
	string powerName
	
	if (recordA)
		if (recordB)
			timeName = waveAname + waveBname + "_time"
			wave timeWave = $(timeName)
			if (measurePower > 0)
			powerName = waveAname + waveBname + "_power"
			wave powerWave = $(powerName)
			endif
		else
			timeName = waveAname + "_time"
			wave timeWave = $(timeName)
			if (measurePower >0)
			powerName = waveAname +  "_power"
			wave powerWave = $(powerName)
			endif
		endif
	elseif (recordB)
		timeName = waveBname + "_time"
		wave timeWave = $(timeName)
		if (measurePower>0)
		powerName = waveBname + "_power"
		wave powerWave = $(powerName)
		endif
	endif
	
	sendSRS("SS1")
	if (receiveSRS())
		if (recordA)
			sendSRS("QA")
			make /n=1 temp = receiveSRS()
			concatenate /NP/KILL {temp}, waveA
		endif
		if (recordB)
			sendSRS("QB")
			make /n=1 temp = receiveSRS()
			concatenate /NP/KILL {temp}, waveB
		endif
		make/n=1 tempTime = timeInterval*pointNumber
		concatenate /NP/KILL{tempTime},timeWave
		
		if (measurePower > 0)
			if (measurePower == 1)
			make /n=200 tempPowerArray
			variable ii;
			for (ii = 0; ii<200;ii+=1)
					tempPowerArray[ii] = getFastReadDAQ()
			endfor
			make /n=1 tempPower = powerScale*mean(tempPowerArray)
			KillWaves tempPowerArray
			endif
			if (measurePower == 2)
			COMMPowerMeter()
			make /n=1 tempPower = queryPowerMeter("ch query")
			COMMSRS()
			endif
			concatenate /NP/KILL{tempPower},powerWave
		endif

		pointNumber = pointNumber + 1
	endif
	
	if (pointNumber > scanLength)
		sendSRS("CH")
		
		if (measurePower == 1)
		fDAQmx_ScanStop("Dev1") //default name change if multiple device or different name
		endif
		return -1
	endif
	
	return 0
end


function startRecordingData()
	
	NVAR recordA = $("root:SRSParameters:recordA") 
	NVAR recordB = $("root:SRSParameters:recordB")
	NVAR scanLength = $("root:SRSParameters:scanLength")
	NVAR pointNumber = $("root:SRSParameters:pointNumber")
	NVAR timeInterval = $("root:SRSParameters:timeInterval") 
	NVAR measurePower = $("root:SRSParameters:measurePower")
	SVAR waveAname = $("root:SRSParameters:waveAname")
	SVAR waveBname = $("root:SRSParameters:waveBname")
	
	string localAname
	string localBname
	string timeControl
	string timeName
	string powerName
	
	
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
		if (waveExists($(localAname)))
			Prompt localAname, "Enter alternate name or press OK to overwrite: "
			DoPrompt "Channel A name already exists. Do you want to overwrite?", localAname
			if (V_flag)
				return -1
			endif
		endif
	endif
	
	if (recordB)
		if (waveExists($(localBname)))
			Prompt localBname, "Enter alternate name or press OK to overwrite: "
			DoPrompt "Channel B name already exists. Do you want to overwrite?", localBname
			if (V_flag)
				return -1
			endif
		endif
	endif
	
	if (recordA)
		waveAname = localAname
		make /O/N=0 $(waveAname)
		wave waveA = $(waveAname)
	endif
	if (recordB)
		waveBname = localBname
		make /O/N=0 $(waveBname)
		wave waveB = $(waveBname)
	endif
	
	if (recordA)
		if (recordB)
			timeName = waveAname + waveBname + "_time"
			make /O/N=0 $(timeName)
			wave waveBothtime = $(timeName)
			
			Edit waveBothtime,waveA,waveB
			Display waveA, waveB vs waveBothtime
			
			if (measurePower > 0)
				powerName = waveAname + waveBname + "_power"
				make /O/N=0 $(powerName)
				wave waveBothpower = $(powerName)
				AppendtoTable waveBothpower
				AppendtoGraph/R waveBothpower vs waveBothtime
			endif
			
			print "Data from Channel A recorded in " + localAname
			print "Data from Channel B recorded in " + localBname
			
		else
		
			timeName = waveAname + "_time"
			make /O/N=0 $(timeName)
			wave waveAtime = $(timeName)
			
			Edit waveAtime, waveA
			Display waveA vs waveAtime
			
			if (measurePower > 0)
				powerName = waveAname + "_power"
				make /O/N=0 $(powerName)
				wave waveApower = $(powerName)
				AppendtoTable waveApower
				AppendtoGraph/R waveApower vs waveAtime
			endif
			print "Data from Channel A recorded in " + localAname
		endif
	else
		timeName = waveBname + "_time"
		make /O/N=0 $(timeName)
		wave waveBtime = $(timeName)
		
		Edit waveBtime, waveB
		Display waveB vs waveBtime
		
		if (measurePower > 0)
			powerName = waveBname + "_power"
			make /O/N=0 $(powerName)
			wave waveBpower = $(powerName)
			AppendtoTable waveBpower
			AppendtoGraph/R waveBpower vs waveBtime
		endif
		
		print "Data from Channel B recorded in " + localBname	
	endif
	
	
	sendSRS("DT")
	variable dwellTime = receiveSRS()
	variable timeFactor
	sendSRS("CI2")
	variable timeResponse = receiveSRS()
	if (timeResponse == 0)
		timeFactor = 1e-7
	elseif (timeResponse == 3)
		timeFactor = 1/(4e3) //trig time factor
	endif
	sendSRS("CP2")
	variable tSet = timeFactor*receiveSRS()
	
	if (stringmatch(timeControl,"tSet"))
		timeInterval = tSet
	elseif(stringmatch(timeControl,"tSetDT"))
		timeInterval = tSet + dwellTime
	endif
		
	if (measurePower == 1)
		setupFastReadDAQ()
	endif
	
	pointNumber = 1
	
	CtrlNamedBackground recordData, period=50, proc=readDataSRS
	CtrlNamedBackground recordData, start
end

function resumeRecordingData()
	CtrlNamedBackground recordData, start
end
	
function stopRecordingData()
	CtrlNamedBackground recordData, stop
end	
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
	
	CtrlNamedBackground recordData, period=50, proc=readDataSRS
	CtrlNamedBackground recordData, start
end

function resumeRecordingData()
	CtrlNamedBackground recordData, start
end
	
function stopRecordingData()
	CtrlNamedBackground recordData, stop
end	
#pragma rtGlobals=1		// Use modern global access method.

//background process for checking if SRS has data and reading it in
function readDataSRS(s)
	STRUCT WMBackgroundStruct &s //line required for background structures
	NVAR recordA = $SRSVar("recordA") 
	NVAR recordB = $SRSVar("recordB")
	NVAR measurePower = $SRSVar("measurePower")
	NVAR powerScale = $SRSVar("powerScale")
	NVAR scanLength = $SRSVar("scanLength")
	NVAR pointNumber = $SRSVar("pointNumber")
	NVAR timeInterval = $SRSVar("timeInterval")
	NVAR autoPause = $SRSVar("autoPause")
	SVAR waveAname = $SRSVar("waveAname")
	SVAR waveBname = $SRSVar("waveBname")
	SVAR devName = $SRSVar("devName")
	
	
	if (querySRS("SS1")) //check if data is ready
		if (recordA)  
			wave waveA = $waveAname //access wave for A in memory
			make /n=1 temp = querySRS("QA")
			concatenate /NP/KILL {temp}, waveA //append data from a if recording it
		endif
		if (recordB)
			wave waveB = $waveBname //access wave for B in memory
			make /n=1 temp = querySRS("QB")
			concatenate /NP/KILL {temp}, waveB //append data from b if recording it
		endif
		string timeName = includeName(waveAname,recordA) + includeName(waveBname,recordB) + "_time"
		wave timeWave = $timeName  //access timeWave in memory
		make/n=1 tempTime = timeInterval*pointNumber //append time data
		concatenate /NP/KILL{tempTime},timeWave //append time data
		
		if (measurePower > 0)   //if measuring power
			string powerName = includeName(waveAname,recordA) + includeName(waveBname,recordB) + "_power"
			wave powerWave = $powerName
			if (measurePower == 1) //if using NIDAQ
				make /n=200 tempPowerArray //create array to hold data
				variable ii;
				for (ii = 0; ii<200;ii+=1)
					tempPowerArray[ii] = getFastReadDAQ() //read in all the points
				endfor
				
				make /n=1 tempPower = powerScale*mean(tempPowerArray) //average and scale power
				KillWaves tempPowerArray //destroy temp array
			endif
			if (measurePower == 2) //if using EPM
				COMMPowerMeter() //start talking to power meter
				make /n=1 tempPower = queryPowerMeter("ch query") //get value
				COMMSRS() //return to talking to SRS
			endif
			
			concatenate /NP/KILL{tempPower},powerWave //append power data
		endif
		
		pointNumber = pointNumber + 1 //increment up one point
		
		if (autoPause > 0) //check if autopause is on, if so, check if should pause
			if (pointNumber > 1)
				if (mod(pointNumber-1,autoPause)==0)
					stopScan()
				endif
			endif
		endif
		 
	endif
	
	if (pointNumber > scanLength) //check if at end of scan
		sendSRS("CH") //stop scan
		
		if (measurePower == 1)
			fDAQmx_ScanStop(devName) //if you're measuring power with NIDAQ, stop it
		endif
		return -1
	endif
	
	return 0 //for background processes
end

//start the background process described above
function startRecordingData()	
	CtrlNamedBackground recordData, period=50, proc=readDataSRS
	CtrlNamedBackground recordData, start
end

//resume background process described above after it's been paused
function resumeRecordingData()
	CtrlNamedBackground recordData, start
end

//stop the background process described above	
function stopRecordingData()
	CtrlNamedBackground recordData, stop
end	

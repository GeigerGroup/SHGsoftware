#pragma rtGlobals=1		// Use modern global access method.


//background process for checking if SRS has data and reading it in
function readDataSRS(s)
	STRUCT WMBackgroundStruct &s //line required for background structures
	NVAR recordA = $SRSVar("recordA") 
	NVAR recordB = $SRSVar("recordB")
	NVAR measurePower = $SRSVar("measurePower")
	NVAR scanLength = $SRSVar("scanLength")
	NVAR pointNumber = $SRSVar("pointNumber")
	NVAR timeInterval = $SRSVar("timeInterval")
	NVAR autoPause = $SRSVar("autoPause")
	NVAR nextPause = $SRSVar("nextPause")
	SVAR waveAname = $SRSVar("waveAname")
	SVAR waveBname = $SRSVar("waveBname")
	SVAR devName = $SRSVar("devName")
	
	if (querySRS("SS1")) //check if data is ready
		appendSRSDataPoint(recordA,waveAname,"QA") //add a data points if recording
		appendSRSDataPoint(recordB,waveBname,"QB") //add b data points if recording

		//add time points
		string timeName = includeName(waveAname,recordA) + includeName(waveBname,recordB) + "_time"
		wave timeWave = $timeName  //access timeWave in memory
		make/n=1 tempTime = timeInterval*pointNumber //append time data
		concatenate /NP/KILL{tempTime},timeWave //append time data
		
		 //add power points if measuring
		if (measurePower > 0)  
			string powerName = includeName(waveAname,recordA) + includeName(waveBname,recordB) + "_power"
			wave powerWave = $powerName
								
			if (measurePower == 1) //if using NIDAQ
				make /n=1 tempPower = getNIDAQpower()
			elseif(measurePower == 2) //if using EPM
				make /n=1 tempPower = getEPMPower()
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
		
		if (nextPause == pointNumber) //check if nextpause is on, if so, pause
			stopScan()
			nextPause = 0 //reset nextPause
		endif	
		
		if (pointNumber > scanLength) //check if at end of scan
			sendSRS("CH") //if so, stop scan
		
			if (measurePower == 1)
				fDAQmx_ScanStop(devName) //if you're measuring power with NIDAQ, stop it
			endif
			return -1
		endif	 	
	endif

	return 0 //for background processes
end

//append data to dataWave
function appendSRSDataPoint(onOff,waveNameAppend,query)
	variable onOff
	string waveNameAppend
	string query
		
	if (onOff)
		wave waveToAppend = $waveNameAppend //does this get thrown away after function returns?
		make /n=1 temp = querySRS(query)
		concatenate /NP/KILL{temp},waveToAppend
	endif
end

//get power if using NIDAQ
function getNIDAQpower()
	NVAR powerScale = $SRSVar("powerScale")
				
	variable meanPower
	make/n = 200 tempPowerArray //create array to hold data
	variable ii;
	for (ii = 0; ii<200;ii+=1)
		tempPowerArray[ii] = getFastReadDAQ() //read in all the points
	endfor
	meanPower = powerScale*mean(tempPowerArray) //average and scale power
	KillWaves tempPowerArray //destroy temp array
	return meanPower
end

//get power if using EPM			
function getEPMPower()
	COMMPowerMeter() //start talking to power meter
	variable power = queryPowerMeter("ch query") //get value
	COMMSRS() //return to talking to SRS
	return power
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

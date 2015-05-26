#pragma rtGlobals=1 //use modern global access method
//code partially inspired by bart mcguyer, princeton university

function initNIDAQ()
	 SVAR devName = $(SRSVar("devName"))
	
	If(stringmatch(devName,""))
		//if no boards, quit
		print "Error initializing NIDAQ, there are no boards connected."
	else
		fDAQmx_ResetDevice(devName) //do a reset of the board
		Print "NIDAQ board " + devName + " initialized."
	endif
end

Function setupFastReadDAQ()
	SVAR devName = $(SRSVar("devName"))
	string param = "0/DIFF,0,1;"  //sets up reading analog channel 0 from 0-1V
	DAQmx_AI_SetupReader/DEV=devName param //call NIDAQ function
End

Function stopFastReadDAQ()
	SVAR devName = $(SRSVar("devName"))
	fDAQmx_ScanStop(devName)
End

Function getFastReadDAQ()
	SVAR devName = $(SRSVar("devName")) //global device name
	make/O/N=1 waveTemp; //set up wave to hold one reading
	fDAQmx_AI_GetReader(devName,waveTemp) //call NIDAQ function to get data in wave
	return waveTemp[0] //return value
End
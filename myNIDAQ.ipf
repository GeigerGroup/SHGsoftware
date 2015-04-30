#pragma rtGlobals=1 //use modern global access method
//code partially from bart mcguyer, princeton university


Function setupFastReadDAQ()
	
	SVAR DevName = $(ksNIDAQmxPath + ":mxDevName") //global device name
	string param = "0/DIFF,0,1;"  //sets up reading analog channel 0 from 0-1V

	DAQmx_AI_SetupReader/DEV=DevName param //call NIDAQ function
End

Function getFastReadDAQ()
	
	SVAR DevName = $(ksNIDAQmxPath + ":mxDevName") //global device name
	wave/N=1 waveTemp; //set up wave to hold one reading
	
	fDAQmx_AI_GetReader(DevName,waveTemp) //call NIDAQ function to get data in wave

	return waveTemp[0] return value
End
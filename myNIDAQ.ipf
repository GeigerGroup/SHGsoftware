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

Function setDIOconfig(channel)
	variable channel
	SVAR devName = $(SRSVar("devName")) //global device name
	wave taskNumWave = root:SRSparameters:taskNumWave

	string param = "/" + devName + "/port0/line" + num2str(channel) //parameters for ports chosen, P0.0
	DAQmx_DIO_Config /DEV=devName /DIR=1 /LGRP=1 param //call NIDAQ function to set it up
	taskNumWave[channel] = V_DAQmx_DIO_TaskNumber //store the taskNumber
End

Function setValve(channel,value)
	variable channel
	variable value //value 0 = closed, value 1 = open
	
	if (channel > 0)
		wave taskNumWave = root:SRSparameters:taskNumWave
		SVAR devName = $(SRSVar("devName")) //global device name
		fDAQmx_DIO_Write(devName,taskNumWave[channel],value)
	endif
End

function openValve(channel)
	variable channel
	
	setValve(channel,1)
end

function closeValve(channel)
	variable channel
	
	setValve(channel,0)
end

function initDOchannels()
	setDIOconfig(1)
	setDIOconfig(2)
	setDIOconfig(3)
	setDIOconfig(4)
	
	closeAllValves()
end

function closeAllValves()
	setValve(1,0)
	setValve(2,0)
	setValve(3,0)
	setValve(4,0)
end
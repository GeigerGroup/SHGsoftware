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

function initDOchannels()
	
	variable i
	for (i = 1; i < 6; i+=1)
		setDIOconfig(i)
	endfor
	
	closeAllValves()
end

Function setDIOconfig(channel)
	variable channel
	SVAR devName = $(SRSVar("devName")) //global device name
	wave taskNumWave = root:SRSparameters:taskNumWave

	string param = "/" + devName + "/port0/line" + num2str(channel) //parameters for ports chosen, P0.0
	DAQmx_DIO_Config /DEV=devName /DIR=1 /LGRP=1 param //call NIDAQ function to set it up
	taskNumWave[channel] = V_DAQmx_DIO_TaskNumber //store the taskNumber
End

Function setValve(channel,value) //channel 1-4 flow, channel 5 is waste valve
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

function closeAllValves()
	variable i
	for (i = 1; i < 6; i+=1)
		setValve(i,0)
	endfor
end

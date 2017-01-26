#pragma rtGlobals=1		// Use modern global access method.
//contains a set of functions that sets up and allows for
// communications with GPC


//Sets everything, must be called prior to acquiring data
function openSRS()	
	COMMSRS() //define communications parameters, open comms with GPC
	
	checkSRS()  //make sure the GPC is there, print status
	
	initSRSVariables() //initialize important GPC variables
	
	initNIDAQ() //initialize NIDAQ board, print status
end

//defines communication parameters, opens comms with GPC
function COMMSRS()
	VDT2/P=COM1 baud=19200,stopbits=2,databits=8,parity=0
	VDTOperationsPort2 COM1
	VDT2 KillIO
end

//initializes important GPC and NIDAQ variables
function initSRSVariables()
	NewDataFolder/O/S root:SRSParameters
	variable/G scanLength = 2000
	variable/G pointNumber = 1
	variable/G recordA = 0
	variable/G recordB = 0
	variable/G timeInterval = 1
	variable/G measurePower = 0
	variable/G powerScale = 1
	variable/G autoPause = 0
	variable/G nextPause = 0
	
	string/G waveAname = "waveA"
	string/G waveBname = "waveB"
	string/G timeInput = ""
	string/G devName = StringFromList(0,fDAQmx_DeviceNames());
	make /n=5/O taskNumWave = 0
	SetDataFolder root:	
end

//return full path to SRS variables (use when calling global variables
//in other functions)
function/s SRSVar(varname)
	string varname	
	varname = "root:SRSParameters:" + varname
	return varname
end

//checks to make sure GPC is there and communicating
function checkSRS()
	VDT2 KillIO //clear channel
	
	sendSRS("") //send empty commands (suggested in SRS manual)
	sendSRS("")
	sendSRS("")
	sendSRS("")
	
	string wasteChar //read in any waste response to throw away variable
	VDTRead2 /O=0.3 /Q  wasteChar
	
	variable responseNum = querySRS("SS6")  //ping status byte
	if (responseNum == 0)
	print "Communication with photon counter appears normal."
	else
	print "Communication error. Is the gated photon counter on and connected?"
	endif	
end

//close communications with photon counter to allow another program access.
//not generally necessary
function closeSRS() 
	VDTClosePort2 COM1
	print "Communication with photon counter closed."	
end

//send string command to GPC
function sendSRS(command)
	String command
	command = command + "\r\n"
	VDTWrite2 command	
end

//receive numeric response from GPC
function receiveSRS()
	String response
	VDTRead2/O=3/T="\r\n" response
	variable responseNum = str2num(response)
	return responseNum	
end

//send command and read in response
function querySRS(command)
	string command
	sendSRS(command)
	
	return receiveSRS()
end	
	
//recall saved GPC settings
function recallGPCParameters(saveNum)
	variable saveNum
	string command = "RC" + num2str(saveNum)
	sendSRS(command)
	sendSRS("CK10") //return to main menu
end
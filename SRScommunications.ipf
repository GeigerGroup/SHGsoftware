function COMMSRS()
	VDT2/P=COM1 baud=19200,stopbits=2,databits=8,parity=0
	VDTOperationsPort2 COM1
	VDT2 KillIO
end

function openSRS()
	
	COMMSRS()
	sendSRS("")
	sendSRS("")
	sendSRS("")
	sendSRS("")
	string wasteChar
	VDTRead2 /O=0.3 /Q  wasteChar
	checkSRS()
	
	NewDataFolder/O/S root:SRSParameters
	variable/G scanLength = 2000
	variable/G pointNumber = 1
	variable/G recordA = 0
	variable/G recordB = 0
	variable/G timeInterval = 1
	variable/G measurePower = 0
	variable/G powerScale = 1
	variable/G autoPause = 0
	string/G waveAname = "waveA"
	string/G waveBname = "waveB"
	string/G timeInput
	//initialize NIDAQ
	initNIDAQ()
	
	sendSRS("NP2000")	
	sendSRS("NE1")

	SetDataFolder root:	
end
	
function checkSRS()
	VDT2 KillIO
	sendSRS("")
	sendSRS("")
	sendSRS("")
	sendSRS("")
	sendSRS("SS6")

	variable responseNum = receiveSRS()
	if (responseNum == 0)
	print "Communication with photon counter appears normal."
	else
	print "There may be a problem communicating with the photon counter. Please check communications."
	endif
		
end

function closeSRS() //not necessary
	VDTClosePort2 COM1
	print "Communication with photon counter closed."	
end

function sendSRS(command)
	String command
	command = command + "\r\n"
	VDTWrite2 command	
end
	 
function receiveSRS()
	String response
	VDTRead2/O=3/T="\r\n" response
	variable responseNum = str2num(response)
	return responseNum	
end

function querySRS(command)
	string command
	command = command + "\r\n"
	VDTWrite2 command
	string response
	VDTRead2/O=3/T="\r\n" response
	variable responseNum = str2num(response)
	return responseNum
end	
	

function recallGPCParameters(saveNum)
	variable saveNum
	string command = "RC" + num2str(saveNum)
	sendSRS(command)
	sendSRS("CK10") //return to main menu
end
	

	 
	 
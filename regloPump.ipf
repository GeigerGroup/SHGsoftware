#pragma rtGlobals=1		// Use modern global access method.

function COMMpump()
	VDT2/P=COM7 baud=9600,stopbits=1,databits=8,parity=0
	VDTOperationsPort2 COM7
	VDT2 KillIO
end

function sendPump(command)
	string command
	command = command + "\r\n"
	VDTWrite2 command
end

function/s receivePump()
	string response
	VDTRead2/O=3/T=",\t\r"  response
	print response
	return response
end
	

function initPumpSettings()
	sendPump("1J") 		//set rotation to clockwise
	sendPump("2J")
	sendPump("3J")
	sendPump("4J")
	
	sendPump("1M")        //set pump to flow rate mode
	sendPump("2M")
	sendPump("3M")
	sendPump("4M")
	
end
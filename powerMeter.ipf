// baud 9600
//parity none
//stopbits 1

#pragma rtGlobals=1

function COMMPowerMeter()
	VDT2/P=COM2 baud=9600,stopbits=1,databits=8,parity=0
	VDTOperationsPort2 COM2
	VDT2 KillIO
end

function queryPowerMeter(command)
	string command
	command = command + "\r\n"
	VDTWrite2 command
	
	string response
	VDTRead2/O=3/T=",\t\r" response
	
	variable num
	sscanf response, "CHAN: QUERY: %f", num
	return num
end
	
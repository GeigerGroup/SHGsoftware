#pragma rtGlobals=1		// Use modern global access method.

function COMMpump()
	VDT2/P=COM7 baud=9600,stopbits=1,databits=8,parity=0
	VDTOperationsPort2 COM7
	VDT2 KillIO
end

function sendPump(command)
	string command
	command = command + "\r\n"
	
	COMMpump()
	VDTWrite2 command
	COMMSRS()
end

function/s receivePump()
	string response
	COMMpump()
	VDTRead2/O=3/T=",\t\r"  response
	COMMSRS()
	print response
	return response
end
	
function initPumpSettings()
	sendPump("1K") 		//set rotation to clockwise
	sendPump("2K")
	sendPump("3K")
	sendPump("4K")
	
	sendPump("1M")        //set pump to flow rate mode
	sendPump("2M")
	sendPump("3M")
	sendPump("4M")	
end

function stopAllFlow()
	sendPump("1I")
	sendPump("2I")
	sendPump("3I")
	sendPump("4I")
end

function startFlow(channel)
	variable channel
	
	string param = num2str(channel) + "H"
	sendPump(param)
end

function stopFlow(channel)
	variable channel
	
	string param = num2str(channel) + "I"
	sendPump(param)
end

function startFlowValve(channel)
	variable channel
	
	startFlow(channel)
	print "Started channel " + num2str(channel)
	openValve(channel)
	print "Opened valve " + num2str(channel)
	
end

function stopValveFlow(channel)
	variable channel
	
	closeValve(channel)
	print "Closed valve " + num2str(channel)
	stopFlow(channel)
	print "Stopped channel " + num2str(channel)
end
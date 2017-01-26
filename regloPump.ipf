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
	
function initPumpValveSettings()
	initDOChannels()

	setAllChannels("K")	//set rotation to clockwise
	setAllChannels("M")    //set pump to flow rate mode

	setAllChannels("f" + convertFlowRate(30)) //set flow rate to 30	
	
	SetDataFolder root:SRSParameters
	variable/G flowControl = 0
	variable/G flowChangeIndex = 0
	variable/G currentChannel = 0
	make/n=100/O flowCounts = 0
	make/n=100/O flowChannels = 0
	make/n=100/O flowSpeed = 0
	SetDataFolder root:
	
	Edit :SRSParameters:flowCounts,:SRSParameters:flowChannels, :SRSParameters:flowSpeed
end

function setAllChannels(command)
	string command
	
	variable i
	for(i=1; i < 5; i+=1)
		sendPump(num2str(i) + command)
	endfor
end

function stopAllFlow()
	setAllChannels("I")
end

function/s convertFlowRate(speed)
	variable speed
	
	string s
	sprintf s, "%.3e", speed //put variable in exponential string form
	
	string speedString = s[0] + s[2,4] + s[6] + s[8] //remove ".", "E", and first exponential digit	
	return speedString
end


function setFlowSpeed(channel, speed)
	variable channel
	variable speed
	
	string param = num2str(channel) + "f" + convertFlowRate(speed)
	sendPump(param)
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
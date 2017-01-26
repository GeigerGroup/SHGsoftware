#pragma rtGlobals=1		// Use modern global access method.

function changeFlow()
	NVAR flowChangeIndex = $SRSVar("flowChangeIndex")  //index of flow control number in run
	NVAR currentChannel = $SRSVar("currentChannel")   //channel currently flowing
	wave flowCounts = root:SRSparameters:flowCounts    //wave that holds counts to make change
	wave flowChannels = root:SRSparameters:flowChannels //wave that holds channels to flow at change point
	wave flowSpeed = root:SRSparameters:flowSpeed    //wave that hodls speeds for change point

	if (flowChangeIndex != 0 && flowChannels[flowChangeIndex] != currentChannel) //check that its not first and the new channel isn't same as wold
		stopValveFlow(currentChannel) //stop current flow
	endif
	
	if (flowSpeed[flowChangeIndex] != 0) //check if speed is specified (if not, remains)
		setFlowSpeed(flowChannels[flowChangeIndex],flowSpeed[flowChangeIndex]) //change flow rate
	endif		
	
	if (flowChannels[flowChangeIndex] != currentChannel) //check that the channel is changing
		startFlowValve(flowChannels[flowChangeIndex])  //start new flow
	endif
	
	currentChannel = flowChannels[flowChangeIndex]
	flowChangeIndex = flowChangeIndex + 1
	
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
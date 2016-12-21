#pragma rtGlobals=1		// Use modern global access method.

function changeFlow()
	NVAR flowChangeIndex = $SRSVar("flowChangeIndex")
	NVAR currentChannel = $SRSVar("currentChannel")
	wave flowCounts = root:SRSparameters:flowCounts
	wave flowChannels = root:SRSparameters:flowChannels

	if (currentChannel != 0)
		setValve(currentChannel,0)
		print "closed valve" + num2str(currentChannel)
		stopFlow(currentChannel)
		print "stopped channel" + num2str(currentChannel)
	endif
	
	startFlow(flowChannels[flowChangeIndex])
	print "started channel" + num2str(flowChannels[flowChangeIndex])
	setValve(flowChannels[flowChangeIndex],1)
	print "opened valve" + num2str(flowChannels[flowChangeIndex])
	
	currentChannel = flowChannels[flowChangeIndex]
	flowChangeIndex = flowChangeIndex + 1
	
end
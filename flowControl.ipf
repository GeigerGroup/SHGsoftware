#pragma rtGlobals=1		// Use modern global access method.

function changeFlow()
	NVAR flowChangeIndex = $SRSVar("flowChangeIndex")
	NVAR currentChannel = $SRSVar("currentChannel")
	wave flowCounts = root:SRSparameters:flowCounts
	wave flowChannels = root:SRSparameters:flowChannels

	if (currentChannel != 0)
		stopValveFlow(currentChannel)
	endif
	
	startFlowValve(flowChannels[flowChangeIndex])
	
	currentChannel = flowChannels[flowChangeIndex]
	flowChangeIndex = flowChangeIndex + 1
	
end
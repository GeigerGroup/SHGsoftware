#pragma rtGlobals=1		// Use modern global access method.

function changeFlow()
	NVAR flowChangeIndex = $SRSVar("flowChangeIndex")  //index of flow control number in run
	wave flowCounts = root:SRSparameters:flowCounts    //wave that holds counts to make change
	wave flowCh1 = root:SRSparameters:flowCh1 //wave that holds channels to flow at change point
	wave flowCh2 = root:SRSparameters:flowCh2 //wave that holds channels to flow at change point
	wave flowCh3 = root:SRSparameters:flowCh3 //wave that holds channels to flow at change point
	wave flowCh4 = root:SRSparameters:flowCh4 //wave that holds channels to flow at change point
	
	variable totalFlow = 0 //variable to hold sum of flowrates and check if something is on
	variable i
	for(i=1;i<5;i+=1) //iterate through the individual channel waves
		wave channelWave = $("root:SRSparameters:flowCh" + num2str(i))
		
		if (channelWave[flowChangeIndex] == 0) //check if the flow for this channel is 0, stop flow and close valve
			stopFlow(i)
			closeValve(i)
		else
			setFlowSpeed(i,channelWave[flowChangeIndex]) //if it isn't 0, set flow speed, start flow, open valve
			startFlow(i)
			openValve(i)
			print "Channel " + num2str(i) + "flowing at " + num2str(channelWave[flowChangeIndex])
		endif
		
		totalFlow = totalFlow + channelWave[flowChangeIndex] //add the flow for this channel to the total flow
	endfor
	
	if (totalFlow > 0) //if total flow is above 0, open waste valve
		openValve(5)
	else
		closeValve(5) //if it isn't (theres no flow), close waste valve
	endif
	
	flowChangeIndex = flowChangeIndex + 1 //iterate to next time to change flow
	
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


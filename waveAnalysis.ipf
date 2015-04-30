#pragma rtGlobals=1		// Use modern global access method.

Function clearNaN()
	string localWaveName
	Prompt localWaveName, "Wave Name:"
	DoPrompt "Enter Wave Name", localWaveName
	if (V_flag)
		return -1
	endif

	wave w = $(localWaveName)
	
	variable numPoints = numpnts(w)
	variable i
	
	for(i=numPoints-1;i>=0;i-=1)
		if (stringmatch(num2str(w[i]),"NaN"))
			DeletePoints i,1,w
		endif
	endfor
end

Function findAverage()
	variable begpt
	variable endpt
	
	string localWaveName
	Prompt localWaveName, "Wave Name:"
	Prompt begpt, "Beginning Point"
	Prompt endpt, "End Point"
	DoPrompt "Enter Info", localWaveName, begpt, endpt
	if (V_flag)
		return -1
	endif
	
	wave w = $(localWaveName)
	variable ave = mean(w, begpt,endpt)
	
	print "Average of " + localWaveName + " from pt" + num2str(begpt) + " to pt" + num2str(endpt) + " is " + num2str(ave)
End
	
	
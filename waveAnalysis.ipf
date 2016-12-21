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
	

Function FindSegmentMeans()
	String source // name of wave that we want to analyze 
	Variable n // number of points in each segment 
	Prompt source, "Source wave", popup WaveList("*", ";", "") 
	Prompt n, "Number of points in each segment"
	DoPrompt "Find Segment Means", source,n
	SegmentMeans($source, n)
End

Function/S SegmentMeans(source, n)
	Wave source
	Variable n
	String dest // name of destination wave 
	Variable segment, numSegments
	Variable startX, endX, lastX
	dest = NameOfWave(source)+"_m" // derive name of dest from source 
	numSegments = trunc(numpnts(source) / n)
	if (numSegments < 1)
		DoAlert 0, "Destination must have at least one point"
		return ""
	endif
	Make/O/N=(numSegments) $dest
	WAVE destw = $dest
	lastX = pnt2x(source, numpnts(source)-1)
	for (segment = 0; segment < numSegments; segment += 1)
		startX = pnt2x(source, segment*n) // start X for segment 
		endX = pnt2x(source, (segment+1)*n - 1)// end X for segment 
		// this handles case where numpnts(source)/n is not an integer 
		endX = min(endX, lastX)
		destw[segment] = mean(source, startX, endX)
	endfor
	return GetWavesDataFolder(destw,2) // string is full path to wave 
End
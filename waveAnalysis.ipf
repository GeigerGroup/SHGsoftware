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

function meanNorm(rootname,numSegment)

	string rootname
	variable numSegment
	
	wave root = $rootname
	wave power = $(rootname + "_power")
	SegmentMeans(root,numSegment)
	SegmentMeans(power,numSegment)
	
	wave rootMean = $(rootname + "_m")
	wave powerMean = $(rootname + "_power_m")
	make /n=(numpnts(rootMean)) $(rootname + "_pow_NORM") = powerMean/powerMean[0]
	wave powerMeanNorm = $(rootname + "_pow_NORM")
	make /n=(numpnts(rootMean)) $(rootname + "_mNORM") = rootMean/powerMeanNorm^2
	wave rootMeanNorm = $(rootname + "_mNORM")
	
	AppendToTable rootMean,powerMean,powerMeanNorm,rootMeanNorm
	
end

function refNorm(rootname)
	string rootname
	variable mmax
	variable mmin
	
	wave w = $rootname
	
	mmin = wavemin(w)
	
	variable length = numpnts(w)
	make /n=(length) $(rootname + "_rn") = w-mmin
	wave rn = $(rootname + "_rn")
	mmax = wavemax(rn)
	rn = rn/mmax
	AppendToTable rn
	
end


function findAverage(name, begpt, endpt)
	string name
	variable begpt
	variable endpt
	
	wave w = $(name)
	variable ave = mean(w,begpt,endpt)
	print "Average = " + num2str(ave)
end

function boxcarNorm(rootname,boxcarNum)
	
	string rootname
	variable boxcarNum
	
	boxcar(rootname,boxcarNum)
	boxcar(rootname + "_power",boxcarNum)
	boxcar(rootname + "_time",boxcarNum)
	
	wave root = $(rootname + "_bc5_0")
	wave power = $(rootname + "_power" + "_bc5_0")
	wave wtime = $(rootname + "_time" + "_bc5_0")
	
	variable length = numpnts(root)
	AppendToTable wtime,root,power
	make /n=(length) $(rootname + "_pow_NORM") = power/power[0]
	wave powerNorm = $(rootname + "_pow_NORM")
	make/n=(length) $(rootname +"_bcNORM") = root/powerNorm^2
	wave rootNorm = $(rootname + "_bcNORM")
	AppendToTable powerNorm,rootNorm
	Display rootNorm vs wtime
	ModifyGraph fSize=14
	ModifyGraph mirror=2;DelayUpdate
	Label left "I\\BSHG \\M [a.u.]";DelayUpdate
	Label bottom "Time[s]"
end




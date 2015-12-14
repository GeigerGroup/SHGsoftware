#pragma rtGlobals=1		// Use modern global access method.

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
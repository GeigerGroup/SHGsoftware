#pragma rtGlobals=1		// Use modern global access method.

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

	
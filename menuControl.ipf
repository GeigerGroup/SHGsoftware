#pragma rtGlobals=1		// Use modern global access method.

Menu "Photon Counter"

	Submenu "Communications"
	"Open", openSRS()
	"Check", checkSRS()
	"Close", closeSRS()
	End
	
	Submenu "Scan"
		"Start Fixed Length", startScan(0)
		"Start Continuous", startScan(1)
		"Pause", stopScan()
		"Resume", resumeScan()
		"Stop and Reset", resetScan()
	End
	Submenu "Wave Analysis"
		"Find Average", findAverage()
	End
		
end
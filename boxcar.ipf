#pragma rtGlobals=1		// Use modern global access method.
// this function is meant to boxcar smooth a wave
Function boxcarprompt()
	string trace
	variable npts
	prompt trace, "wave", popup,WaveList("*",";","")
	prompt npts, "box size"
	DoPrompt "boxcar", trace, npts
	boxcar(trace, npts)
	
end

Function Boxcarxypromptold()
	string trace1, trace2
	variable npts
	prompt trace1, "x wave", popup,WaveList("*",";","")
	prompt trace2, "y wave", popup,WaveList("*",";","")
	prompt npts, "box size"
	DoPrompt "boxcar", trace1, trace2, npts
	boxcar(trace1, npts)
	string xwn, ywn
	SVAR uniqueboxwavename
	xwn=uniqueboxwavename
	boxcar(trace2, npts)
	ywn=uniqueboxwavename
	display $ywn vs $xwn
	ModifyGraph mirror=2,standoff=0
	ModifyGraph mode=3,marker=17
	Label left ywn
	label bottom xwn
end
	
Function Boxcarxyprompt()
	newpanel /W=(150,50,500,185)
	string/g boxtrace1, boxtrace2
	variable/g boxnpts
	popupmenu trace1inmenu, value=wavelist("*",";",""), pos={100,5}, bodywidth=200, proc=trace1in, Title="X wave:", mode=1
	popupmenu trace2inmenu, value=wavelist("*",";",""), pos={100,50}, bodywidth=200, proc=trace2in, Title="Y wave:", mode=1
	SetVariable boxnptsin,pos={10, 100},size={150,17},limits={0,50000,1},value= boxnpts, Title="box size"
	checkbox trace1window, pos={260, 5}, proc=t1w, title="From Target"
	checkbox trace2window, pos={260, 50}, proc=t2w, title="From Target"
	Button runboxcar, title="GO", size={50,20}, proc=runboxxy, pos={270,100} 
end

function t1w(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if checked, 0 if not
	if(checked==1)
		popupmenu trace1inmenu, value=wavelist("*",";","win:")
	else
		popupmenu trace1inmenu, value=wavelist("*",";","")
	endif
end

function t2w(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if checked, 0 if not

	if(checked==1)
		popupmenu trace2inmenu, value=wavelist("*",";","WIN:")
	else
		popupmenu trace2inmenu, value=wavelist("*",";","")
	endif
end

Function trace1in (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	SVAR boxtrace1 // defining the global string wavepc as a local string
	boxtrace1=popstr // storing the name selected in the popupmenu in wavepc
End
	
Function trace2in (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	SVAR boxtrace2 // defining the global string wavepc as a local string
	boxtrace2=popstr // storing the name selected in the popupmenu in wavepc
End
	
	
function runboxxy(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR boxtrace1, boxtrace2
	nvar boxnpts
	
	string killwindowname
	killwindowname=winname(0,64)
	
	boxcar(boxtrace1, boxnpts)
	string xwn, ywn
	SVAR uniqueboxwavename
	xwn=uniqueboxwavename
	boxcar(boxtrace2, boxnpts)
	ywn=uniqueboxwavename
	display $ywn vs $xwn
	ModifyGraph mirror=2,standoff=0
	ModifyGraph mode=3,marker=17
	Label left ywn
	label bottom xwn
	
	dowindow/k $killwindowname
end
	

// inputs:
// wvname = name of wave to be smoothed
// numpts = number of points to average
function boxcar(wvname,numpts)
//declaring parameters
	string wvname
	variable numpts
	variable V_npnts // This is a variable returned by wavestats
	
	// declaring variables
	variable rem, lngth,cnt1,cnt2,a,cnt3, cnt4
	//rem = remainder of a
	//lngth = length of vector to make
	// cnt1-4 are counters
	//a = length of vector to be smoothed divided by the number of points to be averaged
	
	// declaring strings for making the new wavename
	string sumname,bc,ubc,snumpts
	//sumname = sumation of the strings to be used in the unique name fn
	// bc is a string to add bc
	// ubc is the string after the unique name fn
	// snumpts is a string containing the number of pts to be smoothed	
	
	snumpts=num2str(numpts)  // storing the number of pts to be smoothed in a string
	snumpts+="_"  // adding an underscore to the end of the string
	bc="_bc" // setting string bc
	sumname=wvname+bc+snumpts // adding up the strings
	ubc=uniquename(sumname, 1,0) // running the unique name algorithm
	
	
	wavestats $wvname  //getting the wave stats on the wave of interest
	a=V_npnts/numpts // calcing a
	lngth=trunc(a) // getting the length if the wave is evenly divisible by the number of pts
	rem=a-lngth // calculating if there is a remainder
	if (rem>0) //increasing the length by 1 if there is a remainder
		lngth+=1
	endif
	make /o/n=(lngth) $ubc //making the wave to store the boxcar in
	string/G uniqueboxwavename
	uniqueboxwavename=ubc
	wave wb = $ubc //declaring an internal name for the boxcar wave
	wave w = $wvname // declaring an internal name for the input wave
	// setting some counters to 0
	cnt1=0
	cnt2=0
	cnt3=0
	cnt4=0
	
	// main loop if there is no remainder
	// outer loop cycles steps through the entries in the boxcared wave
	// inner loop counts through the individual average ie if you are averaging 3 pts the inner loop adds up 
	// those 3 pts.  The 3rd counter steps through the location in the input wave. the outer loop also divides
	// the entries in the smoothed wave by the number of points averaged together
	if (rem==0)
		for(cnt1=0;cnt1<=(lngth-0.99999999);cnt1+=1)
			for(cnt2=0;cnt2<=(numpts-0.99999999);cnt2+=1)
				wb[cnt1]=wb[cnt1]+w[cnt3]
				cnt3+=1
			endfor
			wb[cnt1]/=numpts
		endfor
	endif
	
	
	// loop for when there is a remainder.  this is the same as the previous loop with the exceptoin of the last
	//point.  The for loops do exactly the same as above with the exception they will not include the last point 
	// in the smoothed wave.  For the last point in the smoothed wave, all the remainder points are added up
	// and divided by the number of them there were.  Meaning the last point is effectively an average of a 
	// smaller number of pts. The number of points in the average is tracked by cnt4 and the average is 
	// performed by the do-while loop.
	if(rem!=0)
		for(cnt1=0;cnt1<=(lngth-1.99999999);cnt1+=1)
			for(cnt2=0;cnt2<=(numpts-0.99999999);cnt2+=1)
				wb[cnt1]=wb[cnt1]+w[cnt3]
				cnt3+=1
			endfor
			wb[cnt1]/=numpts
		endfor
		cnt1=lngth-1
		do
			wb[cnt1]=wb[cnt1]+w[cnt3]
			cnt3+=1		
			cnt4+=1					// execute the loop body
		while (cnt3<V_npnts)				// as long as expression is true
		wb[cnt1]/=cnt4
	endif
	
	
end

function arduinoCom()
	VDT2/P=COM3 baud=9600,stopbits=1,databits=8,parity=0
	VDTOperationsPort2 COM3

	make /O/N=0 power
	Edit power
	Display power
	CtrlNamedBackground arduinoDataGet, period=50,proc=getArduinoData
	CtrlNamedBackground arduinoDataGet, start

end

function stopArduino()
	CtrlNamedBackground arduinoDataGet, stop
end

function getArduinoData(s)
	STRUCT WMBackgroundStruct &s
	string response
	VDTRead2/T="\r\n" response
	if(stringmatch(response,""))
	return 0
	else
	make /n=1 temp = str2num(response)
	concatenate /NP/KILL{temp},power
	return 0
	endif
end

	
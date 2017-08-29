function initializeDataProg()
%declare global variabes
display('Data program variables initiliazed')

global waveName scanLength interval dwellTime pointNumber ...
    photonCounter recordA recordB  ...
    pHmeter pH cond ...
    measurePower NIDAQ EPM ...
    autoPause ...
    flowControl

waveName = 'wave1';
scanLength = 2000;
interval = 1;
dwellTime = 0.02;
pointNumber = 1;

photonCounter = 0;
recordA = 0;
recordB = 0;

pHmeter = 0;
pH = 0;
cond = 0;

measurePower = 0;
NIDAQ = 0;
EPM = 0;

autoPause = 0;
flowControl = 0;

end
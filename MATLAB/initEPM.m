% initiliaze communications with the EPM power meter

% port = COM3 on Hurricane computer


function sPM = initEPM(port)

sPM = serial(port);
set(sPM,'BaudRate',9600,'StopBits',0,'DataBits',8);
fopen(sPM);



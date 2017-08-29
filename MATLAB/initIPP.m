% initiliaze communications with the Ismatec REGLO ICC pump

% port = COM7 on Hurricane computer

function sIPP = initIPP(port)

global pump

if pump == 0
    sIPP = serial(port);
    set(sIPP,'BaudRate',9600,'StopBits',1,'DataBits',8);
    fopen(sSPM);
    pump = 1;
end

end
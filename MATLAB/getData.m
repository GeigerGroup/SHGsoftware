%called at each interval in the timer to get the data

function getData

%load DAQparameters
DAQparam = getappdata(0,'DAQparam');

display('Getting Data');

if DAQparam.photonCounter
    if checkPCdataReady()
        if DAQparam.recordA
            appendDataPC('A',DAQparam.waveName)
        end
        if recordB
            DAQparam.appendDataPC('B',DAQparam.waveName)
        end
    end
end

if DAQparam.pHmeter
    if DAQparam.cond
        appendCondData()
    end
    if DAQparam.pH
        appendpHData()
    end
end

if DAQparam.measurePower
    if DAQparam.NIDAQ
        getNIDAQdata()
    end
    if DAQparam.EPM
        getEPMdata()
    end
end

% see if end of scan or pause
checkAcquisition;


end
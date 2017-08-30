%checks if the end of scan or pause

function checkAcquisition

%load DAQparameters
DAQparam = getappdata(0,'DAQparam');
DAQparam.pointNumber = DAQparam.pointNumber + 1;
setappdata(0,'DAQparam',DAQparam)

%view point number
display('point number')
display(DAQparam.pointNumber)

if DAQparam.autoPause
    if DAQparam.pointNumber == DAQparam.autoPause
        pauseAcquisition();
    end
end


if DAQparam.pointNumber == DAQparam.scanLength
    stopAcquisition();
end

end

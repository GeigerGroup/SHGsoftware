function  startAcquisition

%get DAQparameters
DAQparam = getappdata(0,'DAQparam');
DAQparam.pointNumber = 0;
setappdata(0,'DAQparam',DAQparam);

t = createDataTimer;
start(t)

setappdata(0,'timer',t);

end
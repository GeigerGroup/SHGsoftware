%close program, close DAQ session and close/delete serial communications
function closeProgram

DAQparam = getappdata(0,'DAQparam');

if DAQparam.NIDAQ
    DAQsession = getappdata(0,'DAQsession');
    release(DAQsession)
    delete(DAQsession)
    daqreset
end

delete(instrfind)
end
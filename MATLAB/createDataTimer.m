function t = createDataTimer(acq)
% initializes data timer to called data acquisition function
% currently only runs off photon counter, should make more general


% get appdata
photonCounter = getappdata(0,'photonCounter');

t = timer;
t.StartFcn = @dataTimerStart; % function called when started
t.TimerFcn = {@dataTimerGet, acq};  % function called at each interval
t.StopFcn = @dataTimerStop;  % function called when stopped
t.Period = photonCounter.Interval + photonCounter.DwellTime; % period to wait
t.StartDelay = 1.1*photonCounter.Interval + photonCounter.DwellTime; % wait slightly longer than a period the first time
t.ExecutionMode = 'fixedRate'; % fixed rate, so time to execute doesn't effect

end


function dataTimerStart(timerobj,event)
%function when timer started
display('Acquisition started.')
%display(event.Type)
%display(event.Data)
end

function dataTimerGet(timerobj,event,acq)
%function at each interval
acq.getData
acq.checkAcquisition
%display(event.Type)
%display(event.Data)
end

function dataTimerStop(timerobj,event)
%function with timer stopped
display('Acquisition stopped.')
%display(event.Type)
%display(event.Data)
end



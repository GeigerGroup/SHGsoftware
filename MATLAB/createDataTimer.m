function t = createDataTimer
% initializes data timer to called data acquisition function


% get appdata
DAQparam = getappdata(0,'DAQparam');

t = timer;
t.StartFcn = @dataTimerStart; % function called when started
t.TimerFcn = @dataTimerGet;  % function called at each interval
t.StopFcn = @dataTimerStop;  % function called when stopped
t.Period = DAQparam.interval + DAQparam.dwellTime; % period to wait
t.StartDelay = DAQparam.interval + DAQparam.dwellTime; % wait a period the first time
t.ExecutionMode = 'fixedRate'; % fixed rate, so time to execute doesn't effect

end


function dataTimerStart(mTimer,event)
%function when timer started
display('Timer for Data Started.')
display(event.Type)
display(event.Data)
end

function dataTimerGet(mTimer,event)
%function at each interval
getData;
display(event.Type)
display(event.Data)
end

function dataTimerStop(mTimer,event)
%function with timer stopped
display('Stopping data acquisition')
display(event.Type)
display(event.Data)
end



function t = createDataTimer()
% initializes data timer to called data acquisition function


% interval in seconds
dataInterval = 5;

t = timer;
t.StartFcn = @dataTimerStart; % function called when started
t.TimerFcn = @dataTimerGet;  % function called at each interval
t.StopFcn = @dataTimerStop;  % function called when stopped
t.Period = dataInterval;
t.ExecutionMode = 'fixedSpacing';

end


function dataTimerStart(mTimer,~)
%function when timer started
display('Timer for Data Started.')
end

function dataTimerGet(mTimer,~)
%function at each interval
getData;
end

function dataTimerStop(mTimer,~)
%function with timer stopped
display('Stopping data acquisition')
delete(mTimer)
end



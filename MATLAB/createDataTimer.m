function t = createDataTimer(acq)
% initializes data timer to called data acquisition function
% currently checks to see if data from photon counter is ready every 200 ms

t = timer;
t.StartFcn = @dataTimerStart; % function called when started
t.TimerFcn = {@dataTimerGet, acq};  % function called at each interval
t.StopFcn = @dataTimerStop;  % function called when stopped
t.Period = 0.4; % period to wait 400 ms
t.StartDelay = 0.1; % wait 100 ms before starting
t.ExecutionMode = 'fixedRate'; % fixed rate, so time to execute doesn't effect

end


function dataTimerStart(timerobj,event)
%function when timer started
disp('Acquisition started.')
%display(event.Type)
%display(event.Data)
end

function dataTimerGet(timerobj,event,acq)
%function at each interval
acq.getData
%display(event.Type)
%display(event.Data)
end

function dataTimerStop(timerobj,event)
%function with timer stopped
disp('Acquisition stopped.')
%display(event.Type)
%display(event.Data)
end



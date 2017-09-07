% creates a class for custom NIDAQ session

classdef DAQsession
    properties
        Session
    end
    
    methods
        function obj = DAQsession(devname)
            if nargin > 0
                if ischar(devname)
                    %create session
                    obj.Session = daq.createSession('ni');
                    
                    %add reading analog voltage from channel 0
                    addAnalogInputChannel(obj.Session,devname,0,'Voltage');
                    
                    %add output digital channels, port 0 lines 1 through 5
                    addDigitalChannel(obj.Session,devname,'Port0/Line1:5','OutputOnly');
                    states = [0 0 0 0 0];
                    obj.Session.outputSingleScan(states); % set all to zero
                    
                else
                    error('devname must be char')
                end
            end
        end
        
        function data = getReading(obj)
            data = obj.Session.inputSingleScan;
        end
        
        function setValveState(obj,state)
            obj.Session.outputSingleScan(state)
        end
    end
end
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
                    obj.Session.Rate = 10;
                    
                    %ideally different sessions or something to average
                    %analog data
                    
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
        
        function setValveStates(obj,state)
            obj.Session.outputSingleScan(state)
            
            %update GUI if it exists
            solGUI = getappdata(0,'solGUI');
            if ~isempty(solGUI)
                for i = 1:5
                    solGUI.Children(i).Value = state(i);
                end
            end     
        end
    end
end
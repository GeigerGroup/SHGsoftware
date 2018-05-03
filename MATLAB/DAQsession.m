% creates a class for custom NIDAQ session

classdef DAQsession
    properties
        Session
    end
    
    methods
        function obj = DAQsession()     
                %create session
                obj.Session = daq.createSession('ni');
                
                %assumes first device
                daqs = daq.getDevices();
                devname = daqs(1).ID;
   
                %add output digital channels, port 0 lines 1 through 5
                addDigitalChannel(obj.Session,devname,'Port0/Line1:5','OutputOnly');
                states = [0 0 0 0 0];
                obj.Session.outputSingleScan(states); % set all to zero
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